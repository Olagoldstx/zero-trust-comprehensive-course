#!/usr/bin/env node
/**
 * Real-time dashboard for Lesson 12
 * - Reads labs/12-cross-cloud-correlation/multicloud_events.jsonl
 * - Streams raw events over Server-Sent Events (/stream)
 * - Exposes on-demand correlation (/api/correlations)
 */
const path = require('path');
const fs   = require('fs');
const express = require('express');
const chokidar = require('chokidar');

const APP  = express();
const PORT = process.env.PORT || 5050;

const EVENTS_FILE = path.resolve(
  __dirname, '../12-cross-cloud-correlation/multicloud_events.jsonl'
);

// ---- tiny helpers -----------------------------------------------------------
function parseLine(line) {
  try { return JSON.parse(line); } catch { return null; }
}

function correlate(rows) {
  const byUser = {};
  for (const r of rows) {
    if (!r || !r.user) continue;
    const k = r.user;
    byUser[k] = byUser[k] || { user: k, clouds: new Set(), total: 0, high: 0 };
    byUser[k].clouds.add(r.cloud);
    byUser[k].total += 1;
    if ((r.severity ?? 0) >= 4) byUser[k].high += 1;
  }
  return Object.values(byUser).map(x => ({
    user: x.user,
    clouds: Array.from(x.clouds),
    total_events: x.total,
    high_sev: x.high,
    correlated: x.clouds.size > 1
  }));
}

function readAllEvents() {
  if (!fs.existsSync(EVENTS_FILE)) return [];
  const lines = fs.readFileSync(EVENTS_FILE, 'utf8')
    .split('\n')
    .map(s => s.trim())
    .filter(Boolean);
  return lines.map(parseLine).filter(Boolean);
}

// ---- static UI --------------------------------------------------------------
APP.use(express.static(path.join(__dirname, 'public'), { index: 'index.html' }));

// ---- SSE stream of *new* events -------------------------------------------
APP.get('/stream', (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');

  // Send a hello
  res.write(`event: hello\ndata: ${JSON.stringify({ ok: true })}\n\n`);

  // Keepalive
  const keep = setInterval(() => res.write(':\n\n'), 15000);

  // Tail new lines with chokidar
  let lastSize = fs.existsSync(EVENTS_FILE) ? fs.statSync(EVENTS_FILE).size : 0;
  const watcher = chokidar.watch(EVENTS_FILE, { ignoreInitial: true });

  watcher.on('change', () => {
    const stat = fs.statSync(EVENTS_FILE);
    const stream = fs.createReadStream(EVENTS_FILE, {
      start: lastSize,
      end: stat.size
    });
    lastSize = stat.size;
    let buf = '';
    stream.on('data', chunk => buf += chunk.toString());
    stream.on('end', () => {
      buf.split('\n')
        .map(s => s.trim())
        .filter(Boolean)
        .map(parseLine)
        .filter(Boolean)
        .forEach(ev => res.write(`data: ${JSON.stringify(ev)}\n\n`));
    });
  });

  req.on('close', () => { clearInterval(keep); watcher.close(); });
});

// ---- REST: current correlations --------------------------------------------
APP.get('/api/correlations', (_req, res) => {
  res.json(correlate(readAllEvents()));
});

// ---- REST: seed — returns last N events ------------------------------------
APP.get('/api/events', (req, res) => {
  const n = Number(req.query.n || 200);
  const rows = readAllEvents();
  res.json(rows.slice(-n));
});

APP.listen(PORT, () =>
  console.log(`📊 Dashboard running on http://127.0.0.1:${PORT}`)
);
