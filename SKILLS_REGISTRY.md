# Skills Registry

Every skill in this repo, tracked by the GitHub repo it came from. To remove one, tell Claude: **"remove owner/repo"**.

## Active

| Repo | Added | Installed as | Merged into | Status | Notes |
|---|---|---|---|---|---|
| (built-in) | 2026-10-18 | `skill-intake/` | — | active | Manages this repo: adding, merging, removing skills |
| DietrichGebert/ponytail | 2026-10-18 | `ponytail/`, `ponytail-review/`, `ponytail-audit/`, `ponytail-debt/` (+ `ponytail/LICENSE`) | — | trial | Lazy senior-dev coding mode + code review/audit/shortcut ledger. Skipped: ponytail-gain (marketing), ponytail-help (plugin-only), all hooks/scripts (auto-run code). MIT. |
| addyosmani/agent-skills | 2026-10-18 | `debugging-and-error-recovery/`, `security-and-hardening/` (+ references), `frontend-ui-engineering/` (+ references), `idea-refine/` (+ 3 guide files, `LICENSE`) | `ponytail/` (Before you write), `ponytail-review/` (Missing test, new item 7) | trial | 4 of 25 skills kept. Skipped 21: overlap with ponytail (code-review, code-simplification, performance), conflicts with ponytail (test-driven-development), team/enterprise process (ci-cd, observability, ADRs, shipping, deprecation, constraint/doubt/spec/source-driven, etc.), needs extra installs (browser-testing). idea-refine helper script dropped. MIT. |
| Graphify-Labs/graphify | 2026-10-18 | `graphify/` (Windows variant: `SKILL.md`, 8 `references/`, `LICENSE` + NOTICE) | — | trial | Maps a project into a queryable knowledge graph. Triggers on any codebase question (lyopz's choice). Installs the `graphifyy` Python package on first use; local note added so it asks once before installing. Writes `graphify-out/` in each project. Apache-2.0, pinned to upstream 86c57be. |
| multica-ai/andrej-karpathy-skills | 2026-10-18 | — | `ponytail/` (Before you write; smallest-change rules) | trial | Its one skill (karpathy-guidelines) mostly duplicates ponytail. Merged only the new parts: state assumptions/ask when unclear, surgical edits, step-by-step plan with checks. MIT. |
| nextlevelbuilder/ui-ux-pro-max-skill | 2026-10-18 | `ui-ux-pro-max/` (`SKILL.md`, `scripts/` 4 files, `data/` 13 CSVs + 22 stack CSVs, `references/` 2, `LICENSE`) | — | trial | Local design database + search tool (Python standard library only, no internet). Script paths changed to ~/.claude/skills. Works alongside frontend-ui-engineering (design choices vs. build quality). Skipped 6 skills: design (needs paid AI image APIs), brand, banner-design, design-system, slides, ui-styling (5.8 MB of fonts; overlaps frontend skills). Skipped tests, validate_data.py, unused JSON. MIT, pinned to upstream 56ea9cf. |

## Reviewed, not added

| Repo | Reviewed | Reason |
|---|---|---|
| diegosouzapw/OmniRoute | 2026-10-18 | Not a skill pack: its 46 skills only operate the OmniRoute gateway app, which routes your AI traffic and API keys through a server you'd have to install and run. Its one general skill is a copy of ponytail. |

## Removed

| Repo | Added | Removed | Reason |
|---|---|---|---|
