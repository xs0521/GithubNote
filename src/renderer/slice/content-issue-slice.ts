import { createAsyncThunk } from '@reduxjs/toolkit';
import { Issue } from '@const/index';
import * as db from '@db/index';
import { apiGet } from '@/renderer/server/API';

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
      console.warn('No access token found', repositoryName);
      return [];
    }
    if (!owner) {
      console.warn('No owner found', repositoryName);
      return [];
    }
    if (!userId) {
      console.warn('No userId found', repositoryName);
      return [];
    }
    if (!repositoryId) {
      console.warn('No repositoryId found', repositoryName);
      return [];
    }
    if (!repositoryName) {
      console.warn('No repositoryName found');
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
    const rows = issues.map((item: Issue) => ({
      ...item,
      id: String(item.id),
      body: item.body || '',
      user_id: userId,
      repository_id: String(repositoryId),
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
      console.warn('User ID is required');
      return [];
    }
    if (!repositoryId) {
      console.warn('Repository ID is required');
      return [];
    }

    try {
      const rows = await db.getIssuesByRepo(userId, repositoryId);
      return rows.filter((item) => item.state === 'open');
    } catch (error) {
      console.error('Error fetching issues from DB', error);
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
      console.error('Error saving issues', error);
      return [];
    }
  },
);
