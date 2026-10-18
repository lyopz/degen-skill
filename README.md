# lyopz's Claude Skills

A personal skill library for [Claude Code](https://claude.com/claude-code). Every skill loads on its own when a task calls for it — no commands to remember. Ruflo adds a team of specialist agents that can work on parts of a job in parallel.

| Skills | Agents | Commands | Coding | Design & UI | Swarms (Ruflo) | OmniRoute | Sources |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **94** | 98 | 168 | 6 | 8 | 32 | 45 | 7 repos |

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

## Agents & swarms (Ruflo)

Multi-agent coordination from [Ruflo](https://github.com/ruvnet/ruflo): 32 skills, plus 98 specialist agents and 168 slash commands in [`_ruflo/`](_ruflo). Most need the Ruflo MCP server (see Install).

<details>
<summary>Show all 32 Ruflo skills</summary>

| Skill | What it does |
|---|---|
| [`agentdb-advanced`](agentdb-advanced/SKILL.md) | Master advanced AgentDB features including QUIC synchronization, multi-database management, custom distance me… |
| [`agentdb-learning`](agentdb-learning/SKILL.md) | Create and train AI learning plugins with AgentDB's 9 reinforcement learning algorithms |
| [`agentdb-memory-patterns`](agentdb-memory-patterns/SKILL.md) | Implement persistent memory patterns for AI agents using AgentDB |
| [`agentdb-optimization`](agentdb-optimization/SKILL.md) | Optimize AgentDB performance with quantization (4-32x memory reduction), HNSW indexing (150x faster search), c… |
| [`agentdb-vector-search`](agentdb-vector-search/SKILL.md) | Implement semantic vector search with AgentDB for intelligent document retrieval, similarity matching, and con… |
| [`agentic-jujutsu`](agentic-jujutsu/SKILL.md) | Quantum-resistant, self-learning version control for AI agents with ReasoningBank intelligence and multi-agent… |
| [`browser`](browser/SKILL.md) | Web browser automation with AI-optimized snapshots for claude-flow agents |
| [`dual-collect`](dual-collect/SKILL.md) | Collect results from headless Codex workers |
| [`dual-coordinate`](dual-coordinate/SKILL.md) | Coordinate hybrid Claude Code + Codex workflows |
| [`dual-spawn`](dual-spawn/SKILL.md) | Spawn headless Codex workers from Claude Code for parallel execution |
| [`flow-nexus-neural`](flow-nexus-neural/SKILL.md) | Train and deploy neural networks in distributed E2B sandboxes with Flow Nexus |
| [`flow-nexus-platform`](flow-nexus-platform/SKILL.md) | Comprehensive Flow Nexus platform management - authentication, sandboxes, app deployment, payments, and challe… |
| [`flow-nexus-swarm`](flow-nexus-swarm/SKILL.md) | Cloud-based AI swarm deployment and event-driven workflow automation with Flow Nexus platform |
| [`github-code-review`](github-code-review/SKILL.md) | Comprehensive GitHub code review with AI-powered swarm coordination |
| [`github-multi-repo`](github-multi-repo/SKILL.md) | Multi-repository coordination, synchronization, and architecture management with AI swarm orchestration |
| [`github-project-management`](github-project-management/SKILL.md) | Comprehensive GitHub project management with swarm-coordinated issue tracking, project board automation, and s… |
| [`github-release-management`](github-release-management/SKILL.md) | Comprehensive GitHub release orchestration with AI swarm coordination for automated versioning, testing, deplo… |
| [`github-workflow-automation`](github-workflow-automation/SKILL.md) | Advanced GitHub Actions workflow automation with AI swarm coordination, intelligent CI/CD pipelines, and compr… |
| [`hive-mind-advanced`](hive-mind-advanced/SKILL.md) | Advanced Hive Mind collective intelligence system for queen-led multi-agent coordination with consensus mechan… |
| [`hooks-automation`](hooks-automation/SKILL.md) | Automated coordination, formatting, and learning from Claude Code operations using intelligent hooks with MCP … |
| [`pair-programming`](pair-programming/SKILL.md) | AI-assisted pair programming with multiple modes (driver/navigator/switch), real-time verification, quality mo… |
| [`performance-analysis`](performance-analysis/SKILL.md) | Comprehensive performance analysis, bottleneck detection, and optimization recommendations for Claude Flow swa… |
| [`reasoningbank-agentdb`](reasoningbank-agentdb/SKILL.md) | Implement ReasoningBank adaptive learning with AgentDB's 150x faster vector database |
| [`reasoningbank-intelligence`](reasoningbank-intelligence/SKILL.md) | Implement adaptive learning with ReasoningBank for pattern recognition, strategy optimization, and continuous … |
| [`skill-builder`](skill-builder/SKILL.md) | Create new Claude Code Skills with proper YAML frontmatter, progressive disclosure structure, and complete dir… |
| [`sparc-methodology`](sparc-methodology/SKILL.md) | SPARC (Specification, Pseudocode, Architecture, Refinement, Completion) comprehensive development methodology … |
| [`stream-chain`](stream-chain/SKILL.md) | Stream-JSON chaining for multi-agent pipelines, data transformation, and sequential workflows |
| [`swarm-advanced`](swarm-advanced/SKILL.md) | Advanced swarm orchestration patterns for research, development, testing, and complex distributed workflows |
| [`swarm-orchestration`](swarm-orchestration/SKILL.md) | Orchestrate multi-agent swarms with agentic-flow for parallel task execution, dynamic topology, and intelligen… |
| [`verification-quality`](verification-quality/SKILL.md) | Check code quality and change risk with ruflo's shipped analysis commands (analyze diff, analyze complexity, a… |
| [`worker-benchmarks`](worker-benchmarks/SKILL.md) | Run comprehensive worker system benchmarks and performance analysis |
| [`worker-integration`](worker-integration/SKILL.md) | Worker-Agent integration for intelligent task dispatch and performance tracking |

</details>

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
| [ruvnet/ruflo](https://github.com/ruvnet/ruflo) | 32 skills, 98 agents, 168 commands | MIT |
| [diegosouzapw/OmniRoute](https://github.com/diegosouzapw/OmniRoute) | 45 | MIT |

## Install

```bash
git clone https://github.com/lyopz/degen-skill.git ~/.claude/skills
```

For the Ruflo agents, commands, and tools:

```bash
claude mcp add claude-flow -s user -- npx -y ruflo@latest mcp start
# link agents and commands so Claude Code finds them
ln -s ~/.claude/skills/_ruflo/agents ~/.claude/agents
ln -s ~/.claude/skills/_ruflo/commands ~/.claude/commands
```

Update with `git pull` inside `~/.claude/skills`. Some skills need Python (ui-ux-pro-max, design, graphify) or Node (brand, design-system, ui-styling, Ruflo). AI image generation in `design` needs a Gemini, Atlas Cloud, or MuAPI API key.

<sub>Review notes, change log, and full license texts live in [`_notes/`](_notes).</sub>
