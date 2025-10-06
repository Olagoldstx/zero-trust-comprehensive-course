// labs/02-pep-proxy/pep.js
// Simple PEP proxy that queries OPA for authorization decisions

const http = require('http');
const httpProxy = require('http-proxy');

// Target app behind the proxy (simulated)
const TARGET = 'http://localhost:9000'; // downstream app
const OPA_URL = 'http://localhost:8181/v1/data/httpapi/authz/allow';

const proxy = httpProxy.createProxyServer({ target: TARGET });

const server = http.createServer(async (req, res) => {
  try {
    // Build the input object OPA expects
    const input = {
      input: {
        method: req.method,
        path: req.url,
        user: req.headers['x-user'] || 'anonymous'
      }
    };

    // Ask OPA if this request should be allowed
    const decision = await fetch(OPA_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(input)
    }).then(r => r.json());

    if (decision.result === true) {
      console.log(`✅ ALLOW ${req.method} ${req.url}`);
      proxy.web(req, res);
    } else {
      console.log(`🚫 DENY ${req.method} ${req.url}`);
      res.writeHead(403, { 'Content-Type': 'text/plain' });
      res.end('Access denied by OPA policy\n');
    }
  } catch (err) {
    console.error('Error querying OPA:', err);
    res.writeHead(500);
    res.end('Internal proxy error\n');
  }
});

server.listen(8080, () => {
  console.log('🔐 PEP proxy listening on port 8080');
});
