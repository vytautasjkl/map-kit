// cloudcli-mapas — backend (map-kit standalone versija).
// Servina neon žemėlapį (index.html) į Žemėlapio tab'ą.
//   GET /html          -> { html }   (perskaito ~/projektai/mapas/index.html)
//   GET /html?fresh=1  -> perkuria iš data.json (bin/mapas.sh --no-open), tada grąžina
//   GET /data          -> raw data.json (patogumui)
import http from 'node:http';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { execFile } from 'node:child_process';

const MAPAS = path.join(os.homedir(), 'projektai', 'mapas');
const DATA = path.join(MAPAS, 'data.json');
const HTML = path.join(MAPAS, 'index.html');
const BUILD = path.join(MAPAS, 'bin', 'mapas.sh');

// Perkuria index.html be naršyklės. Resolves true jei pavyko.
function rebuild() {
  return new Promise((resolve) => {
    execFile('bash', [BUILD, '--no-open'], { timeout: 60000 }, (err) => resolve(!err));
  });
}

const server = http.createServer(async (req, res) => {
  const url = req.url || '';
  res.setHeader('Content-Type', 'application/json');

  if (req.method === 'GET' && url.startsWith('/html')) {
    try {
      if (url.includes('fresh=1')) { await rebuild(); }
      let html;
      try {
        html = fs.readFileSync(HTML, 'utf-8');
      } catch {
        await rebuild();
        html = fs.readFileSync(HTML, 'utf-8');
      }
      res.end(JSON.stringify({ html }));
    } catch (err) {
      res.writeHead(500);
      res.end(JSON.stringify({ error: 'Nepavyko paruošti index.html: ' + err.message, path: HTML }));
    }
    return;
  }

  if (req.method === 'GET' && url.startsWith('/data')) {
    try {
      res.end(fs.readFileSync(DATA, 'utf-8'));
    } catch (err) {
      res.writeHead(500);
      res.end(JSON.stringify({ error: 'Nepavyko perskaityti data.json: ' + err.message, path: DATA }));
    }
    return;
  }

  res.writeHead(404);
  res.end(JSON.stringify({ error: 'Not found' }));
});

server.listen(0, '127.0.0.1', () => {
  const addr = server.address();
  if (addr && typeof addr !== 'string') {
    // Būtinas readiness signalas host'ui
    console.log(JSON.stringify({ ready: true, port: addr.port }));
  }
});
