// store/settingSlice.ts
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

// 定义设置状态接口
interface SettingState {
  isShowWorkspace: boolean;
  isDBInitialized: boolean;
  isRepositoriesLoading: boolean;
  isIssuesLoading: boolean;
  isCommentsLoading: boolean;
  lastSyncAt: string | null;
}

// 定义初始state
const initialState: SettingState = {
  isShowWorkspace: false,
  isDBInitialized: false,
  isRepositoriesLoading: false,
  isIssuesLoading: false,
  isCommentsLoading: false,
  lastSyncAt: null,
};

export const settingSlice = createSlice({
  name: 'settingData',
  initialState,
  reducers: {
    updateWorkspace: (state, action: PayloadAction<boolean>) => {
      state.isShowWorkspace = action.payload;
    },
    updateIsDBInitialized: (state, action: PayloadAction<boolean>) => {
      state.isDBInitialized = action.payload;
    },
    updateIsRepositoriesLoading: (state, { payload }) => {
      state.isRepositoriesLoading = payload;
    },
    updateIsIssuesLoading: (state, { payload }) => {
      state.isIssuesLoading = payload;
    },
    updateIsCommentsLoading: (state, { payload }) => {
      state.isCommentsLoading = payload;
    },
    updateLastSyncAt: (state, { payload }) => {
      state.lastSyncAt = payload;
    },
  },
});

// 为每个 case reducer 函数生成 Action creators
export const {
  updateWorkspace,
  updateIsDBInitialized,
  updateIsRepositoriesLoading,
  updateIsIssuesLoading,
  updateIsCommentsLoading,
  updateLastSyncAt,
} = settingSlice.actions;

export default settingSlice.reducer;
