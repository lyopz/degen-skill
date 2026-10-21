# graphify reference: the brain

Load this in Step 6, or whenever the user asks for the brain, the file map, the "neural map", or to restyle it. It turns `graphify-out/graph.json` into `graphify-out/brain.html`, a map drawn like a fruit-fly connectome. Each folder is a dense region of nerve fibres, each file is a small node inside its folder, and signals fire along the links between files. The design is fixed in `templates/brain.html`; reuse it as is. Do not redesign it per project.

## Files

| File | What it is |
|:--|:--|
| `scripts/brain.py` | Folds the symbol graph into files and links and fills the template. Standard library only. |
| `templates/brain.html` | The page: styles, brain growth, rendering and interaction, in plain canvas JavaScript with no libraries. Placeholders `__GRAPH_DATA__` and `__PROJECT_NAME__`. |
| `purposes.json` (per project) | Optional `{"path/to/file": "one-line purpose"}`. Kept in the project, not in this skill. |

## Apply it to a project

1. Run the normal graphify build first so `graphify-out/graph.json` exists.
2. Write purposes for files that have no leading comment. The script uses, in order: the `purposes.json` entry, then the file's first comment block, then its role. List the files that would fall back to a role (`--json-only` and look for empty `purpose`), read each one, and write one plain sentence about what it does for the app. Save the file as `docs/brain/purposes.json`, or wherever the project keeps docs.
3. Build the page. On Windows, run it with the saved interpreter:
   ```powershell
   & (Get-Content graphify-out\.graphify_python) SCRIPT_PATH --graph graphify-out/graph.json --root INPUT_PATH --purposes docs/brain/purposes.json --title "Project Name" --out graphify-out/brain.html
   ```
   SCRIPT_PATH is the absolute path of `scripts/brain.py` beside this skill's SKILL.md. On macOS/Linux use `python3` in place of the interpreter call. Leave out `--purposes` if there is no purposes file.
4. Open `graphify-out/brain.html` in a browser. To share it as a claude.ai Artifact, publish the same file. It is written as an artifact body with no `<html>`/`<head>`/`<body>` tags, which browsers also accept.
5. Tell the user the file and link counts, the most connected files, and one thing the brain shows that they might not know, such as a folder that bridges two others or a busy file with no purpose written.

Rebuild after big changes: re-run graphify (`--update`), then step 3.

## What the script derives

- **Nodes are files.** Every symbol node is mapped to its `source_file`. Nodes whose `source_file` is not a real file fall back to the longest file stem that prefixes the node id. `ref_*` nodes are external packages and are listed on the file that imports them, not drawn.
- **Folder (region).** The first folder under a source root (`src/`, `lib/`, `app/`, `packages/`), otherwise the top folder, otherwise `root`. In the page, `root` reads "project root" and `src` reads "app shell".
- **Role.** From the folder name (`ui` = Interface panel, `engine` = Core engine, `store` = App state…), with overrides for tests, docs, config files and entry points (`main`, `index`, `App`).
- **Link kinds.** graphify relations collapse to five kinds:
  - `imports`: imports, imports_from, re_exports, dynamic_import
  - `calls`: calls, indirect_call
  - `types`: references, implements, inherits
  - `tests`: any link out of a test file
  - `docs`: any link touching a doc file, drawn from the doc to the code
  `contains` and `method` are inside one file and are dropped.
- **Why.** Each link keeps the target symbols per kind, e.g. `calls applyOps(), validate(); uses types OfficeDoc`. Names that are both imported and called show once, under calls. At most 6 per kind are shown, then "+N more".
- **Importance.** "Degree" is the number of distinct files a file touches. The top 12% (at least 2) are the important files: they get a white nucleus and always have a label.

## How the brain grows

The page grows the brain from a fixed seed, so the same `graph.json` always gives the same brain.

- **Regions.** Folders are placed in fly-brain slots, largest first. The two largest become the side optic lobes (taller than wide, with a beaded pink `#ff3d8b` and blue `#3d5bff` rim on their outer half). The rest fill the centre, crown and base. Region area is proportional to file count. The regions are then nudged apart until they just touch, so the brain reads as one mass with no outline.
- **Fibres.** Each region is filled with random-walk fibres that bend back inside it: 70 + 14 per file, at most 560, times 1.3 for the optic lobes, scaled down if the total passes 7,000. Fibre colours jitter ±35° in hue around the folder colour. They are drawn with `lighter` blending, so dense areas glow.
- **Tracts.** Folders whose files link to each other are joined by a bundle of 4 + 2·√weight curves (at most 20), shaded from one folder's colour to the other's and bowed toward the middle of the brain. Each folder also gets a faint bundle to its two nearest neighbours.
- **Files.** Inside each region, files sit on a sunflower spiral, sorted so the most connected are in the middle. Node radius is `1.3 + 0.62·√degree`: a soft glow in the folder colour, a solid core, and a white nucleus on important files.
- **File links.** Every link is its own thin nerve in cool blue `#7a96ff` at rest, bowed toward the middle of the brain (or sideways within a folder).

## Visual style

One dark world on purpose. It is not themed for light mode.

- Ground `#020308` with a soft `#0a0f1f` radial glow in the centre. Menu `#070b16`; glass cards `rgba(9,13,28,.9)` with a 16px blur and a hairline border `rgba(130,160,255,.3)`.
- Text `#e7ecff`, secondary `#a0abd0`, captions `#64709a`. Single UI accent: synapse cyan `#7cf0ff`, used only for focus, selection and search.
- Link kinds: imports `#5ad2ff`, calls `#b28cff`, types `#ffc46b`, tests `#78f7b0`, docs `#ff7ad6`.
- Folder colours, in order of folder size: `#5ad2ff #b28cff #ff7ad6 #ffc46b #78f7b0 #7f9cff #ff9a74 #4ff0d0 #e0a8ff #c8f06e #ff6f9c #9fd4ff #f5e17a #8affd9`.
- Type: Unbounded (title only), IBM Plex Sans (UI), IBM Plex Mono (file names, counts, canvas labels).
- **Folder names** are spaced capitals on a dark plate above each region, drawn in screen space so they stay readable at any zoom. When they would overlap on a small screen, the later ones are skipped until you zoom in.
- **File labels** have a dark 4px halo and are collision-checked. The selected and hovered files always win, then their neighbours, then the important files (or every file once zoomed past 1.6×).

## Signals

- **Firing (default).** Every 140–300 ms a file fires. The choice is weighted toward busy files, and toward the selected file when there is one. Fast signals, each a white-hot head with a tail in the link's kind colour, run along 2–4 of its links, preferring what it depends on. When a signal arrives, that file flashes and usually fires onward with 62% of the energy, so activity cascades through the brain. The folders' own fibres flicker too, more in bigger folders. At most 220 signals are live at once.
- **Calm.** Slow single pulses on the top 22% of links by weight (or on the selected file's links), one every second or two, and a gentle fibre flicker.
- **Still.** Nothing moves. This is the default with `prefers-reduced-motion`.
- **Live hook.** `brain.fire('src/x.ts')`, or `postMessage({type: 'brain:fire', file: 'src/x.ts'})` from a parent page, fires that file; `brain.select('src/x.ts')` selects it. Wire this to an agent's file activity to show real work. Without a feed, the firing is simulated.

## Interaction

- **File menu (left).** Every file, grouped by folder (largest folder first, files by degree). Each row shows the name, its purpose or role, and its degree. Hovering a folder lights up its region and dims the rest to 22%. Hovering or focusing a file lights it, its neighbours and its links in their kind colours. Clicking a file selects it. Click a folder header to collapse it. Projects with more than 150 files start with all but the three largest folders collapsed.
- **Search** (`/` to focus) filters the menu by file name, path, purpose, role and symbol. Enter selects the first match; Esc clears it.
- **Hover** a node in the brain to see its path, role and degree. **Click** it to select it, or click empty space to clear.
- **Card (right).** For the selected file it shows the role, name, path with a Copy button, purpose, folder and graphify community, then line, symbol, depends-on and used-by counts. Below that are the **Depends on** and **Used by** lists, sorted by weight, with kind badges and the reason for each link, then the packages it uses. Hovering a row lights that file; clicking it moves to that file.
- Selecting from the menu or the card glides the camera to the file and fires it.
- **Tools:** Nerves (firing → calm → still, remembered per browser), zoom in, zoom out and Fit. Scroll or pinch zooms, and drag pans. `Esc` clears the selection.
- On phones (≤760px) the menu sits under the brain, taking 42% of the height.

## Changing the design

Change `templates/brain.html` itself, so every project keeps the same look. Keep the two placeholders, and keep it free of script libraries (only the Google Fonts stylesheet loads from outside). Afterwards, rebuild one project and check it at desktop and phone width.
