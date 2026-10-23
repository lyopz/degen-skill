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

## Effects
- Under ~50 live particles per emitter for most effects; atlas/flipbook textures; disable emitters far from the camera or off-screen.
- Post-processing optional on mobile (graphics setting / auto-detect).

## Scripts & UI
- Run cosmetic motion (spin/bob/sway) on the **client**, not the server.
- Don't update UI or tween every frame without need; throttle labels to change-only or 0.1 s.
- Disable whole ScreenGuis; pool list items; one CanvasGroup fade instead of many tweens.

## Source
Nilo — optimize for the Roblox polygon limit: https://nilo.io/articles/optimize-3d-models-roblox-limit · simplified.media UI systems: https://simplified.media/guides/roblox-ui-systems
