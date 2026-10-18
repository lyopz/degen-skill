# Handoff

Read this first in any new conversation. It says where things stand so we can pick up without re-explaining.

## Owner preferences
- Short, direct answers.
- Sends skill repos one at a time.

## What this repo is
lyopz's personal skill library. Lives on GitHub at `lyopz/degen-skill` (public), cloned to `~/.claude/skills`. Each skill is a folder with a `SKILL.md`. The `skill-intake` skill holds the rules for adding, merging, and removing skills.

## Current status
- Setup done: `skill-intake`, `SKILLS_REGISTRY.md`, `HANDOFF.md`.
- Outside repos added (trial): DietrichGebert/ponytail (4 skills), addyosmani/agent-skills (4 skills + merges into ponytail/ponytail-review).
- Reviewed, not added: diegosouzapw/OmniRoute.

## Next up
- Waiting on lyopz's decision about Graphify-Labs/graphify (see Open questions).

## Open questions
- Graphify-Labs/graphify: useful, but the skill installs a Python package (`graphifyy`) on first use and its trigger fires on any codebase question. Add with a narrowed trigger (only when asked to map/graph a codebase), or skip?

## Session Log
Newest at top. One short entry per session: date, what changed, anything left unfinished.

- **2026-10-18** — Reviewed 3 repos. Added 4 skills from addyosmani/agent-skills and merged 2 tagged blocks into ponytail skills. Skipped OmniRoute. graphify pending lyopz's call.
- **2026-10-18** — Added DietrichGebert/ponytail: ponytail, ponytail-review, ponytail-audit, ponytail-debt. Skipped gain/help and hooks.
- **2026-10-18** — Created the skill library: intake rules, registry, handoff file. Made repo public (personal details removed). Waiting on first repo from lyopz.
