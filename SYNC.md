# Sync Spec

This document defines the minimal sync rules for GitNote.

## Data Model
- Repository = workspace
- Issue = notebook
- Comment = note

## Goals
- Incremental sync with "last write wins"
- Startup forces a sync and continues in the background (30s interval)
- Offline create for comments only
- No PR filtering requirement

## Local State Fields
- comment.uuid: local identifier for offline notes
- comment.dirty: boolean (true if local content is newer than remote)
- comment.sync_status: "pending" | "synced" | "failed"
- sync_meta.last_sync_at: scoped by user + repo (+ issue) and sync scope
  - repo_issues scope for Issues sync
  - issue_comments scope for Comments sync

## Startup Sync (Force)
1) For each repo:
   - Pull issues with `since=repo_last_sync_at` (handle pagination).
   - Upsert local issues using `updated_at` (remote wins if newer).
   - Update `repo_last_sync_at = max(updated_at)`.
2) For each issue:
   - Pull comments with `since=issue_last_sync_at` (handle pagination).
   - Upsert local comments using `updated_at` (remote wins if newer).
   - Update `issue_last_sync_at = max(updated_at)`.

## Auto Sync Interval
- After startup, run sync every 30 seconds.

## Comment Edit Sync (Online)
- On content change, set `dirty=true`, `sync_status=pending`.
- Debounce (~2.5s) and only PATCH if content differs from last synced body.
- On success:
  - Replace local comment with server payload (authoritative `updated_at`).
  - Set `dirty=false`, `sync_status=synced`.
- On failure:
  - Keep `dirty=true`, `sync_status=failed`.

## Comment Create Sync (Offline Allowed)
- Offline create:
  - Generate `uuid`, store comment locally with `dirty=true`, `sync_status=pending`.
- Online sync pass:
  - POST pending comments, then replace local row with server payload.
  - Clear `dirty` and mark `synced`.

## Issue Create Sync (Online Only)
- Issues must be created online to obtain `id` and `number`.
- If offline, block creation with UI feedback.

## Conflict Resolution
- "Last write wins" using `updated_at`.
- No conflict copies or merges.

## Deletion
- GitHub does not provide deletion via `since`.
- Current behavior:
  - Local delete removes DB entry; 404 from GitHub delete still removes locally.
  - An in-memory deleted-id set prevents re-insert during the session.
  - Periodic full scan is not implemented.

## Pagination
- Always follow pagination for issues/comments even with `since`.

## Error Handling
- Retry with backoff for network/rate limits (not implemented yet).
- Do not update `last_sync_at` on failed sync.
- 404 responses are treated as empty results at API layer.
- 401 responses clear local auth and return to login.

## Multi-Account Isolation
- Scope `repo_last_sync_at` and `issue_last_sync_at` by user + repo (+ issue).
