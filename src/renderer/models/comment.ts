import { DataFetchModel } from '@models/base';
import log from 'electron-log/renderer';
import { FetchCommentsConfig, FetchDataType } from '@models/model';
import {
  fetchComments,
  fetchCommentsFromDB,
  saveCommentsDB,
} from '@slice/content-comment-slice';
import { updateComments, updateSelectedComment } from '@slice/content-slice';
import { updateIsCommentsLoading } from '@slice/setting-slice';
import { Comment } from '@const/index';
import * as db from '@db/index';
import { markDeletedComment } from '@/renderer/sync/deleted-comment-cache';
import { apiDelete, apiPatch, apiPost } from '@/renderer/server/API';

class DataCommentFetchModel extends DataFetchModel {
  // 从网络获取评论数据
  private async fetchNetworkCommentsData(
    config: FetchCommentsConfig,
  ): Promise<Comment[]> {
    log.info('fetchNetworkCommentsData', { issueNumber: config.issueNumber });
    this.dispatch(updateIsCommentsLoading(true));
    const fetchedComments = await this.dispatch(
      fetchComments({
        accessToken: config.accessToken,
        owner: config.owner,
        repositoryName: config.repositoryName,
        issueNumber: config.issueNumber,
        userId: config.userId,
        repositoryId: config.repositoryId,
        issueId: config.issueId,
      }),
    ).unwrap();
    this.dispatch(updateIsCommentsLoading(false));
    log.info('fetchNetworkCommentsData result count', fetchedComments.length);
    return fetchedComments;
  }

  // 从数据库获取评论数据
  private async fetchDBCommentsData(
    config: FetchCommentsConfig,
  ): Promise<Comment[]> {
    const values = await this.dispatch(
      fetchCommentsFromDB({
        userId: config.userId,
        repositoryId: config.repositoryId,
        issueId: config.issueId,
      }),
    ).unwrap();
    return values;
  }

  // 获取并保存评论数据
  async fetchAndSaveCommentsData(
    ignoreCache: boolean,
    config: FetchCommentsConfig,
  ): Promise<void> {
    await this.fetchAndSaveData(
      FetchDataType.Comments,
      ignoreCache,
      () => this.fetchNetworkCommentsData(config),
      () => this.fetchDBCommentsData(config),
      saveCommentsDB,
      updateComments,
    );
  }

  async deleteComment(
    config: FetchCommentsConfig,
    comment: Comment,
  ): Promise<void> {
    const { accessToken, owner, repositoryName } = config;

    if (!comment) {
      return;
    }

    if (comment.id && !String(comment.id).startsWith('local:')) {
      markDeletedComment(config.userId, String(comment.id));
    }

    const remoteCommentId = Number(comment.id);
    const shouldDeleteRemote =
      Boolean(accessToken) &&
      Boolean(owner) &&
      Boolean(repositoryName) &&
      !Number.isNaN(remoteCommentId);

    if (shouldDeleteRemote) {
      try {
        await apiDelete(
          `/repos/${owner}/${repositoryName}/issues/comments/${remoteCommentId}`,
          accessToken,
        );
      } catch (error: any) {
        const status = error?.response?.status;
        if (status !== 404) {
          log.error('Failed to delete comment from GitHub', error);
          return;
        }
        log.warn('Comment already removed on GitHub, continue local delete');
      }
    }

    try {
      await db.deleteCommentByIdOrUuid(comment);
    } catch (error) {
      log.error('Failed to delete comment from local DB', error);
    }

    const state = this.getState();
    const updatedComments = state.contentData.comments.filter((item) => {
      if (comment.id) {
        return item.id !== comment.id;
      }
      return item.uuid !== comment.uuid;
    });
    this.dispatch(updateComments(updatedComments));

    const selected = state.contentData.selectedComment;
    const isDeletingSelected = selected
      ? comment.id
        ? selected.id === comment.id
        : selected.uuid === comment.uuid
      : false;
    if (isDeletingSelected) {
      this.dispatch(updateSelectedComment(null));
    }
  }

  async uploadComment(
    config: FetchCommentsConfig,
    comment: Comment,
  ): Promise<void> {
    const {
      accessToken,
      owner,
      repositoryName,
      issueNumber,
      userId,
      repositoryId,
      issueId,
    } = config;

    if (!comment) {
      return;
    }

    if (!accessToken || !owner || !repositoryName) {
      log.warn('Missing required configuration to upload comment');
      return;
    }

    try {
      const remoteCommentId = Number(comment.id);
      let response;
      if (comment.id && !Number.isNaN(remoteCommentId)) {
        response = await apiPatch(
          `/repos/${owner}/${repositoryName}/issues/comments/${remoteCommentId}`,
          {
            body: comment.body,
          },
          accessToken,
        );
      } else {
        response = await apiPost(
          `/repos/${owner}/${repositoryName}/issues/${issueNumber}/comments`,
          {
            body: comment.body,
          },
          accessToken,
        );
      }

      const payload = response;
      const normalizedComment: Comment = {
        id: String(payload.id),
        url: payload.url,
        html_url: payload.html_url,
        issue_url: payload.issue_url,
        node_id: payload.node_id,
        created_at: payload.created_at,
        updated_at: payload.updated_at,
        body: payload.body,
        uuid: comment.uuid || '',
        user_id: userId,
        repository_id: repositoryId,
        issue_id: issueId,
      };

      await this.dispatch(saveCommentsDB([normalizedComment]));

      const state = this.getState();
      const currentComments = state.contentData.comments;
      const existingIndex = currentComments.findIndex((item) =>
        normalizedComment.id
          ? item.id === normalizedComment.id
          : item.uuid === normalizedComment.uuid,
      );

      if (existingIndex >= 0) {
        const nextComments = [...currentComments];
        nextComments[existingIndex] = normalizedComment;
        this.dispatch(updateComments(nextComments));
      } else {
        this.dispatch(updateComments([...currentComments, normalizedComment]));
      }

      const selected = state.contentData.selectedComment;
      const isSelected = selected
        ? normalizedComment.id
          ? selected.id === normalizedComment.id
          : selected.uuid === normalizedComment.uuid
        : false;
      if (isSelected) {
        this.dispatch(updateSelectedComment(normalizedComment));
      }
    } catch (error) {
      log.error('Failed to upload comment to GitHub', error);
    }
  }
}

export default DataCommentFetchModel;
