# graphify reference: neural file graph

Load this in Step 6, or whenever the user asks for the file graph, the "neural map", or to restyle it. It turns `graphify-out/graph.json` into `graphify-out/neural-graph.html`: one glowing node per file, one link per related file pair, with the reason for every link. The design is fixed in `templates/neural-graph.html`; reuse it as is. Do not redesign it per project.

## Files

| File | What it is |
|:--|:--|
| `scripts/neural_graph.py` | Folds the symbol graph into files and links and fills the template. Standard library only. |
| `templates/neural-graph.html` | The page: styles, layout, rendering and interaction. Placeholders `__GRAPH_DATA__` and `__PROJECT_NAME__`. Loads d3 7.9.0 from cdnjs. |
| `purposes.json` (per project) | Optional `{"path/to/file": "one-line purpose"}`. Kept in the project, not in this skill. |

## Apply it to a project

1. Run the normal graphify build first so `graphify-out/graph.json` exists.
2. Write purposes for files that have no leading comment. The script uses, in order: the `purposes.json` entry, then the file's first comment block, then its role. List the files that would fall back to a role (`--json-only` and look for empty `purpose`), read each one, and write one plain sentence about what it does for the app. Save the file as `docs/file-graph/purposes.json`, or wherever the project keeps docs.
3. Build the page. On Windows, run it with the saved interpreter:
   ```powershell
   & (Get-Content graphify-out\.graphify_python) SCRIPT_PATH --graph graphify-out/graph.json --root INPUT_PATH --purposes docs/file-graph/purposes.json --title "Project Name" --out graphify-out/neural-graph.html
   ```
   SCRIPT_PATH is the absolute path of `scripts/neural_graph.py` beside this skill's SKILL.md. On macOS/Linux use `python3` in place of the interpreter call. Leave out `--purposes` if there is no purposes file.
4. Open `graphify-out/neural-graph.html` in a browser. To share it as a claude.ai Artifact, publish the same file (it is written as an artifact body, with no `<html>`/`<head>`/`<body>` tags, which browsers also accept).
5. Tell the user the file and link counts, the most connected files, and one thing the graph shows that they might not know, such as an import cycle or a file that bridges two folders.

Rebuild after big changes: re-run graphify (`--update`), then step 3.

## What the script derives

- **Nodes are files.** Every symbol node is mapped to its `source_file`. Nodes whose `source_file` is not a real file fall back to the longest file stem that prefixes the node id. `ref_*` nodes are external packages and are listed on the file that imports them, not drawn.
- **Folder (lobe).** The first folder under a source root (`src/`, `lib/`, `app/`, `packages/`), otherwise the top folder, otherwise `root`. In the page, `root` reads "project root" and `src` reads "app shell".
- **Role.** From the folder name (`ui` = Interface panel, `engine` = Core engine, `store` = App state…), with overrides for tests, docs, config files and entry points (`main`, `index`, `App`).
- **Link kinds.** graphify relations collapse to five kinds:
  - `imports`: imports, imports_from, re_exports, dynamic_import
  - `calls`: calls, indirect_call
  - `types`: references, implements, inherits
  - `tests`: any link out of a test file
  - `docs`: any link touching a doc file, drawn from the doc to the code
  `contains` and `method` are inside one file and are dropped.
- **Why.** Each link keeps the target symbols per kind, e.g. `calls applyOps(), validate(); uses types OfficeDoc`. Names that are both imported and called show once, under calls. At most 6 per kind are shown, then "+N more".
- **Importance.** Node size is `4 + 2.3·√(distinct neighbours)`.

## Visual style

One dark world on purpose. It is not themed for light mode.

- Ground `#04050c` with a soft indigo radial glow in the centre. Glass panels `rgba(10,14,31,.84)` with a 16px blur and a hairline border `rgba(130,160,255,.16)`.
- Text `#e7ecff`, secondary `#a0abd0`, captions `#64709a`. Single UI accent: synapse cyan `#7cf0ff`, used only for focus, selection and the primary button.
- Link kinds: imports `#5ad2ff`, calls `#b28cff`, types `#ffc46b`, tests `#78f7b0`, docs `#ff7ad6`.
- Folder colours, in order of folder size: `#5ad2ff #b28cff #ff7ad6 #ffc46b #78f7b0 #7f9cff #ff9a74 #4ff0d0 #e0a8ff #c8f06e #ff6f9c #9fd4ff #f5e17a #8affd9`.
- Type: Unbounded (title only), IBM Plex Sans (UI), IBM Plex Mono (file names, counts, canvas labels).
- **Nodes:** an additive radial glow sprite (5.6× radius) in the folder colour, a solid core, and a white nucleus at 42% radius. The glow breathes ±7% on a slow sine while pulses are on.
- **Links at rest:** thin curved paths in cool blue `#7a96ff`, opacity 0.07–0.29 and width 0.6–2px by weight, drawn with `lighter` blending so busy bundles glow.
- **Links in focus:** recoloured by their main kind, with a wide faint halo under a bright core line, and a small `kind count` label at the midpoint (when 18 or fewer, or zoomed in).
- **Pulses:** small glowing dots with a 3-dot fading tail travel each link from the file to what it depends on. At rest only the top 22% of links by weight pulse; in focus, only the focused links. One trip takes several seconds.
- **Lobes:** a faint radial nebula in the folder colour behind each folder, and the folder name in spaced capitals just above its topmost node.
- **Labels:** canvas text with a dark 4px halo for contrast. Collision-checked so they never overlap; the selected and hovered files always win.

## Layout rules

- Folders sit as lobes around an ellipse 1.45× wider than tall, like a brain seen from above. Lobe order is greedy: start with the largest folder, then always place next the unplaced folder with the most link weight to the last one, so linked folders are neighbours.
- Each lobe's share of the ring is proportional to √(file count).
- Force layout (d3-force, 420 ticks before first paint, then frozen so the map never drifts): links pull 46px apart within a folder and 120px across folders, with cross-folder pull at 30% strength; charge −170 (max range 420px); collision radius + 12px; every file pulled to its lobe anchor at 0.14, files with no links at 0.6 so they stay with their folder.
- The view opens fitted to the whole graph, leaving room for the detail panel.

## Interaction

- **Hover** a node: it and its direct neighbours stay lit, the rest dim to 16%, and a tooltip shows the path, role and neighbour count.
- **Click** a node: select it. The panel shows role, file name, path with a Copy button, folder and graphify community, purpose, line/symbol/depends-on/used-by counts, then **Depends on** and **Used by** lists sorted by weight. Each row shows the neighbour, kind badges with counts, and the reason. Hovering a row brightens that link; clicking it moves to that file.
- **Focus** (All / 1 hop / 2 hops) hides everything outside the selected file's neighbourhood and refits.
- **Trace a path:** pick a second file (click it, or search) and the shortest path through visible links is lit, with each hop's reason in the panel.
- **Search** (`/` to focus): file name, path, symbol, purpose and role, ranked in that order. Arrow keys and Enter pick a result.
- **Filters:** link-kind chips and folder chips toggle what is shown. Double-click a folder chip to show only that folder, and again to show all.
- **Tools:** Fit, Pulses on/off and All/Auto labels. Pulses and labels are remembered per browser.
- `Esc` clears the selection. Scroll or pinch zooms, and drag pans.
- With nothing selected, the panel shows an overview and the most connected files, so the page is never empty.
- With `prefers-reduced-motion`, pulses and breathing start off and the camera jumps instead of gliding.
- On phones (≤760px) the panel becomes a collapsible bottom sheet and the chip rows scroll sideways.

## Changing the design

Change `templates/neural-graph.html` itself, so every project keeps the same look. Keep the two placeholders and the d3 version pinned. Afterwards, rebuild one project and check it at desktop and phone width.
