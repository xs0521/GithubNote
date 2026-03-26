import { DataFetchModel } from '@models/base';
import log from 'electron-log/renderer';
import { FetchDataType, FetchIssuesConfig } from '@models/model';
import { Issue } from '@const/index';
import {
  fetchIssues,
  fetchIssuesFromDB,
  saveIssues,
} from '@slice/content-issue-slice';
import { updateIssues } from '@slice/content-slice';
import { updateIsIssuesLoading } from '@slice/setting-slice';

class DataIssueFetchModel extends DataFetchModel {
  // 从网络获取问题数据
  private async fetchNetworkIssuesData(
    config: FetchIssuesConfig,
  ): Promise<Issue[]> {
    log.info('fetchNetworkIssuesData', { repositoryName: config.repositoryName });
    this.dispatch(updateIsIssuesLoading(true));
    const fetchedIssues = await this.dispatch(
      fetchIssues({
        accessToken: config.accessToken,
        owner: config.owner,
        repositoryName: config.repositoryName,
        userId: config.userId,
        repositoryId: config.repositoryId,
      }),
    ).unwrap();
    this.dispatch(updateIsIssuesLoading(false));
    log.info('fetchNetworkIssuesData result count', fetchedIssues.length);
    return fetchedIssues;
  }

  // 从数据库获取问题数据
  private async fetchDBIssuesData(config: FetchIssuesConfig): Promise<Issue[]> {
    const values = await this.dispatch(
      fetchIssuesFromDB({
        userId: config.userId,
        repositoryId: config.repositoryId,
      }),
    ).unwrap();
    return values;
  }

  // 获取并保存问题数据
  async fetchAndSaveIssuesData(
    ignoreCache: boolean,
    config: FetchIssuesConfig,
  ): Promise<void> {
    await this.fetchAndSaveData(
      FetchDataType.Issues,
      ignoreCache,
      () => this.fetchNetworkIssuesData(config),
      () => this.fetchDBIssuesData(config),
      saveIssues,
      updateIssues,
    );
  }
}

export default DataIssueFetchModel;
