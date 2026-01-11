import { AppDispatch, RootState } from '@redux/index';
import { Repository, Issue, Comment } from '@const/index';
import * as db from '@db/index';
import { apiPatch, apiPost, fetchPaged } from '@/renderer/server/API';
import {
  updateRepositories,
  updateIssues,
  updateComments,
  updateSelectedComment,
} from '@slice/content-slice';
import {
  updateIsRepositoriesLoading,
  updateIsIssuesLoading,
  updateIsCommentsLoading,
  updateLastSyncAt,
} from '@slice/setting-slice';
import { isDeletedComment } from './deleted-comment-cache';

const SYNC_SCOPE_REPO_ISSUES = 'repo_issues';
const SYNC_SCOPE_ISSUE_COMMENTS = 'issue_comments';
const SYNC_SCOPE_APP_LAST = 'app_last_sync';

async function getLastSyncAt(
  scope: string,
  userId: number,
  repositoryId: string,
  issueId: string = '',
): Promise<Date | null> {
  const meta = await db.getSyncMeta(scope, userId, repositoryId, issueId);
  return meta?.last_sync_at ? new Date(meta.last_sync_at) : null;
}

async function setLastSyncAt(
  scope: string,
  userId: number,
  repositoryId: string,
  issueId: string,
  lastSyncAt: Date,
): Promise<void> {
  await db.setSyncMeta({
    id: db.buildSyncId(scope, userId, repositoryId, issueId),
    user_id: userId,
    repository_id: repositoryId,
    issue_id: issueId,
    last_sync_at: lastSyncAt.toISOString(),
    scope,
  });
}

function normalizeSince(lastSyncAt: Date | null): Date | null {
  if (!lastSyncAt) {
    return null;
  }
  const now = new Date();
  if (lastSyncAt.getTime() > now.getTime()) {
    console.warn('sync since is in the future, ignoring', {
      since: lastSyncAt.toISOString(),
      now: now.toISOString(),
    });
    return null;
  }
  return lastSyncAt;
}

function toDate(value: string | Date): Date {
  return value instanceof Date ? value : new Date(value);
}

export class SyncManager {
  private dispatch: AppDispatch;
  private getState: () => RootState;
  private timer: NodeJS.Timeout | null = null;
  private isSyncing = false;

  constructor(dispatch: AppDispatch, getState: () => RootState) {
    this.dispatch = dispatch;
    this.getState = getState;
  }

  start(): void {
    if (this.timer) {
      return;
    }
    this.loadAppLastSyncAt();
    this.runSync();
    this.timer = setInterval(() => {
      this.runSync();
    }, 30000);
  }

  stop(): void {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }

  async syncSelectedRepo(): Promise<void> {
    const state = this.getState();
    const userInfo = state.userData.userInfo;
    const selectedRepository = state.contentData.selectedRepository;
    if (!userInfo || !selectedRepository) {
      return;
    }
    await this.syncIssuesForRepo(
      userInfo.access_token,
      userInfo.login,
      userInfo.id,
      {
        ...selectedRepository,
        id: String(selectedRepository.id),
      },
    );
  }

  async syncSelectedIssue(): Promise<void> {
    const state = this.getState();
    const userInfo = state.userData.userInfo;
    const selectedRepository = state.contentData.selectedRepository;
    const selectedIssue = state.contentData.selectedIssue;
    if (!userInfo || !selectedRepository || !selectedIssue) {
      return;
    }
    const hasLocalData = await this.loadCommentsFromDB(
      userInfo.id,
      selectedRepository,
      {
        ...selectedIssue,
        id: String(selectedIssue.id),
      },
    );
    await this.syncCommentsForIssue(
      userInfo.access_token,
      userInfo.login,
      userInfo.id,
      selectedRepository,
      {
        ...selectedIssue,
        id: String(selectedIssue.id),
      },
      !hasLocalData,
    );
  }

  private async runSync(): Promise<void> {
    if (this.isSyncing) {
      return;
    }
    const state = this.getState();
    if (!state.settingData.isDBInitialized) {
      return;
    }
    const userInfo = state.userData.userInfo;
    if (!userInfo || !userInfo.access_token) {
      return;
    }

    this.isSyncing = true;
    try {
      await this.syncRepositories(userInfo.access_token, userInfo.id);

      const selectedRepository = this.getState().contentData.selectedRepository;
      if (selectedRepository) {
        await this.syncIssuesForRepo(
          userInfo.access_token,
          userInfo.login,
          userInfo.id,
          {
            ...selectedRepository,
            id: String(selectedRepository.id),
          },
        );
      }

      const selectedIssue = this.getState().contentData.selectedIssue;
      if (selectedRepository && selectedIssue) {
        await this.syncCommentsForIssue(
          userInfo.access_token,
          userInfo.login,
          userInfo.id,
          selectedRepository,
          {
            ...selectedIssue,
            id: String(selectedIssue.id),
          },
          false,
        );
      }

      const now = new Date();
      this.dispatch(updateLastSyncAt(now.toISOString()));
      await setLastSyncAt(SYNC_SCOPE_APP_LAST, userInfo.id, '', '', now);
    } catch (error) {
      console.error('Auto sync failed', error);
    } finally {
      this.isSyncing = false;
    }
  }

  private async syncRepositories(
    accessToken: string,
    userId: number,
  ): Promise<void> {
    this.dispatch(updateIsRepositoriesLoading(true));
    try {
      const repositories = await fetchPaged<Repository>(
        '/user/repos',
        accessToken,
        {},
      );
      const rows = repositories.map((item) => ({
        ...item,
        id: String(item.id),
        language: item.language || 'unknown',
        user_id: userId,
      }));
      await db.saveRepositories(rows);

      const dbRows = await db.getRepositoriesByUser(userId);
      this.dispatch(updateRepositories(dbRows));
    } finally {
      this.dispatch(updateIsRepositoriesLoading(false));
    }
  }

  private async syncIssuesForRepo(
    accessToken: string,
    owner: string,
    userId: number,
    repository: Repository,
  ): Promise<void> {
    this.dispatch(updateIsIssuesLoading(true));
    try {
      const lastSyncAt = normalizeSince(
        await getLastSyncAt(
          SYNC_SCOPE_REPO_ISSUES,
          userId,
          String(repository.id),
        ),
      );

      const issues = await fetchPaged<Issue>(
        `/repos/${owner}/${repository.name}/issues`,
        accessToken,
        {
          since: lastSyncAt ? lastSyncAt.toISOString() : undefined,
          state: 'open',
        },
      );

      const existingRows = await db.getIssuesByRepo(
        userId,
        String(repository.id),
      );
      const existingMap = new Map(
        existingRows.map((item) => [String(item.id), item]),
      );

      const rowsToSave = issues.map((item) => {
        const existing = existingMap.get(String(item.id));
        const updatedAt = toDate(item.updated_at);
        if (existing && toDate(existing.updated_at) >= updatedAt) {
          return null;
        }
        return {
          ...item,
          id: String(item.id),
          body: item.body || '',
          user_id: userId,
          repository_id: String(repository.id),
        } as Issue;
      });

      const filteredRows = rowsToSave.filter(Boolean) as Issue[];
      if (filteredRows.length > 0) {
        await db.saveIssues(filteredRows);
      }

      const dbRows = await db.getIssuesByRepo(
        userId,
        String(repository.id),
      );
      this.dispatch(
        updateIssues(dbRows.filter((item) => item.state === 'open')),
      );

      const maxUpdatedAt = issues.reduce<Date | null>((max, item) => {
        const current = toDate(item.updated_at);
        if (!max || current > max) {
          return current;
        }
        return max;
      }, lastSyncAt);

      if (maxUpdatedAt) {
        await setLastSyncAt(
          SYNC_SCOPE_REPO_ISSUES,
          userId,
          String(repository.id),
          '',
          maxUpdatedAt,
        );
      }
    } finally {
      this.dispatch(updateIsIssuesLoading(false));
    }
  }

  private async syncCommentsForIssue(
    accessToken: string,
    owner: string,
    userId: number,
    repository: Repository,
    issue: Issue,
    showLoading: boolean,
  ): Promise<void> {
    if (showLoading) {
      this.dispatch(updateIsCommentsLoading(true));
    }
    try {
      console.log('sync comments start', {
        repo: repository.name,
        issueId: issue.id,
        issueNumber: issue.number,
        showLoading,
      });
      await this.pushPendingComments(
        accessToken,
        owner,
        userId,
        repository,
        issue,
      );

      const lastSyncAt = normalizeSince(
        await getLastSyncAt(
          SYNC_SCOPE_ISSUE_COMMENTS,
          userId,
          String(repository.id),
          String(issue.id),
        ),
      );

      const comments = await fetchPaged<Comment>(
        `/repos/${owner}/${repository.name}/issues/${issue.number}/comments`,
        accessToken,
        {
          since: lastSyncAt ? lastSyncAt.toISOString() : undefined,
        },
      );
      console.log('sync comments fetched', {
        count: comments.length,
        since: lastSyncAt?.toISOString() || null,
      });

      const existingRows = await db.getCommentsByIssue(
        userId,
        String(repository.id),
        String(issue.id),
      );

      const existingMap = new Map(
        existingRows.map((item) => [String(item.id), item]),
      );

      const filteredComments = comments.filter((item) => {
        const commentId = String(item.id);
        if (isDeletedComment(userId, commentId)) {
          console.error('sync comments skip deleted comment', {
            id: commentId,
            repositoryId: repository.id,
            issueId: issue.id,
          });
          return false;
        }
        return true;
      });

      const rowsToSave = filteredComments.map((item) => {
        const existing = existingMap.get(String(item.id));
        const updatedAt = toDate(item.updated_at);
        if (existing) {
          const existingUpdatedAt = toDate(existing.updated_at);
          if (existing.dirty && existingUpdatedAt >= updatedAt) {
            return null;
          }
          if (existingUpdatedAt >= updatedAt) {
            return null;
          }
        }
        return {
          ...item,
          user_id: userId,
          id: String(item.id),
          repository_id: String(repository.id),
          issue_id: String(issue.id),
          uuid: existing?.uuid || item.uuid || '',
          dirty: false,
          sync_status: 'synced',
        } as Comment;
      });

      const filteredRows = rowsToSave.filter(Boolean) as Comment[];
      if (filteredRows.length > 0) {
        await db.saveComments(filteredRows);
        console.log('sync comments saved', { count: filteredRows.length });
      }

      const dbRows = await db.getCommentsByIssue(
        userId,
        String(repository.id),
        String(issue.id),
      );
      const sortedRows = [...dbRows].sort((a, b) => {
        const updatedDiff =
          new Date(String(b.updated_at)).getTime() -
          new Date(String(a.updated_at)).getTime();
        if (updatedDiff !== 0) {
          return updatedDiff;
        }
        return (
          new Date(String(b.created_at)).getTime() -
          new Date(String(a.created_at)).getTime()
        );
      });
      this.updateCommentsIfChanged(sortedRows);
      console.log('sync comments list', { count: sortedRows.length });

      const maxUpdatedAt = comments.reduce<Date | null>((max, item) => {
        const current = toDate(item.updated_at);
        if (!max || current > max) {
          return current;
        }
        return max;
      }, lastSyncAt);

      if (maxUpdatedAt) {
        await setLastSyncAt(
          SYNC_SCOPE_ISSUE_COMMENTS,
          userId,
          String(repository.id),
          String(issue.id),
          maxUpdatedAt,
        );
      }

      const state = this.getState();
      if (
        state.contentData.comments.length > 0 &&
        !state.contentData.selectedComment
      ) {
        this.dispatch(updateSelectedComment(state.contentData.comments[0]));
      } else if (state.contentData.selectedComment) {
        const selected = state.contentData.selectedComment;
        const shouldMatchByUuid =
          !selected.id || String(selected.id).startsWith('local:');
        const matched = sortedRows.find((item) =>
          shouldMatchByUuid
            ? item.uuid && item.uuid === selected.uuid
            : String(item.id) === String(selected.id),
        );
        if (
          matched &&
          (matched.body !== selected.body ||
            String(matched.id) !== String(selected.id))
        ) {
          this.dispatch(updateSelectedComment(matched));
        }
      }
    } finally {
      if (showLoading) {
        this.dispatch(updateIsCommentsLoading(false));
      }
    }
  }

  private async pushPendingComments(
    accessToken: string,
    owner: string,
    userId: number,
    repository: Repository,
    issue: Issue,
  ): Promise<void> {
    const repositoryId = String(repository.id);
    const issueId = String(issue.id);
    const pendingRows = (await db.getCommentsByIssue(
      userId,
      repositoryId,
      issueId,
    )).filter(
      (comment) =>
        comment.dirty ||
        comment.sync_status === 'pending' ||
        comment.sync_status === 'failed',
    );

    if (pendingRows.length === 0) {
      console.log('sync pending comments empty');
      return;
    }
    console.log('sync pending comments', { count: pendingRows.length });

    for (const comment of pendingRows) {
      try {
        const hasRemoteId =
          Boolean(comment.id) && !String(comment.id).startsWith('local:');
        console.log('sync pending comment attempt', {
          id: comment.id,
          uuid: comment.uuid,
          hasRemoteId,
        });
        const response = hasRemoteId
          ? await apiPatch<Comment>(
              `/repos/${owner}/${repository.name}/issues/comments/${comment.id}`,
              { body: comment.body },
              accessToken,
            )
          : await apiPost<Comment>(
              `/repos/${owner}/${repository.name}/issues/${issue.number}/comments`,
              { body: comment.body },
              accessToken,
            );

        const payload = response as Comment;
        console.log('sync pending comment success', {
          id: payload.id,
          uuid: comment.uuid,
        });
        if (comment.id && comment.id !== String(payload.id)) {
          await db.deleteCommentByIdOrUuid(comment);
        }
        const updatedRow: Comment = {
          id: String(payload.id),
          url: payload.url,
          html_url: payload.html_url,
          issue_url: payload.issue_url,
          node_id: payload.node_id,
          created_at: String(payload.created_at),
          updated_at: String(payload.updated_at),
          body: payload.body,
          uuid: comment.uuid || '',
          dirty: false,
          sync_status: 'synced',
          user_id: userId,
          repository_id: repositoryId,
          issue_id: issueId,
        };
        await db.saveComments([updatedRow]);
      } catch (error) {
        console.error('Failed to push pending comment', error);
        const failedRow: Comment = {
          ...comment,
          id: comment.id,
          dirty: true,
          sync_status: 'failed',
          user_id: userId,
          repository_id: repositoryId,
          issue_id: issueId,
        };
        await db.saveComments([failedRow]);
      }
    }
  }

  private updateCommentsIfChanged(dbRows: Comment[]): void {
    const state = this.getState();
    const currentComments = state.contentData.comments;
    const isSameComments = (() => {
      if (currentComments.length !== dbRows.length) {
        return false;
      }
      return dbRows.every((item, index) => {
        const current = currentComments[index];
        if (!current) {
          return false;
        }
        const currentKey = current.id ? String(current.id) : current.uuid;
        const nextKey = item.id ? String(item.id) : item.uuid;
        if (!currentKey || !nextKey) {
          return false;
        }
        return (
          currentKey === nextKey &&
          String(current.updated_at) === String(item.updated_at)
        );
      });
    })();
    if (!isSameComments) {
      this.dispatch(updateComments(dbRows));
    }
  }

  private async loadCommentsFromDB(
    userId: number,
    repository: Repository,
    issue: Issue,
  ): Promise<boolean> {
    const repositoryId = String(repository.id);
    const issueId = String(issue.id);
    const dbRows = await db.getCommentsByIssue(
      userId,
      repositoryId,
      issueId,
    );
    const sortedRows = [...dbRows].sort((a, b) => {
      const updatedDiff =
        new Date(String(b.updated_at)).getTime() -
        new Date(String(a.updated_at)).getTime();
      if (updatedDiff !== 0) {
        return updatedDiff;
      }
      return (
        new Date(String(b.created_at)).getTime() -
        new Date(String(a.created_at)).getTime()
      );
    });
    this.updateCommentsIfChanged(sortedRows);
    const state = this.getState();
    if (
      state.contentData.comments.length > 0 &&
      !state.contentData.selectedComment
    ) {
      this.dispatch(updateSelectedComment(state.contentData.comments[0]));
    }
    return dbRows.length > 0;
  }

  private async loadAppLastSyncAt(): Promise<void> {
    const state = this.getState();
    const userInfo = state.userData.userInfo;
    if (!userInfo || !userInfo.id) {
      return;
    }
    const lastSyncAt = await getLastSyncAt(
      SYNC_SCOPE_APP_LAST,
      userInfo.id,
      '',
      '',
    );
    if (lastSyncAt) {
      this.dispatch(updateLastSyncAt(lastSyncAt.toISOString()));
    }
  }
}

let sharedSyncManager: SyncManager | null = null;

export function getSyncManager(
  dispatch: AppDispatch,
  getState: () => RootState,
): SyncManager {
  if (!sharedSyncManager) {
    sharedSyncManager = new SyncManager(dispatch, getState);
  }
  return sharedSyncManager;
}
