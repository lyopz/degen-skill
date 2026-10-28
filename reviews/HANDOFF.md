# Handoff

Read this first in any new conversation. It says where things stand so we can pick up without re-explaining.

## Owner preferences
- Short, direct answers.
- Sends skill repos one at a time.
- Every new skill goes to both the repo and his PC (push, then he runs `git pull`).
- When building a site, ask whether he wants animations (Higgsfield video, particle-media, motion).
- Sites: professional standard, a fresh design each time (not a copy of an old template). Tag each section with the skills it used.
- Prompts & designs: any prompt, look or design lyopz shares/approves (images, video, 3D, sites) gets added to `skills/3d-assets/prompts.md`; full worked examples go in `skills/3d-assets/examples/`.
- Roblox learning loop: every Roblox job reads and appends `skills/roblox-dev/lessons.md`, then commits + pushes. Promote repeated lessons into skills/templates.
- Roblox: two 3D tracks — web (`3d-assets`) vs Roblox (`roblox-assets`); always cheapest credits that still look pristine. New Roblox findings/rules go into `roblox-design/references/`. Each Roblox game gets a local style bible (`~/RobloxGames/<project>/art-style.md`, never in the repo); every new asset follows it. "Make it 10,000x cooler" → roblox-design checklist.
- "Widget board" = the bottom tab wheel (`widget-board`). Use the Degen Skills site version as the base idea; pick cards and actions (links, copy buttons…) by what matters for that project; follow his edits as he changes it.

## What this repo is
lyopz's personal skill library. Lives on GitHub at `lyopz/degen-skill` (public), cloned to `~/.claude/degen-skill`, with `~/.claude/skills`, `~/.claude/agents`, `~/.claude/commands` linked to its `skills/`, `agents/`, `commands/` folders. Reviews and registry are in `reviews/`. Each skill is a folder with a `SKILL.md`. The `skill-intake` skill holds the rules for adding, merging, and removing skills.

## Current status
- Setup done: `skill-intake`, `SKILLS_REGISTRY.md`, `HANDOFF.md`.
- Outside repos added (trial): DietrichGebert/ponytail (4 skills), addyosmani/agent-skills (4 skills + merges into ponytail/ponytail-review), Graphify-Labs/graphify (1), nextlevelbuilder/ui-ux-pro-max-skill (7), diegosouzapw/OmniRoute (45), ruvnet/ruflo (32 skills + 98 agents + 168 commands), multica-ai/andrej-karpathy-skills (merged into ponytail), karpathy/llm-council (method rewritten as own skill). 95 skills total (incl. lyopz's own `project-map`).
- Repo layout: `skills/`, `agents/`, `commands/`, `reviews/`, `assets/` + `README.md`. Front page = black/red catalog in plain language.
- lyopz is installing the OmniRoute app to stretch AI credits.
- Ruflo tools need the `claude-flow` MCP server added at user scope.
- Image generation: lyopz will add a custom Higgsfield connector in the Claude app. Once it exists, use it for image/video generation as needed (prefer it over the design skill's Gemini/Atlas/MuAPI scripts). ChatGPT idea dropped.

## Desktop app
- `assets/app/`: Degen Skills desktop app (Edge app-mode window). `launch.ps1` = git pull + build skills.js from SKILL.md files + open window; `install.ps1` makes Desktop/Start shortcuts.
- Skills show as piles by creator (from reviews/SKILLS_REGISTRY.md at build time) or by task. Skills added after the last build land in a "New" pile until `build.py` is rerun — rerun it whenever a skill is added. Prompt library is NOT shown in the app; `skills/3d-assets/prompts.md` is for Claude to use as examples.
- Design changes: edit `assets/app/src/template.html`, run `python assets/app/src/build.py`, commit `index.html`. New skills need nothing (app reads the skill folders). New "core" skills with plain descriptions go in `assets/make_assets.py` CORE.
- Also published as a claude.ai artifact ("Degen Skills") for previews.

## Degen Roblox app
- `assets/roblox-app/`: `launch.ps1` (pull, build roblox-data.js from roblox-* skills, agents/roblox, templates, style bibles, studies, references, lessons; sync Studio plugin; open app; open fast Roblox Claude in ~/RobloxGames), `install.ps1`, `index.html` (edit directly; data is live). Landing page = ▶ Start: task form → `degenroblox://task?b=<base64url brief>` → `start-task.ps1` opens a "Roblox Lead" Claude window (`--strict-mcp-config` Roblox_Studio only, `--append-system-prompt lead.md`, API key hidden). Protocol registered by `install.ps1` (rerun after changes). Shortcut opens the app only. Activity = right-side drawer (hook writes activity-data.js, app polls every 2 s; auto-opens when work starts). App look uses 21st-dev GlowCard + Spotlight ports — see assets/roblox-app/DESIGN.md (design skills are for the app, not the Roblox team). Anything Roblox-related added to the repo shows up automatically.

## Next up
- lyopz sends the next repo, or keeps/removes trial skills after using them.

## Open questions
- (none)

## Session Log
Newest at top. One short entry per session: date, what changed, anything left unfinished.

- **2026-10-28** — daily Roblox refresh: promoted ~90 lessons from Oct 27 (roblox-dev §2/§3/§5/§7 incl. team workflow, ui, vfx, 3d-pipeline, floating-islands, maps dusk skies, game-feel, pet-movement, chatgpt-prompts); dropped ~150 stale re-added lines + added an "append only your own lines" rule; fixed "Edit mode shows no particles" (it does); template `RemoteGuard` v2 (optional args, refusal codes, exactly-once nonces; not run in Studio — luau binary blocked here); maps top games (MM2 ~400k, DONT SPLASH obby riser). lessons.md emptied.
- **2026-10-27** — daily Roblox refresh: maps top-games table (Oct 27: Steal An Egg cooling to ~1M, The Hollow 209k peak, new Illegal Soccer / Huss Valley, horror risers) + The Hollow event-structure read; roblox-assets Texture Generator Fast/Quality (4K PBR); roblox-dev §8 Package Overrides beta; template `EventClock` v2 (claim `grace` window + `CanClaim`, not yet run in Studio). lessons.md was empty.
- **2026-10-26** — daily Roblox refresh: maps top-games table (Oct 26 snapshot; Steal An Egg Halloween Dimension 2M+ CCU, event recipe: event currency → event egg, Blood Moon 2x, train every 30 min); roblox-dev §8 game-specific Quick Words; liveops timed-event shape; new template `EventClock` (shared event schedule + countdown boards; logic checked offline, not yet run in Studio). lessons.md was already empty.
- **2026-10-25** — design/VFX/animation research (lyopz asked): maps.md "Free assets & new looks" (CC0 kits, skies, emissive masks, colour grading, wind, atmosphere, void preset, 12 zone ideas); roblox-vfx combat hits, impact frames, mesh slashes, MIT shaker/spring libs; pet-movement "Attack moves" timing table + 10 move ideas; new template `PetMoves` (not yet tested in Studio); removed stale duplicates (roblox-assets/scripts vfx+motion, roblox-design/scripts ButtonFeel → templates, particle-media/pm-bak).
- **2026-10-25** — daily Roblox refresh: promoted ~170 lessons (≈120 were already-promoted lines re-added by a stale PC copy; new ones → roblox-dev §3/§7, ui, vfx colours, game-feel reveals/audio, maps sky climbs, 3d-pipeline, pet-movement, pet-mouths, chatgpt-prompts; lessons.md emptied); maps top games (MM2 ~1.8M, Halloween updates); publishing: new Home right-pane test + ad/RFY tiles; UGC validation visualizer; SLIM StarterCharacters; reviewer pre-publish checks.
- **2026-10-24** — daily Roblox refresh: top-games table (MM2 Halloween surge to ~1.2M, horror spikes, climb-for-eggs), roblox-dev §8 (server-log deep links, TextChatService migration by May 2027, PromptCreatePlatformContentAsync, TTS asset beta, AvatarUnificationMode deprecation Dec 1); promoted ~110 lessons into roblox-dev/ui/vfx/maps/chatgpt-prompts/3d-pipeline/game-study (lessons.md emptied); new template `ConfirmToken`.
- **2026-10-23** — daily Roblox refresh: top-games table (Steal An Egg #1, steal+hatch hybrids), custom terrain materials launch, UIShadow, Collision Summaries + new `ImpactFX` template, platform updates in roblox-dev §8; promoted all lessons (lessons.md emptied).
- **2026-10-23** — Added Degen Roblox desktop app (`assets/roblox-app/`): brief builder, reference, team, templates, games, lessons; launcher also opens fast Roblox Claude (`--strict-mcp-config` with only Roblox_Studio, API key hidden). Added `roblox-design/references/first-try.md`; all Roblox agents follow spec → build one → check.
- **2026-10-23** — Added `roblox-dev` + templates RemoteGuard, PurchaseHandler. Roblox Studio MCP being set up on his PC (Claude desktop config). 126 skills.
- **2026-10-23** — Added `roblox-game-study` (study games for ideas; never extract/copy). 125 skills.
- **2026-10-23** — Added `roblox-templates` (Studio plugin "Degen Templates" + Documents\Roblox Templates, synced by launch.ps1). Daily Roblox refresh scheduled task (8:35 AM ET) also saves important templates. 124 skills.
- **2026-10-22** — Added the Roblox agent team (`agents/roblox/`, 8 agents; routing in AGENT_ROUTING.md). 83 agents.
- **2026-10-22** — Added own `roblox-art-style` (per-project style bibles, now kept locally in `~/RobloxGames/<project>/`). 123 skills. 
- **2026-10-22** — Added own `roblox-assets` and `roblox-design` (researched Roblox meta). 3d-assets now splits Web vs Roblox. 122 skills.
- **2026-10-22** — Robot chicken 3D model (Higgsfield, 35 credits) replaces the Spline robot in the app. Added own `3d-assets` skill (renamed from ai-3d-assets; examples + prompts.md library) (also for Roblox assets). Cursor particle effect follows faster. 120 skills.
- **2026-10-22** — Added emalorenzo/three-agent-skills (three-best-practices, r3f-best-practices). 119 skills.
- **2026-10-22** — Added Degen Skills desktop app (`assets/app/`), auto-updates from the repo on launch. Site made lighter (particle caps, pause off-screen).
- **2026-10-22** — Added own `widget-board` skill (bottom tab wheel of action cards: jump/link/copy). Cards are picked per project by relevance. 117 skills.
- **2026-10-22** — Added own `particle-media` skill (image/video → liquid cursor particles, WebGL2). Used it on the Degen Skills showcase hero. 116 skills.
- **2026-10-22** — 21st-dev: added spline-scene (3D Spline hero). Voice Powered Orb still to come.
- **2026-10-22** — Added `21st-dev` skill folder for lyopz's 21st.dev components (first: spotlight-card). 115 skills.
- **2026-10-21** — Added pbakaus/impeccable. 114 skills.
- **2026-10-20** — Added taste-skill (design-taste-frontend) and jcode's optimization skill. llm-council was already in. 113 skills.
- **2026-10-20** — Added kepano/obsidian-skills (6 Obsidian skills). 111 skills.
- **2026-10-20** — Added emilkowalski/skills (15 motion/UI-polish skills). 105 skills.
- **2026-10-18** — Cleaned agents (75 left: dropped migration docs, test-long-runner, 7 duplicates). Added `reviews/AGENT_ROUTING.md` (which agent for which task), imported from ~/.claude/CLAUDE.md. Commits now use lyopz's GitHub noreply email. Old commits still carry his real email; history rewrite pending his OK.
- **2026-10-18** — Added `llm-council` (own skill based on karpathy/llm-council's method; upstream app not installed: no license, needs OpenRouter key). Runs on Claude subagents, optional OmniRoute for other vendors. 90 skills.
- **2026-10-18** — Removed Flow Nexus + Codex dual-mode agents and /flow-nexus commands to match. 85 agents, 159 commands.
- **2026-10-18** — Removed 6 Ruflo trial skills (flow-nexus-*, dual-*): need paid cloud account / Codex CLI. 89 skills.
- **2026-10-18** — Added `project-map` (lyopz's own map viewer, blank template + builder from graphify output). Agent Office data not included. 95 skills.
- **2026-10-18** — Reorganized repo into skills/, agents/, commands/, reviews/. New black-and-red front page with plain-English descriptions. Repo now clones to ~/.claude/degen-skill with links. Walked lyopz through OmniRoute basics.
- **2026-10-18** — Added ruvnet/ruflo (32 skills, 98 agents, 168 commands). Skipped its internal v3 dev skills and auto-run hooks. Higgsfield connector pending on lyopz's side.
- **2026-10-18** — Added OmniRoute's 45 skills and the other 6 ui-ux-pro-max skills (incl. fonts + image generation). Moved registry/handoff to `_notes/`, new README catalog. Browser uploads got blocked partway, so lyopz pushed the rest from his PC.
- **2026-10-18** — Added ui-ux-pro-max (design database + search tool; needs Python on the PC). Merged karpathy-guidelines into ponytail. Skipped 6 extra ui-ux-pro-max skills.
- **2026-10-18** — Added Graphify-Labs/graphify (Windows variant). lyopz chose: map any project automatically. Kept a one-time ask before the Python install.
- **2026-10-18** — Reviewed 3 repos. Added 4 skills from addyosmani/agent-skills and merged 2 tagged blocks into ponytail skills. Skipped OmniRoute. graphify pending lyopz's call.
- **2026-10-18** — Added DietrichGebert/ponytail: ponytail, ponytail-review, ponytail-audit, ponytail-debt. Skipped gain/help and hooks.
- **2026-10-18** — Created the skill library: intake rules, registry, handoff file. Made repo public (personal details removed). Waiting on first repo from lyopz.

## 2026-10-23 — Degen Roblox app v3
- App now runs on a local server (`assets/roblox-app/server.ps1`, http://localhost:7777) started by launch.ps1. Send → server opens a Lead window (`lead-start.ps1`); `degenroblox://` stays as a fallback.
- Two-way approvals: `ask-hook.ps1` (PreToolUse on AskUserQuestion) sends questions to the app's Approvals bubble and returns lyopz's pick; `ask.ps1` for picture approvals. Sound + toast on new items.
- Activity shows who is working (agent → job) + feed tagged by agent (`activity-hook.ps1` → `~/RobloxGames/.degen/activity.json`); drawer opens only when a task starts.
- Projects bubble (folders in ~/RobloxGames: pictures, models, HANDOFF.md, Continue). Import video/game file in the + panel → `~/RobloxGames/imports/` → roblox-game-strip.
- Voice: always-listening "Hey Claude" wake word, particle ring reacts to the mic, sends after 10 s pause or "start task"/"finished prompt". Sent prompts are cleared and saved as simplified suggestions. No scrollbars.
- New skills: roblox-shops, roblox-asset-shapes, roblox-game-strip, roblox-playtest. lead.md: handoff per project, token-saving rules, exact-description rule.
- Not yet verified on lyopz's PC (no PowerShell in the sandbox): server.ps1, hooks, ask flow.
