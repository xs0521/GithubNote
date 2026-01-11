import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';
import { Repository, Issue, Comment } from '@const/index';
import * as db from '@db/index';
import {
  createLocalComment,
  deleteCommentNetwork,
} from '@slice/content-comment-slice';

// 定义初始state
const initialState = {
  repositories: [] as Repository[],
  selectedRepository: null as Repository | null,
  issues: [] as Issue[],
  selectedIssue: null as Issue | null,
  comments: [] as Comment[],
  selectedComment: null as Comment | null,
  isSidebarVisible: false,
};

export const initDB = createAsyncThunk('contentData/initDB', async () => {
  const isDBInitialized = await db.initDB();
  return isDBInitialized;
});

export const contentSlice = createSlice({
  name: 'contentData',
  initialState,
  reducers: {
    updateRepositories: (state, { payload }) => {
      state.repositories = payload;
    },
    updateIssues: (state, { payload }) => {
      state.issues = payload;
    },
    updateComments: (state, { payload }) => {
      state.comments = payload;
    },
    updateSelectedRepository: (state, { payload }) => {
      state.selectedRepository = payload;
    },
    updateSelectedIssue: (state, { payload }) => {
      state.selectedIssue = payload;
    },
    updateSelectedComment: (state, { payload }) => {
      state.selectedComment = payload;
    },
    updateIsSidebarVisible: (state, { payload }) => {
      state.isSidebarVisible = payload;
    },
  },
  extraReducers: (builder) => {
    builder.addCase(createLocalComment.fulfilled, (state, { payload }) => {
      if (payload) {
        state.comments = [payload, ...state.comments];
        state.selectedComment = payload;
      }
    });
    builder.addCase(deleteCommentNetwork.fulfilled, (state, { payload }) => {
      if (payload) {
        state.comments = state.comments.filter(
          (comment) => comment.id !== payload.id,
        );
        state.selectedComment = null;
      }
    });
  },
});

// 为每个 case reducer 函数生成 Action creators
export const {
  updateRepositories,
  updateIssues,
  updateComments,
  updateSelectedRepository,
  updateSelectedIssue,
  updateSelectedComment,
  updateIsSidebarVisible,
} = contentSlice.actions;

export default contentSlice.reducer;
