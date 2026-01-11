interface FetchConfig {
  userId: number;
  accessToken: string;
  owner: string;
}

export interface FetchReposConfig extends FetchConfig {}

export interface FetchIssuesConfig extends FetchConfig {
  repositoryId: string;
  repositoryName: string;
}

export interface FetchCommentsConfig extends FetchIssuesConfig {
  issueId: string;
  issueNumber: number;
}

export enum FetchDataType {
  Repos = 'repos',
  Issues = 'issues',
  Comments = 'comments',
}
