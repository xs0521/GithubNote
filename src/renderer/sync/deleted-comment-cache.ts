import * as db from '@db/index';
import log from 'electron-log/renderer';

const deletedCommentsByUser = new Map<number, Set<string>>();

export function markDeletedComment(userId: number, commentId: string): void {
  if (!userId || !commentId) {
    return;
  }
  const key = String(commentId);
  const existing = deletedCommentsByUser.get(userId);
  if (existing) {
    existing.add(key);
  } else {
    deletedCommentsByUser.set(userId, new Set([key]));
  }
  // persist to DB — fire and forget
  db.saveDeletedComment(userId, key).catch((err) =>
    log.error('Failed to persist deleted comment', err),
  );
}

export async function loadDeletedCommentsFromDB(userId: number): Promise<void> {
  const ids = await db.loadDeletedCommentIds(userId);
  if (ids.length === 0) {
    return;
  }
  const existing = deletedCommentsByUser.get(userId);
  if (existing) {
    ids.forEach((id) => existing.add(id));
  } else {
    deletedCommentsByUser.set(userId, new Set(ids));
  }
}

export function isDeletedComment(userId: number, commentId: string): boolean {
  if (!userId || !commentId) {
    return false;
  }
  return deletedCommentsByUser.get(userId)?.has(String(commentId)) ?? false;
}

export function clearDeletedComments(userId?: number): void {
  if (typeof userId === 'number') {
    deletedCommentsByUser.delete(userId);
    db.clearDeletedCommentsFromDB(userId).catch((err) =>
      log.error('Failed to clear deleted comments from DB', err),
    );
    return;
  }
  deletedCommentsByUser.clear();
}
