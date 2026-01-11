import { useMemo } from 'react';
import { useDispatch, useStore } from 'react-redux';
import { AppDispatch, RootState } from '@redux/index';

import DataRepoFetchModel from '@models/repo';
import DataIssueFetchModel from '@models/issue';
import DataCommentFetchModel from '@models/comment';

export function useDataRepoFetchModel() {
  const dispatch = useDispatch<AppDispatch>();
  const store = useStore<RootState>();

  return useMemo(
    () => new DataRepoFetchModel(dispatch, () => store.getState()),
    [dispatch, store],
  );
}

export function useDataIssueFetchModel() {
  const dispatch = useDispatch<AppDispatch>();
  const store = useStore<RootState>();

  return useMemo(
    () => new DataIssueFetchModel(dispatch, () => store.getState()),
    [dispatch, store],
  );
}

export function useDataCommentFetchModel() {
  const dispatch = useDispatch<AppDispatch>();
  const store = useStore<RootState>();

  return useMemo(
    () => new DataCommentFetchModel(dispatch, () => store.getState()),
    [dispatch, store],
  );
}
