import { configureStore } from '@reduxjs/toolkit';
import { combineReducers } from 'redux';

import userReducer from '@slice/user-slice';
import settingReducer from '@slice/setting-slice';
import contentReducer from '@slice/content-slice';
// import { fuseImSlice } from './slices/fuseIm';
/* 持久化缓存 */
import { persistReducer, persistStore } from 'redux-persist';
import storage from 'redux-persist/es/storage';

const unPersistItems = ['settingData'];

// 缓存数据配置
const persistConfig = {
  key: 'root', // LocalStorage中显示为persist:root: {};
  storage,
  blacklist: unPersistItems, // 写在这块的数据不会存在storage
};

const reducers = combineReducers({
  userData: userReducer,
  settingData: settingReducer,
  contentData: contentReducer,
  // fuseIm: fuseImSlice.reducer,
});

const persistedReducer = persistReducer(persistConfig, reducers);
const store = configureStore({
  reducer: persistedReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: false,
    }),
});
// 记得包裹
export const persist = persistStore(store);
export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

export default store;
