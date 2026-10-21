# Handoff

Read this first in any new conversation. It says where things stand so we can pick up without re-explaining.

## Owner preferences
- Short, direct answers.
- Sends skill repos one at a time.

## What this repo is
lyopz's personal skill library. Lives on GitHub at `lyopz/degen-skill` (public), cloned to `~/.claude/degen-skill`, with `~/.claude/skills`, `~/.claude/agents`, `~/.claude/commands` linked to its `skills/`, `agents/`, `commands/` folders. Reviews and registry are in `reviews/`. Each skill is a folder with a `SKILL.md`. The `skill-intake` skill holds the rules for adding, merging, and removing skills.

## Current status
- Setup done: `skill-intake`, `SKILLS_REGISTRY.md`, `HANDOFF.md`.
- Outside repos added (trial): DietrichGebert/ponytail (4 skills), addyosmani/agent-skills (4 skills + merges into ponytail/ponytail-review), Graphify-Labs/graphify (1), nextlevelbuilder/ui-ux-pro-max-skill (7), diegosouzapw/OmniRoute (45), ruvnet/ruflo (32 skills + 98 agents + 168 commands), multica-ai/andrej-karpathy-skills (merged into ponytail), karpathy/llm-council (method rewritten as own skill). 95 skills total (incl. lyopz's own `project-map`).
- Repo layout: `skills/`, `agents/`, `commands/`, `reviews/`, `assets/` + `README.md`. Front page = black/red catalog in plain language.
- lyopz is installing the OmniRoute app to stretch AI credits.
- Ruflo tools need the `claude-flow` MCP server added at user scope.
- Image generation: lyopz will add a custom Higgsfield connector in the Claude app. Once it exists, use it for image/video generation as needed (prefer it over the design skill's Gemini/Atlas/MuAPI scripts). ChatGPT idea dropped.

## Next up
- lyopz sends the next repo, or keeps/removes trial skills after using them.

## Open questions
- (none)

## Session Log
Newest at top. One short entry per session: date, what changed, anything left unfinished.

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
