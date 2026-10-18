# Skills Registry

Every skill in this repo, tracked by the GitHub repo it came from. To remove one, tell Claude: **"remove owner/repo"**.

## Active

| Repo | Added | Installed as | Merged into | Status | Notes |
|---|---|---|---|---|---|
| (built-in) | 2026-10-18 | `skill-intake/` | — | active | Manages this repo: adding, merging, removing skills |
| DietrichGebert/ponytail | 2026-10-18 | `ponytail/`, `ponytail-review/`, `ponytail-audit/`, `ponytail-debt/` (+ `ponytail/LICENSE`) | — | trial | Lazy senior-dev coding mode + code review/audit/shortcut ledger. Skipped: ponytail-gain (marketing), ponytail-help (plugin-only), all hooks/scripts (auto-run code). MIT. |
| addyosmani/agent-skills | 2026-10-18 | `debugging-and-error-recovery/`, `security-and-hardening/` (+ references), `frontend-ui-engineering/` (+ references), `idea-refine/` (+ 3 guide files, `LICENSE`) | `ponytail/` (Before you write), `ponytail-review/` (Missing test, new item 7) | trial | 4 of 25 skills kept. Skipped 21: overlap with ponytail (code-review, code-simplification, performance), conflicts with ponytail (test-driven-development), team/enterprise process (ci-cd, observability, ADRs, shipping, deprecation, constraint/doubt/spec/source-driven, etc.), needs extra installs (browser-testing). idea-refine helper script dropped. MIT. |
| Graphify-Labs/graphify | 2026-10-18 | `graphify/` (Windows variant: `SKILL.md`, 8 `references/`, `LICENSE` + NOTICE) | — | trial | Maps a project into a queryable knowledge graph. Triggers on any codebase question (lyopz's choice). Installs the `graphifyy` Python package on first use; local note added so it asks once before installing. Writes `graphify-out/` in each project. Apache-2.0, pinned to upstream 86c57be. |

## Reviewed, not added

| Repo | Reviewed | Reason |
|---|---|---|
| diegosouzapw/OmniRoute | 2026-10-18 | Not a skill pack: its 46 skills only operate the OmniRoute gateway app, which routes your AI traffic and API keys through a server you'd have to install and run. Its one general skill is a copy of ponytail. |

## Removed

| Repo | Added | Removed | Reason |
|---|---|---|---|
