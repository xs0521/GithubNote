import { Icon } from 'semantic-ui-react';
import { useDispatch, useSelector } from 'react-redux';
import { AppDispatch, RootState } from '@redux/index';
import { type Comment, generateCommentBody } from '@const/index';
import { updateWorkspace } from '@slice/setting-slice';
import { clearUserData } from '@slice/user-slice';
import { useDataCommentFetchModel } from '@/renderer/models';
import DeleteAlert from '@components/side/delete-alert';
import { useCallback, useState } from 'react';
import { type FetchCommentsConfig } from '@models/model';
import NoteTree from '@components/side/note-tree';
import { clearDeletedComments } from '@/renderer/sync/deleted-comment-cache';
import { createLocalComment, saveCommentsDB } from '@slice/content-comment-slice';
import { resetSyncManager } from '@/renderer/sync';

function Side() {
  const dispatch = useDispatch<AppDispatch>();
  const dataCommentFetchModel = useDataCommentFetchModel();
  const selectedComment = useSelector(
    (state: RootState) => state.contentData.selectedComment,
  );

  const selectedIssue = useSelector(
    (state: RootState) => state.contentData.selectedIssue,
  );

  const selectedRepository = useSelector(
    (state: RootState) => state.contentData.selectedRepository,
  );

  const userInfo = useSelector((state: RootState) => state.userData.userInfo);

  const isWindows = window.electron?.platform === 'win32';

  const [showDeleteConfirmAlert, setShowDeleteConfirmAlert] = useState(false);
  const [showSignOutConfirm, setShowSignOutConfirm] = useState(false);

  const [alertContent, setAlertContent] = useState<Comment | null>(null);

  const buildCommentConfig = useCallback((): FetchCommentsConfig | null => {
    if (
      !selectedIssue ||
      !selectedRepository ||
      !userInfo ||
      !userInfo.access_token
    ) {
      return null;
    }

    return {
      userId: userInfo.id,
      accessToken: userInfo.access_token,
      owner: userInfo.login,
      repositoryId: selectedRepository.id,
      repositoryName: selectedRepository.name,
      issueId: selectedIssue.id,
      issueNumber: selectedIssue.number,
    };
  }, [selectedIssue, selectedRepository, userInfo]);

  const onSettingClick = () => {
    setShowSignOutConfirm(true);
  };

  const handleSignOutCancel = () => {
    setShowSignOutConfirm(false);
  };

  const handleSignOutConfirm = (confirmed: boolean) => {
    setShowSignOutConfirm(false);
    if (!confirmed) {
      return;
    }
    if (userInfo?.id) {
      clearDeletedComments(userInfo.id);
    }
    resetSyncManager();
    dispatch(updateWorkspace(false));
    dispatch(clearUserData());
  };

  const getActiveComment = useCallback((): Comment | null => {
    return alertContent ?? selectedComment ?? null;
  }, [alertContent, selectedComment]);

  const handleDeleteRequest = useCallback(
    (comment?: Comment) => {
      const target = comment ?? getActiveComment();
      if (!target) return;
      setAlertContent(target);
      setShowDeleteConfirmAlert(true);
    },
    [getActiveComment],
  );

  const onAddClick = async () => {
    if (!selectedRepository || !userInfo || !selectedIssue) return;
    const result = await dispatch(
      createLocalComment({
        issueId: selectedIssue.id,
        body: generateCommentBody(),
        userId: userInfo.id,
        repositoryId: selectedRepository.id,
      }),
    ).unwrap();
    if (result !== null) {
      dispatch(saveCommentsDB([result]));
    }
  };

  const handleDeleteCancel = () => {
    setShowDeleteConfirmAlert(false);
    setAlertContent(null);
  };

  const handleDeleteConfirm = async (confirmed: boolean) => {
    setShowDeleteConfirmAlert(false);
    if (!confirmed) {
      return;
    }

    const target = getActiveComment();
    if (!target) {
      return;
    }

    const config = buildCommentConfig();
    if (!config) {
      return;
    }

    await dataCommentFetchModel.deleteComment(config, target);
    setAlertContent(null);
  };

  return (
    <div className="flex w-full flex-col h-full bg-gray-50 border-r border-gray-200">
      {/* Toolbar */}
      <div
        className={`flex items-center justify-between border-b border-gray-200 bg-[#F9FAFB] px-3 app-region-drag ${
          isWindows ? 'py-2' : 'pt-[37px] pb-2'
        }`}
      >
        <span className="text-xs font-semibold text-gray-400 uppercase tracking-wider app-region-no-drag">
          {selectedRepository?.name ?? 'Notes'}
        </span>
        <button
          onClick={onAddClick}
          disabled={!selectedIssue}
          className="p-1 text-gray-400 hover:text-gray-700 disabled:opacity-30 transition-colors app-region-no-drag"
          title="New Note"
        >
          <Icon name="pen square" size="large" className="!m-0" />
        </button>
      </div>

      {DeleteAlert(
        showDeleteConfirmAlert,
        handleDeleteCancel,
        (onConfirm: boolean) => {
          handleDeleteConfirm(onConfirm);
        },
      )}
      {showSignOutConfirm && (
        <div className="fixed inset-0 z-50">
          <button
            type="button"
            className="absolute inset-0 bg-black/30"
            aria-label="Close sign out confirmation"
            onClick={handleSignOutCancel}
          />
          <div className="relative z-10 flex h-full w-full items-center justify-center">
            <div className="w-[360px] bg-white rounded-xl shadow-2xl border border-gray-200 p-4">
              <div className="text-xs font-semibold text-gray-500 mb-2">
                SIGN OUT
              </div>
              <div className="text-sm text-gray-700">
                Are you sure you want to sign out?
              </div>
              <div className="flex items-center justify-end gap-2 mt-4">
                <button
                  onClick={handleSignOutCancel}
                  className="px-2.5 py-1.5 text-xs text-gray-500 hover:text-gray-700"
                >
                  Cancel
                </button>
                <button
                  onClick={() => handleSignOutConfirm(true)}
                  className="px-3 py-1.5 text-xs text-white bg-gray-900 rounded-md hover:bg-gray-800"
                >
                  Sign Out
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      <NoteTree onDeleteComment={handleDeleteRequest} />

      <div className="p-4 border-t border-gray-200 bg-white mt-auto">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <img
              src={userInfo?.avatar_url}
              alt="avatar"
              className="w-8 h-8 rounded-full ring-2 ring-gray-100"
            />
            <div className="flex flex-col">
              <span className="text-sm font-medium text-gray-900 leading-none">
                {userInfo?.login || 'User'}
              </span>
            </div>
          </div>
          <button
            onClick={onSettingClick}
            className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors"
            title="Sign out"
          >
            <Icon name="sign-out" className="!m-0" />
          </button>
        </div>
      </div>
    </div>
  );
}
export default Side;
