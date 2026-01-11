import { useEffect, useMemo, useRef, useState } from 'react';
import Vditor from 'vditor';
import 'vditor/dist/index.css';
import { useDispatch, useSelector, useStore } from 'react-redux';
import { AppDispatch, RootState } from '@redux/index';
import { updateCommentDB } from '@slice/content-comment-slice';
import { Comment, PLACEHOLDER } from '@const/index';
import { after, debounce } from 'lodash';
import uploadFileToRepo, { UploadResult } from '@/renderer/server/upload';
import {
  getCommentTitle,
  getImageDimensions,
  getImageMarkdown,
  getImageMaxDimensions,
} from '@/renderer/util';

import { useSnackbar } from 'notistack';
import BottomToastBar, {
  BottomToastBarVariant,
} from '@/renderer/components/bottomtoastbar';
import { getSyncManager } from '@/renderer/sync';
import { updateComments, updateSelectedComment } from '@slice/content-slice';

function Markdown() {
  const { enqueueSnackbar, closeSnackbar } = useSnackbar();

  const userInfo = useSelector((state: RootState) => state.userData.userInfo);
  const selectedRepository = useSelector(
    (state: RootState) => state.contentData.selectedRepository,
  );
  const selectedIssue = useSelector(
    (state: RootState) => state.contentData.selectedIssue,
  );
  const dispatch = useDispatch<AppDispatch>();
  const store = useStore<RootState>();
  const syncManager = useMemo(
    () => getSyncManager(dispatch, () => store.getState()),
    [dispatch, store],
  );

  const selectedComment = useSelector(
    (state: RootState) => state.contentData.selectedComment,
  );
  const comments = useSelector(
    (state: RootState) => state.contentData.comments,
  );

  const enbleAutoSync = useRef(false);
  const autoSyncTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  const syncUploadTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  const selectedCommentRef = useRef<Comment | null>(null);
  const commentsRef = useRef<Comment[]>([]);
  const selectedKeyRef = useRef<string | null>(null);

  const [vd, setVd] = useState<Vditor>();
  useEffect(() => {
    selectedCommentRef.current = selectedComment;
    commentsRef.current = comments;
  }, [selectedComment, comments]);

  useEffect(() => {
    const checkContentChange = debounce(
      (content: string, currentComment: Comment | null) => {
        const activeComment = selectedCommentRef.current;
        if (!activeComment || !content || !currentComment) {
          return;
        }
        const { body } = activeComment;
        if (content === body) {
          return;
        }
        console.log('content changed', getCommentTitle(content));
        const now = new Date().toISOString();
        const saveComment = {
          ...currentComment,
          body: content,
          updated_at: now,
          dirty: true,
          sync_status: 'pending' as const,
        };
        dispatch(updateSelectedComment(saveComment));
        console.log('local edit queued', {
          id: saveComment.id,
          uuid: saveComment.uuid,
          updated_at: saveComment.updated_at,
        });
        dispatch(
          updateComments(
            commentsRef.current.map((comment) => {
              const isMatch = saveComment.id
                ? String(comment.id) === String(saveComment.id)
                : comment.uuid === saveComment.uuid;
              return isMatch ? saveComment : comment;
            }),
          ),
        );
        dispatch(updateCommentDB(saveComment));

        if (syncUploadTimeoutRef.current) {
          clearTimeout(syncUploadTimeoutRef.current);
        }
        syncUploadTimeoutRef.current = setTimeout(() => {
          syncManager.syncSelectedIssue();
          syncUploadTimeoutRef.current = null;
        }, 2500);
      },
      500,
    );

    const vditor = new Vditor('vditor', {
      height: '100%',
      lang: 'en_US',
      toolbar: [
        'emoji',
        'headings',
        'bold',
        'italic',
        'strike',
        'link',
        '|',
        'list',
        'ordered-list',
        'check',
        'outdent',
        'indent',
        '|',
        'quote',
        'line',
        'code',
        'inline-code',
        'insert-before',
        'insert-after',
        '|',
        'upload',
        'table',
        '|',
        'undo',
        'redo',
        '|',
        'edit-mode',
      ],
      after: () => {
        console.log('vditor after');
        setVd(vditor);
        enbleAutoSync.current = true;
      },
      input: (value) => {
        if (!enbleAutoSync.current) {
          console.warn('vditor input not enble auto sync');
          return;
        }
        checkContentChange(value, selectedCommentRef.current);
      },
      customWysiwygToolbar: (type: TWYSISYGToolbar, element: HTMLElement) => {
        console.log('customWysiwygToolbar', type, element);
      },
      value: selectedComment?.body || PLACEHOLDER,
      upload: {
        accept: 'image/*',
        multiple: false,
        filename(name) {
          return name;
        },
        async handler(files) {
          return await handleUploadImage(files);
        },
      },
    });

    async function handleUploadImage(files: File[]) {
      const file = files[0];
      return new Promise<string>((resolve) => {
        try {
          const result = uploadFileToRepo(
            file,
            {
              accessToken: userInfo.access_token,
            },
            userInfo.login,
            selectedRepository?.name || '',
            'githubnote/images',
            'Upload image',
          );
          result.then((value: UploadResult) => {
            console.log('upload image', value);
            if (value.success) {
              const imageUrl = value.url + '?raw=1';
              clipboard(file, imageUrl, () => {
                enqueueSnackbar('upload image success', {
                  content: (key, message) => (
                    <BottomToastBar
                      id={key}
                      variant={BottomToastBarVariant.INFO}
                      message={message}
                      description="auto copy to clipboard successfully"
                    />
                  ),
                });
              });
            } else {
              console.warn('upload image error', value.error);
              const errorMessage = value.error || 'upload image failed';
              enqueueSnackbar('Upload image failed', {
                content: (key, message) => (
                  <BottomToastBar
                    id={key}
                    variant={BottomToastBarVariant.ERROR}
                    message={message}
                    description={errorMessage}
                  />
                ),
              });
            }
          });
        } catch (error) {
          console.warn('upload image error', error);
          enqueueSnackbar('Upload image failed', {
            variant: 'error',
          });
        }
      });
    }

    async function clipboard(file: File, path: string, completion: () => void) {
      const dimensions = await getImageDimensions(file);
      if (dimensions === null) {
        console.warn('get image dimensions error');
        completion();
        return;
      }
      const size = getImageMaxDimensions(dimensions.width, dimensions.height);
      const imageMarkdown: string = getImageMarkdown(path, file.name, size);
      console.log('clipboard', imageMarkdown);
      // 复制到剪切板
      try {
        if (!document.hasFocus()) {
          throw new Error('Document not focused');
        }
        await navigator.clipboard.writeText(imageMarkdown);
        completion();
      } catch (error) {
        console.warn('clipboard write failed', error);
        enqueueSnackbar('Copy to clipboard failed', {
          content: (key, message) => (
            <BottomToastBar
              id={key}
              variant={BottomToastBarVariant.WARNING}
              message={message}
              description="Please focus the app and copy again"
            />
          ),
        });
        completion();
      }
    }

    // Clear the effect
    return () => {
      vd?.destroy();
      setVd(undefined);
      closeSnackbar();
      // 清理定时器
      if (autoSyncTimeoutRef.current) {
        clearTimeout(autoSyncTimeoutRef.current);
        autoSyncTimeoutRef.current = null;
      }
      if (syncUploadTimeoutRef.current) {
        clearTimeout(syncUploadTimeoutRef.current);
        syncUploadTimeoutRef.current = null;
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    console.log('selectedComment changed', selectedComment);
    if (vd) {
      // 取消之前的定时器
      if (autoSyncTimeoutRef.current) {
        clearTimeout(autoSyncTimeoutRef.current);
        autoSyncTimeoutRef.current = null;
      }

      const selectedKey = selectedComment
        ? selectedComment.uuid || selectedComment.id
        : null;
      const currentKey = selectedKeyRef.current;
      const shouldAllowUpdate =
        selectedComment &&
        !selectedComment.dirty &&
        selectedComment.sync_status !== 'pending';
      if (selectedKey && currentKey === selectedKey && !shouldAllowUpdate) {
        return;
      }
      selectedKeyRef.current = selectedKey;
      const content = selectedComment?.body || '';
      const nextValue = content === '' ? PLACEHOLDER : content;
      const currentValue = vd.getValue();
      if (currentValue !== nextValue) {
        vd.setValue(nextValue);
        console.log('vditor set value', getCommentTitle(content));
      }
      vd.clearStack();
      enbleAutoSync.current = false;
      autoSyncTimeoutRef.current = setTimeout(() => {
        enbleAutoSync.current = true;
        autoSyncTimeoutRef.current = null;
      }, 1000);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedComment?.id, selectedComment?.uuid]);

  return (
    <div className="w-full h-full">
      <div
        id="vditor"
        className="vditor"
        style={{ margin: 0, padding: 0, backgroundColor: 'white' }}
      />
    </div>
  );
}

export default Markdown;
