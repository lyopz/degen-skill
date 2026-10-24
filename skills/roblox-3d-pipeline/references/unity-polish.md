# Unity polish (stage 3)

The Unity project is `~/RobloxGames/.degen/degen-polish` (its path is in `~/RobloxGames/.degen/unity-project.txt`). It's a shared workbench for every game: models are copied into `Assets/Degen/<project>/<asset>/` while you polish, and the results are exported to the game's own folder. Never leave game files in another project's export folder.

## Connect
1. The Lead opens Unity on the polish project by itself at startup (`unity-open.ps1`), and the bridge auto-connects (stdio). If the `mcp__unityMCP__*` tools fail, run `powershell -ExecutionPolicy Bypass -NoProfile -File "$env:DEGEN_APP\unity-open.ps1"` (prints OPEN / STARTED / why not), wait about 60 s, and retry. Still failing → go on without Unity and say so in the report. No pop-up for this.
2. Read `mcpforunity://editor/state` and wait for `ready_for_tools`.
3. `execute_code` hidden? `manage_tools(action="activate", group="scripting_ext")`. Over HTTP only `core` is on at the start.

## Your project's spot (do this first, every job)
lyopz's rule: never build on top of another project. One saved scene (`Assets/Degen/Workbench.unity`) holds every game, each in its own zone.
1. `DegenPolish.UseProject("<project>")` (the Studio place name, or `<game>/projects/<name>` for a project inside a game). It opens the workbench, gives the project its own zone the first time (zones are 250 m apart, each 200 × 200 m), remembers it as the current project and frames it. It returns the zone, every model already in it (`x`, `z`, size, tris, status, export path) and `loose` objects that sit in no zone.
2. Read that before building. Same asset name already there → `Import` reuses its cell (re-polish, not a second copy). Something `loose` → leave it alone and mention it in the report.
3. `Import` puts each model on its own free cell (≥ 4 m gap). It checks both the layout file and what is really in the scene, so it never lands on anything. For things you build by hand (ProBuilder, primitives, `manage_gameobject`, assembled scenes): `DegenPolish.Spot("<name>", <widthStuds>, <depthStuds>)` first, then parent every object under the `<name>_Root` it returns. Never set positions outside your zone.
4. All other DegenPolish calls only see the current project's zone, so a "dragon" in another game is never touched. `Shots` hides everything else for the pictures, `ExportForRoblox` exports the model at the origin (the file never carries the workbench spot).
5. Where things are: `~/RobloxGames/.degen/unity-layout.json` (local only, never the repo). `DegenPolish.Where()` lists all zones; `DegenPolish.Remove("<name>")` frees a cell.
6. `DegenPolish.UseProject` doesn't exist yet? Unity hasn't picked up the new DegenPolish.cs (the Lead copies it at start): `refresh_unity`, wait for `is_compiling == false`, retry.

## Calling DegenPolish
Use `execute_code(action="execute", code="return DegenPolish.UseProject(\"MyGame\");")`.
If it says `DegenPolish` doesn't exist (in-memory compile can't see editor scripts), use reflection:
`return System.AppDomain.CurrentDomain.GetAssemblies().Select(a => a.GetType("DegenPolish")).First(t => t != null).GetMethod("Report").Invoke(null, new object[]{"dragon"});`
Compile errors in DegenPolish.cs → `read_console(types=["error"])`, fix the file in the project, and copy the fix back to `skills/roblox-3d-pipeline/unity/DegenPolish.cs`.

| Step | Call | Check |
|---|---|---|
| Project | `DegenPolish.UseProject("<project>")` | zone + existing spots read |
| Import | `DegenPolish.Import(@"<models/asset/asset-raw.glb>", "<asset>", <heightStuds>)` | tris ≤ budget, sizeStuds right |
| Low poly | `DegenPolish.Budget("<asset>", <tris>)` → FAIL → `DegenPolish.Decimate("<asset>", <tris>)` | PASS (hard rule; Export refuses over budget) |
| Materials | `DegenPolish.ToUrpLit("<asset>")` | converted ≥ 1 |
| Regions | `DegenPolish.PaintRegions("<asset>", "<rules json>")` | every rule > 0%; 0% means widen its hue range |
| Tweak | `manage_material(action="set_material_shader_property", material_path=..., property="_Smoothness", value=0.6)` | |
| Light | `DegenPolish.StudioLight()` | |
| Shots | `DegenPolish.Shots("<asset>", @"<models/asset/shots>", 4, 1024)` | open view0 next to the ChatGPT picture |
| Export | `DegenPolish.ExportForRoblox("<asset>", @"<models/asset/export>", 1024)` | glb not null |

`manage_camera(action="screenshot")` is for a quick look at the editor. `Shots` gives clean white-background views that match the picture.

## Region recipes (PaintRegions rules)
Hue is 0–360, sat/val are 0–1, `smooth` is 0 (matte) to 1 (mirror), and `glow` is emission strength. Keep glow ≤ 0.6: lyopz likes subtle glows. The first matching rule wins, so put the narrow ones (gold, crystal) before the broad ones.

Premium pet (the default, matching the "Premium polished pets" block):
```json
{"rules":[
 {"label":"gold","hueMin":35,"hueMax":58,"satMin":0.45,"valMin":0.5,"metal":1,"smooth":0.78,"glow":0},
 {"label":"silver","hueMin":0,"hueMax":360,"satMin":0,"satMax":0.15,"valMin":0.75,"valMax":0.95,"metal":1,"smooth":0.7,"glow":0},
 {"label":"crystal","hueMin":165,"hueMax":215,"satMin":0.45,"valMin":0.55,"metal":0,"smooth":0.92,"glow":0.45},
 {"label":"eyes","hueMin":0,"hueMax":360,"satMin":0.5,"valMin":0.92,"metal":0,"smooth":0.95,"glow":0.35}
],"defaultMetal":0,"defaultSmooth":0.28}
```
- Change the crystal hue to the pet's glow colour: fire ≈ 15–40, toxic ≈ 85–140, ice ≈ 180–210, void ≈ 260–300.
- Armor plates that should be glossy but not metal: add `{"label":"armor","hueMin":<armor hue>,...,"metal":0,"smooth":0.65,"glow":0}` before the default.
- Silver catches white highlights too. Drop it when the pet has white fur or a white body.
- Elemental cracks on dark rock (liked 2x): `{"label":"cracks","hueMin":10,"hueMax":45,"satMin":0.6,"valMin":0.7,"metal":0,"smooth":0.5,"glow":0.55}` with `defaultSmooth` 0.15 (matte rock).

Props and buildings: `defaultSmooth` 0.2. Metal trim gets the gold or silver rule. Windows get `smooth` 0.9.

Save the rules that worked into the game's bible under "Unity recipes" (local). If a recipe works across games, add it here.

## What Unity can and can't do here
- **Can:** finishes per colour region, colour fixes (`manage_material` _BaseColor tint), checking the shape under good light, size/pivot, triangle and texture checks, and GLB/FBX + PBR map export. That makes it the place where "plastic" turns into "premium".
- **Can't:** resculpt shapes or repaint details. A wrong shape is a stage 2 problem (new generation, Higgsfield, or retopology). Use Blender only for small shape fixes.
- **Lighting doesn't carry over to Roblox.** Unity light is only for judging the model. The game's look comes from Studio Lighting + SurfaceAppearance.
- **LOD:** Roblox makes its own mesh LODs (RenderFidelity Automatic), so don't make LOD groups. Keep the base mesh at the budget.
