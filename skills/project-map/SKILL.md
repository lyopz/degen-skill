---
name: project-map
description: Draws an interactive, glowing map of a project's files and how they connect (search, folder filters, click a file to see why it links to others). Use when lyopz asks to see, show, draw, visualize or open a map of a project or codebase, or after graphify builds a graph and he wants to look at it.
---

<!-- from: lyopz (own design, adapted from his Graph POW map). Template has no project data baked in. -->

# Project Map

Turns a project into one self-contained HTML page: each file is a glowing node, folders become coloured lobes, and links show which files import, call, use types from, test or document each other. Click a node to see its purpose, symbols and every connection with the reason for it.

Files in this skill:
- `template.html` — the map viewer, with `__GRAPH_DATA__` and `__PROJECT__` placeholders. Never hand-edit project data into it.
- `build_map.py` — fills the template from a Graphify graph. Python standard library only.

## Steps

1. **Get a graph.** If `graphify-out/graph.json` doesn't exist in the project, run the `graphify` skill first (code-only is enough, no API key).
2. **Optional but better: write one-line purposes.** Read the main files and write `graphify-out/purposes.json` as `{"relative/path.ext": "What this file does, in plain words."}`. Keep each under ~25 words. Skip files you didn't read rather than guessing.
3. **Build the page** from the project root:
   ```
   python ~/.claude/skills/project-map/build_map.py --name "Project Name"
   ```
   Defaults: reads `graphify-out/graph.json`, writes `graphify-out/project-map.html`. Use `-o` for another path.
4. **Show it.** Tell lyopz to open it (`start graphify-out\project-map.html` in PowerShell). In a claude.ai session with the Artifact tool, publish the HTML file as a private artifact instead.

## Notes
- Paths are shown relative to the project; the top folder of each file becomes its colour group (`root` for top-level files).
- Graphify relations map to link types: imports/imports_from → Imports, calls → Calls, uses/inherits/references → Types; links from test files count as Tests, from docs as Docs.
- The page loads d3 from cdnjs and fonts from Google Fonts, so it needs internet to draw.
- Rebuild after `graphify --update` to refresh the map.
