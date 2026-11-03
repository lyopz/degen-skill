# Roblox lessons log (grows with every project)

Every Roblox agent and session that builds or fixes Roblox code **reads this before starting** and **adds to it after finishing**.
One line per lesson, newest at top, grouped by topic. Format: `- YYYY-MM-DD [project] lesson — fix/pattern (file or template)`.
Promoted 2026-11-03: ~940 lessons (10-26..11-03) → roblox-dev SKILL.md §2/§5/§6/§7 (Studio/MCP tooling, captures, Luau traps, tests), gotchas.md, ui.md + roblox-ui-maker, maps/floating-islands/first-try, roblox-vfx §6b + textures.md, game-feel, performance, pets-and-eggs, pet-movement, roblox-portals, vfx-combat, animation-audio, chatgpt-prompts, roblox-import, unity-polish, quality-gates, asset-shapes, roblox-assets, agent files. ~260 older lines were stale re-adds of already-promoted lessons and were dropped. Earlier promotions: see git history of this file.

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
