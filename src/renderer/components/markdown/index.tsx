import { useEffect, useRef } from 'react';
import { Crepe, CrepeFeature } from '@milkdown/crepe';
import '@milkdown/crepe/theme/common/style.css';
import { replaceAll } from '@milkdown/utils';
import { useSelector } from 'react-redux';
import { RootState } from '@redux/index';
import { PLACEHOLDER } from '@const/index';
import {
  getImageDimensions,
  getImageMarkdown,
  getImageMaxDimensions,
} from '@/renderer/util';
import { useSnackbar } from 'notistack';
import BottomToastBar, {
  BottomToastBarVariant,
} from '@/renderer/components/bottomtoastbar';
import uploadFileToRepo, { UploadResult } from '@/renderer/server/upload';

function Markdown() {
  const containerRef = useRef<HTMLDivElement>(null);
  const crepeRef = useRef<Crepe | null>(null);

  const { enqueueSnackbar } = useSnackbar();
  const enqueueSnackbarRef = useRef(enqueueSnackbar);

  const userInfo = useSelector((state: RootState) => state.userData.userInfo);
  const selectedRepository = useSelector(
    (state: RootState) => state.contentData.selectedRepository,
  );
  const selectedComment = useSelector(
    (state: RootState) => state.contentData.selectedComment,
  );

  const userInfoRef = useRef(userInfo);
  const selectedRepositoryRef = useRef(selectedRepository);

  useEffect(() => {
    userInfoRef.current = userInfo;
    selectedRepositoryRef.current = selectedRepository;
    enqueueSnackbarRef.current = enqueueSnackbar;
  });

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
      defaultValue: selectedComment?.body || PLACEHOLDER,
      features: {
        [CrepeFeature.Latex]: false,
      },
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

    let destroyed = false;
    crepe.create().then(() => {
      if (destroyed) return;
      crepeRef.current = crepe;
    });

    return () => {
      destroyed = true;
      crepeRef.current = null;
      crepe.destroy();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Update editor content when selected comment changes
  useEffect(() => {
    const crepe = crepeRef.current;
    if (!crepe) return;
    const content = selectedComment?.body || PLACEHOLDER;
    crepe.editor.action(replaceAll(content));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedComment?.id, selectedComment?.uuid]);

  return <div ref={containerRef} className="w-full h-full crepe-editor-wrapper" />;
}

export default Markdown;
