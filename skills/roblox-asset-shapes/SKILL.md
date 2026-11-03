---
name: roblox-asset-shapes
description: How to give Roblox assets real shape definition so they never look like "a circle on a circle" — eggs, bushes, trees, rocks, pets, crystals, pedestals, coins. Silhouette first, primary/secondary/tertiary shapes, bevels and curved edges, chunky stylized forms, layered foliage clumps, painted shading, when to use Studio parts vs Blender vs image-to-3D (Higgsfield or free Tripo/Meshy/Hunyuan3D/TRELLIS), and a per-asset recipe list. Use whenever making or reviewing any Roblox model, when something looks choppy, blobby, flat or too simple, or when lyopz says "make it look like the picture", "more detail", "curved edges", "it looks cheap".
---

<!-- from: lyopz (2026-10-23): "everything is just a circle over a circle on Roblox Studio" — fix that. Living document. -->

# Roblox Asset Shapes
- **Low poly for Roblox, always (lyopz, 2026-10-24, hard rule).** Stylized low poly over detail: clean chunky shapes, detail from colour/material, not geometry. Budgets (whole model): pet 1.5–3k tris (max 4k), prop 300–2k, accessory ≤ 1.5k, building/big piece ≤ 5k (Roblox's 20k/mesh is a ceiling, never a target). Ask generators for low poly (Customuse face limit), then `DegenPolish.Budget` → over budget = FAIL → `Decimate` or Customuse retopology before export.

**Rule:** a model is done when its **silhouette alone** says what it is, and it matches the approved concept picture side by side. Plain spheres/cubes stacked = not done.

## 0. Smooth + light (lyopz rule)
Never ship a faceted, lumpy, decimated image-to-3D mesh (jagged facets, lumpy surface, lost eyes). Clean it: Customuse retopology + Unity polish first; else rebuild in Blender: few faces + Shade Smooth + Weighted Normal, crisp separate eyes, colors from the picture, small budget (pet 1.5–3k tris). Image-to-3D output = reference only. Details: `references/blender-part-by-part.md`.

## 1. Pick the build route
| Looks like | Route | Why |
|---|---|---|
| Boxy/simple (crate, coin, cube body, pedestal) | Studio parts **with bevels** (or Unity ProBuilder) | 0 credits, exact colors |
| Curvy/organic (egg with trims, bush, tree, rock, creature, pet design parts) | **ChatGPT picture → Customuse/Higgsfield → Unity polish** (`roblox-3d-pipeline`); Blender only if that fails → MeshPart | Studio parts can't do smooth curves without looking stacked |
| Very detailed / matches a concept picture exactly | **Customuse/Higgsfield → Unity polish** first; **Blender part by part** from the picture only as a fallback; image→3D only as a blockout to trace (never shipped as-is) | smooth, light, matches the picture |
| Many copies | 1–3 variants, random rotation/scale ±15% | variety without cost |

**Image → 3D options:** Higgsfield `generate_3d` (credits) · **free:** Tripo, Meshy (free monthly credits, commercial use on free tier per their pages — check), **Hunyuan3D-2** and **TRELLIS 2** (open source, run free on lyopz's PC if the GPU has ~8 GB+ VRAM, unlimited). Always: approved picture first → 3D → Blender cleanup (decimate, fix normals, merge parts, vertex colors / 1 texture) → under budget → import.
**Pictures:** Higgsfield, or lyopz can make them in ChatGPT and drop them in (no ChatGPT connector here) — same prompt template from `3d-assets/prompts.md`.

## 1b. Blender part by part (fallback when Customuse/Higgsfield + Unity can't match the picture)
Follow `references/blender-part-by-part.md`: parts list from the picture (8–25 parts for a pet, each with size relative to the body, position, shape, color), the right technique per part (curves for manes/tails, inset plates for shells, bent cones for horns/tentacles, shrinkwrapped carved runes…), layered and overlapping, then `scripts/compare_to_siblings.py` → side-by-side with the picture + size/shape check against the project's other models. Fix the 3 biggest differences, repeat.

## 2. Shape language (every asset)
1. **Primary shape** (big read, ~60–70% of volume): egg, cube body, bush mass, trunk.
2. **Secondary shapes** (2–5): trims, horns, leaf clumps, roots, wings — they **break the outline**. Silhouette must change when you add them.
3. **Tertiary** (small): gems, runes, highlights, spots — only where the eye should go.
- Vary sizes: big / medium / small (roughly 60/30/10). Never all the same size.
- **Bevel / curved edges** on everything (Blender Bevel modifier 2–3 segments, or Studio: rounded via mesh). No razor edges, no plain spheres.
- **Taper and asymmetry:** wider bottoms, tilted tops, one side heavier. Perfect symmetry looks fake (except faces/eggs).
- **Overlap, don't stack:** parts sink into each other with a visible crease, not balanced on top.
- **Painted shading:** darker color at the bottom/crevices, lighter on top (vertex color gradient or 2-tone). Reads as form even on phones with low graphics.
- **Rim/accent glow** only on the 1–2 focal parts (Neon / emissive).

## 3. Recipes
**Egg (showcase):** egg mesh (not a sphere: wider bottom, height ≈ 1.25× width) · 2–3 trim bands that wrap and slightly stick out (bevelled, gold) · 3–6 gems set into the bands (faceted, emissive core) · crown/crystal top for higher tiers · rune/pattern decal on the shell · pedestal = bevelled stone cylinder with chipped rim + glowing ring inset. Motion: bob + slow spin + light.
**Pet face:** glowing animated eyes (no outlines) on the front face only, upper half (`roblox-art-style/references/pet-eyes.md`) + the sketchy grin (wide, chunky uneven white teeth, black ink crosshatch), bigger and wilder for rarer pets. Tiers and how to put it on the mesh (texture, or Decal / curved mouth plate): `roblox-art-style/references/pet-mouths.md`. Never a smooth round open mouth with a coloured rim.
**Pet back/top accessory:** own model on a mechanical hub at the upper back (`BackMount`), aura floats above the top (`AuraTop`), never on the face; ≤ 1.5k tris; wings = mirrored pair pivoting at the hub. `roblox-art-style/references/pet-accessories.md`.
**Island foliage:** themed trees/bushes/plants per island (scrap metal trees, cyber disc trees, snow pines, lava trees, void crystal trees, gem trees...): `roblox-design/references/floating-islands.md` → "Trees, bushes, plants".
**Bush:** 5–9 **leaf clumps** (each a lumpy, faceted blob or layered leaf cards), different sizes, overlapping, flattened bottom sitting into the ground, a few clumps poking out of the outline; 2 shades + top highlight; optional berries/flowers (tertiary). Never one sphere or 3 equal spheres.
**Tree:** trunk tapers and bends, root flare at the base, 2–3 branches; canopy = 3–7 clumps (same as bush) offset upward and outward; darker under-canopy. Palm: segmented trunk with rings, fronds as curved bevelled blades with a notch, coconuts as tertiary.
**Rock:** faceted chunk (decimate a subdivided cube + random displace), flat-ish bottom, 1 big face + chipped edges, cluster of 3 sizes, moss/snow cap on top faces.
**Crystal:** 5–8 hex prisms with pointed tips, different heights/angles, from one base; emissive core, lighter tips.
**Cube pet:** body = bevelled cube (15–25% bevel or what lyopz says), features as separate shaped parts (ears, horns, tail, wings, snout, feet) that change the silhouette; eyes in recessed sockets, front face, upper half, style by rarity (`pet-eyes.md`). Match the concept picture's proportions exactly.
**Coin/gem pickup:** thick bevelled disk with raised rim + embossed symbol; gem = faceted cut, not a sphere.

**More recipes (2026-11-03)**
- **Plates on a shell:** explicit 2D plates with sharp corners read as riveted sheet metal; random Voronoi cells read as pebbles. Seams/panels can be painted into the colour map from a 3D SDF (`exp(-(d/0.014)^2)`) with no new geometry. Outlines from a shape field: 0-contour by marching triangles, smooth + resample by arc length; corner disc ~1.3× arm half-width, smooth-min k ~0.07 (≥ 0.14 = blobs). Rivets: test against the clipped outline with a min spacing. Voronoi cells: drop slivers (inradius < 0.12 rad) and re-solve; move cell centres away from keep-outs instead of dropping seeds.
- **Crown rim:** one closed wall swept round the lid, scalloped per-sample height, spikes snapped to exact samples; balls on a flat rim read as lumps.
- **Folded feathered wings:** feathers on a bilinear map between leading- and trailing-edge curves, parallel to the leading edge, inner on top, shell steps ~0.04–0.05 × radius, slight cross-curl; more, narrower feathers beat a bigger shell; big and turned ~36° toward the front to read.
- **Foliage:** leaf-card bushes stay faceted; one ray-marched smooth dome (soft union of 3 lobes minus leaf cushions, colour from crease depth, ≥ 40×16 rings) reads stylized at ~2k tris. Canopy = 3–5 lobes of thick teardrop shingle leaves pointing down-slope with a light rim each (round pillows = turtle shell, dark leaf-gap AO = cracked plates).
- **Crusty surfaces:** domain-warped fbm clumps split by narrow winding channels of varying width (Voronoi shards read as stone, big gaps as cow spots).
- **Small stylized water:** mesh + SurfaceAppearance (alpha shore fade) + two slow scrolling Textures beats Terrain water (dark 4-stud facets). Deep-to-shallow fade, soft foam edge, low-contrast large ripples (high-contrast caustics = swimming pool).
- **Ground textures:** 1024 over ~100 studs ≈ 10 px/stud → painted clumps/flowers 1.5–2.5 studs across; saturation ≤ ×1.12 (more drifts lime); a new bright patch reads as a lit rectangle (fade ~7 studs of edge or swap the whole plot). Studio Grass material clashes with baked kits → SmoothPlastic in kit greens.
- **Glass and crystal:** a glowing core inside → transparent SmoothPlastic (T 0.3–0.55, Reflectance 0.18), not Glass (Glass hides transparent parts behind it). See-through bodies need a frosted liner; clip cage triangles behind it.
- **Moving parts:** spinners built at the origin on their own axis, exactly symmetric, tilted via CFrame. Doors need ~70° to read open from the front camera, DoubleSided panels, riders parented under the panel part.
- **Companion props:** reuse the hero's atlas files as-is (same UVs) so image ids and colours match. **Logos:** SurfaceGui ImageLabel (LightInfluence 0) on a face part clear of any bevel, over a dim body-colour backing so a slow load never shows black. **Reads from far:** thick Neon seam band proud of the box, coloured inlays, glow along metal lips.

**What reads wrong:** spoked drums = steering wheels · dark flat discs = holes · octagon-cut squares = crates · full-slab Neon = a sheet (thin band instead) · opaque white glints on wood = scratches · dark painted gap bands = smears (thin Neon tube with a dark lip) · two round knobs side by side = anatomy (upload hold) · a tilted ring adds ~2·R·sin(tilt) height.

**Tri savings with no visible loss:** ring segments → 14–24, tube sides 6, 4-point band profiles, 6-seg or no rivets, no caps on hidden ends, arcs only at loop corners. Spend it on silhouette.

## 4. Quality check (before showing lyopz)
- Silhouette test: black-fill screenshot — can you name it? Does it match the concept's outline?
- Side-by-side with the concept picture in one screenshot. Note 3 differences; fix the biggest.
- 20-stud test (player distance) and phone low-graphics view.
- Edges: no stacked-sphere look, no z-fighting, no gaps where parts meet.
- Budget: tris/parts/texture size per `roblox-art-style` + `roblox-assets`.
- If it looks choppy: more bevel segments / smooth shading on curved parts, flat shading only on intentionally faceted parts.
- **(2026-11-03)** Hero surface forms (slats, plates, domes) are real geometry; paint only colour, grain, glints. Moving/floating pieces: check clearance against the REAL motion (every spin angle, both limits, highest bob) vs sampled shell triangles, not a radius envelope; keep each displaced vertex inside its plate's own cell. Removing decorative rails needs a closed replacement shell (assert manifold, volume, bounds). Socket checks: mount the real accessories (or thin marker parts) on a review clone and compare body-space Y ranges (`GetPartsInPart` on mesh clones returns nothing — trust the shot). Never fit a finished asset by non-uniform scale (flattens bevels/rims, drops a PivotOffset pivot under the floor and drags pivot-anchored UI with it): redesign at the new size; after any resize check `GetPivot()` against the authored point.

## 5. Learn
When lyopz approves or rejects an asset, add a line here (what made it work / what looked bad) and update the project's style bible.

## Sources (researched 2026-10-23)
- DevForum — Low poly tree feedback: https://devforum.roblox.com/t/low-poly-tree-feedback/366051
- DevForum — How to make a low poly tree: https://devforum.roblox.com/t/how-to-make-a-low-poly-tree/1344712
- Blender Artists — tips for stylized low poly: https://blenderartists.org/t/what-are-the-tips-and-tricks-to-make-stylized-low-poly-creations/1510574
- Best free AI 3D generators 2026 (Tripo, Meshy, Hunyuan3D, TRELLIS 2): https://www.3daistudio.com/blog/best-free-ai-3d-model-generators-2026
- Open source 3D generators: https://www.cmarix.com/blog/top-open-source-ai-models-for-3d-image-generation/
