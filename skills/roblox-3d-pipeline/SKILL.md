---
name: roblox-3d-pipeline
description: Full picture-to-Roblox 3D pipeline for premium game assets. Goes ChatGPT picture → Customuse and/or Higgsfield 3D → Customuse retopology → Unity polish (materials, gloss/metal/glow regions, lighting check, shots vs the picture, GLB/FBX + PBR maps) → Roblox Studio import → handoff to the next agent. Has a tool registry that grows as lyopz adds 3D repos. Use for any new pet, egg, prop, building or hero model, or when lyopz says "polish it in Unity" or "make it look premium".
---

<!-- from: lyopz (2026-10-24): "use Unity to polish better, Blender struggles with designing; Higgsfield and/or Customuse; import to Roblox, then pass to whoever is next; grow as I add 3D repos". -->

# Roblox 3D pipeline (picture → 3D → Unity polish → Studio → next agent)
- **Unity first, always (lyopz, 2026-10-24).** For any 3D work (polish, materials, fixes, scale/pivot, scene/prop assembly, previews, export) use Unity (`unityMCP` + `roblox-3d-pipeline` / `unity-mcp` skills). Use Blender only for what Unity can't do (bone rigging + weights, reshaping a mesh) or when lyopz asks for Blender.
- **Own spot in Unity, never on top of another project (lyopz, 2026-10-24, hard rule).** Every game shares one Unity workbench scene. Before any Unity work run `DegenPolish.UseProject("<project>")` (Studio place name, or `<game>/projects/<name>`) and read what it returns: the project's zone, where each model already sits, and any loose objects. `DegenPolish.Import` / `DegenPolish.Spot(name, wStuds, dStuds)` put each model on its own free cell in that zone (zones 250 m apart) and record it in `~/RobloxGames/.degen/unity-layout.json` (local only). Never place, move or edit anything outside your project's `DegenZone_` object; anything built by hand (ProBuilder, primitives, `manage_gameobject`) goes under a `Spot` root. "Where is X?" → `DegenPolish.Where()`.
- **Low poly for Roblox, always (lyopz, 2026-10-24, hard rule).** Stylized low poly over detail: clean chunky shapes, detail from colour/material, not geometry. Budgets (whole model): pet 1.5–3k tris (max 4k), prop 300–2k, accessory ≤ 1.5k, building/big piece ≤ 5k (Roblox's 20k/mesh is a ceiling, never a target). Ask generators for low poly (Customuse face limit), then `DegenPolish.Budget` → over budget = FAIL → `Decimate` or Customuse retopology before export.

Run by the **roblox-3d-designer** agent (`agents/roblox/roblox-3d-designer.md`). Other agents can read it too.

## Before starting (every job)
1. Read `references/registry.md`: which tools exist, which are connected, what each is best at. Use the best connected one for each stage. If a tool isn't connected, use its fallback and say so in one line of the report.
2. Read the taste file (`customuse-design/references/taste.md`), the game's bible (`~/RobloxGames/<project>/art-style.md`), and a saved style if the brief names one (`styles/<name>/`).
3. Read `~/.claude/skills/roblox-dev/lessons.md` (the 3D/Unity lines).
4. Write a 5-line spec: what it is, height in studs, triangle budget, the material regions (e.g. matte body / glossy armor / gold trim / glowing crystal), and what "done" looks like.

## Stages
Each stage writes into `~/RobloxGames/<project>/models/<asset>/` (local only, never the repo).

**1. Picture (always ChatGPT).** Write the 8-part prompt (`roblox-art-style/references/chatgpt-prompts.md`). Pets get the "Premium polished pets" block, the eyes and sketchy grin for their rarity (`roblox-art-style/references/pet-eyes.md`, `pet-mouths.md`), plus matching taste Likes. Run `gpt-image.ps1`. For a change to an existing asset, use `-Ref <current picture>` ("edit this exact picture, only change X"). No approval step.

**2. 3D model.** Pick it from the registry ("3D generators"):
- Default: **Customuse** image-to-3D, low poly, textured (pets 1.5–3k tris, props ≤ 5k). Use `mcp__customuse__*` (customuse_upload_media → customuse_generate on an image-to-3D node from customuse_list_node_types → poll customuse_get_workflow → read meshUrl). Not loaded → `customuse-3d.ps1`.
- **Higgsfield** `generate_3d` when the brief says Higgsfield, when Customuse fails twice, or for a second option on a hero asset. Preflight the cost; stay inside the budget.
- **Both** for hero assets (legendary pets, main egg) when the budget allows. Polish both, put the shots side by side, and keep the better one.
- Mesh lumpy, or too many tris? Run **Customuse retopology** (customuse_estimate_retopology → customuse_start_retopology → customuse_get_retopology_job) before Unity. Never ship a decimated, lumpy mesh.
- Save the .glb as `models/<asset>/<asset>-raw.glb`.

**3. Unity polish** (`references/unity-polish.md`; tool details in the `unity-mcp` skill). This needs Unity open with the degen-polish project and the MCP server started.
0. `DegenPolish.UseProject("<project>")` first and read what is already in the project's zone (`references/unity-polish.md` → "Your project's spot"). Never build on another project's spot.
1. `DegenPolish.Import(raw.glb, name, heightStuds)` puts it on its own free cell in the project's zone with the pivot at the base and the scale in studs, and records where. Then `DegenPolish.Budget(name, <spec tris>)`. FAIL → `DegenPolish.Decimate(name, <spec tris>)` (big cuts look lumpy → Customuse retopology with a face limit instead, then re-import).
2. `DegenPolish.ToUrpLit(name)` gives one material system to edit.
3. `DegenPolish.PaintRegions(name, rules)` gives each colour region its own finish. This is the premium look: matte body, glossy armor, metal gold trim, subtle glowing crystals. Rules come from the spec's regions; recipes are in `references/unity-polish.md`.
4. Fine tune with `manage_material` (base colour, smoothness, emission strength; glows stay subtle).
5. `DegenPolish.StudioLight()` + `DegenPolish.Shots(name, <models/asset/shots>, 4, 1024)`. Put view 0 next to the ChatGPT picture. Fix the 3 biggest differences, using rules, colours or retopology. If the shape itself is wrong, go back to stage 2 (new generation or Higgsfield). Unity can't resculpt; Blender is only for small shape fixes.
6. `DegenPolish.ExportForRoblox(name, <models/asset/export>, 1024)` writes `<asset>.glb` (main), `.fbx` (fallback), the PBR maps and `roblox.json`.

Unity not connected? Skip stage 3, import the Customuse .glb directly, and say "Unity polish skipped (not connected)" in the report.

**4. Roblox Studio** (`references/roblox-import.md`). Upload the polished .glb with `roblox-upload.ps1` and insert it by asset id (no click for lyopz; Import 3D card only if there is no key yet), check the SurfaceAppearance maps, scale to the bible's studs, name it, put it in its folder, and take a screenshot in the game's lighting.

**5. Rate + learn.** Run `design-feedback.ps1 -Tool unity` with the Studio screenshot. Write his words into taste.md (all games) or the bible (this game). Put the region rules that worked into the bible's "Unity recipes" section so the next asset in that game reuses them.

**6. Hand off.** End with the handoff block (`references/handoff.md`). The Lead sends it to the next agent: animator (it moves), vfx-artist (aura/trail/elemental animation; taste rule: elemental = animated), scripter (behaviour), map-builder (placing props), ui-designer (icons/cards), then roblox-reviewer.

## Let lyopz watch (every time, lyopz 2026-10-24)
lyopz wants to see it designing. Keep each step on screen:
- **ChatGPT:** `gpt-image.ps1` already brings the Edge window to the front.
- **Customuse / Higgsfield:** right after starting a generation, open its page so he sees it build: `Start-Process "<canvasUrl>"` (Customuse returns canvasUrl) or the Higgsfield result link.
- **Unity:** the Lead opens it minimized. Run `unity-open.ps1 -Show` at the start of stage 3 so it pops up, and `unity-open.ps1 -Hide` after the export to minimize it again (lyopz's choice). `Import`, `ToUrpLit` and `PaintRegions` frame the model in the Scene view by themselves; call `DegenPolish.Focus(name)` after every `manage_material` tweak too. Do material changes one region at a time, not all in one hidden batch.
- **Studio:** after the import, select the model and point the Studio camera at it (`roblox-import.md` step 6).

## Quality gates (all must pass before handoff)
Full list in `references/quality-gates.md`.
- Silhouette and colours match the picture (shots side by side). It's not "a circle on a circle" (`roblox-asset-shapes`).
- **Low poly (hard):** `Budget` says PASS (pet 1.5–3k, max 4k; prop 300–2k; accessory ≤ 1.5k; building ≤ 5k). Export refuses over budget. Textures ≤ 1024, pivot at base, size in studs per the bible.
- Material contrast reads: body matte, armor/trim shinier, glow subtle. No blown-out neon.
- Smooth surfaces. No lumps, holes or stretched texture.
- Pets: grin crisp and matches the rarity tier; otherwise a mouth decal (`pet-mouths.md` → "On the 3D model").
- Avatar items (bodies, heads, layered clothing, rigid accessories): run Studio's UGC Validation Visualization (Avatar tab, 2026-10-22) — errors red / warnings yellow on the mesh, plus new body Asset Quality checks. https://devforum.roblox.com/t/improving-validation-checks-for-ugc-avatar-bodies-visualization-tool-and-asset-quality/4950522
- Studio screenshot looks as good as the Unity shot. If it doesn't, check the SurfaceAppearance maps.

## Gotchas from projects (promoted 2026-10-24)
- Customuse CR1: geometry-only 100 credits, Model & Texture (1K) 70 credits; put 2–3 parts spaced apart in one picture → split by loose parts (merge by distance first). Base64 uploads can corrupt on flat/repeating images → subtle gradient background, md5-check every upload (WebP from Blender uploaded clean).
- Customuse GLB faces +X: rotate −90° about Z for a −Y front. Image-to-3D keeps the picture's camera angle; pairs from a 3/4 view come out yawed per side — fix each side.
- Studio MULTIPLIES MeshPart.Color with vertex colors: for palette recolor bake greyscale shading (0.75–1.0), one MeshPart per palette region + `PaletteRole`. Textured store meshes don't tint → remove TextureID and recolor. Skip store packs with Synty-style names (PolygonCity_*): doubtful licence.
- Parts mounted on a body: keep the faces they sit on flat; bands/crowns follow the rounded top's bevel. If the approved picture has bigger features than the bible caps, the picture wins.
- **(promoted 2026-10-25)** Open Cloud GLB + InsertService works but Studio turns glTF 180° about Y → rebuild with `CFrame.Angles(0, math.pi, 0) * part.CFrame` and assert pieces land on their layout centres. Studio reads glTF vertex colours as raw sRGB → write the sRGB value into the linear field. Unity `DegenPolish.Import` moves the pivot to bottom-centre → for socket kits ship the Blender GLB (Unity for look shots + Budget only). bmesh: call `bm.normal_update()` after moving verts before any inward-flip test; count per-face normals vs outward on every closed mesh.
- Clean metal without baked textures: 5 shared solid 64 px PNGs (white, black, grey roughness 0.22/0.32/0.45) → SurfaceAppearance ColorMap white tinted by `SA.Color`, Metalness/Roughness from the solids. SA maps can't be swapped live (editing ColorMap didn't re-render) → clone a prepared SA. Tri budget: spend on silhouettes — hidden-side bevels 3 levels, 6-sided feet, 5–8 sided bolts.
- Socket contracts: keep the invisible anchor part + slot Attachments as the contract; a new body/look layer clones that anchor (+ standard feet) and only builds the shell; store rest offsets as CFrame attributes so clients can re-pivot. Extend a contract only where the old resolver refused (gate on a kit-version field) so old assets resolve byte-identically. Asset families (crates, pads, signs): one shared base script `exec`'d by each variant + one table-driven installer (id, tint, tris).
- Blender Standard view: strong emission on light vertex colors clips pink/white → dark base + deep emission, glow pieces as separate Neon meshes in Studio. Free texture: project the source picture from the matching view. Seamless overlays: generate procedurally (draw each primitive at ±size offsets).

- **(promoted 2026-10-28) Colour in imports:** glTFast GLBs have no `COLOR_0` (vertex colour/AO lost) — upload the ASCII .fbx it writes beside the GLB (keeps colours); FBX imports at a uniform ~15.09× (Size = MeshSize / ratio), keep meshes < ~135 studs. Shallow-groove AO never reads → a dark inset strip mesh or bake into a texture. Pre-flipped GLB (x, z × −1) imports in body space → place at layout bbox centres; tag the import copy with an `AssetId` attribute and reload when it changes.
- **(promoted 2026-10-28) One shading map, many colours:** a near-white (AO/edges only) ColorMap + `SA.Color` tint per piece lets one 512 map serve every colour region, and Skins/Shiny only touch SA.Color (painted maps turn muddy). Copper/brass go olive above metalness ~0.3 → 0.18–0.25 or SmoothPlastic; neon on copper needs a hue + value gap (FF7A1A/FFC15A on C47A4E).
- **(promoted 2026-10-28) Procedural Unity buildings** (kit + one builder per building) beat generators for hubs: separate moving parts, exact palette, 0 credits. Plan tris first (arch window ~45, porthole ~60, bollard ~112, bevelled box 44 vs 12). Grounding: 3 rock outline rings stepping down/out, root 2–4 studs under the floor. Stepped tiers trap baked AO → ao 0.2 / distance 0.045. Change shared kit colours first, upload last. Dark gunmetal lifts ~1.2× under dusk. Text on a −Z face comes out mirrored → flip X; judge in Studio, not Unity.
- **(promoted 2026-10-28) Installers:** one table-driven installer for a whole set (pcall + `task.wait()` per asset), kept as a ModuleScript in ServerStorage; prefix attachment names (`DoorLHinge`). Single-sided domes vanish from below → underside disc. Lid rigs: take the rest pose at spawn (`chest:GetPivot():ToObjectSpace(lid:GetPivot())`); pose every lid open in one shot before handoff. Stacked accessories: always preview stacked; rest a stacker on the measured visible top under its footprint + a gap. Patina masks: smoothstep edges. Blender headless image: set `colorspace_settings.name` before writing pixels (else black).
## Growing this skill (when lyopz adds a 3D repo or tool)
Follow `references/registry.md` → "Adding a tool". Vet it first (licence, no install scripts that download and run unknown code, no telemetry you can't turn off, stars/activity). Add one row, wire it into the stage it improves, and log what it was better at in "Results" after the first real use. Tools that win stay default; tools that lose move to fallback.
