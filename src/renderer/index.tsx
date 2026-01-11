import { createRoot } from 'react-dom/client';
import store, { persist } from '@redux/index';
import { Provider } from 'react-redux';
import { PersistGate } from 'redux-persist/integration/react';
import { SnackbarProvider } from 'notistack';
import { CHANNEL_COMMON } from '@/shared/constants';
import App from './App';
import BottomToast from '@/renderer/components/bottomtoastbar';

const container = document.getElementById('root') as HTMLElement;
const root = createRoot(container);

root.render(
  <Provider store={store}>
    <PersistGate loading={null} persistor={persist}>
      <SnackbarProvider
        anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
      >
        <App />
      </SnackbarProvider>
    </PersistGate>
  </Provider>,
);

// calling IPC exposed from preload script
window.electron?.ipcRenderer.once(CHANNEL_COMMON, (arg) => {
  // eslint-disable-next-line no-console
  console.log('receive main to renderer message', arg);
});

window.electron?.ipcRenderer.sendMessage(CHANNEL_COMMON, ['ping']);
