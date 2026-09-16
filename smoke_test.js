const http = require('http');
const { spawn } = require('child_process');
const port = 18787;
const child = spawn(process.execPath, ['server.js'], { cwd: __dirname, env: { ...process.env, PORT: String(port), OPENAI_API_KEY: '' }, stdio: 'ignore' });
const fail = (m) => { console.error(m); child.kill(); process.exit(1); };
setTimeout(() => {
  http.get(`http://127.0.0.1:${port}/health`, (res) => {
    let body = '';
    res.on('data', c => body += c);
    res.on('end', () => {
      try {
        const d = JSON.parse(body);
        if (res.statusCode !== 200 || !d.ok || d.providerConfigured !== false) fail(`Unexpected health response: ${body}`);
        console.log('Backend smoke test passed.'); child.kill(); process.exit(0);
      } catch (e) { fail(e.message); }
    });
  }).on('error', e => fail(e.message));
}, 500);
