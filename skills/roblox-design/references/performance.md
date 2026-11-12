# Roblox performance budgets (so "cool" still runs on phones)

## Meshes & textures
- 20,000 triangles max per mesh (accessories 4,000). Tiny prop 50–500, normal 1k–10k (repeated 3–4k), big environment 10–18k, hero 10–20k.
- Textures: 256 small / 512 medium / 1024 max. Reuse materials and textures across props.
- Roblox auto-generates 4 LODs per mesh; `RenderFidelity = Performance` for background props, `Precise` only for hero items.
- `Model.LevelOfDetail = StreamingMesh` for big models outside the streaming radius.

## Collision & physics
- CollisionFidelity: **Box** (cheapest) for decor with CanCollide off; Hull for simple solid props; Default/PreciseConvexDecomposition only where players really touch the shape.
- Collision data stays in the file even with CanCollide off, so Box keeps memory low.
- Visual-only parts: CanCollide, CanTouch, CanQuery = false; Anchored = true.

## World
- `Workspace.StreamingEnabled = true` for big maps; keep important stuff in `ModelStreamingMode = Persistent` only when required.
- Fewer, bigger MeshParts beat thousands of small Parts; union sparingly (unions are heavy); use Terrain for ground/water.
- Lights: limit shadow-casting lights; most decorative PointLights `Shadows = false`.

- **(2026-11-12)** Studio **Performance Simulator** emulates a lower-end device's graphics + memory — run it before phone playtests on big maps. https://devforum.roblox.com/t/test-graphics-and-memory-on-lower-end-devices-with-the-performance-simulator/4979313
- **(2026-11-07)** Min draw distance is now 500 studs even on the lowest quality (was 200): more of the map renders on phones, so far scenery must stay cheap (few big MeshParts, no lights/emitters far out). https://devforum.roblox.com/t/increasing-the-minimum-draw-distance-to-500-studs-and-other-auto-quality-level-improvements/4977292

## Effects
- Under ~50 live particles per emitter for most effects; atlas/flipbook textures; disable emitters far from the camera or off-screen.
- Post-processing optional on mobile (graphics setting / auto-detect).
- **(2026-11-03)** Rate-based emitters are thinned by the graphics level (`:Emit` isn't) — budget and test both. `TweenService:Create` allocates an Instance per call: hot paths (every hatch/hit) use pooled instances + one manual stepper (`roblox-vfx` §6b). Animated surface Textures: ~525 at 20 Hz ≈ 0.65 ms — cache attributes, don't call GetAttribute per tick. Multi-reveal screens: only the rarest slot keeps lights (≤ 2). Card reels: virtualise cards, pre-warm one art per id, sweep with `UIGradient.Offset`, one Highlight per batch Model.

## Motion cost (2026-11-03)
- `Model:ScaleTo` ≈ 0.19 ms on a ~23-part model (`PivotTo` 0.017): continuous breathing via ScaleTo took 6 pets 0.47 → 1.1 ms/frame. Throttle breathing-only scales to ~8 Hz per model (staggered, near the camera only), full rate only while a squash plays. Measure with a self-timing attribute + the Low-quality toggle.
- Anchored rigs: one `workspace:BulkMoveTo` per frame for all parts; spinners: flat (unbevelled) gears save ~60 % of tris.

## Part count (2026-11-03)
- `GeometryService:UnionAsync` with UsePartColor=false keeps each part's colour but renders the whole union in ONE material (the first part's — a Neon bit makes wood glow): group merges by Material + MaterialVariant + Reflectance (+ collision/shadow), per parent model and 32-stud cell, ≤ 60 parts per union (12.8k → 7.4k parts, no visible change). CollisionFidelity Box comes back Hull.
- A Ball part is ~380 tris: small rotated blocks (12 tris) for flowers/filler.

## Phones + measuring (2026-11-03)
- Treat touch-only devices (`TouchEnabled and not KeyboardEnabled`) as Low quality (phones report Automatic): one shared check in every FX script. Phone LOD inside one model: a `RunContext = Client` Script in it that destroys `PCOnly`-attribute parts on touch-only devices (streaming off; with streaming on that Script doesn't run → PlayerGui LocalScript).
- A fixed 30 Hz step at 40–60 fps moves things every 2nd/3rd frame (choppy): step every rendered frame while busy, 30 Hz only idle. Pre-build reveal models hidden at the press and cache their BaseParts.
- Sum placed tris per plot/scene, not per asset (one plot: 23 bushes × 4.5k + 7 trees × 15k ≈ 210k of 455k); crowd foliage goes on the low/medium tier even when the game default is high.
- Studio Play frame times measure the PC: take the effect's DELTA over an idle sample in the same session (Heartbeat dt + `Stats.HeartbeatTimeMs` + RenderCPUFrameTime, plus a camera-at-sky sample); absolute targets need MicroProfiler or a phone. Never time while a screen-grab loop runs (~2× inflated): A/B in back-to-back clean Play sessions. FX that freeze past a LOD distance: put the Play camera next to the model before judging motion.

## Cutting tris & lights (2026-11-10)
- Measure real tris before planning cuts (an audit count was 110k stale): EditableMesh face count per unique MeshId, cached (`roblox-3d-pipeline` quality-gates). Count tris × instances — 13 cloned wall panels held more rivet tris (~26k) than the dome; merging adjacent rivet rows, 5-sided studs under 0.3 studs and dropping hidden rows cut 24k with no silhouette change.
- Static grass tufts → ~12 merged sector clumps (476 → 12 parts); keep a few dozen live tufts where sway/push-away is seen.
- Light pools without lights: invisible 0.05-stud Part + Top Decal (radial glow, tinted Color3, Transparency 0.55–0.72) 0.04 above the floor — cheaper than lights and doesn't count toward the light cap. A real SpotLight over an amber shaft: keep it a shade lighter than the shaft (#FFCF85 over #FFC15A) so a cyan hero under it doesn't go orange.

## Scripts & UI
- Run cosmetic motion (spin/bob/sway) on the **client**, not the server.
- Don't update UI or tween every frame without need; throttle labels to change-only or 0.1 s.
- Disable whole ScreenGuis; pool list items; one CanvasGroup fade instead of many tweens.

## Source
Nilo — optimize for the Roblox polygon limit: https://nilo.io/articles/optimize-3d-models-roblox-limit · simplified.media UI systems: https://simplified.media/guides/roblox-ui-systems
