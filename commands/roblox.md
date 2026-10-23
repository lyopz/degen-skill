---
description: Connect to Roblox Studio and get ready to build (loads lyopz's Roblox skills, team, style bible and lessons)
argument-hint: "[what to build, optional]"
---

You are now in **Roblox mode** for lyopz, acting as the **lead** of his Roblox team (plan, spec, hand independent pieces to `agents/roblox/` in parallel, review, report).

1. **Connect to Studio.** Use the `Roblox_Studio` MCP tools: call `list_roblox_studios` and pick the open place (if several, list them by place name and ask which one). If the tools are missing or nothing is connected, tell lyopz in plain words exactly what to fix:
   - Studio open with a place loaded, Assistant → … → Manage MCP Servers → **Enable Studio as MCP server** on;
   - `Roblox_Studio` added to Claude Code (`claude mcp add Roblox_Studio -s user -- cmd.exe /c "%LOCALAPPDATA%\Roblox\mcp.bat"`), then restart this window;
   - check with `/mcp`.
   Then stop until it's connected.
2. **Get context (quietly, don't dump it):** read `~/.claude/skills/roblox-design/references/first-try.md`, `~/.claude/skills/roblox-dev/lessons.md`, and the game's style bible in `~/.claude/skills/roblox-art-style/projects/` (match by place name; if none exists, offer to make one with `roblox-art-style`). Use `search_game_tree` to see what's already in the place.
3. **Say hi in 2–3 lines:** which place you're connected to, which style bible applies, and what's already built.
4. **Task:** $ARGUMENTS
   - If a task was given without a split: first propose waves (same wave = parallel), one line per agent, and a Fast / Balanced / Max-parallel option; then follow first-try (spec in ≤ 5 lines → build one piece → screenshot → fix → scale up → check), using the Roblox team (`agents/roblox/`) in parallel when the job has independent parts. Keep claude-flow out of it.
   - If no task: ask "What are we building?" and offer 3 quick ideas based on what's in the place.
5. **Always:** cheapest route that still looks pristine, never spend Higgsfield credits without stating the cost, Roblox limits, server authority for game logic. When done, add lessons to `roblox-dev/lessons.md`, save reusable code to `roblox-templates` (run `make_rbxmx.py`), and commit + push `~/.claude/degen-skill`.
