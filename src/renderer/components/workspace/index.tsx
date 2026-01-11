import React, { useState } from 'react';
import { GridRow, GridColumn, Grid, Button, Icon } from 'semantic-ui-react';
import { useDispatch, useSelector } from 'react-redux';
import {
  updateSelectedComment,
  updateSelectedIssue,
  updateSelectedRepository,
  updateIssues,
  updateComments,
  updateRepositories,
} from '@slice/content-slice';
import { updateWorkspace } from '@slice/setting-slice';
import { AppDispatch, RootState } from '@redux/index';
import { Repository } from '@const/index';
import PlaceholderAnimationLine from '@components/placeholder';
import {
  CHANNEL_COMMON,
  CHANNEL_ACTION_WINDOW_MINIMIZE,
  CHANNEL_ACTION_WINDOW_MAXIMIZE,
  CHANNEL_ACTION_WINDOW_CLOSE,
} from '@/shared/constants';
import { apiPost } from '@/renderer/server/API';
import * as db from '@db/index';

function Workspace() {
  const dispatch = useDispatch<AppDispatch>();
  const isWindows = window.electron?.platform === 'win32';
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [repoName, setRepoName] = useState('');
  const [createError, setCreateError] = useState('');
  const [isCreating, setIsCreating] = useState(false);

  const repositories = useSelector(
    (state: RootState) => state.contentData.repositories,
  );

  const selectedRepository = useSelector(
    (state: RootState) => state.contentData.selectedRepository,
  );

  const userInfo = useSelector((state: RootState) => state.userData.userInfo);

  const isRepositoriesLoading = useSelector(
    (state: RootState) => state.settingData.isRepositoriesLoading,
  );

  const onItemClick = (item: Repository, e: React.MouseEvent) => {
    e.stopPropagation();
    if (item.id === selectedRepository?.id) {
      dispatch(updateWorkspace(false));
      return;
    }
    dispatch(updateSelectedRepository(item));
    dispatch(updateIssues([]));
    dispatch(updateComments([]));
    dispatch(updateSelectedIssue(null));
    dispatch(updateSelectedComment(null));
    dispatch(updateWorkspace(false));
  };

  const onBackClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    dispatch(updateWorkspace(false));
  };

  const onCreateRepoClick = () => {
    setIsCreateOpen(true);
    setCreateError('');
  };

  const onCreateCancel = () => {
    setIsCreateOpen(false);
    setRepoName('');
    setCreateError('');
    setIsCreating(false);
  };

  const onCreateConfirm = async () => {
    if (!navigator.onLine) {
      setCreateError('Need network connection to create a repository.');
      return;
    }
    if (!userInfo || !userInfo.access_token) {
      setCreateError('Missing user credentials.');
      return;
    }
    if (!repoName.trim()) {
      setCreateError('Repository name is required.');
      return;
    }
    setIsCreating(true);
    try {
      const payload = await apiPost<any>(
        '/user/repos',
        {
          name: repoName.trim(),
          private: true,
        },
        userInfo.access_token,
      );
      const newRepo: Repository = {
        id: String(payload.id),
        name: payload.name,
        full_name: payload.full_name || '',
        private: Boolean(payload.private),
        html_url: payload.html_url || '',
        created_at: payload.created_at || '',
        updated_at: payload.updated_at || '',
        pushed_at: payload.pushed_at || '',
        size: payload.size || 0,
        language: payload.language || '',
        stargazers_count: payload.stargazers_count || 0,
        watchers_count: payload.watchers_count || 0,
        forks_count: payload.forks_count || 0,
        open_issues_count: payload.open_issues_count || 0,
        default_branch: payload.default_branch || 'main',
        user_id: userInfo.id,
      };
      await db.saveRepositories([newRepo]);
      dispatch(updateRepositories([newRepo]));
      dispatch(updateSelectedRepository(newRepo));
      dispatch(updateIssues([]));
      dispatch(updateComments([]));
      dispatch(updateSelectedIssue(null));
      dispatch(updateSelectedComment(null));
      dispatch(updateWorkspace(false));
      onCreateCancel();
    } catch (error) {
      console.warn('Failed to create repository', error);
      setCreateError('Create repository failed. Please try again.');
      setIsCreating(false);
    }
  };

  const sendWindowAction = (action: string) => {
    window.electron?.ipcRenderer.sendMessage(CHANNEL_COMMON, [action]);
  };

  const isSelected = (item: Repository) => {
    return item.id === selectedRepository?.id;
  };

  const renderItem = (item: Repository) => {
    return (
      <div className="list-item flex-row items-center justify-center  mt-[20px]">
        <div
          className="absolute left-[3px] bottom-[4px] w-[4px] h-[20px]"
          style={{
            backgroundColor: isSelected(item) ? '#555555' : 'transparent',
          }}
        />
        <Button
          compact
          onClick={(e) => onItemClick(item, e)}
          style={{
            width: '100%',
            overflow: 'hidden',
            textOverflow: 'ellipsis',
            whiteSpace: 'nowrap',
          }}
        >
          {item.name}
        </Button>
      </div>
    );
  };

  return (
    <div className="fixed inset-0 bg-[#F9FAFB] justify-center items-center z-50 overflow-y-auto">
      {!selectedRepository && (
        <div className="absolute top-0 left-0 w-full flex items-center justify-center px-6 py-3 bg-gray-50 border-b border-gray-200 text-xl font-medium text-gray-600">
          Select a repository to continue.
        </div>
      )}
      <div
        className={`fixed flex-col bottom-[40px] left-[20px]
        } flex items-center z-10`}
      >
        {selectedRepository && (
          <Button
            onClick={(e) => onBackClick(e)}
            className="app-region-no-drag"
            style={{
              backgroundColor: 'transparent',
            }}
          >
            <Icon name="arrow left" size="big" />
          </Button>
        )}
        <Button
          onClick={onCreateRepoClick}
          className="app-region-no-drag"
          style={{
            backgroundColor: 'transparent',
          }}
        >
          <Icon name="plus square" size="big" />
        </Button>
      </div>
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
      {isRepositoriesLoading ? (
        <PlaceholderAnimationLine style={{ width: '100%' }} />
      ) : (
        <>
          <Grid columns={4} style={{ margin: 0, padding: 100 }}>
            <GridRow>
              {repositories.map((item) => (
                <GridColumn key={item.id}>{renderItem(item)}</GridColumn>
              ))}
            </GridRow>
          </Grid>
        </>
      )}
      {isCreateOpen && (
        <div className="fixed inset-0 z-50">
          <button
            type="button"
            className="absolute inset-0 bg-black/30"
            aria-label="Close create repository"
            onClick={onCreateCancel}
          />
          <div className="relative z-10 flex h-full w-full items-center justify-center">
            <div className="w-[360px] bg-white rounded-xl shadow-2xl border border-gray-200 p-4">
              <div className="text-xs font-semibold text-gray-500 mb-2">
                CREATE REPOSITORY
              </div>
              <input
                className="w-full text-sm border border-gray-200 rounded-md px-3 py-2 outline-none focus:border-gray-400"
                placeholder="Repository name"
                value={repoName}
                onChange={(event) => setRepoName(event.target.value)}
              />
              {createError && (
                <div className="text-xs text-red-500 mt-2">{createError}</div>
              )}
              <div className="flex items-center justify-end gap-2 mt-4">
                <button
                  onClick={onCreateCancel}
                  className="px-2.5 py-1.5 text-xs text-gray-500 hover:text-gray-700"
                  disabled={isCreating}
                >
                  Cancel
                </button>
                <button
                  onClick={onCreateConfirm}
                  className="px-3 py-1.5 text-xs text-white bg-gray-900 rounded-md hover:bg-gray-800 disabled:opacity-60"
                  disabled={isCreating}
                >
                  {isCreating ? 'Creating...' : 'Create'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default Workspace;
