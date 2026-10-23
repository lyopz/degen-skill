# Start here (new session)

Repo: github.com/lyopz/degen-skill — cloned on lyopz's PC at `C:\Users\edpfl\.claude\degen-skill`, with junctions for skills, agents and commands. **Everything lives in this repo**: push to GitHub, then lyopz runs `cd $HOME\.claude\degen-skill; git pull --no-edit` (the apps also pull when opened). He likes short, plain answers; PowerShell commands run in normal PowerShell.

## Roblox setup
- **Degen Roblox app** (`assets/roblox-app/`):
  - `launch.ps1` starts `server.ps1` (localhost:7777) and opens the app.
  - Send / "Hey Claude" → `lead-start.ps1` → `lead-run.ps1` opens a Claude Code **Lead** window (Studio + Higgsfield MCP, rules in `lead.md`).
  - Approvals: `ask-hook.ps1` and `ask.ps1`, with Decline / Delete.
  - Activity: `activity-hook.ps1` writes `~/RobloxGames/.degen/activity.json`.
  - Projects bubble, imports, voice ring.
- **Pictures:** always ChatGPT, through `gpt-image.ps1` + `gpt-image.mjs`.
  - Edge on port 9333 with Playwright, profile `DegenChatGPT`.
  - One asset per picture, on a white background.
  - `-Ref` edits an existing picture.
  - The result goes straight to the modeler.
- **Models (from 2026-10-23):** ChatGPT picture → Customuse image-to-3D, low poly, textured, .glb → Studio (`customuse-design`; `customuse-3d.ps1` by hand until the MCP is set up with `customuse-setup.ps1`). Blender only for fixes. Old rule (Blender rebuild part by part):
  - `roblox-asset-shapes/references/blender-part-by-part.md`
  - `roblox-asset-shapes/scripts/compare_to_siblings.py`
- **Lead rules:**
  - Execute, don't ask.
  - Project = the Studio place name (`~/RobloxGames/<place>`), with a HANDOFF.md per project.
  - Edits change only what was asked, in the same .blend.
  - Save tokens.
- **Skills:**
  - roblox-design
  - roblox-art-style (bibles + `references/chatgpt-prompts.md`)
  - roblox-assets
  - roblox-asset-shapes
  - roblox-templates
  - roblox-game-study
  - roblox-game-strip
  - roblox-shops
  - roblox-playtest
  - roblox-dev (+ lessons.md)
  - 3d-assets
  - customuse-design (Customuse designs + `references/taste.md`, lyopz's likes/dislikes; rate with `design-feedback.ps1`)
- **Agents:** `agents/roblox/` (8). **Command:** `/roblox`.

## Games
Starting fresh as of 2026-10-23: old game folders were moved to `~/RobloxGames/_archive/`. Their style bibles (`roblox-art-style/projects/`) and the lessons are kept as examples and learned rules, not as active games.

## Still to verify on the PC
- the ChatGPT `-Ref` upload
- `compare_to_siblings.py`
- the Decline / Delete buttons
- Customuse MCP address (`customuse-setup.ps1`), `customuse-3d.ps1`, `design-feedback.ps1`
