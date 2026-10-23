// Drives the signed-in ChatGPT window (Edge, remote port 9333): types the prompt, waits for the new picture, saves it.
// node gpt-image.mjs <promptFile> <outFileNoExt> <url>   -> prints the saved path on the last line
import { chromium } from 'playwright-core';
import fs from 'node:fs';
const [,, promptFile, outBase, url] = process.argv;
const prompt = fs.readFileSync(promptFile, 'utf8');
const log = (...a) => console.error(...a);
const sleep = ms => new Promise(r => setTimeout(r, ms));
const browser = await chromium.connectOverCDP('http://127.0.0.1:9333');
const ctx = browser.contexts()[0];
let page = ctx.pages().find(p => /chatgpt\.com|openai\.com/.test(p.url())) || ctx.pages()[0] || await ctx.newPage();
await page.bringToFront();
await page.goto(url, { waitUntil: 'domcontentloaded' });
const box = page.locator('#prompt-textarea, div[contenteditable="true"]').first();
try { await box.waitFor({ timeout: 60000 }); } catch { log('ChatGPT message box not found (signed out?)'); process.exit(2); }
await sleep(1500);
const before = new Set(await page.evaluate(() => [...document.images].map(i => i.currentSrc || i.src)));
await box.click();
await page.keyboard.insertText(prompt);
await sleep(800);
const send = page.locator('[data-testid="send-button"], button[aria-label*="Send"]').first();
if (await send.count() && await send.isEnabled()) await send.click(); else await page.keyboard.press('Enter');
log('[3/4] Prompt sent - waiting for the picture...');
let last = '', stable = 0, src = '', t0 = Date.now();
while (Date.now() - t0 < 15 * 60000) {
  await sleep(3000);
  const s = await page.evaluate(b => {
    const before = new Set(b);
    const busy = !!document.querySelector('[data-testid="stop-button"]');
    const imgs = [...document.images].filter(i => { const s = i.currentSrc || i.src; return s && !before.has(s) && i.complete && i.naturalWidth >= 400 && i.naturalHeight >= 400 && !/avatar|profile|favicon/i.test(s); });
    imgs.sort((x, y) => y.naturalWidth * y.naturalHeight - x.naturalWidth * x.naturalHeight);
    const im = imgs[0];
    return { busy, n: imgs.length, src: im ? (im.currentSrc || im.src) : '' };
  }, [...before]).catch(() => null);
  if (!s) continue;
  if ((Date.now() - t0) % 30000 < 3000) log(`  ...still waiting (busy=${s.busy}, new pictures=${s.n})`);
  if (s.src) { if (s.src === last) stable++; else { stable = 0; last = s.src; } if ((stable >= 2 && !s.busy) || stable >= 4) { src = s.src; break; } }
}
if (!src) { log('No new picture found'); process.exit(3); }
log('[4/4] Saving the picture...');
let buf = null, ext = '.png';
try {
  const r = await ctx.request.get(src);
  if (r.ok()) { buf = await r.body(); const ct = r.headers()['content-type'] || ''; ext = /jpe?g/.test(ct) ? '.jpg' : /webp/.test(ct) ? '.webp' : '.png'; }
} catch {}
if (!buf) {
  const d = await page.evaluate(async u => { const r = await fetch(u, { credentials: 'include' }); const b = await r.blob(); return await new Promise(ok => { const f = new FileReader(); f.onload = () => ok(f.result); f.readAsDataURL(b); }); }, src).catch(() => '');
  const m = /^data:image\/(\w+);base64,(.+)$/.exec(d || ''); if (m) { buf = Buffer.from(m[2], 'base64'); ext = m[1] === 'jpeg' ? '.jpg' : '.' + m[1]; }
}
if (!buf) { log('Could not download the picture'); process.exit(4); }
fs.writeFileSync(outBase + ext, buf);
console.log(outBase + ext);
await browser.close().catch(() => {});   // disconnects only; the ChatGPT window stays open
process.exit(0);
