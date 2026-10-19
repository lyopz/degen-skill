# Agent routing (degen-skill)

Agents in `~/.claude/agents` come from this repo. lyopz has authorized using them: when a task is big enough to hand off (several files, a separate review pass, research that would flood the main chat), delegate to the matching agent with the Agent tool instead of a generic one. Small tasks: just do them, no agent.

| Task | Agent (`subagent_type`) |
|---|---|
| Write or change code | `coder`; `backend-dev`, `mobile-dev`, `ml-developer`, `python-specialist`, `typescript-specialist` when the stack fits |
| Review a change / code quality | `reviewer` (or `analyst` for a deeper quality report) |
| Security check | `security-auditor` |
| Write or run tests | `tester`; `tdd-london-swarm` only if he asks for mock-first TDD |
| "Is this ready to ship?" | `production-validator` |
| Research, read docs, compare options | `researcher` |
| Plan a feature or break down a job | `planner`; `system-architect` for architecture calls |
| Slow code | `perf-analyzer` |
| Database design / queries | `database-specialist` |
| API docs (OpenAPI) | `api-docs` |
| CI/CD pipelines | `cicd-engineer` |
| Spec → pseudocode → architecture → refine | `specification`, `pseudocode`, `architecture`, `refinement` (SPARC, when he asks for it) |

Rules:
- Run independent agents in parallel (one message, several Agent calls). Give each the full context it needs; they start cold.
- Agents report back; the main session checks the result before telling lyopz it's done.
- **Needs the `claude-flow` MCP server** (check `claude mcp list`; skip these if it's missing): swarm/hive/consensus coordinators (`*-coordinator`, `queen-coordinator`, `swarm-*`, `raft-manager`, `quorum-manager`, `crdt-synchronizer`, `security-manager`, `memory-coordinator`, `smart-agent`, `task-orchestrator`, `sparc-coord`), `sona-learning-optimizer`, `safla-neural`, sublinear/matrix/pagerank agents.
- **Needs a GitHub MCP server or the `gh` CLI**: the GitHub agents (`pr-manager`, `issue-tracker`, `release-*`, `repo-architect`, `swarm-pr`, `swarm-issue`, `sync-coordinator`, `workflow-automation`, `multi-repo-swarm`, `project-board-sync`, `code-review-swarm`, `github-modes`). Without them, do GitHub work in the main session.
- Never use `trading-predictor` or `agentic-payments` to move real money.
- For a second opinion from several models, use the `llm-council` skill, not an agent.
