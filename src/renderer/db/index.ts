import Dexie, { Table } from 'dexie';
import { Repository, Issue, Comment } from '@const/index';

const DB_NAME = 'gitnoteDB';
const DB_VERSION = 1;

export interface SyncMeta {
  id: string;
  user_id: number;
  repository_id: string;
  issue_id: string;
  last_sync_at: string;
  scope: string;
}

class GitnoteDB extends Dexie {
  repositories!: Table<Repository, string>;

  issues!: Table<Issue, string>;

  comments!: Table<Comment, string>;

  sync_meta!: Table<SyncMeta, string>;

  constructor() {
    super(DB_NAME);
    this.version(DB_VERSION).stores({
      repositories: 'id, user_id, updated_at, [user_id+id]',
      issues:
        'id, user_id, repository_id, state, updated_at, [user_id+repository_id], [user_id+repository_id+state]',
      comments:
        'id, uuid, user_id, repository_id, issue_id, updated_at, [user_id+repository_id+issue_id]',
      sync_meta:
        'id, user_id, repository_id, issue_id, scope, [user_id+repository_id+issue_id+scope]',
    });
  }
}

export const db = new GitnoteDB();

let isInitialized = false;

export async function initDB(): Promise<boolean> {
  try {
    if (isInitialized) {
      return true;
    }
    await db.open();
    isInitialized = true;
    console.log('Database initialized successfully');
    return true;
  } catch (error) {
    console.error('Failed to initialize database:', error);
    return false;
  }
}

export async function close(): Promise<void> {
  try {
    if (isInitialized) {
      db.close();
      isInitialized = false;
      console.log('Database closed successfully');
    }
  } catch (error) {
    console.error('Failed to close database:', error);
    throw error;
  }
}

export function isDBInitialized(): boolean {
  return isInitialized;
}

export function buildSyncId(
  scope: string,
  userId: number,
  repositoryId: string,
  issueId: string = '',
): string {
  return `${scope}:${userId}:${repositoryId}:${issueId}`;
}

export async function getRepositoriesByUser(
  userId: number,
): Promise<Repository[]> {
  if (!isInitialized) {
    return [];
  }
  return await db.repositories.where('user_id').equals(userId).toArray();
}

export async function saveRepositories(
  repositories: Repository[],
): Promise<void> {
  if (!isInitialized) {
    return;
  }
  await db.repositories.bulkPut(repositories);
}

export async function deleteRepositoryById(
  repositoryId: string,
): Promise<void> {
  if (!isInitialized) {
    return;
  }
  await db.repositories.delete(String(repositoryId));
}

export async function getIssuesByRepo(
  userId: number,
  repositoryId: string,
): Promise<Issue[]> {
  if (!isInitialized) {
    return [];
  }
  return await db.issues
    .where('[user_id+repository_id]')
    .equals([userId, repositoryId])
    .toArray();
}

export async function saveIssues(issues: Issue[]): Promise<void> {
  if (!isInitialized) {
    return;
  }
  await db.issues.bulkPut(issues);
}

export async function deleteIssuesByRepositoryId(
  userId: number,
  repositoryId: string,
): Promise<void> {
  if (!isInitialized) {
    return;
  }
  const ids = await db.issues
    .where('[user_id+repository_id]')
    .equals([userId, repositoryId])
    .primaryKeys();
  if (ids.length > 0) {
    await db.issues.bulkDelete(ids);
  }
}

export async function getCommentsByIssue(
  userId: number,
  repositoryId: string,
  issueId: string,
): Promise<Comment[]> {
  if (!isInitialized) {
    return [];
  }
  return await db.comments
    .where('[user_id+repository_id+issue_id]')
    .equals([userId, repositoryId, issueId])
    .toArray();
}

export async function saveComments(comments: Comment[]): Promise<void> {
  if (!isInitialized) {
    return;
  }
  await db.comments.bulkPut(comments);
}

export async function deleteCommentsByRepositoryId(
  userId: number,
  repositoryId: string,
): Promise<void> {
  if (!isInitialized) {
    return;
  }
  const ids = await db.comments
    .where('repository_id')
    .equals(repositoryId)
    .and((item) => item.user_id === userId)
    .primaryKeys();
  if (ids.length > 0) {
    await db.comments.bulkDelete(ids);
  }
}

export async function deleteCommentByIdOrUuid(
  comment: Comment,
): Promise<void> {
  if (!isInitialized) {
    return;
  }
  if (comment.id) {
    await db.comments.delete(comment.id);
    return;
  }
  if (comment.uuid) {
    await db.comments.where('uuid').equals(comment.uuid).delete();
  }
}

export async function deleteIssueById(issueId: string): Promise<void> {
  if (!isInitialized) {
    return;
  }
  await db.issues.delete(String(issueId));
}

export async function deleteSyncMetaByRepositoryId(
  userId: number,
  repositoryId: string,
): Promise<void> {
  if (!isInitialized) {
    return;
  }
  const ids = await db.sync_meta
    .where('repository_id')
    .equals(repositoryId)
    .and((item) => item.user_id === userId)
    .primaryKeys();
  if (ids.length > 0) {
    await db.sync_meta.bulkDelete(ids);
  }
}

export async function updateCommentByIdOrUuid(
  comment: Comment,
  changes: Partial<Comment>,
): Promise<void> {
  if (!isInitialized) {
    return;
  }
  if (comment.id) {
    const updated = await db.comments.update(String(comment.id), changes);
    if (updated > 0) {
      console.log('db update comment by id', {
        id: String(comment.id),
        changes,
      });
      return;
    }
  }
  if (comment.uuid) {
    console.log('db update comment by uuid', {
      uuid: comment.uuid,
      changes,
    });
    await db.comments.where('uuid').equals(comment.uuid).modify(changes);
  }
}

export async function getSyncMeta(
  scope: string,
  userId: number,
  repositoryId: string,
  issueId: string,
): Promise<SyncMeta | undefined> {
  if (!isInitialized) {
    return undefined;
  }
  const id = buildSyncId(scope, userId, repositoryId, issueId);
  return await db.sync_meta.get(id);
}

export async function setSyncMeta(meta: SyncMeta): Promise<void> {
  if (!isInitialized) {
    return;
  }
  await db.sync_meta.put(meta);
}
