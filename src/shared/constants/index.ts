export const GITHUB_CLIENT_ID = 'Ov23liFKH5Ro2ZweAEoZ';
export const GITHUB_CLIENT_SECRET = 'dc7b96ec1d9bc95f99e68648ad9f7614beac961e';
export const GITHUB_BASE_URL = 'https://api.github.com';
export const GITHUB_URL = 'https://github.com';
export const GITHUB_AUTHORIZE_URL = 'https://github.com/login/oauth/authorize';
export const GITHUB_SCOPES = [
  'read:user',
  'user:email',
  'repo',
  'write:discussion',
];

export const CHANNEL_ACTION_OPEN_GITHUB_LOGIN =
  'channel-action-open-github-login';

export const CHANNEL_ACTION_GITHUB_TOKEN =
  'channel-action-github-login-user-token';
export const CHANNEL_ACTION_UPDATE_DOWNLOADED =
  'channel-action-update-downloaded';
export const CHANNEL_ACTION_INSTALL_UPDATE =
  'channel-action-install-update';
export const CHANNEL_ACTION_UPDATE_AVAILABLE =
  'channel-action-update-available';
export const CHANNEL_ACTION_UNAUTHORIZED = 'channel-action-unauthorized';
export const CHANNEL_ACTION_WINDOW_MINIMIZE =
  'channel-action-window-minimize';
export const CHANNEL_ACTION_WINDOW_MAXIMIZE =
  'channel-action-window-maximize';
export const CHANNEL_ACTION_WINDOW_CLOSE = 'channel-action-window-close';

export const CHANNEL_GITHUB_LOGIN_SUCCESS = 'github-login-success';
export const CHANNEL_GITHUB_LOGIN_ERROR = 'github-login-error';
export const CHANNEL_COMMON = 'ipc-common';
