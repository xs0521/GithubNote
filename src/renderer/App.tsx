import { useDispatch, useSelector } from 'react-redux';
import { AppDispatch, RootState } from '@redux/index';
import log from 'electron-log/renderer';
import './index.css';

import Login from '@components/login';
import { useEffect, useState } from 'react';
import { initDB } from '@slice/content-slice';
import { updateIsDBInitialized } from '@slice/setting-slice';
import {
  clearUserData,
  fetchAccessToken,
  fetchUserInfo,
} from '@slice/user-slice';
import SidebarExampleSidebar from '@components/main';
import {
  CHANNEL_GITHUB_LOGIN_ERROR,
  CHANNEL_GITHUB_LOGIN_SUCCESS,
  CHANNEL_ACTION_UNAUTHORIZED,
  CHANNEL_ACTION_UPDATE_AVAILABLE,
  CHANNEL_COMMON,
} from '@/shared/constants';

function App() {
  const user = useSelector((state: RootState) => state.userData);
  const dispatch = useDispatch<AppDispatch>();
  const [updateInfo, setUpdateInfo] = useState<{
    version: string;
    url: string;
  } | null>(null);
  const isDev = process.env.NODE_ENV === 'development';

  useEffect(() => {
    // 监听 GitHub 登录成功消息
    window.electron?.ipcRenderer.on(CHANNEL_GITHUB_LOGIN_SUCCESS, (code) => {
      log.info('receive github login success message');
      if (code) {
        dispatch(fetchAccessToken(code as unknown as string));
      }
    });

    // 监听 GitHub 登录错误消息
    window.electron?.ipcRenderer.on(CHANNEL_GITHUB_LOGIN_ERROR, (arg) => {
      log.warn('receive github login error message', arg);
    });

    const offCommon = window.electron?.ipcRenderer.on(
      CHANNEL_COMMON,
      (payload) => {
        if (
          Array.isArray(payload) &&
          payload[0] === CHANNEL_ACTION_UPDATE_AVAILABLE &&
          payload[1]
        ) {
          setUpdateInfo(payload[1] as { version: string; url: string });
        }
        if (
          Array.isArray(payload) &&
          payload[0] === CHANNEL_ACTION_UNAUTHORIZED
        ) {
          dispatch(clearUserData());
        }
      },
    );

    return () => {
      if (offCommon) {
        offCommon();
      }
    };
  }, [dispatch]);

  useEffect(() => {
    const startInitDB = async () => {
      const isDBInitialized = await dispatch(initDB()).unwrap();
      log.info('isDBInitialized', isDBInitialized);
      dispatch(updateIsDBInitialized(isDBInitialized));
    };
    startInitDB();
    if (user.userInfo.id) {
      log.info('user.userInfo loaded', { id: user.userInfo.id, login: user.userInfo.login });
      return;
    }
    if (user.userInfo.access_token) {
      log.info('start fetchUserInfo');
      dispatch(fetchUserInfo(user.userInfo.access_token));
    }
  }, [dispatch, user.userInfo, user.userInfo.access_token]);

  return (
    <>
      {user.userInfo.id ? <SidebarExampleSidebar /> : <Login />}
      {updateInfo && (
        <div className="fixed left-1/2 bottom-5 z-50 -translate-x-1/2 app-region-no-drag">
          <div className="flex items-center gap-3 rounded-lg border border-gray-200 bg-white px-3 py-2 shadow-lg">
            <span className="text-xs text-gray-600">
              Update {updateInfo.version} is available.
            </span>
            <button
              onClick={() => window.open(updateInfo.url, '_blank')}
              className="px-2.5 py-1 text-xs text-white bg-gray-900 rounded-md hover:bg-gray-800"
            >
              View Release
            </button>
            <button
              onClick={() => setUpdateInfo(null)}
              className="text-gray-400 hover:text-gray-600"
              aria-label="Close update notification"
            >
              ×
            </button>
          </div>
        </div>
      )}
    </>
  );
}

export default App;
