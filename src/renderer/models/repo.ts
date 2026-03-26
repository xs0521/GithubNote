import { DataFetchModel } from '@models/base';
import log from 'electron-log/renderer';
import { FetchDataType, FetchReposConfig } from '@models/model';
import { updateIsRepositoriesLoading } from '@slice/setting-slice';
import {
  fetchRepositories,
  fetchRepositoriesFromDB,
  saveRepositories,
} from '@slice/content-repo-slice';
import { updateRepositories } from '@slice/content-slice';
import { Repository } from '@const/index';

class DataRepoFetchModel extends DataFetchModel {
  // 从网络获取仓库数据
  private async fetchNetworkReposData(
    config: FetchReposConfig,
  ): Promise<Repository[]> {
    this.dispatch(updateIsRepositoriesLoading(true));
    const fetchedRepos = await this.dispatch(
      fetchRepositories({
        accessToken: config.accessToken,
        userId: config.userId,
      }),
    ).unwrap();
    this.dispatch(updateIsRepositoriesLoading(false));
    log.info('fetchNetworkReposData result count', fetchedRepos.length);
    return fetchedRepos;
  }

  // 从数据库获取仓库数据
  private async fetchDBReposData(
    config: FetchReposConfig,
  ): Promise<Repository[]> {
    const values = await this.dispatch(
      fetchRepositoriesFromDB(config.userId),
    ).unwrap();
    return values;
  }

  // 获取并保存仓库数据
  async fetchAndSaveReposData(
    ignoreCache: boolean,
    config: FetchReposConfig,
  ): Promise<void> {
    await this.fetchAndSaveData(
      FetchDataType.Repos,
      ignoreCache,
      () => this.fetchNetworkReposData(config),
      () => this.fetchDBReposData(config),
      saveRepositories,
      updateRepositories,
    );
  }
}

export default DataRepoFetchModel;
