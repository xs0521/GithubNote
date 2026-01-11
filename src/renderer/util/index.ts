export const getCommentTitle = (commentBody: string) => {
  if (!commentBody) {
    return '';
  }
  const firstLine = commentBody.split(/\r?\n/)[0];
  const value = firstLine.replace(/#/g, '');
  return value;
};

export const formatTwitterTime = (value?: string | null): string => {
  if (!value) {
    return '';
  }
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return '';
  }
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  if (diffMs < 0) {
    return 'now';
  }
  const diffSeconds = Math.floor(diffMs / 1000);
  if (diffSeconds < 60) {
    return 'now';
  }
  const diffMinutes = Math.floor(diffSeconds / 60);
  if (diffMinutes < 60) {
    return `${diffMinutes}m`;
  }
  const diffHours = Math.floor(diffMinutes / 60);
  if (diffHours < 24) {
    return `${diffHours}h`;
  }
  const diffDays = Math.floor(diffHours / 24);
  if (diffDays < 7) {
    return `${diffDays}d`;
  }

  const isSameYear = date.getFullYear() === now.getFullYear();
  const monthDay = new Intl.DateTimeFormat('en-US', {
    month: 'short',
    day: 'numeric',
  }).format(date);
  if (isSameYear) {
    return monthDay;
  }
  const monthDayYear = new Intl.DateTimeFormat('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  }).format(date);
  return monthDayYear;
};

export const formatDebugTime = (value?: string | null): string => {
  if (!value) {
    return '';
  }
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return '';
  }
  const pad = (num: number) => String(num).padStart(2, '0');
  const year = date.getFullYear();
  const month = pad(date.getMonth() + 1);
  const day = pad(date.getDate());
  const hours = pad(date.getHours());
  const minutes = pad(date.getMinutes());
  const seconds = pad(date.getSeconds());
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
};

/**
 * 获取图片文件的宽高信息
 */
export const getImageDimensions = (
  file: File,
): Promise<{ width: number; height: number } | null> => {
  return new Promise((resolve) => {
    // 检查是否为图片文件
    if (!file.type.startsWith('image/')) {
      resolve(null);
      return;
    }

    const reader = new FileReader();
    reader.onload = (event) => {
      const img = new Image();
      img.onload = () => {
        resolve({ width: img.width, height: img.height });
      };
      img.onerror = () => resolve(null);
      img.src = event.target?.result as string;
    };
    reader.onerror = () => resolve(null);
    reader.readAsDataURL(file);
  });
};

export const getImageMaxDimensions = (width: number, height: number) => {
  const maxHeight = 400;
  const maxWidth = Math.min(width, (maxHeight * height) / width);
  return { width: maxWidth, height: maxHeight };
};

/**
 * 获取文件的基本信息（包括图片的宽高）
 */
export const getFileInfo = async (file: File) => {
  const baseInfo = {
    name: file.name,
    size: file.size,
    type: file.type,
    lastModified: file.lastModified,
  };

  // 如果是图片，获取宽高信息
  const imageDimensions = await getImageDimensions(file);

  return {
    ...baseInfo,
    ...(imageDimensions && { dimensions: imageDimensions }),
  };
};

/**
 * 格式化文件大小
 */
export const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 Bytes';

  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));

  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

/**
 * 检查文件是否为图片
 */
export const isImageFile = (file: File): boolean => {
  return file.type.startsWith('image/');
};

/**
 * 检查文件是否为支持的图片格式
 */
export const isSupportedImageFormat = (file: File): boolean => {
  const supportedFormats = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
  ];
  return supportedFormats.includes(file.type.toLowerCase());
};

export const getImageMarkdown = (
  path: string,
  name: string,
  size: { width: number; height: number },
) => {
  return `<img src="${path}" alt="${name}" width="${size.width}px" height="${size.height}px" />`;
};
