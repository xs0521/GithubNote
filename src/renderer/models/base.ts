import { AppDispatch, RootState } from '@redux/index';
import { FetchDataType } from '@models/model';
import log from 'electron-log/renderer';

// 数据获取模型类
export class DataFetchModel {
  dispatch: AppDispatch;

  getState: () => RootState;

  constructor(dispatch: AppDispatch, getState: () => RootState) {
    this.dispatch = dispatch;
    this.getState = getState;
  }

  // 检查数据库是否已初始化
  private isDBInitialized(): boolean {
    return this.getState().settingData.isDBInitialized;
  }

  // 通用数据获取和保存方法
  async fetchAndSaveData<T>(
    dataType: FetchDataType,
    ignoreCache: boolean,
    fetchNetworkData: () => Promise<T[]>,
    fetchDBData: () => Promise<T[]>,
    saveData: (data: T[]) => any,
    updateData: (data: T[]) => any,
  ): Promise<void> {
    if (!this.isDBInitialized()) {
      log.warn(`fetch ${dataType} data failed, isDBInitialized: false`);
      return;
    }

    if (ignoreCache) {
      const fetchedData = await fetchNetworkData();
      await this.dispatch(saveData(fetchedData));
      this.dispatch(updateData(fetchedData));
      return;
    }

    const dbData = await fetchDBData();
    log.info(`db${dataType} count`, dbData.length);

    if (dbData.length > 0) {
      this.dispatch(updateData(dbData));
      return;
    }

    const fetchedData = await fetchNetworkData();
    await this.dispatch(saveData(fetchedData));
    this.dispatch(updateData(fetchedData));
  }
}

export default DataFetchModel;
