---
name: ai-3d-assets
description: Makes 3D models (GLB) from a text idea or a picture using Higgsfield — design image first, then image-to-3D, then shrink and drop into a website, the Degen Skills app, Blender or Roblox Studio. Use when lyopz wants a 3D model, 3D asset, prop, character, item or mesh for a site, app or Roblox game ("make a 3D ___", "turn this into 3D", "make a Roblox asset").
---

<!-- from: lyopz (own workflow, first used for the robot chicken in the Degen Skills app) -->

# AI 3D Assets

The pipeline that made the robot chicken: **idea → picture → 3D model → shrink → use it.**

## 1. Plan it (ask only what's missing)
- What is it, what style, what colors? For Roblox: what is it for (prop, tool/weapon, pet, building piece, character accessory)?
- One object per model. Props and items work best. Characters come out as one solid mesh (statue), not a moving rig — see Roblox notes.

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

## 5. Use it
- **Website / Degen Skills app:** three.js `GLTFLoader` (load three from jsdelivr pinned, e.g. `three@0.169.0`). Center + scale the model from its bounding box, `OrbitControls` with autoRotate and no zoom, a red rim light, tilt toward the cursor, render only while on screen. Follow `three-best-practices`. The app's version is in `assets/app/src/template.html` (`loadModel`). In the app, the GLB lives at `assets/app/src/chicken.glb`; `launch.ps1` turns it into `chicken.js` (file:// pages can't fetch files).
- **Blender:** import the GLB (File → Import → glTF 2.0) to clean up, decimate, or rig. The Blender connector on his PC can do this.
- **Roblox Studio:** see below.

## Roblox notes
- Import: Studio → **Avatar/Home tab → Import 3D** (accepts `.glb`/`.gltf`, `.fbx`, `.obj`). It becomes a MeshPart with its texture.
- Keep it light: aim under **~10k triangles** per mesh (Roblox has a per-mesh triangle limit, and lower is better for phones). AI meshes are often 50–100k, so **decimate in Blender** first (Modifiers → Decimate, ratio until under the limit) and export GLB/FBX.
- Textures max **1024×1024** (`shrink_glb.py --size 1024`).
- Scale: Roblox studs (~1 stud ≈ 0.28 m). Resize in Studio or set scale on import; a character is ~5 studs tall.
- Moving characters need an R15 rig that matches Roblox's rules. AI meshes aren't rigged that way, so use them as props, pets (with simple tween/spin scripts), statues, accessories, or rig them in Blender with Roblox's R15 template.
- Upload costs: importing to your own place is free; publishing to the Creator Store/marketplace may need verification.

## Notes
- Save the source picture and GLB with the project so it can be re-converted or edited later.
- Tell lyopz the credit cost before spending, and balance after.
