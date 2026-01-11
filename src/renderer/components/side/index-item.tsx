import { Comment } from '@const/index';
import { type OptionsType } from '@right-menu/core';
import RightMenu from '@right-menu/react';
import {
  formatDebugTime,
  formatTwitterTime,
  getCommentTitle,
} from '@util/index';
import {
  updateSelectedComment,
  updateIsSidebarVisible,
  updateComments,
} from '@slice/content-slice';
import { useDispatch, useSelector } from 'react-redux';
import { AppDispatch, RootState } from '@redux/index';
import {
  fetchCommentNetWork,
  updateCommentDB,
} from '@slice/content-comment-slice';

interface IndexItemProps {
  item: Comment;
  setAlertContent: (item: Comment) => void;
  options: OptionsType;
  isSelected: (item: Comment) => boolean;
}

function IndexItem({
  item,
  setAlertContent,
  options,
  isSelected,
}: IndexItemProps) {
  const isDev = process.env.NODE_ENV === 'development';
  const dispatch = useDispatch<AppDispatch>();
  const userInfo = useSelector((state: RootState) => state.userData.userInfo);
  const selectedRepository = useSelector(
    (state: RootState) => state.contentData.selectedRepository,
  );
  const comments = useSelector(
    (state: RootState) => state.contentData.comments,
  );

  const handleItemClick = () => {
    dispatch(updateSelectedComment(item));
    dispatch(updateIsSidebarVisible(false));
    checkHadNewContent();
  };

  const checkHadNewContent = async () => {
    if (!userInfo || !selectedRepository) {
      return;
    }
    const remoteComment = (await fetchCommentNetWork({
      commentId: item.id,
      accessToken: userInfo.access_token,
      owner: userInfo.login,
      repositoryName: selectedRepository.name,
    })) as Comment;
    if (!remoteComment) {
      console.warn('remoteComment is null');
      return;
    }
    if (remoteComment.body === item.body) {
      return;
    }
    console.log('comment had new content');
    const newComment = {
      ...item,
      body: remoteComment.body,
      updated_at: remoteComment.updated_at,
      dirty: false,
      sync_status: 'synced' as const,
    };
    dispatch(updateCommentDB(newComment));
    dispatch(updateSelectedComment(newComment));
    dispatch(
      updateComments(
        comments.map((comment) =>
          comment.id === item.id ? newComment : comment,
        ),
      ),
    );
  };

  const selected = isSelected(item);

  return (
    <div onContextMenu={() => setAlertContent(item)}>
      <RightMenu
        options={options}
        theme="mac"
        minWidth={60}
        maxWidth={80}
        onBeforeInit={() => {}}
        onAfterInit={() => {}}
      >
        <div
          onClick={handleItemClick}
          className={`
                relative px-4 py-3 cursor-pointer select-none transition-colors duration-150 flex flex-col gap-1
                ${selected ? '' : 'hover:bg-gray-50'}
            `}
        >
          {/* Title - Bold and Dark */}
          <div
            className={`text-sm font-bold truncate ${selected ? 'text-gray-900' : 'text-gray-900'}`}
          >
            {getCommentTitle(item.body) || 'New Note'}
          </div>

          {/* Date and Preview */}
          <div className="flex items-baseline gap-2 text-xs">
            <span
              className={`${selected ? 'text-gray-600' : 'text-gray-500'} font-medium whitespace-nowrap`}
            >
              {formatTwitterTime(item.updated_at || item.created_at)}
            </span>
            <span
              className={`${selected ? 'text-gray-500' : 'text-gray-400'} truncate`}
            >
              {(item.body || '').replace(/[#*`]/g, '').slice(0, 50) ||
                'No additional text'}
            </span>
          </div>
          {isDev && (
            <div className="absolute inset-x-0 top-0 text-[8px] text-red-500 text-center pointer-events-none">
              {formatDebugTime(item.updated_at || item.created_at)}
            </div>
          )}
        </div>
      </RightMenu>
    </div>
  );
}

export default IndexItem;
