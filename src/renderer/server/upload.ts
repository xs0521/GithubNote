import { apiGet, apiPut } from '@/renderer/server/API';

// GitHub上传配置接口 - 使用已有的access_token
interface GitHubUploadConfig {
  accessToken: string; // 使用已有的GitHub access token
}

// 上传结果接口
export interface UploadResult {
  success: boolean;
  url?: string;
  error?: string;
}

// 允许的文件类型
const ALLOWED_FILETYPES = [
  '.gif',
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
  '.docx',
  '.gz',
  '.log',
  '.pdf',
  '.pptx',
  '.txt',
  '.xlsx',
  '.zip',
];

// GitHub上传类 - 使用GitHub仓库API
class GitHubUploader {
  private accessToken: string = '';

  constructor(accessToken: string) {
    this.accessToken = accessToken;
  }

  /**
   * 验证access token是否有效
   */
  async validateToken(): Promise<boolean> {
    try {
      await apiGet('/user', this.accessToken);
      return true;
    } catch (error) {
      console.error('Token validation failed:', error);
      return false;
    }
  }

  /**
   * 获取文件扩展名
   */
  private getFileExtension(fileName: string): string {
    const lastDot = fileName.lastIndexOf('.');
    return lastDot === -1 ? '' : fileName.substring(lastDot).toLowerCase();
  }

  /**
   * 将ArrayBuffer转换为base64
   */
  private arrayBufferToBase64(buffer: ArrayBuffer): string {
    const bytes = new Uint8Array(buffer);
    let binary = '';
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
  }

  /**
   * 上传文件到GitHub仓库
   */
  async uploadFileToRepo(
    file: File,
    owner: string,
    repo: string,
    path: string = '',
    message: string = 'Upload file',
  ): Promise<UploadResult> {
    try {
      const fileName = file.name;

      // 检查文件类型
      const fileExt = this.getFileExtension(fileName);
      if (!ALLOWED_FILETYPES.includes(fileExt)) {
        return {
          success: false,
          error: `Unsupported file type: ${fileExt}. Supported types: ${ALLOWED_FILETYPES.join(', ')}`,
        };
      }

      // 将文件转换为base64
      const arrayBuffer = await file.arrayBuffer();
      const base64Content = this.arrayBufferToBase64(arrayBuffer);

      const fullPath = path ? `${path}/${fileName}` : fileName;

      // 使用GitHub API上传文件
      const response = await apiPut<any>(
        `https://api.github.com/repos/${owner}/${repo}/contents/${fullPath}`,
        {
          message: message,
          content: base64Content,
        },
        this.accessToken,
        {
          timeout: 30000,
        },
      );

      if (response && response.content && response.content.html_url) {
        return {
          success: true,
          url: response.content.html_url,
        };
      } else {
        return {
          success: false,
          error: 'Upload failed: no file URL returned',
        };
      }
    } catch (error: any) {
      console.error('File upload failed:', error);
      return {
        success: false,
        error:
          error.response?.data?.message ||
          error.message ||
          'Unknown error occurred during upload',
      };
    }
  }
}

// 导出上传函数 - 上传到GitHub仓库
export async function uploadFileToRepo(
  file: File,
  config: GitHubUploadConfig,
  owner: string,
  repo: string,
  path: string = '',
  message: string = 'Upload file',
): Promise<UploadResult> {
  const uploader = new GitHubUploader(config.accessToken);

  // 验证token
  const tokenValid = await uploader.validateToken();
  if (!tokenValid) {
    return {
      success: false,
      error: 'GitHub access token is invalid',
    };
  }

  // 上传文件到仓库
  return await uploader.uploadFileToRepo(file, owner, repo, path, message);
}

// 导出类供直接使用
export { GitHubUploader };

// 默认导出
export default uploadFileToRepo;
