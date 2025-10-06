// labs/02-pep-proxy/target.js
const http = require('http');

const server = http.createServer((req, res) => {
  if (req.url === '/profiles') {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Profiles Data ✅ (from target app)\n');
  } else {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end(`Target says: ${req.method} ${req.url}\n`);
  }
});

server.listen(9000, () => console.log('🎯 Target app listening on :9000'));
