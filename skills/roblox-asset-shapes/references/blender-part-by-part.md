# Blender: build every piece to match the picture (part by part)

## RULE: smooth + light, not faceted + heavy (lyopz 2026-10-23)
Bad: `../examples/bad-faceted-kraken.png` — a decimated image-to-3D mesh: jagged facets everywhere, lumpy surface, eyes lost, too many tris for what it shows. Target: `../examples/target-tidefrost.webp` — smooth toy-like surfaces, clean shapes, crisp details.
- **Model each asset clean from simple shapes** (rounded cube, cylinders, curves) in Blender, using the picture (and any image-to-3D mesh) only as a **reference/blockout** — never ship a decimated AI mesh.
- **Low poly but smooth:** few clean faces + **Shade Smooth + Weighted Normal modifier** (or Shade Auto Smooth 30–40°) so it looks round with few tris. Subdivision only at level 1, applied, on curved parts; bevels 2–3 segments.
- **Flat shading only on crystals/gems** (they're meant to be faceted). Everything else smooth.
- Budget targets: pet **1.5–3k tris total** (body ~200–400), egg **800–1.5k**, pedestal **≤1k**. Texture: vertex colors or ONE 512 texture; no per-part textures.
- **Eyes must read:** separate glossy eye parts — dark pupil #1B1530, iris in element color, big white highlight piece top-left, small second highlight. Never let eyes merge into the body.
- **Colors from the picture:** eyedropper every part; body, accents, glow. Glow only on runes/gems/tips (Neon/emissive in Studio).
- Simplify, don't lose identity: keep every feature the picture has (crest, dots, side fins, tentacle crystal tips, rune) as a clean simple shape; drop noise (lumps, micro-cracks, random bumps).


Goal: the Blender model matches the approved picture **piece by piece**, and fits next to the project's other models in **size and shape language**. Never one blob, never stacked primitives.

## 0. Before modeling
1. Load the picture as a reference: `Add > Image > Reference` (front/three-quarter), set the camera to the same angle (three-quarter, ~35° above). Lock it.
2. Load 1–2 **sibling models** from the project (same egg/pet tier) for scale: `File > Append` or import their GLB from `<project>/higgs/final` or the project's model folder.
3. Write the **parts list** (in the brief / a comment in the .blend): every piece you can see in the picture with
   - name (body, shell, beak, hair-fringe-01…, foot-L, rune-side-L…)
   - size relative to the body (e.g. beak = 0.30 × body width, horns = 0.5 × body height)
   - position (top-back, front-center, sides)
   - shape notes (curved, tapered, layered 3 deep, faceted, plates)
   - color hex sampled from the picture (eyedropper on the reference)
   Aim for **8–25 parts** for a pet, **6–15** for an egg + pedestal, **5–12** for a bush/tree.

## 1. Body (primary shape)
- Start from the project's shared body (style bible). Cube pets: cube → Bevel modifier (width per bible, 3–4 segments, profile 0.5–0.7) → optional slight taper/squish (Simple Deform Taper 0.05–0.1).
- Match the picture's silhouette: overlay the reference in camera view and adjust proportions until the outline lines up.

## 2. Each part (secondary + tertiary)
For every item in the parts list, pick the right technique:
| Part type | Technique |
|---|---|
| Curved flowing pieces (manes, tails, fins, leaves, flames, hair locks) | **Bezier/curve with bevel + taper** or a plane → Solidify → Subdivision (crease the edges you want sharp); bend with Simple Deform/Curve modifier |
| Shells, plates, armor, scales | Hex/quad grid on a sphere section → Inset each face → Extrude slightly → Bevel edges; lighter edge color |
| Horns, spikes, crystals, tentacles | Cone/cylinder → taper + bend (Simple Deform Bend) → segments for tentacles; crystals = hex prisms, flat-shaded, emissive core |
| Beaks, snouts, ears, feet | Low-poly box → Subdivision 2 → shape with proportional editing; ears hollowed with Inset + Extrude in |
| Eyes | Rounded square or sphere-flattened, glossy material, **separate highlight piece** (white), dark pupil |
| Runes / markings | Shrinkwrap a flat curve/mesh onto the surface + tiny Solidify (carved look: Boolean difference 0.02 deep) with emissive color |
| Rings, bands, trims (eggs) | Torus scaled to fit the shell + Bevel; gems set into it (Ico sphere level 1, flat shaded) |
| Foliage clumps | Ico sphere level 2 → Displace (Voronoi/Clouds, small) → Decimate planar for faceting; or leaf cards in layers |
- **Layer it:** flowing parts in 2–3 overlapping layers, each a shade lighter toward the tip.
- **Overlap into the body** (no floating, no gaps); hide seams under other parts.
- **Bevel / smooth shading** on curved parts; flat shading only on intentionally faceted parts (crystals, rocks).
- Keep each part a separate object while modeling (easy fixes), name them from the parts list.

## 3. Color & surface
- Vertex colors or one small texture: base color + darker underside/crevices + lighter top (gradient). Sample hexes from the picture; keep inside the bible palette.
- Emissive only where the picture glows (runes, gem cores, eye rims, tips).

## 4. Check against the picture AND siblings (every time)
Run `scripts/compare_to_siblings.py` in Blender (or the same steps by hand):
- **Picture match:** render the camera view next to the reference (side by side). List the 3 biggest differences (shape, size, color, missing piece) → fix → render again. Stop when a stranger would say "that's the picture".
- **Silhouette:** black-fill render vs picture outline.
- **Siblings:** overall height, width, head/body ratio and part sizes within the bible's rules (pets 2.5 studs, Legendary 3, Mythical 3.2; eggs 4.5 tall). Same bevel size, same eye style, same detail density as the other models in this project.
- Budget: tris per bible (merge parts into one mesh at the end, Decimate only what doesn't change the silhouette).

## 5. Export
Apply transforms, origin at the base, join parts (or keep a few: body, moving parts for animation), export GLB, import to Studio, screenshot in the place next to existing pets. Save `.blend`, GLB and the comparison renders in the project folder.
