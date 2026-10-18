# lyopz's Claude Skills

A personal skill library for [Claude Code](https://claude.com/claude-code). Every skill loads on its own when a task calls for it — no commands to remember.

| Skills | Coding | Design & UI | Planning | OmniRoute | Sources |
|:-:|:-:|:-:|:-:|:-:|:-:|
| **62** | 6 | 8 | 2 | 45 | 6 repos |

## Coding

Write and fix code the lean way, then check it.

| Skill | What it does |
|---|---|
| [`ponytail`](ponytail/SKILL.md) | Smallest change that fully solves the task, plain-English replies |
| [`ponytail-review`](ponytail-review/SKILL.md) | Reviews a change: bugs, security, load, missing tests, dead weight |
| [`ponytail-audit`](ponytail-audit/SKILL.md) | Same review for a whole project, ranked by what to fix first |
| [`ponytail-debt`](ponytail-debt/SKILL.md) | Lists every shortcut taken so none get forgotten |
| [`debugging-and-error-recovery`](debugging-and-error-recovery/SKILL.md) | Finds the root cause when something breaks |
| [`security-and-hardening`](security-and-hardening/SKILL.md) | Catches security holes in logins, inputs, and data handling |

## Design & UI

Websites, apps, stores, and brand visuals.

| Skill | What it does |
|---|---|
| [`ui-ux-pro-max`](ui-ux-pro-max/SKILL.md) | Searchable design database: styles, palettes, fonts, UX rules |
| [`frontend-ui-engineering`](frontend-ui-engineering/SKILL.md) | Accessible, responsive, production-ready interfaces |
| [`ui-styling`](ui-styling/SKILL.md) | shadcn/ui + Tailwind styling, with 29 bundled font families |
| [`design`](design/SKILL.md) | Logos, icons, mockups, social images (AI image generation) |
| [`design-system`](design-system/SKILL.md) | Design tokens, component specs, slide generation |
| [`brand`](brand/SKILL.md) | Brand voice, visual identity, style guides |
| [`banner-design`](banner-design/SKILL.md) | Banners for social, ads, web heroes, and print |
| [`slides`](slides/SKILL.md) | HTML presentations with charts and layouts |

## Planning & projects

Shape ideas and understand codebases.

| Skill | What it does |
|---|---|
| [`idea-refine`](idea-refine/SKILL.md) | Turns a rough idea into a sharp one-page plan |
| [`graphify`](graphify/SKILL.md) | Maps a project into a searchable knowledge graph |

## Library

Keeps this repo organized.

| Skill | What it does |
|---|---|
| [`skill-intake`](skill-intake/SKILL.md) | Reviews new skill repos, merges overlaps, removes by repo name |

## OmniRoute

45 skills for running the [OmniRoute](https://github.com/diegosouzapw/OmniRoute) AI gateway: providers, routing, budgets, keys, caching, and its CLI. They need the OmniRoute app installed.

<details>
<summary>Show all 45 OmniRoute skills</summary>

| Skill | What it does |
|---|---|
| [`cli-a2a`](cli-a2a/SKILL.md) | Interact with the OmniRoute A2A server from the CLI |
| [`cli-backup-sync`](cli-backup-sync/SKILL.md) | Backup and restore OmniRoute data from the CLI |
| [`cli-batches`](cli-batches/SKILL.md) | Submit and monitor batch inference jobs from the CLI |
| [`cli-chat`](cli-chat/SKILL.md) | Send chat completions, stream responses, and start an interactive REPL session from the CLI |
| [`cli-compression`](cli-compression/SKILL.md) | Configure and test prompt compression from the CLI |
| [`cli-contexts`](cli-contexts/SKILL.md) | Manage context engineering configurations, RTK filter sets, and conversation sessions from the CLI |
| [`cli-cost-usage`](cli-cost-usage/SKILL.md) | View cost breakdowns, token usage, and call logs from the CLI |
| [`cli-eval`](cli-eval/SKILL.md) | Create and run evaluation suites, watch live benchmark progress, view scorecards, compare model performance, a… |
| [`cli-health`](cli-health/SKILL.md) | Check server health, component status, and live metrics from the CLI |
| [`cli-keys`](cli-keys/SKILL.md) | Create, list, rotate, and revoke OmniRoute API keys from the CLI |
| [`cli-mcp`](cli-mcp/SKILL.md) | Inspect the MCP server status, list registered tools and scopes, run tool invocations, and manage MCP audit lo… |
| [`cli-models`](cli-models/SKILL.md) | Query available AI models, list model aliases, and browse the full model catalog from the CLI |
| [`cli-plugins-skills`](cli-plugins-skills/SKILL.md) | Manage Omni Skills (list, install, test, remove), plugins (create, configure), and persistent memory (search, … |
| [`cli-policy-audit`](cli-policy-audit/SKILL.md) | Inspect audit logs, manage access policies, view telemetry data, and review request history from the CLI |
| [`cli-providers`](cli-providers/SKILL.md) | Manage provider connections from the CLI: list available/configured providers, add, test, test-all, validate, … |
| [`cli-resilience`](cli-resilience/SKILL.md) | Inspect and manage circuit-breaker states, connection cooldowns, quota limits, and backoff levels from the CLI |
| [`cli-routing`](cli-routing/SKILL.md) | Create, list, update, and delete routing combos from the CLI |
| [`cli-serve`](cli-serve/SKILL.md) | Start, stop, and restart the OmniRoute server from the CLI |
| [`cli-setup`](cli-setup/SKILL.md) | Run initial setup, configure global CLI settings, manage environment variables, check for updates, and configu… |
| [`cli-skill-collector`](cli-skill-collector/SKILL.md) | Detect installed CLI coding tools (Claude Code, Codex, Cursor, Copilot, Cline and more), search GitHub for mat… |
| [`cli-tunnel`](cli-tunnel/SKILL.md) | Start and stop tunnel connections (ngrok, Cloudflare, custom) from the CLI |
| [`config-codex-cli`](config-codex-cli/SKILL.md) | Step-by-step agent workflow to configure the OpenAI Codex CLI on any machine (Linux, macOS, Windows) to use Om… |
| [`omni-agents-a2a`](omni-agents-a2a/SKILL.md) | Interact with OmniRoute via JSON-RPC 2.0 agent-to-agent protocol |
| [`omni-api-keys`](omni-api-keys/SKILL.md) | Create, list, rotate, and revoke OmniRoute API keys |
| [`omni-auth`](omni-auth/SKILL.md) | Manage API key authentication and session tokens |
| [`omni-budget`](omni-budget/SKILL.md) | Configure spending limits, token quotas, and rate-limit policies per API key or globally |
| [`omni-cache`](omni-cache/SKILL.md) | Manage the LLM response cache |
| [`omni-cli-tools`](omni-cli-tools/SKILL.md) | Manage CLI tool integrations exposed via the API |
| [`omni-combos-routing`](omni-combos-routing/SKILL.md) | Create and manage routing combos with 19 strategies (priority, weighted, round-robin, Auto-combo, and more) |
| [`omni-compression`](omni-compression/SKILL.md) | Configure RTK (command output), Caveman (prose), and stacked compression modes |
| [`omni-context-rtk`](omni-context-rtk/SKILL.md) | Configure RTK filters, context engineering rules, and context relay settings |
| [`omni-db-backups`](omni-db-backups/SKILL.md) | Trigger system backups, restore from backup files, and manage the SQLite database lifecycle |
| [`omni-github-skills`](omni-github-skills/SKILL.md) | Search, score, scan, and import agent skills from GitHub repositories that contain SKILL.md, CLAUDE.md, .curso… |
| [`omni-inference`](omni-inference/SKILL.md) | The core OpenAI-compatible inference endpoints: chat completions, embeddings, images, audio (TTS/STT), moderat… |
| [`omni-mcp`](omni-mcp/SKILL.md) | Connect to the OmniRoute MCP server (110 tools, 3 transports: SSE/stdio/HTTP) |
| [`omni-models`](omni-models/SKILL.md) | Query available AI models across all configured providers |
| [`omni-providers`](omni-providers/SKILL.md) | Manage provider connections, API keys, OAuth flows, and connection tests via the REST API |
| [`omni-proxies`](omni-proxies/SKILL.md) | Configure HTTP/HTTPS/SOCKS proxies for upstream provider requests |
| [`omni-resilience`](omni-resilience/SKILL.md) | Monitor provider health, circuit-breaker states, p50/p95/p99 latency metrics, and budget guard alerts |
| [`omni-settings`](omni-settings/SKILL.md) | Read and update global application settings: system prompts, thinking budget, IP filters, payload rules, combo… |
| [`omni-sync-cloud`](omni-sync-cloud/SKILL.md) | Synchronise OmniRoute configuration, provider connections, and settings to/from cloud storage |
| [`omni-tunnels`](omni-tunnels/SKILL.md) | Create and manage secure tunnels (ngrok, Cloudflare Tunnel, custom) to expose OmniRoute to the internet or sha… |
| [`omni-usage-logs`](omni-usage-logs/SKILL.md) | Access detailed call logs and usage analytics |
| [`omni-version-manager`](omni-version-manager/SKILL.md) | Install, start, stop, restart, and update embedded services (9Router, CLIProxyAPI) |
| [`omni-webhooks`](omni-webhooks/SKILL.md) | Register, list, test, and remove webhook endpoints |

</details>

## Sources

| Repo | Skills used | License |
|---|---|---|
| [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | 4 | MIT |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | 4 (+ ideas merged into ponytail) | MIT |
| [Graphify-Labs/graphify](https://github.com/Graphify-Labs/graphify) | 1 | Apache-2.0 |
| [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) | merged into ponytail | MIT |
| [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | 7 | MIT |
| [diegosouzapw/OmniRoute](https://github.com/diegosouzapw/OmniRoute) | 45 | MIT |

## Install

```bash
git clone https://github.com/lyopz/degen-skill.git ~/.claude/skills
```

Update with `git pull` inside `~/.claude/skills`. Some skills need Python (ui-ux-pro-max, design, graphify) or Node (brand, design-system, ui-styling). AI image generation in `design` needs a Gemini, Atlas Cloud, or MuAPI API key.

<sub>Review notes, change log, and full license texts live in [`_notes/`](_notes).</sub>
