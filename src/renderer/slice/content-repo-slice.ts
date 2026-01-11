import { createAsyncThunk } from '@reduxjs/toolkit';
import { Repository } from '@const/index';
import * as db from '@db/index';
import { apiGet } from '@/renderer/server/API';

export const fetchRepositories = createAsyncThunk(
  'contentData/fetchRepositories',
  async ({ accessToken, userId }: { accessToken: string; userId: number }) => {
    if (!accessToken) {
      console.warn('No access token found');
      return [];
    }
    if (!userId) {
      console.warn('No userId found', accessToken);
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
      console.warn('User ID is required');
      return [];
    }
    try {
      return await db.getRepositoriesByUser(userId);
    } catch (error) {
      console.error('Error fetching repositories from DB', error);
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
      console.error('Error saving repositories', error);
      return [];
    }
  },
);
