# Example: pigeon → flying cube pet (Cube / blocky preset)

**Ask:** "make a pigeon pet, cube style, give it wings."

## 1. Look up the real thing → identity traits
Plump grey-blue body · small round head · iridescent green-purple neck band · orange eye · short dark beak with white cere · pink feet · two dark bars on each wing.

## 2. Translate into the cube style
- Body + head = **one rounded cube** (bevel ~15%), grey-blue `#8a9bb5`, lighter belly face `#b9c4d6`.
- Neck band = a **flat strip** around the top third, green `#3fb68b` fading to purple `#8b5cf6` (or two flat bands).
- Eyes = two **big orange discs** `#f59e0b` with a black pupil + white highlight, on the front face.
- Beak = small dark **wedge** `#374151` with a white cere dot.
- Wings = two **flat rounded paddles** on the sides, same grey with two dark bars `#4b5563`; flap for flying.
- Feet = two tiny **pink nubs** `#f9a8d4` (hidden while flying).
- Size ~2.5 studs, floats beside the player at shoulder height.

## 3. Cheapest pristine route: Blender (0 credits)
Through the Blender connector:
1. Cube 1×1×1, Bevel modifier (width 0.15, segments 3) → apply. Flat colors via vertex paint or 1 small 256 texture with color swatches.
2. Neck band: loop-cut strip, assign band material. Eyes/beak: small cylinders/wedge, joined.
3. Wings: flattened rounded cubes (0.6×0.1×0.4), origin at the shoulder edge (pivot for flapping). Feet: 2 tiny spheres.
4. ~600–1,200 tris total. Apply transforms, origin at center-bottom.
5. Rig (optional): root + body + wing.L + wing.R bones, or keep wings as separate MeshParts.
6. Export GLB → Studio Import 3D (Custom rig, or No Rig + separate wing parts).

**Motion (no credits):**
- Float + follow: `roblox-templates/templates/Motion.lua` → `Motion.Follow(pet, player, Vector3.new(3, 2, 2))`.
- Wing flap (separate wing parts welded with Motor6D or bones): tween wing rotation ±35° every 0.15 s while moving, slower glide when idle.
- Optional trail/aura for rare tiers: `VFX.Aura(pet.PrimaryPart, rarityColor)`.

**Variants (no credits):** Golden = gold `#f5c542` + Neon trim + sparkle emitter; Rainbow = animated color shift; Dark Matter = near-black + purple aura.

## 4. Higgsfield alternative (if he wants more detail/charm, ~35 credits)
```
A single full-body cute pigeon pet shaped like a rounded cube, blocky toy-like, flat solid colors,
grey-blue body, green-purple neck band, big orange eyes, small dark beak, two flat rounded wings spread,
tiny pink feet, soft bevels, Roblox pet style, three-quarter view, whole object fully visible, centered,
plain neutral grey background, soft even lighting, no text
```
`gpt_image_2_5` 1:1, pass the project's approved pet anchors as reference → approve → `image_to_3d` (textured) → `shrink_glb.py --size 512` → decimate to < 2k tris in Blender.

## 5. Check
Next to the other pets in the game: same cube ratio, same bevel, same eye style, palette colors only, same size class.
