import React, { useState, useRef, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
  createLocalComment,
  saveCommentsDB,
} from '@slice/content-comment-slice';
import {
  updateSelectedComment,
  updateSelectedIssue,
  updateComments,
  updateIssues,
} from '@slice/content-slice';
import { AppDispatch, RootState } from '@redux/index';
import {
  CREATE_NOTE_BOOK,
  Issue,
  SELECTED_NOTE_BOOK,
  SELECTED_WORKSPACE,
} from '@const/index';
import { generateCommentBody } from '@const/index';
import { Icon } from 'semantic-ui-react';
import { apiPatch, apiPost } from '@/renderer/server/API';
import * as db from '@db/index';
import RightMenu from '@right-menu/react';
import DeleteNotebookAlert from '@components/side/delete-notebook-alert';

function NoteBookSearch() {
  const dispatch = useDispatch<AppDispatch>();
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [newNotebookName, setNewNotebookName] = useState('');
  const [createError, setCreateError] = useState('');
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [deleteError, setDeleteError] = useState('');
  const [deleteTarget, setDeleteTarget] = useState<Issue | null>(null);
  const [isRenameOpen, setIsRenameOpen] = useState(false);
  const [renameError, setRenameError] = useState('');
  const [renameTarget, setRenameTarget] = useState<Issue | null>(null);
  const [renameValue, setRenameValue] = useState('');

  const selectedIssue = useSelector(
    (state: RootState) => state.contentData.selectedIssue,
  );

  const selectedRepository = useSelector(
    (state: RootState) => state.contentData.selectedRepository,
  );

  const userInfo = useSelector((state: RootState) => state.userData.userInfo);

  const issues = useSelector((state: RootState) => state.contentData.issues);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (
        dropdownRef.current &&
        !dropdownRef.current.contains(event.target as Node)
      ) {
        setIsDropdownOpen(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  const onDropdownItemClick = (value: string) => {
    const issue = issues.find((item) => item.id === value);
    if (issue) {
      console.log('selected issue', issue);
      dispatch(updateSelectedIssue(issue as Issue));
      dispatch(updateSelectedComment(null));
      dispatch(updateComments([]));
      setIsDropdownOpen(false);
    }
  };

  const onCreateNotebookClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    setIsCreateOpen(true);
    setCreateError('');
  };

  const onCreateCancel = () => {
    setIsCreateOpen(false);
    setNewNotebookName('');
    setCreateError('');
  };

  const onCreateConfirm = async () => {
    if (!navigator.onLine) {
      setCreateError('Need network connection to create a notebook.');
      return;
    }
    if (!selectedRepository || !userInfo || !userInfo.access_token) {
      setCreateError('Missing repository or user credentials.');
      return;
    }
    if (!newNotebookName.trim()) {
      setCreateError('Notebook name is required.');
      return;
    }
    try {
      const payload = await apiPost<any>(
        `/repos/${userInfo.login}/${selectedRepository.name}/issues`,
        {
          title: newNotebookName.trim(),
        },
        userInfo.access_token,
      );
      const newIssue: Issue = {
        id: String(payload.id),
        number: payload.number,
        title: payload.title,
        body: payload.body || '',
        state: payload.state,
        user_id: userInfo.id,
        repository_id: String(selectedRepository.id),
        created_at: payload.created_at,
        updated_at: payload.updated_at,
      };
      await db.saveIssues([newIssue]);
      dispatch(updateIssues([newIssue, ...issues]));
      dispatch(updateSelectedIssue(newIssue));
      dispatch(updateSelectedComment(null));
      dispatch(updateComments([]));
      setIsCreateOpen(false);
      setNewNotebookName('');
      setCreateError('');
    } catch (error) {
      console.warn('Failed to create notebook', error);
      setCreateError('Create notebook failed. Please try again.');
    }
  };

  const onDeleteRequest = (issue: Issue) => {
    setDeleteTarget(issue);
    setDeleteError('');
    setIsDeleteOpen(true);
  };

  const onDeleteCancel = () => {
    setIsDeleteOpen(false);
    setDeleteError('');
    setDeleteTarget(null);
  };

  const onDeleteConfirm = async (confirmed: boolean) => {
    if (!confirmed) {
      onDeleteCancel();
      return;
    }
    if (!navigator.onLine) {
      setDeleteError('Need network connection to delete a notebook.');
      return;
    }
    if (!deleteTarget || !selectedRepository || !userInfo) {
      setDeleteError('Missing notebook or user credentials.');
      return;
    }
    try {
      await apiPatch(
        `/repos/${userInfo.login}/${selectedRepository.name}/issues/${deleteTarget.number}`,
        { state: 'closed' },
        userInfo.access_token,
      );
    } catch (error) {
      console.warn('Failed to close notebook on GitHub', error);
      setDeleteError('Delete notebook failed. Please try again.');
      return;
    }

    await db.deleteIssueById(deleteTarget.id);
    const currentIndex = issues.findIndex(
      (item) => item.id === deleteTarget.id,
    );
    const nextIssues = issues.filter((item) => item.id !== deleteTarget.id);
    dispatch(updateIssues(nextIssues));
    if (selectedIssue?.id === deleteTarget.id) {
      const nextIndex = currentIndex >= 0 ? currentIndex : 0;
      const fallbackIndex =
        nextIndex >= nextIssues.length ? nextIssues.length - 1 : nextIndex;
      const nextIssue =
        nextIssues.length > 0 ? nextIssues[Math.max(fallbackIndex, 0)] : null;
      dispatch(updateSelectedIssue(nextIssue));
      dispatch(updateSelectedComment(null));
      dispatch(updateComments([]));
    }
    onDeleteCancel();
  };

  const onRenameRequest = (issue: Issue) => {
    setRenameTarget(issue);
    setRenameValue(issue.title || '');
    setRenameError('');
    setIsRenameOpen(true);
  };

  const onRenameCancel = () => {
    setIsRenameOpen(false);
    setRenameError('');
    setRenameTarget(null);
    setRenameValue('');
  };

  const onRenameConfirm = async (confirmed: boolean) => {
    if (!confirmed) {
      onRenameCancel();
      return;
    }
    if (!navigator.onLine) {
      setRenameError('Need network connection to rename a notebook.');
      return;
    }
    if (!renameTarget || !selectedRepository || !userInfo) {
      setRenameError('Missing notebook or user credentials.');
      return;
    }
    const nextTitle = renameValue.trim();
    if (!nextTitle) {
      setRenameError('Notebook name is required.');
      return;
    }
    try {
      const payload = await apiPatch<any>(
        `/repos/${userInfo.login}/${selectedRepository.name}/issues/${renameTarget.number}`,
        { title: nextTitle },
        userInfo.access_token,
      );
      const updatedIssue: Issue = {
        ...renameTarget,
        title: payload.title,
        body: payload.body || '',
        state: payload.state,
        updated_at: payload.updated_at,
      };
      await db.saveIssues([updatedIssue]);
      dispatch(
        updateIssues(
          issues.map((item) =>
            item.id === updatedIssue.id ? updatedIssue : item,
          ),
        ),
      );
      if (selectedIssue?.id === updatedIssue.id) {
        dispatch(updateSelectedIssue(updatedIssue));
      }
      onRenameCancel();
    } catch (error) {
      console.warn('Failed to rename notebook', error);
      setRenameError('Rename notebook failed. Please try again.');
    }
  };

  const onAddClick = async (e: React.MouseEvent) => {
    e.stopPropagation();
    if (!selectedRepository || !userInfo || !selectedIssue) {
      return;
    }
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

  const getPlaceholder = (): string => {
    if (issues.length > 0) {
      return SELECTED_NOTE_BOOK;
    }
    if ((selectedRepository?.name?.trim() ?? '').length === 0) {
      return SELECTED_WORKSPACE;
    }
    return CREATE_NOTE_BOOK;
  };

  const isSelectedIssue = (selectedIssue?.title?.trim() ?? '').length > 0;

  return (
    <div
      className="relative flex gap-2 items-center w-full min-w-0"
      ref={dropdownRef}
    >
      {/* Title / Dropdown Trigger */}
      <div
        className="flex-1 flex gap-1 items-center cursor-pointer min-w-0"
        onClick={() => setIsDropdownOpen(!isDropdownOpen)}
      >
        <Icon
          name="caret down"
          size="large"
          className={`text-gray-500 transition-transform duration-200 flex-shrink-0 ${isDropdownOpen ? 'rotate-180' : ''}`}
        />
        <div className="flex-1 flex justify-start min-w-0">
          <p
            className={`${isSelectedIssue ? 'text-gray-500 text-xl font-bold' : 'text-gray-500 text-sm'} truncate select-none text-center`}
          >
            {isSelectedIssue ? selectedIssue?.title : getPlaceholder()}
          </p>
        </div>
      </div>

      {/* Actions */}
      <div className="flex items-center flex-shrink-0">
        <button
          onClick={onAddClick}
          className="text-gray-500 transition-colors border-0 focus:outline-none focus:ring-0"
          title="New Note"
        >
          <Icon name="pen square" size="large" />
        </button>
      </div>

      {/* Custom Dropdown Menu */}
      {isDropdownOpen && (
        <div className="absolute top-full left-0 mt-2 w-full bg-white/95 backdrop-blur-xl rounded-lg shadow-2xl border border-gray-100/50 py-1 z-50 animate-in fade-in zoom-in-95 duration-100 origin-top-left ring-1 ring-black/5">
          <div className="px-3 py-2 text-xs font-semibold text-gray-400 bg-gray-50/50 border-b border-gray-100 mb-1 flex items-center justify-between">
            <span>NOTEBOOKS</span>
            <button
              onClick={onCreateNotebookClick}
              className="text-gray-400 hover:text-gray-600 transition-colors border-0 focus:outline-none focus:ring-0"
              title="New Notebook"
            >
              <Icon name="plus" className="!m-0" />
            </button>
          </div>
          <div className="max-h-64 overflow-y-auto py-1 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
            {issues.map((option) => (
              <RightMenu
                key={option.id}
                options={[
                  {
                    type: 'li',
                    text: 'RE',
                    callback: () => onRenameRequest(option),
                  },
                  {
                    type: 'li',
                    text: 'DEL',
                    class: 'right-menu-delete',
                    callback: () => onDeleteRequest(option),
                  },
                ]}
                theme="mac"
                minWidth={60}
                maxWidth={80}
                onBeforeInit={() => {}}
                onAfterInit={() => {}}
              >
                <div
                  onClick={() => onDropdownItemClick(option.id)}
                  className={`
                                flex items-center gap-2 px-3 py-2 text-sm cursor-pointer mx-2 rounded-md transition-colors
                                ${selectedIssue?.id === option.id ? 'bg-blue-50 text-gray-700' : 'text-gray-700 hover:bg-gray-100'}
                            `}
                >
                  <Icon
                    name={selectedIssue?.id === option.id ? 'folder' : 'folder'}
                    size="small"
                  />
                  <span className="truncate">{option.title}</span>
                </div>
              </RightMenu>
            ))}
            {issues.length === 0 && (
              <div className="px-4 py-3 text-sm text-gray-400 text-center italic">
                No notebooks found
              </div>
            )}
          </div>
        </div>
      )}
      {isCreateOpen && (
        <div className="fixed inset-0 z-50">
          <button
            type="button"
            className="absolute inset-0 bg-black/30"
            aria-label="Close create notebook"
            onClick={onCreateCancel}
          />
          <div className="relative z-10 flex h-full w-full items-center justify-center">
            <div className="w-[360px] bg-white rounded-xl shadow-2xl border border-gray-200 p-4">
              <div className="text-xs font-semibold text-gray-500 mb-2">
                CREATE NOTEBOOK
              </div>
              <input
                value={newNotebookName}
                onChange={(e) => setNewNotebookName(e.target.value)}
                placeholder="Notebook name"
                className="w-full text-sm px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-0 focus:border-gray-300"
              />
              {createError && (
                <div className="mt-2 text-xs text-red-500">{createError}</div>
              )}
              <div className="flex items-center justify-end gap-2 mt-4">
                <button
                  onClick={onCreateCancel}
                  className="px-2.5 py-1.5 text-xs text-gray-500 hover:text-gray-700"
                >
                  Cancel
                </button>
                <button
                  onClick={onCreateConfirm}
                  className="px-3 py-1.5 text-xs text-white bg-gray-900 rounded-md hover:bg-gray-800"
                >
                  Create
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
      {DeleteNotebookAlert(
        isDeleteOpen,
        deleteError,
        onDeleteCancel,
        onDeleteConfirm,
      )}
      {isRenameOpen && (
        <div className="fixed inset-0 z-50">
          <button
            type="button"
            className="absolute inset-0 bg-black/30"
            aria-label="Close rename notebook"
            onClick={onRenameCancel}
          />
          <div className="relative z-10 flex h-full w-full items-center justify-center">
            <div className="w-[360px] bg-white rounded-xl shadow-2xl border border-gray-200 p-4">
              <div className="text-xs font-semibold text-gray-500 mb-2">
                RENAME NOTEBOOK
              </div>
              <input
                value={renameValue}
                onChange={(e) => setRenameValue(e.target.value)}
                placeholder="Notebook name"
                className="w-full text-sm px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-0 focus:border-gray-300"
              />
              {renameError && (
                <div className="mt-2 text-xs text-red-500">{renameError}</div>
              )}
              <div className="flex items-center justify-end gap-2 mt-4">
                <button
                  onClick={onRenameCancel}
                  className="px-2.5 py-1.5 text-xs text-gray-500 hover:text-gray-700"
                >
                  Cancel
                </button>
                <button
                  onClick={() => onRenameConfirm(true)}
                  className="px-3 py-1.5 text-xs text-white bg-gray-900 rounded-md hover:bg-gray-800"
                >
                  Rename
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default NoteBookSearch;
