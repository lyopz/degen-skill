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
## Animation & VFX
## Studio / tooling (MCP, import, plugins)
- 2026-10-23 [pet-sim] MCP execute_luau runs in its own VM: `_G` set by game scripts is invisible to it. Drive dev tools through a Studio-only DevCommand remote from the Client datamodel; call RemoteFunctions with InvokeServer.
- 2026-10-23 [pet-sim] A whole Model (the hub island) got moved ~11 studs in Studio while building (likely a stray editor drag/select) and covered the plaza; screenshots showed an empty floor. Lock finished map parts (`Locked=true`) and sanity-check a few anchor positions before trusting a capture.
- 2026-10-23 [pet-sim] `screen_capture` draws BillboardGuis a few studs off to the side of their adornee at wide FOV; judge label placement from a close shot, not the spawn capture.
## Workflow (what made building faster)
- 2026-10-23 [pet-sim] gpt-image with -Ref saved the reference instead of the result: ChatGPT re-renders the attachment as `alt="User attachment"` outside any message-role element. Fixed in `assets/roblox-app/gpt-image.mjs` (skip user attachments, prefer `data-testid*="generated-image"`). Always hash-check queue outputs; a result in < 25 s is suspicious.
- 2026-10-23 [pet-sim] ChatGPT ignores "white background" on dark/glowing pets (adds a dark glow haze) → fix with a -Ref edit asking for white; that edit can return a transparent PNG → flatten onto white (System.Drawing, no PIL here).
- 2026-10-23 [pet-sim] A -Ref "edit this exact picture" keeps camera angle and proportions; turning to three-quarter or forcing 1:1:1 in an edit is ignored → put view + proportions in the FIRST prompt.
- 2026-10-23 [pet-sim] Hub sightlines: before placing tall side props, compute the spawn->portal ray x at that z (x = portalX * (z - spawnZ)/(portalZ - spawnZ)) and keep props outside it; moved Assembly Lab + leaderboards out of the portal view this way. Neon under Brightness 3: use deeper colors (violet (100,50,235), gold (235,150,20)); lighter violet renders pink and gold renders lemon yellow.
- 2026-10-23 [play-session study] watch-play.ps1 left no `sheets/` and no notes text; built sheets with `roblox-game-study/scripts/make-sheets.ps1`. Like/dislike marks can be misclicks — wait for/accept lyopz's correction before writing dislikes into taste.md.
