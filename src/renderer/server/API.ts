import axios, { AxiosRequestConfig } from 'axios';
import { GITHUB_BASE_URL } from '@/shared/constants';
import {
  CHANNEL_ACTION_UNAUTHORIZED,
  CHANNEL_COMMON,
} from '@/shared/constants';
import log from '@/renderer/logger';

export interface ApiRequestOptions<T = unknown> extends AxiosRequestConfig<T> {
  accessToken?: string;
}

export class RateLimitError extends Error {
  resetAt: Date;

  constructor(resetAt: Date) {
    super('GitHub API rate limit exceeded');
    this.name = 'RateLimitError';
    this.resetAt = resetAt;
  }
}

export async function apiRequest<T = unknown>({
  accessToken,
  headers,
  ...config
}: ApiRequestOptions): Promise<T> {
  const mergedHeaders: Record<string, string> = {
    ...(headers as Record<string, string> | undefined),
  };
  if (accessToken) {
    mergedHeaders.Authorization = `Bearer ${accessToken}`;
  }

  try {
    const response = await axios({
      ...config,
      baseURL: config.baseURL ?? GITHUB_BASE_URL,
      headers: mergedHeaders,
    });
    return response.data as T;
  } catch (error) {
    const status = (error as any)?.response?.status;
    if (status === 401) {
      window.electron?.ipcRenderer.sendMessage(CHANNEL_COMMON, [
        CHANNEL_ACTION_UNAUTHORIZED,
      ]);
      return [] as T;
    }
    if (status === 404) {
      return [] as T;
    }
    if (status === 403 || status === 429) {
      const headers = (error as any)?.response?.headers ?? {};
      const resetUnix =
        headers['x-ratelimit-reset'] ?? headers['retry-after'];
      const resetAt = resetUnix
        ? new Date(Number(resetUnix) * 1000)
        : new Date(Date.now() + 60_000);
      throw new RateLimitError(resetAt);
    }
    log.error('API request failed', {
      url: config.url,
      method: config.method,
      status,
    });
    throw error;
  }
}

export function apiGet<T = unknown>(
  url: string,
  accessToken?: string,
  config: Omit<ApiRequestOptions, 'url' | 'method' | 'accessToken'> = {},
): Promise<T> {
  return apiRequest<T>({ ...config, url, method: 'get', accessToken });
}

export function apiPost<T = unknown>(
  url: string,
  data?: unknown,
  accessToken?: string,
  config: Omit<ApiRequestOptions, 'url' | 'method' | 'data' | 'accessToken'> = {},
): Promise<T> {
  return apiRequest<T>({ ...config, url, method: 'post', data, accessToken });
}

export function apiPatch<T = unknown>(
  url: string,
  data?: unknown,
  accessToken?: string,
  config: Omit<ApiRequestOptions, 'url' | 'method' | 'data' | 'accessToken'> = {},
): Promise<T> {
  return apiRequest<T>({ ...config, url, method: 'patch', data, accessToken });
}

export function apiPut<T = unknown>(
  url: string,
  data?: unknown,
  accessToken?: string,
  config: Omit<ApiRequestOptions, 'url' | 'method' | 'data' | 'accessToken'> = {},
): Promise<T> {
  return apiRequest<T>({ ...config, url, method: 'put', data, accessToken });
}

export function apiDelete<T = unknown>(
  url: string,
  accessToken?: string,
  config: Omit<ApiRequestOptions, 'url' | 'method' | 'accessToken'> = {},
): Promise<T> {
  return apiRequest<T>({ ...config, url, method: 'delete', accessToken });
}

export async function fetchPaged<T = unknown>(
  url: string,
  accessToken: string,
  params: Record<string, string | number | undefined> = {},
  shouldStop?: (page: T[]) => boolean,
): Promise<T[]> {
  const results: T[] = [];
  let page = 1;
  const perPage = 100;

  while (true) {
    const data = await apiGet<T[]>(url, accessToken, {
      params: {
        ...params,
        per_page: perPage,
        page,
      },
    });
    results.push(...data);
    if (data.length < perPage) {
      break;
    }
    if (shouldStop?.(data)) {
      break;
    }
    page += 1;
  }

  return results;
}
