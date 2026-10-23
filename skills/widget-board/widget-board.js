/* widget-board.js — a floating "tab wheel" of widget cards at the bottom of the screen.
   Original code for lyopz's degen-skill library. No dependencies. MIT.

   WidgetBoard({
     items: [
       { label: 'Skills', img: 'skills.jpg', section: 'skills' },             // scrolls to #skills
       { label: 'Book',   img: 'table.jpg',  href: 'https://…' },             // opens a link
       { label: 'Update', html: '$ git pull', copy: 'git pull' },             // copies text
       { label: 'Call',   html: '☎ 555-0100', href: 'tel:5550100' },
       { label: 'Run',    html: '▶', action: () => doThing() },               // any custom action
     ],
     accent: '#e11d2e',          // glow color
     particles: true,            // use ParticleMedia on image cards if it's on the page
     showAfter: '#hero',         // hide while this element is on screen (null = always show)
   });
*/
(function (g) {
  const CSS = `
  .wb-wheel{--acc:#e11d2e;position:fixed;left:50%;bottom:14px;transform:translateX(-50%) translateY(140%);width:min(560px,calc(100vw - 32px));height:150px;perspective:900px;z-index:60;transition:transform .5s cubic-bezier(.2,.8,.2,1);font-family:inherit}
  .wb-wheel.show{transform:translateX(-50%) translateY(0)}
  .wb-wheel::before{content:"";position:absolute;inset:auto 0 0;height:96px;border-radius:24px;background:rgba(12,12,16,.82);backdrop-filter:blur(14px);-webkit-backdrop-filter:blur(14px);border:1px solid rgba(255,255,255,.09);box-shadow:0 20px 60px rgba(0,0,0,.55)}
  .wb-ring{position:absolute;left:50%;top:6px;width:0;height:120px;transform-style:preserve-3d}
  .wb-card{position:absolute;left:-62px;top:0;width:124px;height:110px;border-radius:14px;overflow:hidden;background:#000;border:1px solid rgba(255,255,255,.1);text-decoration:none;color:#fff;font-family:inherit;padding:0;cursor:pointer;transition:transform .55s cubic-bezier(.2,.8,.2,1),border-color .3s,box-shadow .3s,opacity .4s}
  .wb-card.front{border-color:var(--acc);box-shadow:0 0 24px color-mix(in srgb,var(--acc) 55%,transparent)}
  .wb-face{position:absolute;inset:0;background-size:cover;background-position:center;padding:14px 10px;font:12px/1.6 ui-monospace,Menlo,Consolas,monospace;color:#fecaca}
  .wb-face canvas{position:absolute;inset:0;width:100%;height:100%}
  .wb-label{position:absolute;left:0;right:0;bottom:0;padding:18px 10px 7px;font-size:13px;font-weight:600;background:linear-gradient(transparent,rgba(0,0,0,.85));z-index:2;display:flex;justify-content:space-between;align-items:center;gap:4px}
  .wb-act{font-size:10.5px;font-weight:500;border:1px solid rgba(255,255,255,.3);border-radius:6px;padding:0 5px;white-space:nowrap}
  .wb-btn{position:absolute;bottom:30px;width:34px;height:34px;border-radius:50%;border:1px solid rgba(255,255,255,.12);background:#16161c;color:#fff;font-size:20px;line-height:1;cursor:pointer;z-index:3}
  .wb-btn:hover{border-color:var(--acc)}.wb-btn.l{left:12px}.wb-btn.r{right:12px}`;

  function copyText(t) {
    if (navigator.clipboard) return navigator.clipboard.writeText(t).catch(() => fallback(t));
    return fallback(t);
    function fallback(s) { const ta = document.createElement('textarea'); ta.value = s; document.body.appendChild(ta); ta.select(); try { document.execCommand('copy'); } finally { ta.remove(); } return Promise.resolve(); }
  }

  function WidgetBoard(o) {
    o = Object.assign({ items: [], accent: '#e11d2e', particles: true, showAfter: null, mount: document.body }, o);
    if (!document.getElementById('wb-css')) { const s = document.createElement('style'); s.id = 'wb-css'; s.textContent = CSS; document.head.appendChild(s); }
    const RM = matchMedia('(prefers-reduced-motion: reduce)').matches;
    const wh = document.createElement('nav'); wh.className = 'wb-wheel'; wh.style.setProperty('--acc', o.accent); wh.setAttribute('aria-label', 'Quick widgets');
    const ring = document.createElement('div'); ring.className = 'wb-ring'; wh.appendChild(ring);
    const cards = o.items.map((it, k) => {
      const c = document.createElement(it.href || it.section ? 'a' : 'button');
      c.className = 'wb-card';
      if (it.href) { c.href = it.href; if (/^https?:/.test(it.href)) { c.target = '_blank'; c.rel = 'noopener'; } }
      if (it.section) c.href = '#' + it.section;
      const face = document.createElement('div'); face.className = 'wb-face';
      if (it.img) face.style.backgroundImage = `url(${it.img})`;
      if (it.html) face.innerHTML = it.html;
      if (it.bg) face.style.background = it.bg;
      const lab = document.createElement('span'); lab.className = 'wb-label'; lab.textContent = it.label;
      const verb = it.copy ? '⧉ Copy' : it.actionLabel || '';
      if (verb) { const a = document.createElement('em'); a.className = 'wb-act'; a.style.fontStyle = 'normal'; a.textContent = verb; lab.appendChild(a); c._act = a; }
      c.append(face, lab); ring.appendChild(c);
      c.addEventListener('click', e => {
        if (k !== i) { e.preventDefault(); set(k); return; }
        if (it.copy) { e.preventDefault(); copyText(it.copy).then(() => { c._act.textContent = '✓ Copied'; setTimeout(() => c._act.textContent = '⧉ Copy', 1600); }); }
        else if (it.action) { e.preventDefault(); it.action(e); }
      });
      return c;
    });
    const L = document.createElement('button'), R = document.createElement('button');
    L.className = 'wb-btn l'; L.textContent = '‹'; L.setAttribute('aria-label', 'Previous');
    R.className = 'wb-btn r'; R.textContent = '›'; R.setAttribute('aria-label', 'Next');
    wh.append(L, R); o.mount.appendChild(wh);
    const N = cards.length; let i = 0;
    function set(n) {
      i = ((n % N) + N) % N;
      const sp = Math.min(130, wh.clientWidth / 4.6);
      cards.forEach((c, k) => {
        let d = ((k - i) % N + N) % N; if (d > N / 2) d -= N; const ad = Math.abs(d);
        c.style.transform = `translateX(${d * sp}px) translateZ(${-ad * 90}px) rotateY(${-d * 28}deg) scale(${ad ? 0.86 : 1})`;
        c.style.opacity = ad > 2 ? 0 : ad > 1 ? 0.45 : 1; c.style.zIndex = 10 - ad; c.style.pointerEvents = ad > 2 ? 'none' : 'auto';
        c.classList.toggle('front', !d); c.tabIndex = ad > 2 ? -1 : 0;
        const it = o.items[k];
        if (ad <= 1 && it.img && o.particles && !RM && !c._pm && g.ParticleMedia) {
          c._pm = 1; const face = c.querySelector('.wb-face'); const im = new Image(); im.src = it.img;
          const cv = document.createElement('canvas'); face.appendChild(cv);
          if (g.ParticleMedia(cv, im, { density: 1.5, max: 5000, fps: 30, point: 2, cut: 0.03, radius: 0.4, strength: 0.3, intro: 800, tint: o.accent, tintAmount: 0.35, target: c })) face.style.backgroundImage = 'none'; else cv.remove();
        }
      });
    }
    L.onclick = () => set(i - 1); R.onclick = () => set(i + 1);
    wh.addEventListener('keydown', e => { if (e.key === 'ArrowLeft') set(i - 1); if (e.key === 'ArrowRight') set(i + 1); });
    let acc = 0; wh.addEventListener('wheel', e => { e.preventDefault(); acc += e.deltaY + e.deltaX; if (Math.abs(acc) > 60) { set(i + Math.sign(acc)); acc = 0; } }, { passive: false });
    let sx = null; wh.addEventListener('pointerdown', e => { sx = e.clientX; }); addEventListener('pointerup', e => { if (sx !== null && Math.abs(e.clientX - sx) > 30) set(i + (e.clientX < sx ? 1 : -1)); sx = null; });
    addEventListener('resize', () => set(i));
    const secs = o.items.map((it, k) => [it.section && document.getElementById(it.section), k]).filter(x => x[0]);
    if (secs.length) { const io = new IntersectionObserver(es => es.forEach(e => { if (e.isIntersecting) { const f = secs.find(s => s[0] === e.target); if (f) set(f[1]); } }), { rootMargin: '-45% 0px -50% 0px' }); secs.forEach(s => io.observe(s[0])); }
    const gate = o.showAfter && document.querySelector(o.showAfter);
    if (gate) new IntersectionObserver(es => wh.classList.toggle('show', !es[0].isIntersecting), { threshold: 0.35 }).observe(gate); else wh.classList.add('show');
    set(0);
    return { set, el: wh };
  }
  g.WidgetBoard = WidgetBoard;
})(typeof window !== 'undefined' ? window : this);
