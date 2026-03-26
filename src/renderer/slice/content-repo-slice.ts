import { createAsyncThunk } from '@reduxjs/toolkit';
import { Repository } from '@const/index';
import * as db from '@db/index';
import { apiGet } from '@/renderer/server/API';
import log from 'electron-log/renderer';

export const fetchRepositories = createAsyncThunk(
  'contentData/fetchRepositories',
  async ({ accessToken, userId }: { accessToken: string; userId: number }) => {
    if (!accessToken) {
      log.warn('No access token found');
      return [];
    }
    if (!userId) {
      log.warn('No userId found');
      return [];
    }
    const repositories = await apiGet<Repository[]>('/user/repos', accessToken);
    const rows = repositories.map((item: Repository) => ({
      ...item,
      id: String(item.id),
      language: item.language || 'unknown',
      user_id: userId,
    }));
    return rows;
  },
);

export const fetchRepositoriesFromDB = createAsyncThunk(
  'contentData/fetchRepositoriesFromDB',
  async (userId: number | null) => {
    if (!userId) {
      log.warn('User ID is required');
      return [];
    }
    try {
      return await db.getRepositoriesByUser(userId);
    } catch (error) {
      log.error('Error fetching repositories from DB', error);
      return [];
    }
  },
);

export const saveRepositories = createAsyncThunk(
  'contentData/saveRepositories',
  async (repositories: Repository[]) => {
    try {
      await db.saveRepositories(repositories);
      return repositories;
    } catch (error) {
      log.error('Error saving repositories', error);
      return [];
    }
  },
);
