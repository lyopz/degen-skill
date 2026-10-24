# Roblox lessons log (grows with every project)

Every Roblox agent and session that builds or fixes Roblox code **reads this before starting** and **adds to it after finishing**.
One line per lesson, newest at top, grouped by topic. Format: `- YYYY-MM-DD [project] lesson — fix/pattern (file or template)`.
When a lesson repeats 2–3 times or is clearly general, promote it into `SKILL.md` (or a template) and delete the lines here.
Promoted 2026-10-23: terrain/island/scatter → `roblox-design/references/maps.md`; VFX tuning/testing → `game-feel.md`; Creator Store backdoors + Studio MCP/EditableMesh gotchas → `roblox-dev/SKILL.md`; ChatGPT automation → `roblox-art-style/references/chatgpt-prompts.md`; smooth models → `roblox-modeler`.

## Data & saving
## Security & remotes
## Purchases
## Performance
## UI
- 2026-10-23 [pet-sim] A Folder of templates inside a ScreenGui still renders its GUI children → hold templates in a `Visible=false` Frame.
- 2026-10-23 [pet-sim] ButtonFeel's UIScale changes the size UIListLayout sees, so a hovered button pushes its row-mates → leave ~6% spare width in button rows. Short landscape phones (338 px tall with CoreUISafeInsets ≈ 405 design px) need a compact mode: pin side tiles to the top, 2×2 icon grid, panels 97% height.
- 2026-10-23 [pet-sim] Under the Studio Device Simulator, MCP `user_mouse_input` clicks don't reach GUI buttons → test menus via keyboard shortcuts or by toggling Visible; device simulator setters work from the Client datamodel in Play.
- 2026-10-23 [pet-sim] Global UIScale over Scale-sized UI: size the root at 1/scale (centered) so children still fill the screen; clamp the low end so 64 design-px buttons stay ≥ 44 px. ButtonFeel.Apply sets a "Feel" attribute — apply to the live root, never a Templates folder (clones would skip feel).
## Animation & VFX
- 2026-10-23 [pet-sim] Blender Standard view transform: strong emission on light vertex colors clips to pink/white. Use a dark base + deep violet emission; in Studio make glow pieces separate meshes set to Neon.
## Studio / tooling (MCP, import, plugins)
- 2026-10-23 [pet-sim] Syncing scripts into Studio: serve the scripts folder with `python -m http.server --bind 127.0.0.1`, GetAsync with HttpEnabled on only during the fetch, normalize `
` → `
`, `loadstring` to compile-check before setting `.Source`. Patch scripts that find/replace anchors break on CRLF vs LF — prefer syncing the whole file.
- 2026-10-23 [pet-sim] An unsaved Studio place can close mid-job (lost hub built only via execute_luau). Save new places to a file/Roblox before building; agents check `list_roblox_studios` before long jobs and keep code on disk + one install script so work survives a Studio drop.
- 2026-10-23 [pet-sim] Customuse CR1 image-to-3D = 100 credits per run, geometry only (no texture). Free texture: project the source picture onto the mesh from the matching view. Put 2–3 small parts spaced apart in ONE picture to get several meshes per run, then split by loose parts in Blender.
- 2026-10-23 [pet-sim] Base64 JPEG uploads to Customuse got corrupted (long white runs); a WebP exported from Blender (view transform Standard) uploaded byte-exact — md5-check uploads. Image-to-3D keeps the picture's camera angle: rotate + tilt parts to the mount before placing.
- 2026-10-23 [pet-sim] MCP execute_luau runs in its own VM: `_G` set by game scripts is invisible to it. Drive dev tools through a Studio-only DevCommand remote from the Client datamodel; call RemoteFunctions with InvokeServer.
- 2026-10-23 [pet-sim] A whole Model (the hub island) got moved ~11 studs in Studio while building (likely a stray editor drag/select) and covered the plaza; screenshots showed an empty floor. Lock finished map parts (`Locked=true`) and sanity-check a few anchor positions before trusting a capture.
- 2026-10-23 [pet-sim] `screen_capture` draws BillboardGuis a few studs off to the side of their adornee at wide FOV; judge label placement from a close shot, not the spawn capture.
## Workflow (what made building faster)
- 2026-10-23 [pet-sim] Building parts to the bible's size caps made the pet much tamer than the approved concept (small horns/wings). The approved picture beats the caps: measure part sizes from the concept relative to the body and raise the caps if needed.
- 2026-10-23 [pet-sim] gpt-image with -Ref saved the reference instead of the result: ChatGPT re-renders the attachment as `alt="User attachment"` outside any message-role element. Fixed in `assets/roblox-app/gpt-image.mjs` (skip user attachments, prefer `data-testid*="generated-image"`). Always hash-check queue outputs; a result in < 25 s is suspicious.
- 2026-10-23 [pet-sim] ChatGPT ignores "white background" on dark/glowing pets (adds a dark glow haze) → fix with a -Ref edit asking for white; that edit can return a transparent PNG → flatten onto white (System.Drawing, no PIL here).
- 2026-10-23 [pet-sim] A -Ref "edit this exact picture" keeps camera angle and proportions; turning to three-quarter or forcing 1:1:1 in an edit is ignored → put view + proportions in the FIRST prompt.
- 2026-10-23 [pet-sim] Hub sightlines: before placing tall side props, compute the spawn->portal ray x at that z (x = portalX * (z - spawnZ)/(portalZ - spawnZ)) and keep props outside it; moved Assembly Lab + leaderboards out of the portal view this way. Neon under Brightness 3: use deeper colors (violet (100,50,235), gold (235,150,20)); lighter violet renders pink and gold renders lemon yellow.
- 2026-10-23 [play-session study] watch-play.ps1 left no `sheets/` and no notes text; built sheets with `roblox-game-study/scripts/make-sheets.ps1`. Like/dislike marks can be misclicks — wait for/accept lyopz's correction before writing dislikes into taste.md.
