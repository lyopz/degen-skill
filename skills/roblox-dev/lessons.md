# Roblox lessons log (grows with every project)

Every Roblox agent and session that builds or fixes Roblox code **reads this before starting** and **adds to it after finishing**.
One line per lesson, newest at top, grouped by topic. Format: `- YYYY-MM-DD [project] lesson — fix/pattern (file or template)`.
Promoted 2026-11-17: 2 opening/clone lessons → roblox-animator agent (step 8). Promoted 2026-11-16: 13 lessons (11-15/11-16 Build-A-Pet arenas + Dynamo) → roblox-dev §7 (PrimaryPart pivot + random insert yaw; "Play tests & resumes": post-teleport wait, Escape for result cards, Scriptable camera before on-screen gates, resume a closed Lead from disk, roblox-assets.json after concurrent uploads), performance.md (tri profiling per build line), maps.md (fallback exits, ClockTime jumps), modeler/reviewer/vfx-artist/map-builder agents (moss sleeve, glow caps, both-face panels, bbox-centre on-screen checks, calm-opening rule + burst flag, GLB 180°/ApplyMesh); ~700 already-promoted lines re-added by a stale copy (Nov 16 03:00 commit) dropped — 6th time. Earlier promotions: see git history (2026-10-23..11-15). **On the PC: `git pull` BEFORE appending, and append only your OWN new lines — never paste an old copy of this file back.**

## Data & saving
## Security & remotes
## Purchases
## Performance
## UI
## Animation & VFX
- 2026-11-16 (build-a-pet, modeler): to thread a ring between fins, solve its height from the recorded fin cross-sections but set its tilt by hand (auto-solve gave an unusable 61.7°).
## Studio / tooling (MCP, import, plugins)
## Workflow (what made building faster)
- 2026-10-28 (lead): showcase.ps1 -Shots/-Files/-Concept paths are relative to the GAME folder (build-a-pet/), not the repo root; a wrong path is skipped silently and the Showcase entry has no pictures. Check the showcase folder has 1-*.jpg after saving.
- 2026-10-28 · An in-app save of a file (e.g. MASTER-PROMPT) can overwrite edits Claude made since the app loaded it: re-grep after lyopz saves and re-apply.
- 2026-11-04 (tools) reverse-game.ps1 runs one video at a time (fixed CDP port): wait for .degen/reverse/status.json "done":true before the next URL; fandom pages need the api.php?action=parse&prop=wikitext route (direct fetch 402).
