// Phase 12b: an exported page's player in Chrome with real time (no virtual time), driven over the DevTools protocol with Node's own WebSocket and fetch
//   (Node 22 or later; no npm package). No model call. Sourced by no one: tests/smoke.R (12b-1, heavy) runs it with system2(), and it runs alone:
//   node tests/motion_realtime_12b.mjs page.html [--mode=observe|print|memory|look|layout] [--throttle=4] [--headed] [--reduced] [--noscript] [--replay] [--out=dir] [--width=1400] [--height=1000] [--play=k]
// observe (the default): loads the page and takes a screenshot of the window every 50 ms for the first 800 ms (each with the state of every animated card: a
//   screenshot takes some tens of milliseconds, so the shots fall at most every 50 ms and their times are written), then one at rest (6 s); writes
//   shot_NN.png, rest.png and observe.json into `out` (default: a new temporary folder) and prints the folder. In the page, a script added before the page's
//   own records every frame drawn on a card's canvas (which card, which frame of its frames, when) and, at each paint, what each card shows. With --replay
//   the first card's Replay is then pressed, and the state read 1 s and 6 s later.
// print: loads the page with print media emulated from 60 ms and reads every card's state then and at 1 s (a card in view is then playing on screen media);
//   writes print.json.
// memory: loads the page, waits 8 s (the cards in view at load have played), collects garbage and reads the memory; then scrolls card k (default the last)
//   into view, presses its Replay and reads the memory again 1.5 s later, while it plays, and once more 5 s later (it has stopped); writes memory.json. The
//   figures are Windows' private bytes of this Chrome's renderers and of all its processes (Chrome's own task manager shows a close figure as "Memory
//   footprint"), and the page's performance.memory.usedJSHeapSize (with --enable-precise-memory-info).
// look: every animated card scrolled into view and played in turn, then the whole page captured at rest (look.png).
// layout: every card's place, its chart's place and what is shown, at this width, 2 s after load (layout.json). --throttle=N slows the CPU N times
//   (Emulation.setCPUThrottlingRate). The state also holds each card's frame-0 picture (shown, loaded) and, for every card, [its top on the page, its height, whether it is whole (its source
//   line has been read), whether any of it is on the screen].
// --reduced asks for reduced motion (--force-prefers-reduced-motion); --noscript turns the page's script off (the state is still read by the driver).
import { spawn, execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { pathToFileURL } from 'node:url';

const argv = process.argv.slice(2);
const opt = Object.fromEntries(argv.filter((a) => a.startsWith('--')).map((a) => { const [k, ...v] = a.slice(2).split('='); return [k, v.length ? v.join('=') : true]; }));
const html = argv.find((a) => !a.startsWith('--'));
const CHROME = opt.chrome || 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const mode = opt.mode || 'observe';
const W = +(opt.width || 1400), H = +(opt.height || 1000);
const out = opt.out || fs.mkdtempSync(path.join(os.tmpdir(), 'p12b_'));
fs.mkdirSync(out, { recursive: true });
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// The state of every animated card (the count of its frames is kept once read whole: early in the load its JSON may not have come in yet): its frame and play attributes, whether its canvas is there and shown, whether its finished picture is shown (visibility)
//   and loaded, and where its picture is on the screen.
const STATE_FN = `function () {
  var cards = [].slice.call(document.querySelectorAll('.motion'));
  return { t: performance.now(), motionJs: document.documentElement.classList.contains('motion-js'), cards: cards.map(function (box) {
    var img = box.querySelector('img.motion-still'), c = box.querySelector('canvas.motion-canvas'), r = (img || box).getBoundingClientRect();
    return { frame: box.getAttribute('data-frame'), playing: box.hasAttribute('data-playing'), played: box.getAttribute('data-played'), failed: box.hasAttribute('data-failed'),
             canvas: !!c, canvasShown: !!(c && getComputedStyle(c).display !== 'none'), still: img ? getComputedStyle(img).visibility : null,
             stillLoaded: !!(img && img.complete && img.naturalWidth), images: box._images ? box._images.length : 0,
             kept: box._p12n > 0 ? box._p12n : (box._p12n = (function () { try { var fid = box.getAttribute('data-frames'); return JSON.parse((fid ? document.getElementById(fid) : box.querySelector('script.motion-frames')).textContent).frames.length; } catch (e) { return -1; } })()),
             software: c ? !!c.getContext('2d').getContextAttributes().willReadFrequently : null, top: r.top, left: r.left, width: r.width, height: r.height,
             first: (function () { var f = box.querySelector('img.motion-first'); return f ? { shown: getComputedStyle(f).display !== 'none' && getComputedStyle(f).visibility !== 'hidden', loaded: !!(f.complete && f.naturalWidth) } : null; })() };
  }), layout: [].slice.call(document.querySelectorAll('.card')).map(function (c) { var q = c.getBoundingClientRect(); return [q.top + window.scrollY, q.height, !!c.querySelector('.source'), q.top < window.innerHeight && q.bottom > 0]; }) };
}`;
// What the page records (added before the page's own scripts): every drawImage on a card's canvas, with the index of the frame drawn (its place in the card's
//   frames; -1 when it is not one of them), and at each animation frame the state of every card.
const LOG_JS = `(function () {
  var L = window.__p12b = { draws: [], paints: [] };
  var cache = new WeakMap();
  var index = function (box, im) {
    var a = cache.get(box);
    if (!a) { try { var fid = box.getAttribute('data-frames'); a = JSON.parse((fid ? document.getElementById(fid) : box.querySelector('script.motion-frames')).textContent).frames; } catch (e) { a = []; } cache.set(box, a); }
    return im && im.src ? a.indexOf(im.src) : -2;
  };
  var d0 = CanvasRenderingContext2D.prototype.drawImage;
  CanvasRenderingContext2D.prototype.drawImage = function (im) {
    try { var box = this.canvas.closest && this.canvas.closest('.motion'); if (box) L.draws.push({ t: performance.now(), card: [].slice.call(document.querySelectorAll('.motion')).indexOf(box), frame: index(box, im) }); } catch (e) {}
    return d0.apply(this, arguments);
  };
  var state = ${STATE_FN};
  var tick = function () { if (L.paints.length < 1200) L.paints.push(state()); requestAnimationFrame(tick); };
  requestAnimationFrame(tick);
})();`;

const udd = fs.mkdtempSync(path.join(os.tmpdir(), 'p12b_chrome_'));
const flags = [`--user-data-dir=${udd}`, '--remote-debugging-port=0', '--no-first-run', '--no-default-browser-check', '--disable-extensions', '--enable-precise-memory-info',
  `--window-size=${W},${H + 140}`, '--disable-background-timer-throttling', '--disable-renderer-backgrounding', '--disable-backgrounding-occluded-windows'];
if (!opt.headed) flags.push('--headless=new');
if (opt.reduced) flags.push('--force-prefers-reduced-motion');
flags.push('about:blank');
const chrome = spawn(CHROME, flags, { stdio: 'ignore' });
// a run never hangs: after --limit ms (default 120 s) Chrome is closed and the run ends with no result (a headed Chrome whose window draws nothing never
//   answers a screenshot); each call to Chrome is given up after 20 s
setTimeout(() => { console.error('the run took too long: no result'); try { chrome.kill(); } catch (e) { /* gone */ } process.exit(3); }, +(opt.limit || 120000));

const portFile = path.join(udd, 'DevToolsActivePort');
const readPort = () => { try { const t = fs.readFileSync(portFile, 'utf8'); return t.includes('\n') ? t.split('\n')[0].trim() : null; } catch (e) { return null; } };   // Chrome may still be writing it
const waitPort = async (k) => readPort() || (k > 200 ? null : (await sleep(50), waitPort(k + 1)));
const port = await waitPort(0);
if (!port) { console.error('Chrome did not open its DevTools port'); chrome.kill(); process.exit(2); }

const connect = (url) => new Promise((res, rej) => {
  const ws = new WebSocket(url);
  let id = 0;
  const pending = new Map();
  ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pending.has(m.id)) { const p = pending.get(m.id); pending.delete(m.id); m.error ? p.rej(new Error(m.error.message)) : p.res(m.result); } };
  ws.onopen = () => res({ ws, send: (method, params = {}) => new Promise((ok, no) => {
    id += 1;
    const k = id, late = setTimeout(() => { if (pending.has(k)) { pending.delete(k); no(new Error(method + ': no answer in 20 s')); } }, 20000);
    pending.set(k, { res: (v) => { clearTimeout(late); ok(v); }, rej: (er) => { clearTimeout(late); no(new Error(method + ': ' + er.message)); } });
    ws.send(JSON.stringify({ id: k, method, params }));
  }) });
  ws.onerror = rej;
});
// the tab opened on about:blank (a headed Chrome may list other pages of its own)
const findTab = async (k) => {
  const targets = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
  const t = targets.find((x) => x.type === 'page' && x.url === 'about:blank');
  return t || k > 100 ? t : (await sleep(50), findTab(k + 1));
};
const tab = await findTab(0);
const version = await (await fetch(`http://127.0.0.1:${port}/json/version`)).json();
await sleep(300);
const page = await connect(tab.webSocketDebuggerUrl);
const browser = await connect(version.webSocketDebuggerUrl);
await page.send('Page.enable');
await page.send('Runtime.enable');
await page.send('Emulation.setDeviceMetricsOverride', { width: W, height: H, deviceScaleFactor: 1, mobile: false });
if (opt.noscript) await page.send('Emulation.setScriptExecutionDisabled', { value: true });
else await page.send('Page.addScriptToEvaluateOnNewDocument', { source: LOG_JS });
if (opt.throttle) await page.send('Emulation.setCPUThrottlingRate', { rate: +opt.throttle });
const evaluate = async (expr) => { try { const r = await page.send('Runtime.evaluate', { expression: expr, returnByValue: true, awaitPromise: true }); return r.result.value; } catch (e) { return null; } };
const state = () => evaluate(`(${STATE_FN})()`);
const shot = async (file) => { const r = await page.send('Page.captureScreenshot', { format: 'png', optimizeForSpeed: true }); fs.writeFileSync(path.join(out, file), Buffer.from(r.data, 'base64')); };
const url = pathToFileURL(path.resolve(html)).href;
const mb = (b) => Math.round(b / 1024 / 1024 * 10) / 10;

// The private bytes of every process of this Chrome (from the browser's own list of them), of its renderers and of its GPU process; and the page's JS heap.
const memory = async (collect) => {
  if (collect) { await page.send('HeapProfiler.enable'); await page.send('HeapProfiler.collectGarbage'); await sleep(500); }
  const info = (await browser.send('SystemInfo.getProcessInfo')).processInfo;
  const ps = execFileSync('powershell.exe', ['-NoProfile', '-Command', `Get-Process -Id ${info.map((p) => p.id).join(',')} -ErrorAction SilentlyContinue | ForEach-Object { "$($_.Id) $($_.PrivateMemorySize64)" }; exit 0`], { encoding: 'utf8' });
  const rows = Object.fromEntries(ps.trim().split(/\r?\n/).map((l) => l.trim().split(/\s+/).map(Number)));
  const of = (type) => info.filter((p) => p.type === type).reduce((s, p) => s + (rows[p.id] || 0), 0);
  const js = await evaluate('performance.memory ? performance.memory.usedJSHeapSize : null');
  return { renderer_private_mb: mb(of('renderer')), gpu_private_mb: mb(of('GPU')), browser_total_private_mb: mb(Object.values(rows).reduce((s, v) => s + v, 0)), js_heap_mb: js === null ? null : mb(js) };
};

if (mode === 'observe') {
  const t0 = Date.now();
  await page.send('Page.navigate', { url });
  const shots = [];
  const take = async (k) => {
    if (k > 16) return;
    const due = t0 + 50 * k;
    if (Date.now() < due) await sleep(due - Date.now());
    const at = Date.now() - t0;
    const file = `shot_${String(k).padStart(2, '0')}.png`;
    const ok = await shot(file).then(() => true, () => false);   // no screenshot while the navigation is not yet committed (the old blank page is on the screen)
    shots.push({ k, due_ms: 50 * k, at_ms: at, done_ms: Date.now() - t0, file: ok ? file : null, state: await state() });
    await take(k + 1);
  };
  await take(0);
  await sleep(Math.max(0, t0 + 6000 - Date.now()));
  await shot('rest.png');
  const rest = await state();
  // --replay: Replay of the first card is pressed at rest; its state 1 s later (playing) and 5 s later (at rest again)
  const replay = opt.replay ? { press: await evaluate("(function () { document.querySelector('.motion button.motion-replay').click(); return true; })()") } : null;
  if (replay) { await sleep(1000); replay.mid = await state(); await sleep(5000); replay.end = await state(); }
  const log = opt.noscript ? null : await evaluate('JSON.stringify({ draws: window.__p12b.draws, paints: window.__p12b.paints })');
  if (!opt.noscript && !log) console.error('log not read:', await page.send('Runtime.evaluate', { expression: 'typeof window.__p12b', returnByValue: true }).then((r) => JSON.stringify(r).slice(0, 600), (e) => e.message));
  fs.writeFileSync(path.join(out, 'observe.json'), JSON.stringify({ url, width: W, height: H, headed: !!opt.headed, reduced: !!opt.reduced, noscript: !!opt.noscript, shots, rest, replay, log: log ? JSON.parse(log) : null }));
} else if (mode === 'print') {
  const t0 = Date.now();
  await page.send('Page.navigate', { url });
  await sleep(Math.max(0, t0 + 60 - Date.now()));
  await page.send('Emulation.setEmulatedMedia', { media: 'print' });
  const early = await state();
  await sleep(Math.max(0, t0 + 1000 - Date.now()));
  const mid = await state();
  await page.send('Emulation.setEmulatedMedia', { media: '' });
  const screen = await state();
  fs.writeFileSync(path.join(out, 'print.json'), JSON.stringify({ url, early, mid, screen }));
} else if (mode === 'layout') {
  // layout: the page at this width 2 s after load: every card, whether it has its row, its box and padding, its slot, the chart shown in it (the picture, the
  //   motion box or the phone drawing, whichever is displayed) and the parts after the slot; and whether the page scrolls sideways (layout.json)
  await page.send('Page.navigate', { url });
  await sleep(2000);
  const lay = await evaluate(`(function () {
    var R = function (e) { var b = e.getBoundingClientRect(); return { l: b.left, t: b.top + scrollY, r: b.right, b: b.bottom + scrollY, w: b.width, h: b.height }; };
    var shown = function (e) { return e && getComputedStyle(e).display !== 'none' && e.getBoundingClientRect().width > 0; };
    return { vw: document.documentElement.clientWidth, sw: document.documentElement.scrollWidth, cards: [].slice.call(document.querySelectorAll('.card')).map(function (c) {
      var cs = getComputedStyle(c), slot = c.querySelector('.slot'), chart = [].slice.call(c.querySelectorAll('.slot picture > img, .slot .motion, .slot img.motion-phone, .slot .widget')).filter(shown)[0] || null;
      var after = [].slice.call(c.children).filter(function (e) { return slot && e !== slot && (slot.compareDocumentPosition(e) & Node.DOCUMENT_POSITION_FOLLOWING); });
      var still = c.querySelector('img.motion-still');
      return { full: c.classList.contains('full'), card: R(c), pad: parseFloat(cs.paddingLeft) + parseFloat(cs.paddingRight) + parseFloat(cs.borderLeftWidth) + parseFloat(cs.borderRightWidth),
               slot: slot ? R(slot) : null, chart: chart ? R(chart) : null, kind: chart ? (chart.classList.contains('motion') ? 'motion' : chart.classList.contains('motion-phone') ? 'phone' : chart.className || chart.tagName) : null,
               natural: still ? still.naturalWidth : (chart && chart.naturalWidth) || null, after: after.map(function (e) { return R(e); }) };
    }) };
  })()`);
  fs.writeFileSync(path.join(out, 'layout.json'), JSON.stringify(lay));
} else if (mode === 'look') {
  // look: every animated card is scrolled into view in turn and left to play (4.5 s), then the whole page is captured at rest (look.png)
  await page.send('Page.navigate', { url });
  await sleep(1500);
  const n = await evaluate("document.querySelectorAll('.motion').length");
  const play = async (k) => { if (k >= n) return; await evaluate(`document.querySelectorAll('.motion')[${k}].scrollIntoView({ block: 'center' })`); await sleep(4500); await play(k + 1); };
  await play(0);
  await evaluate('window.scrollTo(0, 0)');
  await sleep(500);
  const r = await page.send('Page.captureScreenshot', { format: 'png', captureBeyondViewport: true });
  fs.writeFileSync(path.join(out, 'look.png'), Buffer.from(r.data, 'base64'));
  fs.writeFileSync(path.join(out, 'look.json'), JSON.stringify(await state()));
} else if (mode === 'memory') {
  await page.send('Page.navigate', { url });
  await sleep(8000);
  const rest = await memory(true);
  const n = await evaluate("document.querySelectorAll('.motion').length");
  const k = opt.play === undefined ? n - 1 : +opt.play;
  await evaluate(`(function () { var b = document.querySelectorAll('.motion')[${k}]; b.scrollIntoView({ block: 'center' }); b.querySelector('button.motion-replay').click(); return true; })()`);
  await sleep(1500);
  const cardState = await evaluate(`(function () { var b = document.querySelectorAll('.motion')[${k}]; return { frame: b.getAttribute('data-frame'), playing: b.hasAttribute('data-playing') }; })()`);
  const playing = { ...(await memory(false)), card: k, state: cardState };
  await sleep(5000);
  const after = await memory(true);
  fs.writeFileSync(path.join(out, 'memory.json'), JSON.stringify({ url, cards: n, rest, playing, after_replay: after }, null, 1));
}
try { await browser.send('Browser.close'); } catch (e) { chrome.kill(); }
await sleep(300);
try { fs.rmSync(udd, { recursive: true, force: true }); } catch (e) { /* Chrome may still hold a file for a moment */ }
console.log(out);
process.exit(0);
