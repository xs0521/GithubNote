const fs = require('fs');
const path = require('path');

function pad(value) {
  return String(value).padStart(2, '0');
}

function getBuildNumber() {
  const now = new Date();
  const year = now.getFullYear();
  const month = pad(now.getMonth() + 1);
  const day = pad(now.getDate());
  const hour = pad(now.getHours());
  const minute = pad(now.getMinutes());
  return `${year}${month}${day}${hour}${minute}`;
}

const packagePath = path.join(__dirname, '../..', 'package.json');
const raw = fs.readFileSync(packagePath, 'utf8');
const pkg = JSON.parse(raw);
pkg.build = pkg.build || {};
pkg.build.buildNumber = getBuildNumber();
pkg.build.extraMetadata = pkg.build.extraMetadata || {};
pkg.build.extraMetadata.buildNumber = pkg.build.buildNumber;

fs.writeFileSync(packagePath, `${JSON.stringify(pkg, null, 2)}\n`, 'utf8');
console.log(`Set build number: ${pkg.build.buildNumber}`);
