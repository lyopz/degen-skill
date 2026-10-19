# Skills Registry

Every skill in this repo, tracked by the GitHub repo it came from. All skill folders live under `skills/`. Full license texts: `reviews/licenses/` and the LICENSE files inside skill folders. To remove one, tell Claude: **"remove owner/repo"**.

## Active

| Repo | Added | Installed as | Merged into | Status | Notes |
|---|---|---|---|---|---|
| (built-in) | 2026-10-18 | `skill-intake/` | — | active | Manages this repo: adding, merging, removing skills |
| lyopz (own) | 2026-10-18 | `project-map/` (`SKILL.md`, `template.html`, `build_map.py`) | — | active | Interactive file map viewer from lyopz's Graph POW artifact. Agent Office project data stripped out; template is blank and filled from any project's graphify-out/graph.json. Loads d3 (cdnjs) + Google Fonts. |
| DietrichGebert/ponytail | 2026-10-18 | `ponytail/`, `ponytail-review/`, `ponytail-audit/`, `ponytail-debt/` (+ `ponytail/LICENSE`) | — | trial | Lazy senior-dev coding mode + code review/audit/shortcut ledger. Skipped: ponytail-gain (marketing), ponytail-help (plugin-only), all hooks/scripts (auto-run code). MIT. |
| addyosmani/agent-skills | 2026-10-18 | `debugging-and-error-recovery/`, `security-and-hardening/` (+ references), `frontend-ui-engineering/` (+ references), `idea-refine/` (+ 3 guide files, `LICENSE`) | `ponytail/` (Before you write), `ponytail-review/` (Missing test, new item 7) | trial | 4 of 25 skills kept. Skipped 21: overlap with ponytail (code-review, code-simplification, performance), conflicts with ponytail (test-driven-development), team/enterprise process (ci-cd, observability, ADRs, shipping, deprecation, constraint/doubt/spec/source-driven, etc.), needs extra installs (browser-testing). idea-refine helper script dropped. MIT. |
| Graphify-Labs/graphify | 2026-10-18 | `graphify/` (Windows variant: `SKILL.md`, 8 `references/`, `LICENSE` + NOTICE) | — | trial | Maps a project into a queryable knowledge graph. Triggers on any codebase question (lyopz's choice). Installs the `graphifyy` Python package on first use; local note added so it asks once before installing. Writes `graphify-out/` in each project. Apache-2.0, pinned to upstream 86c57be. |
| multica-ai/andrej-karpathy-skills | 2026-10-18 | — | `ponytail/` (Before you write; smallest-change rules) | trial | Its one skill (karpathy-guidelines) mostly duplicates ponytail. Merged only the new parts: state assumptions/ask when unclear, surgical edits, step-by-step plan with checks. MIT. |
| nextlevelbuilder/ui-ux-pro-max-skill | 2026-10-18 | `ui-ux-pro-max/`, `design/`, `design-system/`, `brand/`, `banner-design/`, `slides/`, `ui-styling/` (incl. 81 font files) | — | trial | All 7 skills. ui-ux-pro-max: local design database + search (stdlib Python, no internet), script paths changed to ~/.claude/skills. design: logo/icon/mockup image generation via Gemini, Atlas Cloud or MuAPI (needs that provider's API key; no OpenAI support in its scripts). ui-styling: shadcn/Tailwind + canvas fonts; its shadcn_add.py runs `npx shadcn add` in the project. design-system/fetch-background.py downloads stock photos from Pexels. Skipped: tests, validate_data.py, unused JSON. MIT, pinned to upstream 56ea9cf. |
| diegosouzapw/OmniRoute | 2026-10-18 | 45 folders: `cli-*` (21), `omni-*` (23), `config-codex-cli` | — | trial | Re-reviewed after lyopz chose to install the OmniRoute app. Skills are docs for driving the OmniRoute CLI/API (local gateway on localhost); no scripts. Links to upstream skill files rewritten to local `../`. Skipped: its ponytail copy (already installed), repo-only quality templates, test fixtures. MIT, pinned to upstream df60c41. |
| ruvnet/ruflo | 2026-10-18 | 32 skill folders (29 from `.claude/skills` + `dual-collect`, `dual-coordinate`, `dual-spawn` split out of its `dual-mode/` folder so they load), `agents/` (98), `commands/` (168) | — | trial | Multi-agent swarms, memory (AgentDB/ReasoningBank), SPARC, GitHub automation. Most skills/agents call the `claude-flow` MCP server (`npx ruflo@latest mcp start`) and other npx packages (agentdb, flow-nexus). Skipped: 9 `v3-*` skills and its `agents/v3/` (internal work on Ruflo itself; would hijack generic requests), its project settings/hooks/statusline/helpers (auto-run scripts on every action; run `npx ruflo init` per project if wanted), dev-only mcp.json. flow-nexus skills need a Flow Nexus cloud account; dual-* need OpenAI Codex CLI. MIT, upstream b931448. |
| karpathy/llm-council | 2026-10-18 | `llm-council/` (`SKILL.md`, written from scratch) | — | trial | Upstream is a local web app (FastAPI + React) that needs an OpenRouter key and paid credits, and has no license. Rewrote only the 3-stage method (answer → blind peer ranking → chairman) as a skill using Claude subagents (opus/sonnet/haiku); optional cross-vendor mode via OmniRoute. No upstream code or prompts copied. Upstream 92e1fcc. Plus `council.py` + `council.json`: stdlib script for cross-vendor councils via OmniRoute (key from COUNCIL_API_KEY env var). |

## Reviewed, not added

| Repo | Reviewed | Reason |
|---|---|---|

## Removed

| Repo | Added | Removed | Reason |
|---|---|---|---|
| ruvnet/ruflo (partial: flow-nexus-neural, flow-nexus-platform, flow-nexus-swarm, dual-spawn, dual-coordinate, dual-collect) | 2026-10-18 | 2026-10-18 | Need a paid Flow Nexus account or the OpenAI Codex CLI |
