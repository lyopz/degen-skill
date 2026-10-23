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
## Studio / tooling (MCP, import, plugins)
- 2026-10-23 [island-test] Terrain voxels are 4 studs and hold one material. Sand surface inside the top water layer (y −4..0) gets no water over it and shows as a dry pit below sea level. Keep underwater shelves ≤ −8 (tops ~−10) and let island slopes cross sea level steeply.
- 2026-10-23 [island-test] `screen_capture` right after a big terrain edit can show a stale or broken mesh. Check voxels (raycast grid / `ReadVoxels`) or capture again before "fixing" it.
- 2026-10-23 [island-test] `Lighting.Technology` can't be read or written from MCP `execute_luau` (RobloxScript capability). Even reading it in `return` errors the call; wrap in `pcall` and set Future by hand in Properties. The rest of the maps.md preset applies fine.
- 2026-10-23 [island-test] Ground height for placing props: raycast with Include={Terrain}, `IgnoreWater=true`. Sink trunks 1 stud. Spawn on slopes: raycast 4 corners + center, put the top at the highest hit.
## Workflow (what made building faster)
- 2026-10-23 [island-test] Island recipe: `Clear` → water FillBlock (−28..0) → sand seafloor → shelf → 2–3 overlapping sand `FillBall`s with centers far below the surface (organic low dome). Sand color (246,205,120), WaterColor (40,200,220), WaterTransparency 0.6 + bright cartoon preset = turquoise cartoon sea.
- 2026-10-23 [island-test] Pull `~/.claude/degen-skill` at the start of every session. The local clone was 8 commits behind and missed roblox-art-style and this file.
