/* eslint global-require: off, no-console: off, promise/always-return: off */

/**
 * This module executes inside of electron's main process. You can start
 * electron renderer process from here and communicate with the other processes
 * through IPC.
 *
 * When running `npm run build` or `npm run build:main`, this file is compiled to
 * `./src/main.js` using webpack. This gives us some performance wins.
 */
import path from 'path';
import { app, BrowserWindow, shell, ipcMain, session } from 'electron';
import AppUpdateCheck from './app-update-check';
import log from 'electron-log';
import MenuBuilder from './menu';
import { resolveHtmlPath } from './util';
import {
  handleProtocolCallback,
  registerCustomProtocol,
  createAuthWindow,
} from './auth';
import {
  CHANNEL_ACTION_OPEN_GITHUB_LOGIN,
  CHANNEL_COMMON,
  CHANNEL_ACTION_GITHUB_TOKEN,
  CHANNEL_ACTION_WINDOW_MINIMIZE,
  CHANNEL_ACTION_WINDOW_MAXIMIZE,
  CHANNEL_ACTION_WINDOW_CLOSE,
  CHANNEL_ACTION_UPDATE_AVAILABLE,
} from '@/shared/constants';

interface UserInfo {
  access_token: string;
  username: string;
}

class AppUpdater {
  constructor() {
    log.transports.file.level = 'info';
    const checker = new AppUpdateCheck((info) => {
      sendToMainRenderer(CHANNEL_COMMON, [
        CHANNEL_ACTION_UPDATE_AVAILABLE,
        info,
      ]);
    });
    checker.check();
  }
}

let userInfo: UserInfo | null = null;
let mainWindow: BrowserWindow | null = null;

ipcMain.on(CHANNEL_COMMON, async (event, arg) => {
  if (arg[0] === CHANNEL_ACTION_OPEN_GITHUB_LOGIN) {
    await createAuthWindow();
  }
  if (arg[0] === CHANNEL_ACTION_GITHUB_TOKEN) {
    const token = arg[1];
    const userName = arg[2];
    console.log('receive github token', token);
    console.log('receive github user name', userName);
    userInfo = {
      access_token: token,
      username: userName,
    };
  }
  if (arg[0] === CHANNEL_ACTION_WINDOW_MINIMIZE) {
    mainWindow?.minimize();
  }
  if (arg[0] === CHANNEL_ACTION_WINDOW_MAXIMIZE) {
    if (mainWindow?.isMaximized()) {
      mainWindow.unmaximize();
    } else {
      mainWindow?.maximize();
    }
  }
  if (arg[0] === CHANNEL_ACTION_WINDOW_CLOSE) {
    mainWindow?.close();
  }
  const action = arg[0] ?? 'unknown';
  const msgTemplate = (pingPong: string) =>
    `IPC Receive: ${action} ${pingPong}`;
  console.log(msgTemplate(arg));
  event.reply(CHANNEL_COMMON, msgTemplate('pong'));
});

if (process.env.NODE_ENV === 'production') {
  const sourceMapSupport = require('source-map-support');
  sourceMapSupport.install();
}

const isDebug =
  process.env.NODE_ENV === 'development' || process.env.DEBUG_PROD === 'true';

if (isDebug) {
  require('electron-debug').default();
}

const installExtensions = async () => {
  try {
    const installer = require('electron-devtools-installer');
    const forceDownload = !!process.env.UPGRADE_EXTENSIONS;
    const extensions = ['REACT_DEVELOPER_TOOLS', 'REDUX_DEVTOOLS'];

    const results = await Promise.allSettled(
      extensions.map((name) => {
        const extension = installer[name];
        if (!extension) {
          console.warn(`Extension ${name} not found`);
          return Promise.resolve();
        }
        return installer.default(extension, forceDownload);
      }),
    );

    results.forEach((result, index) => {
      if (result.status === 'rejected') {
        console.warn(
          `Failed to install extension ${extensions[index]}:`,
          result.reason,
        );
      }
    });
  } catch (error) {
    console.warn('Failed to install extensions:', error);
  }
};

export function sendToMainRenderer(channel: string, ...args: any[]) {
  mainWindow?.webContents.send(channel, ...args);
}

const createWindow = async () => {
  if (isDebug) {
    await installExtensions();
  }

  const RESOURCES_PATH = app.isPackaged
    ? path.join(process.resourcesPath, 'assets')
    : path.join(__dirname, '../../assets');

  const getAssetPath = (...paths: string[]): string => {
    return path.join(RESOURCES_PATH, ...paths);
  };

  mainWindow = new BrowserWindow({
    show: false,
    width: 1024,
    height: 728,
    icon: getAssetPath('icon.png'),
    webPreferences: {
      preload: app.isPackaged
        ? path.join(__dirname, 'preload.js')
        : path.join(__dirname, '../../.erb/dll/preload.js'),
      webSecurity: false,
      allowRunningInsecureContent: true,
    },
    frame: false,
    titleBarStyle: 'hidden',
    trafficLightPosition: {
      x: 14,
      y: 14,
    },
  });

  mainWindow.loadURL(resolveHtmlPath('index.html'));

  mainWindow.on('ready-to-show', () => {
    if (!mainWindow) {
      throw new Error('"mainWindow" is not defined');
    }
    if (process.env.START_MINIMIZED) {
      mainWindow.minimize();
    } else {
      mainWindow.show();
    }
  });

  mainWindow.on('closed', () => {
    mainWindow = null;
  });

  const menuBuilder = new MenuBuilder(mainWindow);
  menuBuilder.buildMenu();

  // Open urls in the user's browser
  mainWindow.webContents.setWindowOpenHandler((edata) => {
    shell.openExternal(edata.url);
    return { action: 'deny' };
  });

  // Remove this if your app does not use auto updates
  // eslint-disable-next-line
  new AppUpdater();
};

/**
 * Add event listeners...
 */

app.on('window-all-closed', () => {
  // Respect the OSX convention of having the application in memory even
  // after all windows have been closed
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// 处理自定义协议回调
app.on('open-url', (event, url) => {
  event.preventDefault();
  console.log('App opened with URL:', url);
  handleProtocolCallback(url);
});

// 处理命令行参数中的协议回调
app.on('second-instance', (event, commandLine) => {
  // Someone tried to run a second instance, we should focus our window instead.
  if (mainWindow) {
    if (mainWindow.isMinimized()) mainWindow.restore();
    mainWindow.focus();
  }

  // 检查命令行参数中是否有协议回调
  const protocolUrl = commandLine.find((arg) =>
    arg.startsWith('githubnote://'),
  );
  if (protocolUrl) {
    console.log('Protocol callback from second instance:', protocolUrl);
    handleProtocolCallback(protocolUrl);
  }
});

app
  .whenReady()
  .then(() => {
    // 注册自定义协议
    registerCustomProtocol();

    session.defaultSession.webRequest.onBeforeSendHeaders(
      (details, callback) => {
        const { host } = new URL(details.url);
        const value = userInfo as UserInfo | null;
        if (value) {
          if (host === 'github.com' || host === 'raw.githubusercontent.com') {
            details.requestHeaders['Authorization'] =
              `Bearer ${value.access_token}`;
          }
        }
        callback({ requestHeaders: details.requestHeaders });
      },
    );

    session.defaultSession.webRequest.onBeforeRequest((details, callback) => {
      if (!userInfo) {
        callback({});
        return;
      }
      let handleUrl = details.url;
      const value = userInfo as UserInfo | null;
      if (!handleUrl.includes('github.com/' + value?.username)) {
        callback({});
        return;
      }
      handleUrl = handleUrl.replace('github.com', 'raw.githubusercontent.com');
      handleUrl = handleUrl.replace('blob/', 'refs/heads/');
      callback({ redirectURL: handleUrl });
    });

    createWindow();
    app.on('activate', () => {
      // On macOS it's common to re-create a window in the app when the
      // dock icon is clicked and there are no other windows open.
      if (mainWindow === null) createWindow();
    });
  })
  .catch(console.log);

export { mainWindow };
