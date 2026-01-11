import { createAsyncThunk } from '@reduxjs/toolkit';
import * as db from '@db/index';
import { Comment } from '@const/index';
import { apiDelete, apiGet, apiPatch, apiPost } from '@/renderer/server/API';

interface CreateCommentParams {
  issueNumber: number;
  issueId: string;
  body: string;
  accessToken: string;
  owner: string;
  repositoryName: string;
  userId: number;
  repositoryId: string;
}

export const createComment = createAsyncThunk(
  'contentData/createComment',
  async ({
    issueNumber,
    issueId,
    body,
    accessToken,
    owner,
    repositoryName,
    userId,
    repositoryId,
  }: CreateCommentParams) => {
    if (!accessToken || !owner || !repositoryName || !issueNumber) {
      console.warn('Missing required configuration to create comment');
      return null;
    }
    const comment = await apiPost<Comment>(
      `/repos/${owner}/${repositoryName}/issues/${issueNumber}/comments`,
      { body },
      accessToken,
    );
    const normalizedComment: Comment = {
      ...comment,
      id: String(comment.id),
      user_id: userId,
      repository_id: String(repositoryId),
      issue_id: String(issueId),
    };
    // 返回数据，由 reducer 处理保存到数据库的逻辑
    return normalizedComment;
  },
);

interface CreateLocalCommentParams {
  issueId: string;
  body: string;
  userId: number;
  repositoryId: string;
}

export const createLocalComment = createAsyncThunk(
  'contentData/createLocalComment',
  async ({ issueId, body, userId, repositoryId }: CreateLocalCommentParams) => {
    const uuid = crypto.randomUUID();
    const now = new Date().toISOString();
    const localComment: Comment = {
      id: `local:${uuid}`,
      url: '',
      html_url: '',
      issue_url: '',
      node_id: '',
      created_at: now,
      updated_at: now,
      body,
      uuid,
      dirty: true,
      sync_status: 'pending',
      user_id: userId,
      repository_id: String(repositoryId),
      issue_id: String(issueId),
    };
    return localComment;
  },
);

export const fetchCommentsFromDB = createAsyncThunk(
  'contentData/fetchCommentsFromDB',
  async ({
    userId,
    repositoryId,
    issueId,
  }: {
    userId: number;
    repositoryId: string;
    issueId: string;
  }) => {
    try {
      return await db.getCommentsByIssue(userId, repositoryId, issueId);
    } catch (error) {
      console.error('Error fetching comments from DB', error);
      return [];
    }
  },
);

export const fetchComments = createAsyncThunk(
  'contentData/fetchComments',
  async ({
    accessToken,
    owner,
    repositoryName,
    issueNumber,
    userId,
    repositoryId,
    issueId,
  }: {
    accessToken: string;
    owner: string;
    repositoryName: string;
    issueNumber: number;
    userId: number;
    repositoryId: string;
    issueId: string;
  }) => {
    if (!accessToken) {
      console.warn('No access token found', repositoryName);
      return [];
    }
    if (!owner) {
      console.warn('No owner found', repositoryName);
      return [];
    }
    if (!repositoryName) {
      console.warn('No repositoryName found', repositoryName);
      return [];
    }
    if (!issueNumber) {
      console.warn('No issueNumber found', repositoryName);
      return [];
    }
    if (!userId) {
      console.warn('No userId found', repositoryName);
      return [];
    }
    const page = 1;
    const perPage = 100;
    const comments = await apiGet<Comment[]>(
      `/repos/${owner}/${repositoryName}/issues/${issueNumber}/comments`,
      accessToken,
      {
        params: {
          page,
          per_page: perPage,
        },
      },
    );
    const rows = comments.map((item: Comment) => ({
      ...item,
      id: String(item.id),
      uuid: item.uuid || '',
      dirty: false,
      sync_status: 'synced' as const,
      user_id: userId,
      repository_id: String(repositoryId),
      issue_id: String(issueId),
    }));
    return rows;
  },
);

export const saveCommentsDB = createAsyncThunk(
  'contentData/saveComments',
  async (comments: Comment[]) => {
    try {
      await db.saveComments(comments);
      return comments;
    } catch (error) {
      console.error('Error saving comments', error);
      return [];
    }
  },
);

interface FetchCommentNetWorkParmms {
  commentId: string;
  accessToken: string;
  owner: string;
  repositoryName: string;
}

export const fetchCommentNetWork = async ({
  commentId,
  accessToken,
  owner,
  repositoryName,
}: FetchCommentNetWorkParmms) => {
  try {
    return await apiGet<Comment>(
      `/repos/${owner}/${repositoryName}/issues/comments/${commentId}`,
      accessToken,
    );
  } catch (error) {
    console.error('Error fetching comment from network', error);
    return null;
  }
};

export const deleteCommentDB = createAsyncThunk(
  'contentData/deleteCommentDB',
  async (comment: Comment) => {
    try {
      await db.deleteCommentByIdOrUuid(comment);
    } catch (error) {
      console.error('Failed to delete comment from local DB', error);
      return [];
    }
    return comment;
  },
);

interface DeleteCommentNetworkParams {
  comment: Comment;
  accessToken: string;
  owner: string;
  repositoryName: string;
}

export const deleteCommentNetwork = createAsyncThunk(
  'contentData/deleteComment',
  async ({
    comment,
    accessToken,
    owner,
    repositoryName,
  }: DeleteCommentNetworkParams) => {
    if (!comment) {
      return null;
    }
    try {
      await apiDelete(
        `/repos/${owner}/${repositoryName}/issues/comments/${comment.id}`,
        accessToken,
      );
    } catch (error) {
      console.error('Failed to delete comment from network', error);
      return null;
    }
    return comment;
  },
);

interface UpdateCommentNetworkParams {
  comment: Comment;
  accessToken: string;
  owner: string;
  repositoryName: string;
}

export const updateCommentNetwork = createAsyncThunk(
  'contentData/updateCommentNetwork',
  async ({
    comment,
    accessToken,
    owner,
    repositoryName,
  }: UpdateCommentNetworkParams) => {
    if (!comment) {
      return null;
    }
    try {
      await apiPatch(
        `/repos/${owner}/${repositoryName}/issues/comments/${comment.id}`,
        { body: comment.body },
        accessToken,
      );
    } catch (error) {
      console.error('Failed to update comment from network', error);
      return null;
    }
    return comment;
  },
);

export const updateCommentDB = createAsyncThunk(
  'contentData/updateCommentDB',
  async (comment: Comment) => {
    try {
      await db.updateCommentByIdOrUuid(comment, {
        body: comment.body ?? '',
        updated_at: comment.updated_at ?? new Date().toISOString(),
        dirty: comment.dirty ?? false,
        sync_status: comment.sync_status ?? 'synced',
      });
    } catch (error) {
      console.error('Failed to update comment from local DB', error);
      return [];
    }
    return comment;
  },
);
