---
name: roblox-3d-pipeline
description: Full picture-to-Roblox 3D pipeline for premium game assets. Goes ChatGPT picture → Customuse and/or Higgsfield 3D → Customuse retopology → Unity polish (materials, gloss/metal/glow regions, lighting check, shots vs the picture, GLB/FBX + PBR maps) → Roblox Studio import → handoff to the next agent. Has a tool registry that grows as lyopz adds 3D repos. Use for any new pet, egg, prop, building or hero model, or when lyopz says "polish it in Unity" or "make it look premium".
---

<!-- from: lyopz (2026-10-24): "use Unity to polish better, Blender struggles with designing; Higgsfield and/or Customuse; import to Roblox, then pass to whoever is next; grow as I add 3D repos". -->

# Roblox 3D pipeline (picture → 3D → Unity polish → Studio → next agent)

Run by the **roblox-3d-designer** agent (`agents/roblox/roblox-3d-designer.md`). Other agents can read it too.

## Before starting (every job)
1. Read `references/registry.md`: which tools exist, which are connected, what each is best at. Use the best connected one for each stage. If a tool isn't connected, use its fallback and say so in one line of the report.
2. Read the taste file (`customuse-design/references/taste.md`), the game's bible (`~/RobloxGames/<project>/art-style.md`), and a saved style if the brief names one (`styles/<name>/`).
3. Read `~/.claude/skills/roblox-dev/lessons.md` (the 3D/Unity lines).
4. Write a 5-line spec: what it is, height in studs, triangle budget, the material regions (e.g. matte body / glossy armor / gold trim / glowing crystal), and what "done" looks like.

## Stages
Each stage writes into `~/RobloxGames/<project>/models/<asset>/` (local only, never the repo).

**1. Picture (always ChatGPT).** Write the 8-part prompt (`roblox-art-style/references/chatgpt-prompts.md`). Pets get the "Premium polished pets" block plus matching taste Likes. Run `gpt-image.ps1`. For a change to an existing asset, use `-Ref <current picture>` ("edit this exact picture, only change X"). No approval step.

**2. 3D model.** Pick it from the registry ("3D generators"):
- Default: **Customuse** image-to-3D, low poly, textured (pets 1.5–3k tris, props ≤ 5k). Use `mcp__customuse__*` (customuse_upload_media → customuse_generate on an image-to-3D node from customuse_list_node_types → poll customuse_get_workflow → read meshUrl). Not loaded → `customuse-3d.ps1`.
- **Higgsfield** `generate_3d` when the brief says Higgsfield, when Customuse fails twice, or for a second option on a hero asset. Preflight the cost; stay inside the budget.
- **Both** for hero assets (legendary pets, main egg) when the budget allows. Polish both, put the shots side by side, and keep the better one.
- Mesh lumpy, or too many tris? Run **Customuse retopology** (customuse_estimate_retopology → customuse_start_retopology → customuse_get_retopology_job) before Unity. Never ship a decimated, lumpy mesh.
- Save the .glb as `models/<asset>/<asset>-raw.glb`.

**3. Unity polish** (`references/unity-polish.md`; tool details in the `unity-mcp` skill). This needs Unity open with the degen-polish project and the MCP server started.
1. `DegenPolish.Import(raw.glb, name, heightStuds)` puts it at the origin with the pivot at the base and the scale in studs. Then `Report(name)` checks tris and size.
2. `DegenPolish.ToUrpLit(name)` gives one material system to edit.
3. `DegenPolish.PaintRegions(name, rules)` gives each colour region its own finish. This is the premium look: matte body, glossy armor, metal gold trim, subtle glowing crystals. Rules come from the spec's regions; recipes are in `references/unity-polish.md`.
4. Fine tune with `manage_material` (base colour, smoothness, emission strength; glows stay subtle).
5. `DegenPolish.StudioLight()` + `DegenPolish.Shots(name, <models/asset/shots>, 4, 1024)`. Put view 0 next to the ChatGPT picture. Fix the 3 biggest differences, using rules, colours or retopology. If the shape itself is wrong, go back to stage 2 (new generation or Higgsfield). Unity can't resculpt; Blender is only for small shape fixes.
6. `DegenPolish.ExportForRoblox(name, <models/asset/export>, 1024)` writes `<asset>.glb` (main), `.fbx` (fallback), the PBR maps and `roblox.json`.

Unity not connected? Skip stage 3, import the Customuse .glb directly, and say "Unity polish skipped (not connected)" in the report.

**4. Roblox Studio** (`references/roblox-import.md`). Import the polished .glb, check the SurfaceAppearance maps, scale to the bible's studs, name it, put it in its folder, and take a screenshot in the game's lighting.

**5. Rate + learn.** Run `design-feedback.ps1 -Tool unity` with the Studio screenshot. Write his words into taste.md (all games) or the bible (this game). Put the region rules that worked into the bible's "Unity recipes" section so the next asset in that game reuses them.

**6. Hand off.** End with the handoff block (`references/handoff.md`). The Lead sends it to the next agent: animator (it moves), vfx-artist (aura/trail/elemental animation; taste rule: elemental = animated), scripter (behaviour), map-builder (placing props), ui-designer (icons/cards), then roblox-reviewer.

## Quality gates (all must pass before handoff)
Full list in `references/quality-gates.md`.
- Silhouette and colours match the picture (shots side by side). It's not "a circle on a circle" (`roblox-asset-shapes`).
- Tris ≤ budget, textures ≤ 1024, pivot at base, size in studs per the bible.
- Material contrast reads: body matte, armor/trim shinier, glow subtle. No blown-out neon.
- Smooth surfaces. No lumps, holes or stretched texture.
- Studio screenshot looks as good as the Unity shot. If it doesn't, check the SurfaceAppearance maps.

## Growing this skill (when lyopz adds a 3D repo or tool)
Follow `references/registry.md` → "Adding a tool". Vet it first (licence, no install scripts that download and run unknown code, no telemetry you can't turn off, stars/activity). Add one row, wire it into the stage it improves, and log what it was better at in "Results" after the first real use. Tools that win stay default; tools that lose move to fallback.
