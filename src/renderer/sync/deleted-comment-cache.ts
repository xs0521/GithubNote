const deletedCommentsByUser = new Map<number, Set<string>>();

export function markDeletedComment(userId: number, commentId: string): void {
  if (!userId || !commentId) {
    return;
  }
  const key = String(commentId);
  const existing = deletedCommentsByUser.get(userId);
  if (existing) {
    existing.add(key);
    return;
  }
  deletedCommentsByUser.set(userId, new Set([key]));
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
    return;
  }
  deletedCommentsByUser.clear();
}
