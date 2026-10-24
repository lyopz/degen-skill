# Quality gates

Adapted from `create-game-assets` (gamedev-skills/awesome-gamedev-agent-skills, Apache-2.0) and our own lessons. A render is not proof: check the real mesh and the Studio result.

## Shape
- Silhouette matches the ChatGPT picture from the three-quarter view (Unity view0 side by side). Head, horns, wings and tail are in the right place and the right size.
- It isn't "a circle on a circle" or a plain cube (`roblox-asset-shapes`). Accessories are real shaped parts.
- No lumps, holes, floating bits, inverted faces or stretched texture. Lumpy → Customuse retopology or a new generation.
- Same size and style as the game's other models (`compare_to_siblings.py` when there are siblings).

## Technical
- **Low poly (hard, FAIL if over):** pet 1.5–3k (max 4k), prop 300–2k, accessory ≤ 1.5k, building/big piece ≤ 5k. Stylized low poly over detail. Textures ≤ 1024.
- Pivot at the base centre, size in studs per the bible, no leftover scale/rotation.
- Export has a .glb (or .fbx) + roblox.json. Studio has a SurfaceAppearance with maps.
- Collision: Box for decor, Hull for pets. Never use the detailed mesh as collision for big props.

## Look (lyopz's taste)
- Material contrast reads: matte body, glossy armor, metal trim, small subtle glow. Never a blown-out neon sheet.
- Rich, deep colours, not pastel candy or muddy dark. Eyes stay visible against the body (lesson: same-hue glow disappears).
- Elemental designs get animation (handoff to vfx-artist).
- Looks good on a phone: check one Studio screenshot zoomed out to gameplay size.

## Records
- Write into `models/<asset>/notes.md` (local): picture path, generator + credits, retopology yes/no, region rules used, export paths, Studio location, lyopz's rating.
