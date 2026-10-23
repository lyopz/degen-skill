# Roblox lessons log (grows with every project)

Every Roblox agent and session that builds or fixes Roblox code **reads this before starting** and **adds to it after finishing**.
One line per lesson, newest at top, grouped by topic. Format: `- YYYY-MM-DD [project] lesson — fix/pattern (file or template)`.
When a lesson repeats 2–3 times or is clearly general, promote it into `SKILL.md` (or a template) and delete the lines here.

## Data & saving
## Security & remotes
- 2026-10-23 [island-test] Free Creator Store models can carry backdoors: a "low poly palm" hid Scripts under `Extra > Humanoid > HumanoidDescription`. After every insert, list `LuaSourceContainer` descendants and delete the model if decor has scripts. MCP `insert_asset` returning `sandboxed:true` means it found scripts. Keyword-stuffed names are usually reuploads; plain name + older ID was clean ("Stylized Palm Tree" 9851468187).
## Purchases
## Performance
- 2026-10-23 [island-test] Free Creator Store decor: one clean asset, `ScaleTo` 0.45–0.62 per copy with random yaw + ±5–8° lean, all Anchored, leaves CanCollide off. Reads as variety and costs nothing.
## UI
## Animation & VFX
- 2026-10-23 [island-test] Real ocean waves = EditableMesh radial grid (dense near the island, wide rings to the horizon) moved every frame with 4 Gerstner waves + analytic normals; ships/trees move client-side via CollectionService tags. Studio cost ~5 ms per update for ~7.4k verts, so the update rate adapts (every 2nd/3rd frame when slow). (roblox-templates: Waves, OceanMesh, OceanClient)
- 2026-10-23 [island-test] ParticleEmitters under an Attachment: parent the Attachment before setting `WorldPosition`, otherwise the world coords become local offsets and the flames land far away.
## Studio / tooling (MCP, import, plugins)
- 2026-10-23 [island-test] EditableMesh in play needs Game Settings > Security > allow Mesh/Image APIs (error: "EditableMesh is not accessible"). The server and edit mode can create one even when clients can't, so decide fallbacks on the client. Client terrain edits (WriteVoxels) didn't apply in MCP play tests; style terrain water with client-side property changes instead.
- 2026-10-23 [island-test] EditableMesh → MeshPart: max extent 2048 studs; the part keeps the size it was created with, so a flat mesh gets Size.Y 0.001 and squashes later motion. Add two tiny hidden triangles at ±max height before `CreateMeshPartAsync`.
- 2026-10-23 [island-test] Terrain water stays visible at `WaterTransparency = 1`, so a wave mesh dipping under it shows cyan patches. Lift the waves (mean + max amplitude, scaled by wave strength) so troughs never go below the terrain water surface.
- 2026-10-23 [island-test] Bright cartoon preset (Brightness 3) multiplies vertex colors: mid-blue (12,105,165) rendered as flat cyan. Ocean base colors had to be ~1/3 as bright: shallow (18,95,100), deep (3,24,55).
- 2026-10-23 [island-test] Narrow terrain peaks render as flat mesas at lower terrain LOD (captures and weak devices) while raycasts still hit the real peak. Use broad hills with flat tops for landmarks, and sink poles 5+ studs so they never look like they float.
- 2026-10-23 [island-test] MCP `start_stop_play` spawns like "Play Here" (where the edit camera looks). Aim the edit camera at the spawn first. A SpawnLocation rotated sideways (e.g. to make a round cylinder) spawns players off to the side: keep the SpawnLocation flat and invisible on top of a decorative part.
- 2026-10-23 [island-test] `screen_capture` sometimes hangs over 120 s on models with 1000+ parts; skip those (too heavy for phones anyway). Of 7 free pirate ships, 2 had hidden scripts; the clean light one was 127437169533552 (28 MeshParts, cartoon style).
- 2026-10-23 [island-test] Terrain voxels are 4 studs and hold one material. Sand surface inside the top water layer (y −4..0) gets no water over it and shows as a dry pit below sea level. Keep underwater shelves ≤ −8 (tops ~−10) and let island slopes cross sea level steeply.
- 2026-10-23 [island-test] `screen_capture` right after a big terrain edit can show a stale or broken mesh. Check voxels (raycast grid / `ReadVoxels`) or capture again before "fixing" it.
- 2026-10-23 [island-test] `Lighting.Technology` can't be read or written from MCP `execute_luau` (RobloxScript capability). Even reading it in `return` errors the call; wrap in `pcall` and set Future by hand in Properties. The rest of the maps.md preset applies fine.
- 2026-10-23 [island-test] Ground height for placing props: raycast with Include={Terrain}, `IgnoreWater=true`. Sink trunks 1 stud. Spawn on slopes: raycast 4 corners + center, put the top at the highest hit.
## Workflow (what made building faster)
- 2026-10-23 [island-test] Island from a height map + one WriteVoxels call (coastline R(θ) = base + 3 sines, beach/plateau/hill profile, material by height and slope) beats stacking FillBalls: gentle beaches, controllable shape, and the same R(θ) feeds the shore foam.
- 2026-10-23 [island-test] Island recipe: `Clear` → water FillBlock (−28..0) → sand seafloor → shelf → 2–3 overlapping sand `FillBall`s with centers far below the surface (organic low dome). Sand color (246,205,120), WaterColor (40,200,220), WaterTransparency 0.6 + bright cartoon preset = turquoise cartoon sea.
- 2026-10-23 [island-test] Pull `~/.claude/degen-skill` at the start of every session. The local clone was 8 commits behind and missed roblox-art-style and this file.
