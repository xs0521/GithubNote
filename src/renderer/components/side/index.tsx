import { Button, Icon } from 'semantic-ui-react';
import NoteBookSearch from '@components/side/note-book-search';
import { useDispatch, useSelector } from 'react-redux';
import { AppDispatch, RootState } from '@redux/index';
import { type Comment } from '@const/index';
import { updateWorkspace } from '@slice/setting-slice';
import { clearUserData } from '@slice/user-slice';
import PlaceholderAnimationLine from '@components/placeholder';
import { useDataCommentFetchModel } from '@/renderer/models';
import { type OptionsType } from '@right-menu/core';
import DeleteAlert from '@components/side/delete-alert';
import { useCallback, useMemo, useState } from 'react';
import { type FetchCommentsConfig } from '@models/model';
import IndexItem from '@components/side/index-item';
import { clearDeletedComments } from '@/renderer/sync/deleted-comment-cache';

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

  const comments = useSelector(
    (state: RootState) => state.contentData.comments,
  );

  const isCommentsLoading = useSelector(
    (state: RootState) => state.settingData.isCommentsLoading,
  );
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
    dispatch(updateWorkspace(false));
    dispatch(clearUserData());
  };

  const getActiveComment = useCallback((): Comment | null => {
    return alertContent ?? selectedComment ?? null;
  }, [alertContent, selectedComment]);

  const handleDeleteRequest = useCallback(() => {
    const target = getActiveComment();
    if (!target) {
      return;
    }
    setAlertContent(target);
    setShowDeleteConfirmAlert(true);
  }, [getActiveComment]);

  const options = useMemo<OptionsType>(
    () => [
      {
        type: 'li',
        text: 'DEL',
        class: 'right-menu-delete',
        callback: () => {
          handleDeleteRequest();
        },
      },
    ],
    [handleDeleteRequest],
  );

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

  const isSelected = (item: Comment) => {
    return item.id === selectedComment?.id;
  };

  return (
    <div className="flex w-full flex-col h-full bg-gray-50 border-r border-gray-200">
      <div
        className={`border-b border-gray-200 bg-[#F9FAFB] shadow-sm p-4 ${
          isWindows ? 'pt-4' : 'pt-[37px]'
        }`}
      >
        <NoteBookSearch />
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

      {isCommentsLoading ? (
        <div className="p-4">
          <PlaceholderAnimationLine style={{ width: '100%' }} />
        </div>
      ) : (
        <ul className="flex-1 overflow-y-auto py-2 list-none m-0 p-0">
          {comments.map((item) => (
            <li
              key={item.id}
              className={`
                    group mx-3 my-1 rounded-lg transition-all duration-200
                    ${isSelected(item) ? 'bg-[#e8e8e8]' : 'hover:bg-gray-100'}
                `}
            >
              <IndexItem
                item={item}
                setAlertContent={setAlertContent}
                options={options}
                isSelected={isSelected}
              />
            </li>
          ))}
        </ul>
      )}

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
