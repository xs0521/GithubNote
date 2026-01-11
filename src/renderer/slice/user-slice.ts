// store/userDataSlice.js
import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';
import axios from 'axios';
import {
  GITHUB_CLIENT_ID,
  GITHUB_CLIENT_SECRET,
  GITHUB_BASE_URL,
  GITHUB_URL,
} from '@/shared/constants';

export interface UserInfo {
  uuid: string;
  identifier: string;
  hash: string;
  id: number;
  login: string;
  node_id: string;
  avatar_url: string;
  gravatar_id: string;
  url: string;
  html_url: string;
  followers_url: string;
  following_url: string;
  gists_url: string;
  starred_url: string;
  subscriptions_url: string;
  organizations_url: string;
  repos_url: string;
  events_url: string;
  received_events_url: string;
  type: string;
  user_view_type: string;
  site_admin: boolean;
  name: string;
  company: string;
  blog: string;
  location: string;
  email: string;
  hireable: string;
  bio: string;
  twitter_username: string;
  public_repos: number;
  public_gists: number;
  followers: number;
  following: number;
  created_at: string;
  updated_at: string;
  private_gists: number;
  total_private_repos: number;
  owned_private_repos: number;
  disk_usage: number;
  collaborators: number;
  two_factor_authentication: boolean;
  notification_email: string;
  access_token: string;
}

export const fetchAccessToken = createAsyncThunk(
  'userData/fetchAccessToken',
  async (code: string) => {
    const response = await axios.post(
      `${GITHUB_URL}/login/oauth/access_token`,
      {
        client_id: GITHUB_CLIENT_ID,
        client_secret: GITHUB_CLIENT_SECRET,
        code,
      },
    );
    return response.data;
  },
);

export const fetchUserInfo = createAsyncThunk(
  'userData/fetchUserInfo',
  async (accessToken: string) => {
    const response = await axios.get(`${GITHUB_BASE_URL}/user`, {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });
    return response.data;
  },
);

// 定义初始state
const initialState = {
  userInfo: {} as UserInfo,
  isLoading: false,
};

export const userDataSlice = createSlice({
  name: 'userData',
  initialState,
  reducers: {
    editUserData: (state, { payload }) => {
      state.userInfo = { ...state.userInfo, ...payload };
    },
    clearUserData: (state) => {
      state.userInfo = {} as UserInfo;
    },
  },
  extraReducers: (builder) => {
    builder.addCase(fetchAccessToken.pending, (state) => {
      console.log('fetchAccessToken.pending');
      state.isLoading = true;
    });
    builder.addCase(fetchAccessToken.fulfilled, (state, action) => {
      console.log('fetchAccessToken.fulfilled,', action.payload);
      const accessToken = action.payload.split('&')[0].split('=')[1];
      state.userInfo.access_token = accessToken;
    });
    builder.addCase(fetchUserInfo.fulfilled, (state, action) => {
      const accessToken = state.userInfo.access_token;
      state.userInfo = { ...action.payload, access_token: accessToken };
      console.log('fetchUserInfo.fulfilled,', state.userInfo);
      state.isLoading = false;
    });
  },
});

// 为每个 case reducer 函数生成 Action creators
export const { editUserData, clearUserData } = userDataSlice.actions;

export default userDataSlice.reducer;
