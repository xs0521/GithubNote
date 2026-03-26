// 使用示例：如何与现有的认证系统集成使用GitHub文件上传功能
// 使用GitHub仓库API上传文件

import { uploadFileToRepo } from './upload';
import { useSelector } from 'react-redux';
import log from 'electron-log/renderer';
import { RootState } from '../redux';

// 示例1：在React组件中使用，从Redux store获取access token
export const useGitHubUpload = () => {
  const userInfo = useSelector((state: RootState) => state.userData.userInfo);

  // 上传到GitHub仓库
  const uploadToRepository = async (
    file: File,
    owner: string,
    repo: string,
    path: string = '',
    message: string = 'Upload file',
  ) => {
    if (!userInfo.access_token) {
      throw new Error('Please sign in to GitHub first');
    }

    return await uploadFileToRepo(
      file,
      { accessToken: userInfo.access_token },
      owner,
      repo,
      path,
      message,
    );
  };

  return {
    uploadToRepository,
    isLoggedIn: !!userInfo.access_token,
    userLogin: userInfo.login,
  };
};

// 示例2：直接使用函数
export const exampleUsage = async () => {
  // 假设你已经有了access token（从Redux store或localStorage获取）
  const accessToken = 'your_github_access_token_here';

  // 上传文件到指定仓库
  const result = await uploadFileToRepo(
    new File(['file content'], 'file.txt'),
    { accessToken: accessToken },
    'username', // 仓库所有者
    'repository-name', // 仓库名
    'uploads', // 仓库内的路径
    'Upload file via API', // 提交信息
  );

  if (result.success) {
    log.info('File upload success:', result.url);
    // 返回的URL可以直接在markdown中使用
  } else {
    log.error('File upload failed:', result.error);
  }
};

/*
GitHub文件上传方案说明：

## 方案：GitHub仓库API

### 工作原理
- 使用GitHub官方API上传文件到指定仓库
- 文件转换为base64格式上传
- 文件成为仓库的一部分，有版本控制

### 优势
- ✅ 完全兼容OAuth token
- ✅ 稳定可靠，使用官方API
- ✅ 文件有版本控制
- ✅ 可以上传到私有仓库
- ✅ 支持大文件（GitHub限制内）

### 支持的文件类型
- .gif, .jpg, .jpeg, .png (图片)
- .docx, .pdf, .pptx, .xlsx (文档)
- .txt, .log (文本)
- .gz, .zip (压缩文件)

### 使用场景
- Markdown编辑器中的图片上传
- 文档附件上传
- 项目资源文件管理
- 长期文件存储

### 注意事项
- 需要有效的GitHub access token
- 需要对目标仓库有写入权限
- 文件会成为仓库的一部分
- 适合长期存储和版本控制
*/
