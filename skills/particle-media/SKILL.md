---
name: particle-media
description: Turns any image or video into tens of thousands of glowing "liquid" particles that flow away from the cursor and settle back (WebGL2, no libraries). Use when lyopz wants a picture or video on a site to break into particles, react to the mouse, have a "liquid sculpture" / particle hero look, or asks to "do that particle effect" to his images or videos.
---

<!-- from: lyopz (own code, inspired by the liquid-sculpture-hero look on 21st.dev; no code copied) -->

# Particle Media

`particle-media.js` (in this folder) samples an `<img>` or `<video>` onto a grid of points. Each point takes its pixel's color, dark pixels are dropped, and points near the cursor get pushed and swirled, then drift back. Videos stay live: every frame recolors the particles.

## Use it

1. Paste the contents of `particle-media.js` into a `<script>` on the page (or load it as a file).
2. Put a `<canvas>` where the picture goes, sized with CSS (it fills its box like `object-fit: cover`).
3. Start it:
```js
const img = new Image(); img.src = 'hero.jpg';          // or a <video muted loop autoplay playsinline>
const pm = ParticleMedia(canvas, img, { tint: '#ff2a3d', density: 2 });
// optional: begin on the poster image, switch when the video starts
video.addEventListener('playing', () => pm.setSource(video), { once: true });
```
4. Hide the original image/video (keep a video in the DOM and playing, e.g. `opacity:0`) so only the particles show.

## Options
| option | default | what it does |
|---|---|---|
| `density` | 2 | pixels between particles (smaller = more) |
| `max` | 60000 | hard cap on particles; density is loosened to stay under it |
| `dpr` | 1.5 | max pixel ratio (lower = lighter on high-res screens) |
| `fps` | 60 | frame cap; 30 for small or background effects |
| `radius` | 0.22 | cursor reach (screen-height units) |
| `strength` | 0.18 | how far particles get pushed |
| `point` | 1.8 | particle size |
| `alpha` | 0.8 | overall brightness |
| `cut` | 0.06 | drop pixels darker than this (0–1) |
| `tint` / `tintAmount` | null / 0.6 | push colors toward a brand color |
| `follow` | 0.08 | how smoothly the effect trails the cursor (lower = more liquid) |
| `intro` | 1800 | ms for particles to fly in and assemble; 0 = off |
| `additive` | true | glowy blending; set false on light backgrounds |
| `target` | canvas parent | element that listens for the mouse |

## Notes
- Skip it when `prefers-reduced-motion` is set; show the plain image instead.
- `ParticleMedia` returns `null` without WebGL2, so keep the normal image visible as the fallback.
- The image must be same-origin or a data/blob URL (WebGL can't read cross-origin pixels without CORS).
- Works best on dark backgrounds with bright subjects. Add a dark gradient behind any text on top.
- Pauses by itself when scrolled off screen or the tab is hidden, so idle effects cost nothing.
- Keep it light: hero `max` 40–60k, small cards 6–10k with `fps: 30`. A video source re-uploads every frame, so use ~720p.
- Several on one page are fine (each is its own WebGL canvas). Start small ones lazily, e.g. on first hover or when scrolled into view.
- Examples in use on the Degen Skills showcase site:
  - **Hero:** an animated Higgsfield video, tinted red, full screen.
  - **Nav hover previews:** each menu tab's dropdown picture turns into particles on first hover (`density 1.4`, `radius .35`, `intro 900`).
  - **Closing banner:** a background picture behind the call-to-action, started when it scrolls into view.
