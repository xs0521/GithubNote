import { useEffect, useMemo, useRef } from 'react';
import { Crepe, CrepeFeature } from '@milkdown/crepe';
import '@milkdown/crepe/theme/common/style.css';
import '@milkdown/crepe/theme/frame.css';
import { replaceAll } from '@milkdown/utils';
import { useDispatch, useSelector, useStore } from 'react-redux';
import { debounce } from 'lodash';
import { AppDispatch, RootState } from '@redux/index';
import { updateCommentDB } from '@slice/content-comment-slice';
import { Comment, PLACEHOLDER } from '@const/index';
import {
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
import uploadFileToRepo, { UploadResult } from '@/renderer/server/upload';

function Markdown() {
  const containerRef = useRef<HTMLDivElement>(null);
  const crepeRef = useRef<Crepe | null>(null);
  const isExternalUpdateRef = useRef(false);

  const { enqueueSnackbar } = useSnackbar();
  const dispatch = useDispatch<AppDispatch>();
  const store = useStore<RootState>();

  const syncManager = useMemo(
    () => getSyncManager(dispatch, () => store.getState()),
    [dispatch, store],
  );

  const userInfo = useSelector((state: RootState) => state.userData.userInfo);
  const selectedRepository = useSelector(
    (state: RootState) => state.contentData.selectedRepository,
  );
  const selectedComment = useSelector(
    (state: RootState) => state.contentData.selectedComment,
  );
  const comments = useSelector(
    (state: RootState) => state.contentData.comments,
  );

  // Stable refs for async callbacks
  const selectedCommentRef = useRef<Comment | null>(null);
  const commentsRef = useRef<Comment[]>([]);
  const syncUploadTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  const userInfoRef = useRef(userInfo);
  const selectedRepositoryRef = useRef(selectedRepository);
  const enqueueSnackbarRef = useRef(enqueueSnackbar);

  useEffect(() => {
    selectedCommentRef.current = selectedComment;
    commentsRef.current = comments;
    userInfoRef.current = userInfo;
    selectedRepositoryRef.current = selectedRepository;
    enqueueSnackbarRef.current = enqueueSnackbar;
  });

  const handleContentChange = useMemo(
    () =>
      debounce((markdown: string) => {
        const current = selectedCommentRef.current;
        if (!current || !markdown || markdown === current.body) return;

        const now = new Date().toISOString();
        const saved: Comment = {
          ...current,
          body: markdown,
          updated_at: now,
          dirty: true,
          sync_status: 'pending',
        };

        dispatch(updateSelectedComment(saved));
        dispatch(
          updateComments(
            commentsRef.current.map((c) => {
              const match = saved.id
                ? String(c.id) === String(saved.id)
                : c.uuid === saved.uuid;
              return match ? saved : c;
            }),
          ),
        );
        dispatch(updateCommentDB(saved));

        if (syncUploadTimeoutRef.current)
          clearTimeout(syncUploadTimeoutRef.current);
        syncUploadTimeoutRef.current = setTimeout(() => {
          syncManager.syncSelectedIssue();
          syncUploadTimeoutRef.current = null;
        }, 2500);
      }, 500),
    [dispatch, syncManager],
  );

  // Initialize Crepe editor once
  useEffect(() => {
    if (!containerRef.current) return;

    const handleUpload = async (file: File): Promise<string> => {
      return new Promise<string>((resolve) => {
        const ui = userInfoRef.current;
        const repo = selectedRepositoryRef.current;
        uploadFileToRepo(
          file,
          { accessToken: ui.access_token },
          ui.login,
          repo?.name || '',
          'githubnote/images',
          'Upload image',
        ).then((value: UploadResult) => {
          if (value.success) {
            const url = value.url + '?raw=1';
            (async () => {
              const dims = await getImageDimensions(file);
              if (dims) {
                const size = getImageMaxDimensions(dims.width, dims.height);
                const md = getImageMarkdown(url, file.name, size);
                try {
                  await navigator.clipboard.writeText(md);
                } catch {
                  // clipboard access denied, ignore
                }
              }
            })();
            enqueueSnackbarRef.current('Upload image success', {
              content: (key, message) => (
                <BottomToastBar
                  id={key}
                  variant={BottomToastBarVariant.INFO}
                  message={message}
                  description="auto copy to clipboard successfully"
                />
              ),
            });
            resolve(url);
          } else {
            enqueueSnackbarRef.current('Upload image failed', {
              content: (key, message) => (
                <BottomToastBar
                  id={key}
                  variant={BottomToastBarVariant.ERROR}
                  message={message}
                  description={value.error || 'upload failed'}
                />
              ),
            });
            resolve('');
          }
        });
      });
    };

    const crepe = new Crepe({
      root: containerRef.current,
      defaultValue: selectedCommentRef.current?.body || PLACEHOLDER,
      featureConfigs: {
        [CrepeFeature.ImageBlock]: {
          onUpload: handleUpload,
          inlineOnUpload: handleUpload,
          blockOnUpload: handleUpload,
        },
        [CrepeFeature.Placeholder]: {
          text: 'Start writing...',
        },
      },
    });

    crepe.on((api) => {
      api.markdownUpdated((_ctx, markdown) => {
        if (isExternalUpdateRef.current) return;
        handleContentChange(markdown);
      });
    });

    let destroyed = false;
    crepe.create().then(() => {
      if (destroyed) return;
      crepeRef.current = crepe;
      // Apply latest content in case selectedComment changed during async init
      const content = selectedCommentRef.current?.body || PLACEHOLDER;
      isExternalUpdateRef.current = true;
      crepe.editor.action(replaceAll(content));
      setTimeout(() => {
        isExternalUpdateRef.current = false;
      }, 100);
    });

    return () => {
      destroyed = true;
      crepeRef.current = null;
      crepe.destroy();
      handleContentChange.cancel();
      if (syncUploadTimeoutRef.current)
        clearTimeout(syncUploadTimeoutRef.current);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [handleContentChange]);

  // Update editor content when selected comment changes
  useEffect(() => {
    const crepe = crepeRef.current;
    if (!crepe) return;
    const content = selectedComment?.body || PLACEHOLDER;
    isExternalUpdateRef.current = true;
    crepe.editor.action(replaceAll(content));
    setTimeout(() => {
      isExternalUpdateRef.current = false;
    }, 100);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedComment?.id, selectedComment?.uuid]);

  return <div ref={containerRef} className="w-full h-full crepe-editor-wrapper" />;
}

export default Markdown;
