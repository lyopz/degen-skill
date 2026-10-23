/* particle-media.js — turn any image or video into liquid particles that flow away from the cursor.
   Original code for lyopz's degen-skill library (inspired by the "liquid sculpture" hero look on 21st.dev).
   No dependencies. WebGL2. MIT.

   Usage:
     const pm = ParticleMedia(canvas, sourceElement, { density: 2, radius: 0.22, strength: 0.18 });
     // sourceElement: <img> or <video> (video keeps updating live). Call pm.destroy() to stop.
     pm.setSource(el) swaps to another image/video (e.g. start on the poster image, switch when the video plays).
*/
(function (g) {
  const VS = `#version 300 es
  in vec2 aUV; in float aRand;
  uniform sampler2D uTex; uniform vec2 uMouse; uniform float uAspect, uTime, uRadius, uStrength, uIntro, uPoint, uCut, uAlpha, uTintAmt; uniform vec3 uTint;
  uniform vec2 uCoverS; uniform vec2 uCoverO;
  out vec4 vCol;
  float h(float n){return fract(sin(n)*43758.5453);}
  void main(){
    vec2 suv = aUV*uCoverS+uCoverO;
    vec4 c = texture(uTex, vec2(suv.x, 1.0-suv.y));
    float lum = dot(c.rgb, vec3(.299,.587,.114));
    vec2 p = aUV*2.0-1.0;
    vec2 pa = vec2(p.x*uAspect, p.y);
    vec2 d = pa - vec2(uMouse.x*uAspect, uMouse.y);
    float dist = length(d);
    float f = smoothstep(uRadius, 0.0, dist);
    vec2 dir = dist > 1e-4 ? d/dist : vec2(0.0);
    vec2 swirl = vec2(-dir.y, dir.x);
    vec2 off = (dir*(0.6+aRand) + swirl*0.8*(aRand-0.5)) * f * uStrength;
    off += vec2(sin(uTime*0.8+aRand*40.0), cos(uTime*0.7+aRand*31.0)) * 0.004 * (0.3+lum);
    pa += off;
    vec2 start = vec2(h(aRand*91.0)*2.0-1.0, h(aRand*57.0)*2.0-1.0) * vec2(uAspect*1.6, 1.6);
    float t = smoothstep(0.0, 1.0, clamp(uIntro*1.4 - aRand*0.4, 0.0, 1.0));
    pa = mix(start, pa, t);
    gl_Position = vec4(pa.x/uAspect, pa.y, 0.0, 1.0);
    float on = step(uCut, lum);
    gl_PointSize = uPoint * (0.7 + lum) * on;
    vec3 col = mix(c.rgb, uTint * (0.35 + 0.9*lum), uTintAmt);
    vCol = vec4(col * (0.85 + f*0.6), on * uAlpha * (0.35 + 0.65*lum));
  }`;
  const FS = `#version 300 es
  precision mediump float; in vec4 vCol; out vec4 o;
  void main(){ vec2 q = gl_PointCoord-0.5; float a = smoothstep(0.5, 0.15, length(q)); o = vec4(vCol.rgb, vCol.a*a); }`;

  function ParticleMedia(canvas, src, opt) {
    opt = Object.assign({ density: 2, radius: 0.22, strength: 0.18, point: 1.8, cut: 0.06, alpha: 0.8, tint: null, tintAmount: 0.6, follow: 0.08, intro: 1800, max: 60000, dpr: 1.5, fps: 60, videoFps: 15 }, opt || {});
    const gl = canvas.getContext('webgl2', { premultipliedAlpha: false, alpha: true });
    if (!gl) return null;
    const sh = (t, s) => { const x = gl.createShader(t); gl.shaderSource(x, s); gl.compileShader(x); if (!gl.getShaderParameter(x, gl.COMPILE_STATUS)) throw gl.getShaderInfoLog(x); return x; };
    const pr = gl.createProgram(); gl.attachShader(pr, sh(gl.VERTEX_SHADER, VS)); gl.attachShader(pr, sh(gl.FRAGMENT_SHADER, FS)); gl.linkProgram(pr); gl.useProgram(pr);
    const U = n => gl.getUniformLocation(pr, n);
    const tex = gl.createTexture(); gl.bindTexture(gl.TEXTURE_2D, tex);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR); gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE); gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, new Uint8Array([0, 0, 0, 0]));
    let count = 0, buf = gl.createBuffer(), W = 0, H = 0;
    let isVid = src.tagName === 'VIDEO';
    const mw = () => isVid ? src.videoWidth : src.naturalWidth, mh = () => isVid ? src.videoHeight : src.naturalHeight;
    function grid() {
      const dpr = Math.min(devicePixelRatio || 1, opt.dpr);
      W = canvas.clientWidth; H = canvas.clientHeight; canvas.width = W * dpr; canvas.height = H * dpr;
      gl.viewport(0, 0, canvas.width, canvas.height);
      let step = opt.density; if ((W / step) * (H / step) > opt.max) step = Math.sqrt((W * H) / opt.max);
      const cols = Math.floor(W / step), rows = Math.floor(H / step);
      const a = new Float32Array(cols * rows * 3); let k = 0;
      for (let y = 0; y < rows; y++) for (let x = 0; x < cols; x++) { a[k++] = (x + .5) / cols; a[k++] = (y + .5) / rows; a[k++] = Math.random(); }
      count = cols * rows;
      gl.bindBuffer(gl.ARRAY_BUFFER, buf); gl.bufferData(gl.ARRAY_BUFFER, a, gl.STATIC_DRAW);
      const l1 = gl.getAttribLocation(pr, 'aUV'), l2 = gl.getAttribLocation(pr, 'aRand');
      gl.enableVertexAttribArray(l1); gl.vertexAttribPointer(l1, 2, gl.FLOAT, false, 12, 0);
      gl.enableVertexAttribArray(l2); gl.vertexAttribPointer(l2, 1, gl.FLOAT, false, 12, 8);
      gl.uniform1f(U('uAspect'), W / H); gl.uniform1f(U('uPoint'), opt.point * dpr);
    }
    function cover() { // object-fit: cover
      const ar = W / H, mr = (mw() || 1) / (mh() || 1);
      let sx = 1, sy = 1; if (mr > ar) sx = ar / mr; else sy = mr / ar;
      gl.uniform2f(U('uCoverS'), sx, sy); gl.uniform2f(U('uCoverO'), (1 - sx) / 2, (1 - sy) / 2);
    }
    const m = { x: 9, y: 9, tx: 9, ty: 9 };
    const move = e => { const r = canvas.getBoundingClientRect(); const p = e.touches ? e.touches[0] : e; m.tx = ((p.clientX - r.left) / r.width) * 2 - 1; m.ty = -(((p.clientY - r.top) / r.height) * 2 - 1); };
    const leave = () => { m.tx = 9; m.ty = 9; };
    const host = opt.target || canvas.parentElement || canvas;
    host.addEventListener('pointermove', move); host.addEventListener('touchmove', move, { passive: true }); host.addEventListener('pointerleave', leave);
    gl.enable(gl.BLEND); gl.blendFunc(gl.SRC_ALPHA, opt.additive === false ? gl.ONE_MINUS_SRC_ALPHA : gl.ONE);
    gl.uniform1f(U('uRadius'), opt.radius); gl.uniform1f(U('uStrength'), opt.strength); gl.uniform1f(U('uCut'), opt.cut); gl.uniform1f(U('uAlpha'), opt.alpha);
    const tc = opt.tint ? opt.tint.replace('#', '').match(/../g).map(x => parseInt(x, 16) / 255) : [1, 1, 1];
    gl.uniform3f(U('uTint'), tc[0], tc[1], tc[2]); gl.uniform1f(U('uTintAmt'), opt.tint ? opt.tintAmount : 0);
    grid(); const ro = new ResizeObserver(grid); ro.observe(canvas);
    let t0 = performance.now(), raf = 0, uploaded = false, live = true, vis = true, last = 0, lastUp = 0;
    const io = new IntersectionObserver(es => { vis = es[0].isIntersecting; if (vis && live && !raf) raf = requestAnimationFrame(frame); }); io.observe(canvas);
    const onVis = () => { if (!document.hidden && vis && live && !raf) raf = requestAnimationFrame(frame); }; document.addEventListener('visibilitychange', onVis);
    function frame(now) {
      raf = 0;
      if (!live || !vis || document.hidden) return;
      if (now - last < 1000 / opt.fps - 2) { raf = requestAnimationFrame(frame); return; }
      last = now;
      const ready = isVid ? src.readyState >= 2 : src.complete && src.naturalWidth;
      if (ready && (!uploaded || (isVid && now - lastUp > 1000 / opt.videoFps))) {
        lastUp = now;
        gl.bindTexture(gl.TEXTURE_2D, tex);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, src);
        if (!uploaded && opt.intro) t0 = now; uploaded = true; cover();
      }
      m.x += (m.tx - m.x) * opt.follow; m.y += (m.ty - m.y) * opt.follow;
      gl.uniform2f(U('uMouse'), m.x, m.y); gl.uniform1f(U('uTime'), now / 1000);
      gl.uniform1f(U('uIntro'), opt.intro ? Math.min(1, (now - t0) / opt.intro) : 1);
      gl.clearColor(0, 0, 0, 0); gl.clear(gl.COLOR_BUFFER_BIT);
      if (uploaded) gl.drawArrays(gl.POINTS, 0, count);
      raf = requestAnimationFrame(frame);
    }
    raf = requestAnimationFrame(frame);
    return { count: () => count, setSource(el) { src = el; isVid = el.tagName === 'VIDEO'; uploaded = false; opt.intro = 0; }, destroy() { live = false; cancelAnimationFrame(raf); ro.disconnect(); io.disconnect(); document.removeEventListener('visibilitychange', onVis); host.removeEventListener('pointermove', move); host.removeEventListener('pointerleave', leave); } };
  }
  g.ParticleMedia = ParticleMedia;
})(typeof window !== 'undefined' ? window : this);
