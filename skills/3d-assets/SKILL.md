---
name: 3d-assets
description: Turns any idea into 3D assets or a whole 3D scene (single props or environments like "an island with trees"). Makes reference pictures with Higgsfield, converts them to GLB with image-to-3D and/or builds and assembles them in Blender, then exports for a website, the Degen Skills app or Roblox Studio. Also holds lyopz's prompt & design library (prompts.md). Use for any 3D model, asset, prop, character, map, level or scene request ("make a 3D ___", "build a Roblox map", "make game assets"), and whenever writing or saving an image/video/design prompt.
---

<!-- from: lyopz (own workflow, first used for the robot chicken in the Degen Skills app) -->

# 3D Assets

## Two kinds of 3D — pick first
| | **Web 3D** (this skill) | **Roblox 3D** (`roblox-assets`) |
|---|---|---|
| Goal | Looks great on a web page / the Degen Skills app | Imports into Roblox Studio and usually **moves** |
| Output | One GLB, shown with three.js | MeshParts under 20k tris, 1024 textures, rigs (Custom/R15), animations, VFX scripts |
| Motion | three.js spin/tilt, optional baked animation | Blender rig + Animation Editor, scripted motion, ParticleEmitter/Beam/Trail effects |
| Polish rules | `three-best-practices` | `roblox-design` (meta, UI sizes, game feel, "10,000x cooler") |

**Credits rule (both):** use the cheapest route that still looks pristine — Roblox VFX / Blender / scripted motion cost 0; Higgsfield only for detailed unique models (~35 per model, picture first so the look is approved before the 3D step). Many copies = 1–3 variants duplicated.

A general process for any 3D request: **idea → break it into assets → picture of each → 3D model of each (Higgsfield or Blender) → assemble the scene in Blender → shrink/export → use it.** (First used to make a robot chicken, but it works for anything.)

## 0. Break the request down
- **One object** ("a sword", "a robot chicken") → steps 2–4, one model.
- **A scene** ("an island with trees", "a spooky village") → list the pieces and decide how each is made:
  - **Ground / big shapes** (island, terrain, water, roads, walls, floors): build directly in **Blender** — sculpted/displaced plane, simple modelled shapes, ocean plane. These come out cleaner and lighter than AI meshes.
  - **Detailed props** (palm trees, rocks, huts, chests, characters, vehicles): **Higgsfield** picture → image-to-3D, one per unique prop; reuse copies for repeats (10 trees = 1–3 tree models, duplicated, rotated, scaled).
  - **Simple repeats** (fences, planks, crates) are often faster to model in Blender than to generate.
- Also make one **concept picture of the whole scene** first (`generate_image`, wide 16:9) so lyopz can approve the look and you have a layout guide.
- Show him the plan + credit estimate before generating: ~a few credits per picture, ~30 per textured 3D model.

## 1. Ask only what's missing
- What is it, what style, what colors? For Roblox: what is it for (prop, tool/weapon, pet, building piece, character accessory)?
- One object per model (never ask image-to-3D for a whole scene; it can only rebuild one object). Props and items work best. Characters come out as one solid mesh (statue), not a moving rig — see Roblox notes.

## 2. Make the source picture (Higgsfield `generate_image`)
Model `gpt_image_2_5`, `aspect_ratio: "1:1"`. A picture built for 3D conversion gets far better results:
```
A single full-body [THING], [style], [colors/materials], three-quarter view,
whole object fully visible, centered, plain neutral grey background, soft even lighting, no text
```
- Three-quarter view, nothing cut off, plain background, no other objects, no heavy shadows.
- For Roblox, add "low-poly stylized, chunky shapes, game asset" to match the Roblox look.
- Show lyopz the picture before converting if he's around (it's cheap to redo; 3D costs more).

## 3. Convert to 3D (Higgsfield `generate_3d`)
- Model `image_to_3d`, `medias: [{value: <image job id>, role: "image"}]`, `should_texture: true` for color.
- Cost: ~30 credits with color, ~20 grey. Preflight with `get_cost: true` and tell him the number.
- Several views of the same thing? Use `multi_image_to_3d` (2–4 images) for better shape.
- Result is a `.glb` URL on cloudfront. The cloud sandbox can't download it: use the browser pane on his PC (request access to the cloudfront host, open the file URL, fetch it as a blob and click a download link), then `device_stage_files` from his Downloads (the file may land as a `.tmp` or a random name; match by size).

## 4. Shrink it
`python shrink_glb.py in.glb out.glb --size 1024` (in this folder). Textures are usually most of the size (the chicken: 5 MB → 2.3 MB). Roblox's max texture size is 1024, so always use 1024 for Roblox.

## 5. Assemble a scene in Blender (Blender connector on his PC)
Use the `mcp__remote-devices__Blender__*` tools (`execute_blender_code`, screenshots, `render_viewport_to_path`):
1. Build the base: e.g. island = subdivided plane + noise displacement, sand/grass material by height, ocean plane with a blue/transparent material.
2. Import each GLB: `bpy.ops.import_scene.gltf(filepath=...)` (stage/copy the GLBs into a folder Blender can reach on his PC).
3. Place copies with variety (random rotation 0–360°, scale 0.8–1.2), keep them on the ground (raycast down onto the terrain).
4. Add lights/sky, check with a viewport screenshot, fix what looks off.
5. Clean up for the target: decimate heavy meshes, join small static props, apply transforms.
6. Export: whole scene `bpy.ops.export_scene.gltf(filepath=..., export_format='GLB')` for web/app; for Roblox export each asset separately (FBX or GLB) so they import as separate MeshParts, plus the terrain.
Save the `.blend` file with the project so it can be edited later.

## 6. Use it
- **Website / Degen Skills app:** three.js `GLTFLoader` (load three from jsdelivr pinned, e.g. `three@0.169.0`). Center + scale the model from its bounding box, `OrbitControls` with autoRotate and no zoom, a red rim light, tilt toward the cursor, render only while on screen. Follow `three-best-practices`. The app's version is in `assets/app/src/template.html` (`loadModel`). In the app the shown model is `assets/app/src/chicken.glb` (swap the file to change it); `launch.ps1` turns it into `chicken.js` because file:// pages can't fetch files.
- **Blender:** import the GLB (File → Import → glTF 2.0) to clean up, decimate, or rig. The Blender connector on his PC can do this.
- **Roblox Studio:** see below. For terrain, Roblox's own Terrain Editor (Generate / Import heightmap) is often better than a mesh island: export a heightmap image from Blender and import it.

## Roblox notes
For anything going into a Roblox game, switch to **`roblox-assets`** (limits, decimation, rigging, animation, VFX like fireballs/flaming legs, import steps) and **`roblox-design`** (what looks and feels good in Roblox right now).

## Examples and prompt library
- `examples/robot-chicken.md` — single object, start to finish, real prompt + costs.
- `examples/island-scene.md` — scene plan (what's made in Blender vs Higgsfield, prompts, estimate).
- `prompts.md` — **every prompt and design that worked**, for images, video, 3D and sites. Read it before writing a new prompt; add to it whenever lyopz shares or approves a prompt, a look or a design.

## Notes
- Save the source picture and GLB with the project so it can be re-converted or edited later.
- Tell lyopz the credit cost before spending, and balance after.
