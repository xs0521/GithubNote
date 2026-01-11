import React, { useEffect, useMemo } from 'react';
import { Icon } from 'semantic-ui-react';
import Markdown from '@components/markdown';
import Side from '@components/side';
import Workspace from '@components/workspace';
import Breadcrumb from '@components/breadcrumb';
import { useDispatch, useSelector, useStore } from 'react-redux';
import { AppDispatch, RootState } from '@redux/index';
import { updateWorkspace } from '@slice/setting-slice';
import {
  updateIsSidebarVisible,
  updateSelectedComment,
} from '@slice/content-slice';
import {
  CHANNEL_COMMON,
  CHANNEL_ACTION_GITHUB_TOKEN,
  CHANNEL_ACTION_WINDOW_MINIMIZE,
  CHANNEL_ACTION_WINDOW_MAXIMIZE,
  CHANNEL_ACTION_WINDOW_CLOSE,
} from '@/shared/constants';
import { getSyncManager } from '@/renderer/sync';

function SidebarExampleSidebar() {
  const isShowWorkspace = useSelector(
    (state: RootState) => state.settingData.isShowWorkspace,
  );
  const isSidebarVisible = useSelector(
    (state: RootState) => state.contentData.isSidebarVisible,
  );

  const dispatch = useDispatch<AppDispatch>();
  const store = useStore<RootState>();
  const syncManager = useMemo(
    () => getSyncManager(dispatch, () => store.getState()),
    [dispatch, store],
  );
  const isWindows = useMemo(() => window.electron?.platform === 'win32', []);

  const selectedRepository = useSelector(
    (state: RootState) => state.contentData.selectedRepository,
  );

  const selectedIssue = useSelector(
    (state: RootState) => state.contentData.selectedIssue,
  );

  const isDBInitialized = useSelector(
    (state: RootState) => state.settingData.isDBInitialized,
  );
  const lastSyncAt = useSelector(
    (state: RootState) => state.settingData.lastSyncAt,
  );

  const userInfo = useSelector((state: RootState) => state.userData.userInfo);
  const comments = useSelector(
    (state: RootState) => state.contentData.comments,
  );
  const selectedComment = useSelector(
    (state: RootState) => state.contentData.selectedComment,
  );

  useEffect(() => {
    if (isDBInitialized && userInfo?.access_token) {
      syncManager.start();
      return () => {
        syncManager.stop();
      };
    }
    return undefined;
  }, [isDBInitialized, userInfo?.access_token, syncManager]);

  useEffect(() => {
    if (isDBInitialized && userInfo && !selectedRepository) {
      dispatch(updateWorkspace(true));
    }
  }, [isDBInitialized, userInfo, selectedRepository, dispatch]);

  useEffect(() => {
    if (isDBInitialized && userInfo && selectedRepository) {
      syncManager.syncSelectedRepo();
    }
  }, [isDBInitialized, userInfo, selectedRepository, syncManager]);

  useEffect(() => {
    if (isDBInitialized && userInfo && selectedIssue && selectedRepository) {
      syncManager.syncSelectedIssue();
    }
  }, [
    isDBInitialized,
    userInfo,
    selectedIssue,
    selectedRepository,
    syncManager,
  ]);

  useEffect(() => {
    if (comments.length > 0 && !selectedComment) {
      dispatch(updateSelectedComment(comments[0]));
    }
  }, [comments, selectedComment, dispatch]);

  useEffect(() => {
    if (userInfo) {
      window.electron?.ipcRenderer.sendMessage(CHANNEL_COMMON, [
        CHANNEL_ACTION_GITHUB_TOKEN,
        userInfo.access_token,
        userInfo.login,
      ]);
    }
  }, [userInfo]);

  const onWorkSpaceClick = () => {
    dispatch(updateWorkspace(true));
    // enqueueSnackbar('Workspace clicked', {
    //   anchorOrigin: {
    //     vertical: 'bottom',
    //     horizontal: 'center',
    //   },
    //   content: (key, message) => (
    //     <BottomToastBar
    //       id={key}
    //       variant={BottomToastBarVariant.SUCCESS}
    //       message={message}
    //       description="Workspace clicked description"
    //     />
    //   ),
    // });
  };

  const sendWindowAction = (action: string) => {
    window.electron?.ipcRenderer.sendMessage(CHANNEL_COMMON, [action]);
  };

  return (
    <div className="flex h-screen w-full bg-gray-50 text-gray-900 overflow-hidden">
      {/* Sidebar Area */}
      <div
        className={`flex-shrink-0 bg-white border-r border-gray-200 transition-all duration-300 ease-in-out ${
          isSidebarVisible ? 'w-64' : 'w-0'
        } overflow-hidden`}
      >
        <div className="h-full w-64 flex flex-col">
          <Side />
        </div>
      </div>

      {/* Main Content Area */}
      <div className="flex flex-1 flex-col h-full min-w-0">
        {/* Top Navigation Bar */}
        <div
          className={`flex h-12 items-center justify-between border-b border-gray-200 px-4 app-region-drag`}
        >
          <div
            className={`flex items-center gap-3 app-region-no-drag ${isSidebarVisible || isWindows ? '' : 'ml-[64px]'}`}
          >
            <button
              onClick={() =>
                dispatch(updateIsSidebarVisible(!isSidebarVisible))
              }
              className="p-1.5 rounded-md text-gray-500 hover:bg-gray-100 hover:text-gray-700 focus:outline-none focus:ring-0 border-0 transition-colors"
            >
              <Icon
                name={isSidebarVisible ? 'outdent' : 'indent'}
                className="!m-0"
              />
            </button>
            <button
              onClick={onWorkSpaceClick}
              className="text-gray-500 hover:bg-gray-100 hover:text-gray-700 focus:outline-none focus:ring-0 border-0 transition-colors"
            >
              <Icon name="folder" />
            </button>
            <div className="h-4 w-px bg-gray-300 mx-1"></div>
            <Breadcrumb />
          </div>
          {isWindows && (
            <div className="flex items-center app-region-no-drag">
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
        </div>

        {/* Editor Content */}
        <div className="flex-1 overflow-hidden relative">
          <Markdown />
        </div>
        <div className="h-[22px] border-t border-gray-200 bg-gray-50 px-3 text-[11px] text-gray-500 flex items-center justify-between">
          <span>Auto Sync</span>
          <span>
            {lastSyncAt
              ? `Last sync: ${new Date(lastSyncAt).toLocaleTimeString()}`
              : 'Last sync: --'}
          </span>
        </div>
      </div>

      {/* Workspace Overlay */}
      {isShowWorkspace && <Workspace />}
    </div>
  );
}

export default SidebarExampleSidebar;
