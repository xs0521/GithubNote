import { createAsyncThunk } from '@reduxjs/toolkit';
import { Issue } from '@const/index';
import * as db from '@db/index';
import { apiGet } from '@/renderer/server/API';
import log from 'electron-log/renderer';

export const fetchIssues = createAsyncThunk(
  'contentData/fetchIssues',
  async ({
    accessToken,
    owner,
    repositoryName,
    userId,
    repositoryId,
  }: {
    accessToken: string;
    owner: string;
    repositoryName: string;
    userId: number;
    repositoryId: string;
  }) => {
    if (!accessToken) {
      log.warn('No access token found', { repositoryName });
      return [];
    }
    if (!owner) {
      log.warn('No owner found', { repositoryName });
      return [];
    }
    if (!userId) {
      log.warn('No userId found', { repositoryName });
      return [];
    }
    if (!repositoryId) {
      log.warn('No repositoryId found', { repositoryName });
      return [];
    }
    if (!repositoryName) {
      log.warn('No repositoryName found');
      return [];
    }
    const issues = await apiGet<Issue[]>(
      `/repos/${owner}/${repositoryName}/issues`,
      accessToken,
      {
        params: {
          page: 1,
          per_page: 100,
        },
      },
    );
    const rows = issues.map((item: any) => ({
      ...item,
      id: String(item.id),
      body: item.body || '',
      user_id: userId,
      repository_id: String(repositoryId),
      labels: (item.labels ?? []).map((l: any) => ({
        id: String(l.id),
        name: l.name,
        color: l.color,
      })),
    }));
    return rows;
  },
);

export const fetchIssuesFromDB = createAsyncThunk(
  'contentData/fetchIssuesFromDB',
  async ({
    userId,
    repositoryId,
  }: {
    userId: number;
    repositoryId: string;
  }) => {
    if (!userId) {
      log.warn('User ID is required');
      return [];
    }
    if (!repositoryId) {
      log.warn('Repository ID is required');
      return [];
    }

    try {
      const rows = await db.getIssuesByRepo(userId, repositoryId);
      return rows.filter((item) => item.state === 'open');
    } catch (error) {
      log.error('Error fetching issues from DB', error);
      return [];
    }
  },
);

export const saveIssues = createAsyncThunk(
  'contentData/saveIssues',
  async (issues: Issue[]) => {
    try {
      await db.saveIssues(issues);
      return issues;
    } catch (error) {
      log.error('Error saving issues', error);
      return [];
    }
  },
);
