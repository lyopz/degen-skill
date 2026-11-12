# Roblox lessons log (grows with every project)

Every Roblox agent and session that builds or fixes Roblox code **reads this before starting** and **adds to it after finishing**.
One line per lesson, newest at top, grouped by topic. Format: `- YYYY-MM-DD [project] lesson — fix/pattern (file or template)`.
Promoted 2026-11-12: 4 lessons (11-10 Scrap-room spotlight shade → performance.md; islet outline mapping, collider refit, lane-centred rim gaps → floating-islands.md). 2026-11-11: 24 Build-A-Pet plot-ring lessons (11-10) → roblox-dev §7 (plots/clones/archives, render privacy), floating-islands (edges, walk-floor coverage, jump chains), performance (tri/light cuts), roblox-import (kit offsets), modeler/reviewer/map-builder agents; 672 already-promoted lines re-added by a stale copy (Nov 10 commits) were dropped — 3rd time: on the PC, `git pull` before appending. 2026-11-09: 5 Collided City r2b lessons → floating-islands Checks/Layout, reviewer agent, roblox-dev §7; 664 already-promoted lines re-added again by a stale copy (Nov 9 commit) were dropped. 2026-11-05: 110 new lessons (11-03..11-05, Build-A-Pet r24–r48) → roblox-dev §2/§3/§4/§6/§7, ui.md "From projects (2026-11-05)", roblox-vfx §6c (auras), chatgpt-prompts, 3d-pipeline roblox-import, reviewer/ui-designer/vfx-artist agents; 554 already-promoted lines re-added by a stale copy were dropped. Earlier: 2026-11-03 (~940 lessons). Append only your OWN new lines — never paste an old copy of this file back.

## Data & saving
## Security & remotes
## Purchases
## Performance
## UI
## Animation & VFX
## Studio / tooling (MCP, import, plugins)
## Workflow (what made building faster)
- 2026-10-28 (lead): showcase.ps1 -Shots/-Files/-Concept paths are relative to the GAME folder (build-a-pet/), not the repo root; a wrong path is skipped silently and the Showcase entry has no pictures. Check the showcase folder has 1-*.jpg after saving.
- 2026-10-28 · An in-app save of a file (e.g. MASTER-PROMPT) can overwrite edits Claude made since the app loaded it: re-grep after lyopz saves and re-apply.
- 2026-11-04 (tools) reverse-game.ps1 runs one video at a time (fixed CDP port): wait for .degen/reverse/status.json "done":true before the next URL; fandom pages need the api.php?action=parse&prop=wikitext route (direct fetch 402).
