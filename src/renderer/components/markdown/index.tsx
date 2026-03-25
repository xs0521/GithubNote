import { useCallback, useEffect, useMemo, useRef } from 'react';
import { Milkdown, MilkdownProvider, useEditor, useInstance } from '@milkdown/react';
import { Editor, rootCtx, defaultValueCtx } from '@milkdown/core';
import {
  commonmark,
  toggleStrongCommand,
  toggleEmphasisCommand,
  toggleInlineCodeCommand,
  wrapInBulletListCommand,
  wrapInOrderedListCommand,
  wrapInHeadingCommand,
  wrapInBlockquoteCommand,
  createCodeBlockCommand,
} from '@milkdown/preset-commonmark';
import { gfm, toggleStrikethroughCommand } from '@milkdown/preset-gfm';
import { history, undoCommand, redoCommand } from '@milkdown/plugin-history';
import { listener, listenerCtx } from '@milkdown/plugin-listener';
import { upload, uploadConfig } from '@milkdown/plugin-upload';
import { callCommand, replaceAll } from '@milkdown/utils';
import type { CmdKey } from '@milkdown/core';
import { useDispatch, useSelector, useStore } from 'react-redux';
import { debounce } from 'lodash';
import { AppDispatch, RootState } from '@redux/index';
import { updateCommentDB } from '@slice/content-comment-slice';
import { Comment, PLACEHOLDER } from '@const/index';
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
import uploadFileToRepo, { UploadResult } from '@/renderer/server/upload';

// ─── Toolbar ────────────────────────────────────────────────────────────────

function ToolbarBtn({
  onClick,
  title,
  children,
}: {
  onClick: () => void;
  title: string;
  children: React.ReactNode;
}) {
  return (
    <button
      onMouseDown={(e) => {
        e.preventDefault();
        onClick();
      }}
      title={title}
      className="px-1.5 py-0.5 text-xs text-gray-500 hover:text-gray-800 hover:bg-gray-200 rounded transition-colors select-none"
    >
      {children}
    </button>
  );
}

function ToolbarDivider() {
  return <span className="w-px h-4 bg-gray-200 mx-0.5" />;
}

function Toolbar() {
  const [loading, getInstance] = useInstance();

  const exec = useCallback(
    (cmd: { key: CmdKey<any> }, payload?: unknown) => {
      if (loading) return;
      getInstance()?.action(callCommand(cmd.key, payload));
    },
    [loading, getInstance],
  );

  return (
    <div className="flex items-center gap-0.5 px-3 py-1.5 border-b border-gray-200 bg-[#F9FAFB] flex-wrap flex-shrink-0">
      <ToolbarBtn onClick={() => exec(wrapInHeadingCommand, 1)} title="Heading 1">H1</ToolbarBtn>
      <ToolbarBtn onClick={() => exec(wrapInHeadingCommand, 2)} title="Heading 2">H2</ToolbarBtn>
      <ToolbarBtn onClick={() => exec(wrapInHeadingCommand, 3)} title="Heading 3">H3</ToolbarBtn>
      <ToolbarDivider />
      <ToolbarBtn onClick={() => exec(toggleStrongCommand)} title="Bold"><strong>B</strong></ToolbarBtn>
      <ToolbarBtn onClick={() => exec(toggleEmphasisCommand)} title="Italic"><em>I</em></ToolbarBtn>
      <ToolbarBtn onClick={() => exec(toggleStrikethroughCommand)} title="Strikethrough"><s>S</s></ToolbarBtn>
      <ToolbarBtn onClick={() => exec(toggleInlineCodeCommand)} title="Inline Code">`code`</ToolbarBtn>
      <ToolbarDivider />
      <ToolbarBtn onClick={() => exec(wrapInBulletListCommand)} title="Bullet List">• list</ToolbarBtn>
      <ToolbarBtn onClick={() => exec(wrapInOrderedListCommand)} title="Ordered List">1. list</ToolbarBtn>
      <ToolbarBtn onClick={() => exec(wrapInBlockquoteCommand)} title="Blockquote">&ldquo;</ToolbarBtn>
      <ToolbarBtn onClick={() => exec(createCodeBlockCommand)} title="Code Block">{ '{ }' }</ToolbarBtn>
      <ToolbarDivider />
      <ToolbarBtn onClick={() => exec(undoCommand)} title="Undo">↩</ToolbarBtn>
      <ToolbarBtn onClick={() => exec(redoCommand)} title="Redo">↪</ToolbarBtn>
    </div>
  );
}

// ─── Editor Core ────────────────────────────────────────────────────────────

interface EditorCoreProps {
  defaultValue: string;
  onChange: (markdown: string) => void;
  onUploadImage: (file: File) => Promise<string>;
  onEditorReady: (updater: (content: string) => void) => void;
}

function MilkdownEditorCore({
  defaultValue,
  onChange,
  onUploadImage,
  onEditorReady,
}: EditorCoreProps) {
  const isExternalUpdateRef = useRef(false);

  const { get } = useEditor((root) =>
    Editor.make()
      .config((ctx) => {
        ctx.set(rootCtx, root);
        ctx.set(defaultValueCtx, defaultValue);

        ctx.get(listenerCtx).markdownUpdated((_, markdown) => {
          if (isExternalUpdateRef.current) return;
          onChange(markdown);
        });

        ctx.update(uploadConfig.key, (prev) => ({
          ...prev,
          uploader: async (files: FileList, schema: any) => {
            const nodes: any[] = [];
            for (let i = 0; i < files.length; i++) {
              const file = files.item(i);
              if (!file?.type.startsWith('image/')) continue;
              const url = await onUploadImage(file);
              const node = schema.nodes.image?.createAndFill({
                src: url,
                alt: file.name,
              });
              if (node) nodes.push(node);
            }
            return nodes;
          },
        }));
      })
      .use(commonmark)
      .use(gfm)
      .use(history)
      .use(listener)
      .use(upload),
  );

  useEffect(() => {
    onEditorReady((content: string) => {
      isExternalUpdateRef.current = true;
      get()?.action(replaceAll(content));
      setTimeout(() => {
        isExternalUpdateRef.current = false;
      }, 100);
    });
  }, [get, onEditorReady]);

  return <Milkdown />;
}

// ─── Main Component ──────────────────────────────────────────────────────────

function Markdown() {
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

  const selectedCommentRef = useRef<Comment | null>(null);
  const commentsRef = useRef<Comment[]>([]);
  const syncUploadTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  const editorUpdateRef = useRef<((content: string) => void) | null>(null);

  useEffect(() => {
    selectedCommentRef.current = selectedComment;
    commentsRef.current = comments;
  }, [selectedComment, comments]);

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

        if (syncUploadTimeoutRef.current) {
          clearTimeout(syncUploadTimeoutRef.current);
        }
        syncUploadTimeoutRef.current = setTimeout(() => {
          syncManager.syncSelectedIssue();
          syncUploadTimeoutRef.current = null;
        }, 2500);
      }, 500),
    [dispatch, syncManager],
  );

  const handleUploadImage = useCallback(
    async (file: File): Promise<string> => {
      return new Promise((resolve) => {
        const result = uploadFileToRepo(
          file,
          { accessToken: userInfo.access_token },
          userInfo.login,
          selectedRepository?.name || '',
          'githubnote/images',
          'Upload image',
        );
        result.then((value: UploadResult) => {
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
                  // clipboard failed, ignore
                }
              }
            })();
            enqueueSnackbar('Upload image success', {
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
            enqueueSnackbar('Upload image failed', {
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
    },
    [userInfo, selectedRepository, enqueueSnackbar],
  );

  const handleEditorReady = useCallback((updater: (content: string) => void) => {
    editorUpdateRef.current = updater;
  }, []);

  // Update editor when selected comment changes
  useEffect(() => {
    const content = selectedComment?.body || '';
    const next = content === '' ? PLACEHOLDER : content;
    editorUpdateRef.current?.(next);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedComment?.id, selectedComment?.uuid]);

  useEffect(() => {
    return () => {
      handleContentChange.cancel();
      if (syncUploadTimeoutRef.current) {
        clearTimeout(syncUploadTimeoutRef.current);
      }
    };
  }, [handleContentChange]);

  const defaultValue = selectedComment?.body || PLACEHOLDER;

  return (
    <div className="w-full h-full flex flex-col overflow-hidden">
      <MilkdownProvider>
        <Toolbar />
        <div className="flex-1 overflow-y-auto milkdown-editor-wrapper">
          <MilkdownEditorCore
            defaultValue={defaultValue}
            onChange={handleContentChange}
            onUploadImage={handleUploadImage}
            onEditorReady={handleEditorReady}
          />
        </div>
      </MilkdownProvider>
    </div>
  );
}

export default Markdown;
