import log from 'electron-log/renderer';

if (log.transports?.file) {
  log.transports.file.level = 'info';
}
if (log.transports?.console) {
  log.transports.console.level = 'warn';
}

export default log;
