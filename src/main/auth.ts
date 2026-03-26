import { BrowserWindow, app } from 'electron';
import path from 'path';
import log from 'electron-log';

import { mainWindow, sendToMainRenderer } from './main';
import {
  GITHUB_AUTHORIZE_URL,
  CHANNEL_GITHUB_LOGIN_SUCCESS,
  CHANNEL_GITHUB_LOGIN_ERROR,
  GITHUB_CLIENT_ID,
  GITHUB_SCOPES,
} from '@/shared/constants';

let authWindow: BrowserWindow | null = null;

// 注册自定义协议
export function registerCustomProtocol() {
  if (process.defaultApp) {
    if (process.argv.length >= 2) {
      app.setAsDefaultProtocolClient('githubnote', process.execPath, [
        path.resolve(process.argv[1]),
      ]);
    }
  } else {
    app.setAsDefaultProtocolClient('githubnote');
  }
}

// 处理自定义协议回调
export function handleProtocolCallback(url: string) {
  log.info('Protocol callback received');

  // 解析 URL 中的 code 参数
  const urlObj = new URL(url);
  const code = urlObj.searchParams.get('code');
  const error = urlObj.searchParams.get('error');

  log.info('OAuth code received:', Boolean(code));
  log.info('OAuth error:', error);

  if (code) {
    // 发送成功消息到渲染进程
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send(CHANNEL_GITHUB_LOGIN_SUCCESS, code);
    }
    // 关闭授权窗口
    if (authWindow && !authWindow.isDestroyed()) {
      authWindow.destroy();
      authWindow = null;
    }
  } else if (error) {
    log.error('GitHub auth error:', error);
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send(CHANNEL_GITHUB_LOGIN_ERROR, error);
    }
    if (authWindow && !authWindow.isDestroyed()) {
      authWindow.destroy();
      authWindow = null;
    }
  }
}

export async function createAuthWindow() {
  // 创建一个新的浏览器窗口
  authWindow = new BrowserWindow({
    width: 800,
    height: 600,
    show: false,
    frame: true,
    transparent: false,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      webSecurity: false,
      allowRunningInsecureContent: true,
    },
  });

  // 构建 GitHub OAuth URL
  const authUrl =
    GITHUB_AUTHORIZE_URL +
    '?' +
    new URLSearchParams({
      client_id: GITHUB_CLIENT_ID,
      scope: GITHUB_SCOPES.join(' '),
      allow_signup: 'true',
    }).toString();

  log.info('Loading auth URL');

  // 添加错误处理
  authWindow.webContents.on(
    'did-fail-load',
    (event, errorCode, errorDescription, validatedURL) => {
      log.error(
        'Failed to load auth URL:',
        errorCode,
        errorDescription,
        validatedURL,
      );
    },
  );

  authWindow.webContents.on('did-finish-load', () => {
    log.info('Auth window loaded successfully');
  });

  authWindow.webContents.on('render-process-gone', (event, details) => {
    log.error('Auth window render process gone:', details);
  });

  try {
    await authWindow.loadURL(authUrl);
    authWindow.show();
  } catch (error) {
    log.error('Error loading auth URL:', error);
  }

  // 处理回调 URL
  async function handleCallback(url: string) {
    const codeMatch = /code=([^&]*)/.exec(url) || null;
    const code = codeMatch && codeMatch.length > 1 ? codeMatch[1] : null;
    const error = /\?error=(.+)$/.exec(url);
    log.info('handleCallback - code received:', Boolean(code));

    // 如果有 code，获取 token
    if (code) {
      // 发送成功消息到渲染进程
      if (mainWindow && !mainWindow.isDestroyed()) {
        sendToMainRenderer(CHANNEL_GITHUB_LOGIN_SUCCESS, code);
      }
      // 关闭授权窗口
      if (authWindow && !authWindow.isDestroyed()) {
        authWindow.destroy();
        authWindow = null;
      }
    } else if (error) {
      log.error('GitHub auth error:', error);
      if (mainWindow && !mainWindow.isDestroyed()) {
        sendToMainRenderer(CHANNEL_GITHUB_LOGIN_ERROR, error);
      }
      if (authWindow && !authWindow.isDestroyed()) {
        authWindow.destroy();
        authWindow = null;
      }
    }
  }

  // 监听导航事件
  // @ts-ignore
  authWindow.webContents.on('will-navigate', (event: Event, url: string) => {
    log.info('will-navigate');
    handleCallback(url);
  });

  // 监听重定向请求
  // @ts-ignore
  authWindow.webContents.on(
    // @ts-ignore
    'did-get-redirect-request',
    (event: Event, oldUrl: string, newUrl: string) => {
      log.info('did-get-redirect-request');
      handleCallback(newUrl);
    },
  );

  // 窗口关闭时重置 authWindow
  authWindow.on('closed', () => {
    authWindow = null;
  });
}
