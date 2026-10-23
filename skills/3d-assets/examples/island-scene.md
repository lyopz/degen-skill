# Example plan: "Put me on an island with trees" (scene → Blender → Roblox/web)

A reference plan for scene requests. Adjust pieces to the ask.

| Piece | How | Credits |
|---|---|---|
| Concept picture of the whole scene (16:9) | Higgsfield `generate_image` — for approval + layout | few |
| Island ground (sand edge, grass top) | Blender: subdivided plane + noise displace, height-based material | 0 |
| Ocean | Blender: large plane, blue/transparent material (Roblox: Terrain water) | 0 |
| Palm tree ×2 variants | Higgsfield picture → `image_to_3d` (textured) | ~70 |
| Rocks ×1–2 variants | Higgsfield or Blender (rock = displaced ico-sphere) | 0–70 |
| Hut / dock (optional) | Higgsfield picture → 3D | ~35 |

**Concept prompt:**
```
Stylized small tropical island in a calm ocean, white sand ring, green grass center, 8 palm trees,
a few grey rocks, a small wooden hut, bright daylight, low-poly game style, three-quarter aerial view, no text
```
**Prop prompt (tree):**
```
A single stylized palm tree, curved trunk, 6 large leaves, low-poly game asset, three-quarter view,
whole object fully visible, centered, plain neutral grey background, soft even lighting, no text
```
**Assemble in Blender:** import tree/rock GLBs, scatter 8–12 copies on the grass (random rotation, scale 0.8–1.2, snap to ground), add sun + sky, screenshot to check.
**Export:** web/app = one GLB of the scene. Roblox = trees/rocks/hut as separate FBX/GLB (under ~10k tris each, 1024 textures) + terrain via Roblox Terrain Editor heightmap (or the island mesh).
**Estimate:** ~80–180 credits depending on prop count.
