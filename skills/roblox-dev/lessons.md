# Roblox lessons log (grows with every project)

Every Roblox agent and session that builds or fixes Roblox code **reads this before starting** and **adds to it after finishing**.
One line per lesson, newest at top, grouped by topic. Format: `- YYYY-MM-DD [project] lesson — fix/pattern (file or template)`.
Promoted 2026-11-11: 24 Build-A-Pet plot-ring lessons (11-10) → roblox-dev §7 (plots/clones/archives, render privacy), floating-islands (edges, walk-floor coverage, jump chains), performance (tri/light cuts), roblox-import (kit offsets), modeler/reviewer/map-builder agents; 672 already-promoted lines re-added by a stale copy (Nov 10 commits) were dropped — 3rd time: on the PC, `git pull` before appending. 2026-11-09: 5 Collided City r2b lessons → floating-islands Checks/Layout, reviewer agent, roblox-dev §7; 664 already-promoted lines re-added again by a stale copy (Nov 9 commit) were dropped. 2026-11-05: 110 new lessons (11-03..11-05, Build-A-Pet r24–r48) → roblox-dev §2/§3/§4/§6/§7, ui.md "From projects (2026-11-05)", roblox-vfx §6c (auras), chatgpt-prompts, 3d-pipeline roblox-import, reviewer/ui-designer/vfx-artist agents; 554 already-promoted lines re-added by a stale copy were dropped. Earlier: 2026-11-03 (~940 lessons). Append only your OWN new lines — never paste an old copy of this file back.

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
- 2026-11-10 (vfx, Scrap room) keep the SpotLight a shade lighter (#FFCF85) than the amber shaft (#FFC15A) so a cyan hero doesn't go orange (light pools → performance.md).
- 2026-11-10 (map-builder): islet outline mapping: in the islet pivot frame (angle = atan2(z,x)) the report outline radius is r_at(angle - 90); with +90 coverage drops to ~96%, so check the mapping first when coverage looks off.
- 2026-11-10 (map-builder, ring r43) An off-centre exit gap came from the lane line, not the walls: FitRimGap aimed Islet_01 -> plot pivot, but players (and the reviewer's rays) run Islet_01 floor centre -> plot centre (9.2,-1.9); over ~25 studs that bends the gap ~2 studs. Measure "centred" from the same centre the bearings use, and prove it with the ray sweep (one gap, side clearance diff <= 0.4).
- 2026-11-10 (map-builder, ring r43) Collider overhang is usually a few bad vertices, not a uniform offset: a flat 0.5 inset of the 16 islet edge radii cut overhang 43 -> 20 but dropped coverage to 93%; refitting each radius to the r_at outline offline (numpy 0.5 grid + coordinate descent, cost = overhang + 40 x max(0, 98 - coverage)) gave 0.25-2.25 sq studs at 97.7-98.1%. Box-fidelity MeshParts (islet Body) can't be raycast for their real top: use the build report outline.
