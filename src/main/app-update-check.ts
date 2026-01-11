import https from 'https';
import { app } from 'electron';
import { build } from '../../package.json';
import log from 'electron-log';

type ReleaseInfo = {
  version: string;
  url: string;
};

function parseVersion(value: string): number[] {
  const normalized = value.replace(/^v/i, '');
  return normalized.split('.').map((part) => Number(part) || 0);
}

function isNewerVersion(latest: string, current: string): boolean {
  const latestParts = parseVersion(latest);
  const currentParts = parseVersion(current);
  const length = Math.max(latestParts.length, currentParts.length);
  for (let index = 0; index < length; index += 1) {
    const latestValue = latestParts[index] ?? 0;
    const currentValue = currentParts[index] ?? 0;
    if (latestValue > currentValue) {
      return true;
    }
    if (latestValue < currentValue) {
      return false;
    }
  }
  return false;
}

async function fetchLatestRelease(
  owner: string,
  repo: string,
): Promise<ReleaseInfo | null> {
  const url = `https://api.github.com/repos/${owner}/${repo}/releases/latest`;
  log.info('Update check request', { url });
  return new Promise((resolve) => {
    const req = https.get(
      url,
      {
        headers: {
          'User-Agent': 'GitNote',
          Accept: 'application/vnd.github+json',
        },
      },
      (res) => {
        if (!res || res.statusCode !== 200) {
          log.warn('Update check failed', { status: res?.statusCode });
          resolve(null);
          return;
        }
        let raw = '';
        res.on('data', (chunk) => {
          raw += chunk;
        });
        res.on('end', () => {
          try {
            const data = JSON.parse(raw);
            resolve({
              version: data.tag_name || data.name || '',
              url: data.html_url || `https://github.com/${owner}/${repo}/releases`,
            });
          } catch (error) {
            log.error('Update check parse failed', error);
            resolve(null);
          }
        });
      },
    );
    req.on('error', (error) => {
      log.error('Update check request error', error);
      resolve(null);
    });
    req.end();
  });
}

export default class AppUpdateCheck {
  private onUpdateAvailable: (info: ReleaseInfo) => void;

  constructor(onUpdateAvailable: (info: ReleaseInfo) => void) {
    this.onUpdateAvailable = onUpdateAvailable;
  }

  async check(): Promise<void> {
    const publish = Array.isArray(build?.publish)
      ? build.publish[0]
      : build?.publish;
    if (!publish || publish.provider !== 'github') {
      log.warn('Update check skipped (no publish config)');
      return;
    }
    const owner = publish.owner;
    const repo = publish.repo;
    if (!owner || !repo) {
      log.warn('Update check skipped (missing owner/repo)');
      return;
    }
    const latest = await fetchLatestRelease(owner, repo);
    if (!latest || !latest.version) {
      log.warn('Update check skipped (no release info)');
      return;
    }
    const currentVersion = app.getVersion();
    log.info('Update check versions', {
      current: currentVersion,
      latest: latest.version,
    });
    if (isNewerVersion(latest.version, currentVersion)) {
      log.info('Update available', { latest: latest.version });
      this.onUpdateAvailable(latest);
    } else {
      log.info('No update available');
    }
  }
}
