# Example: Robot chicken (single object → Degen Skills app)

**Ask:** "make a robot chicken with long legs" (for the 3D section of the Degen Skills app).

**1. Picture** — `generate_image`, model `gpt_image_2_5`, `aspect_ratio: "1:1"` (~a few credits):
```
A single full-body robot chicken with very long thin mechanical legs, standing, three-quarter view,
glossy black metal body with glowing red accents and red visor eye, red comb made of metal plates,
clean 3D render, whole object fully visible, centered, plain neutral grey background, no text
```
Result: `robot-chicken.jpg` (this folder).

**2. 3D** — `generate_3d`, model `image_to_3d`, `should_texture: true`, media = the image job id. 30 credits. ~2 min.
Raw GLB: 4.9 MB (55k vertices, 2048px texture).

**3. Shrink** — `python shrink_glb.py raw.glb chicken.glb --size 1024` → 2.3 MB.

**4. Use** — saved as `assets/app/src/chicken.glb`; the app shows it with three.js (auto-rotate, drag to spin, tilts toward the cursor, red rim light).

**Total:** ~35 credits.
**Lessons:** plain grey background + three-quarter view + "whole object visible" gave a clean mesh first try. three.js addons need an import map (`"three": …`) or they fail silently.
