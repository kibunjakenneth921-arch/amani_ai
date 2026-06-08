const { URL } = require('url');
try {
  const u = new URL('http://127.0.0.1:8085/');
  console.log('host:', u.hostname, 'port:', u.port);
} catch (e) {
  console.error('error', e && e.message);
  process.exit(1);
}
