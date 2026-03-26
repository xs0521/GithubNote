# Sync 机制已知问题

## 问题列表

### 1. ✅ 并发冲突：手动同步不检查 `isSyncing` 标志（已修复）

`syncSelectedRepo()` 和 `syncSelectedIssue()` 是公共方法，不检查 `isSyncing`，只有 `runSync()` 才检查。
手动触发的同步可以和 30 秒自动同步同时运行，可能导致数据重复写入或状态混乱。

**修复方案**：在公共方法入口统一检查并设置 `isSyncing`。

---

### 2. ✅ `hasSyncedRepositories` 在请求成功前就设为 `true`（已修复）

`src/renderer/sync/index.ts:284`

```ts
this.hasSyncedRepositories = true;  // 先标记
await this.syncRepositories(...);    // 才执行
```

如果启动时请求失败，这个标志已经是 `true`，后续不会重试。

---

### 3. ✅ Repository 同步没有增量机制（已修复）

Issues 和 Comments 都用 `since` 参数做增量同步，但 Repositories 每次都全量拉取（`/user/repos` 所有页），
对仓库数量多的用户压力较大，也更容易触发 GitHub Rate Limit。

---

### 4. ✅ Issues 加载状态每 30 秒触发一次 UI 更新（已修复）

`syncIssuesForRepo` 没有 `showLoading` 参数控制，每次调用都会 dispatch `updateIsIssuesLoading(true/false)`，
包括后台自动同步，每 30 秒触发一次 Redux 状态变化和 UI re-render。

---

### 5. 本地脏数据可能被远端覆盖（时钟偏差）

冲突处理逻辑只有当本地时间 >= 远端时间时才保留本地修改。
如果用户设备时钟落后，即使本地有未保存的 `dirty` 改动，也会被远端覆盖，造成数据丢失。

---

### 6. 已删除评论的缓存仅存在于内存中

`deleted-comment-cache.ts` 是纯内存缓存，应用重启后清空。
重启后、下次 GitHub 真正处理删除之前，被本地删除的评论可能会重新出现在列表中。

---

### 7. 单例不会在登出时重置

```ts
let sharedSyncManager: SyncManager | null = null;
```

调用 `stop()` 后 `sharedSyncManager` 仍保持引用，登出再登入会复用同一个实例，
其中 `hasSyncedRepositories` 等状态不会重置，可能导致切换账号后行为异常。

---

### 8. 没有 GitHub Rate Limit 处理

每 30 秒同步一次，遇到 GitHub 返回 `403/429` 时没有退避策略，
会持续消耗 Rate Limit 直到彻底被限流。

---

## 优先级

| 严重程度 | 问题 |
|---------|------|
| 高 | #5 本地 dirty 数据被覆盖（数据丢失） |
| 高 | #1 手动/自动同步并发竞争 |
| 中 | #7 单例登出不重置 |
| 中 | #2 `hasSyncedRepositories` 提前标记 |
| 低 | #3 Repository 无增量同步 |
| 低 | #6 删除缓存内存限制 |
| 低 | #8 无 Rate Limit 退避 |
