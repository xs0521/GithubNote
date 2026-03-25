import dayjs from 'dayjs';

export interface Repository {
  id: string;
  name: string;
  full_name: string;
  private: boolean;
  html_url: string;
  created_at: string;
  updated_at: string;
  pushed_at: string;
  size: number;
  language: string;
  stargazers_count: number;
  watchers_count: number;
  forks_count: number;
  open_issues_count: number;
  default_branch: string;
  user_id: number;
}

export enum IssueStatus {
  OPEN = 'open',
  CLOSED = 'closed',
}

export interface Label {
  id: string;
  name: string;
  color: string;
}

export interface Issue {
  id: string;
  number: number;
  title: string;
  body: string;
  state: IssueStatus;
  user_id: number;
  repository_id: string;
  created_at: string;
  updated_at: string;
  labels?: Label[];
}

export interface Comment {
  id: string;
  url: string;
  html_url: string;
  issue_url: string;
  node_id: string;
  created_at: string;
  updated_at: string;
  body: string;
  uuid: string;
  dirty?: boolean;
  sync_status?: 'pending' | 'synced' | 'failed';
  user_id: number;
  repository_id: string;
  issue_id: string;
}

export const PLACEHOLDER = 'input your note here...';

export const SELECTED_NOTE_BOOK = 'Selected Note Book';
export const CREATE_NOTE_BOOK = 'Create Note Book';
export const SELECTED_WORKSPACE = 'Selected Workspace';

export const generateCommentBody = () => {
  return `# NOTE ${dayjs().format('MM-DD HH:mm:ss')}`;
};
