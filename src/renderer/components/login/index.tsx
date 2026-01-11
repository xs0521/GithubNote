import { useEffect, useState } from 'react';
import { Icon } from 'semantic-ui-react';

import {
  CHANNEL_ACTION_OPEN_GITHUB_LOGIN,
  CHANNEL_COMMON,
  CHANNEL_ACTION_WINDOW_MINIMIZE,
  CHANNEL_ACTION_WINDOW_MAXIMIZE,
  CHANNEL_ACTION_WINDOW_CLOSE,
} from '@/shared/constants';

const Login = () => {
  const isWindows = window.electron?.platform === 'win32';
  const sendWindowAction = (action: string) => {
    window.electron?.ipcRenderer.sendMessage(CHANNEL_COMMON, [action]);
  };

  const onPressLogin = () => {
    try {
      console.log('Attempting to open GitHub login...');
      if (window.electron?.ipcRenderer) {
        window.electron.ipcRenderer.sendMessage(CHANNEL_COMMON, [
          CHANNEL_ACTION_OPEN_GITHUB_LOGIN,
        ]);
        console.log('Login request sent successfully');
      } else {
        console.error('Electron IPC renderer not available');
      }
    } catch (error) {
      console.error('Error opening GitHub login:', error);
    }
  };

  return (
    <div className="relative flex min-h-screen w-full items-center justify-center bg-gradient-to-br from-indigo-50 to-blue-100">
      {isWindows && (
        <div className="fixed top-0 right-0 flex items-center z-20 app-region-no-drag">
          <button
            onClick={() => sendWindowAction(CHANNEL_ACTION_WINDOW_MINIMIZE)}
            className="h-8 w-10 flex items-center justify-center text-gray-500 hover:bg-gray-100"
            aria-label="Minimize"
          >
            <Icon name="window minimize" className="!m-0" />
          </button>
          <button
            onClick={() => sendWindowAction(CHANNEL_ACTION_WINDOW_MAXIMIZE)}
            className="h-8 w-10 flex items-center justify-center text-gray-500 hover:bg-gray-100"
            aria-label="Maximize"
          >
            <Icon name="window maximize" className="!m-0" />
          </button>
          <button
            onClick={() => sendWindowAction(CHANNEL_ACTION_WINDOW_CLOSE)}
            className="h-8 w-10 flex items-center justify-center text-gray-500 hover:bg-red-500 hover:text-white"
            aria-label="Close"
          >
            <Icon name="close" className="!m-0" />
          </button>
        </div>
      )}
      <div className="w-full max-w-md space-y-8 rounded-2xl bg-white p-10 shadow-xl ring-1 ring-gray-900/5 transition-all hover:shadow-2xl">
        <div className="flex flex-col items-center justify-center text-center">
          <div className="mb-4 flex h-20 w-20 items-center justify-center rounded-2xl bg-white shadow-lg shadow-blue-600/10">
            <img
              src={require('../../../../assets/icon.png')}
              alt="GitNote logo"
              className="h-full w-full"
            />
          </div>
          <h2 className="mt-2 text-3xl font-bold tracking-tight text-gray-900">
            GitNote
          </h2>
          <p className="mt-2 text-sm text-gray-500">
            Your personal notebook, seamlessly synced with GitHub.
          </p>
        </div>

        <div className="mt-8 space-y-6">
          <button
            onClick={onPressLogin}
            className="group relative flex w-full items-center justify-center rounded-lg bg-[#24292F] py-3.5 px-4 text-sm font-semibold text-white shadow-sm transition-all hover:bg-[#24292F]/90 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 active:scale-[0.98]"
          >
            <span className="absolute left-0 inset-y-0 flex items-center pl-3">
              <svg
                className="h-5 w-5 text-gray-300 transition-colors group-hover:text-white"
                fill="currentColor"
                viewBox="0 0 20 20"
                aria-hidden="true"
              >
                <path
                  fillRule="evenodd"
                  d="M10 0C4.477 0 0 4.484 0 10.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0110 4.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0020 10.017C20 4.484 15.522 0 10 0z"
                  clipRule="evenodd"
                />
              </svg>
            </span>
            Sign in with GitHub
          </button>
        </div>
      </div>
    </div>
  );
};

export default Login;
