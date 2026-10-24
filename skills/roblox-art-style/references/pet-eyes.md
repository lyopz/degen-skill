# Pet eyes: styles by rarity (lyopz, 2026-10-24)

<!-- from: lyopz (2026-10-24): sent the "Eyes Accessory Pack" sheet (pet-eyes/eye-ideas.jpg) right after the mouth sheet; eyes are done the same way as mouths (`pet-mouths.md`). -->

Reference: `pet-eyes/eye-ideas.jpg` (27 styles, fit example, animations). Two styles on that sheet copy a famous anime's eye designs; they are renamed and redesigned below. **Never use those two original names or their designs (red iris with three comma marks; purple concentric ripple rings) in a game.**

## Rules (every pet)
- **Front face only.** Left, right and back faces have no eyes.
- **Recessed 3D sockets**, not flat painted dots: a shallow socket cut into the body with a thin rim, a glossy eyeball inside, the iris/glow on top. Depth is what makes them read as premium.
- **Size: upper half of the front face.** Each eye about 15–22% of the face width, set in from the edges, so the lower half stays free for any mouth (mouths wrap 3 sides, `pet-mouths.md`). Eyes never touch or overlap the grin.
- Sharp and confident shapes (slanted, almond, slit, gem). No huge round googly eyes (taste.md). "Classic Gloss" is the only round one, and it's Common.
- Glow stays subtle (emission ≤ 0.6) and a different hue from the body (same-hue glow disappears, quality gates).
- Eyes and mouth come from the same tier and element where possible (fire eyes + Demon Fangs, ice eyes + Crystal Teeth).

## Styles by rarity
| Tier | Styles | Look |
|---|---|---|
| Common | Classic Gloss, Narrow Slit | glossy round blue eyes with a white glint; thin slanted white glowing slits |
| Uncommon | Cat Eyes, Anime Sharp | amber eyes with vertical slit pupils; sharp angled red eyes with a bright highlight |
| Rare | Cyber Lens, Heterochromia, Ring Eyes | metal camera-lens rims with blue glowing iris; one blue + one orange eye; purple iris with 2–3 rings |
| Epic | Four Eyes, Third Eye, Demon Eyes, Void Eyes, Toxic Eyes | two pairs of small purple eyes; a third diamond eye above the pair; red eyes with flame-shaped lids; white-hot eyes with purple smoke; green eyes with slime drips |
| Legendary | Crystal Eyes, Star Eyes, Inferno Eyes, Multi Eyes, Guardian Eyes | ice shard frames; golden four-point star pupils with sparkle; fire-wreathed orange eyes; six small eyes in two columns; white-gold feather wings round each eye |
| Secret | Celestial Eyes, Glitch Eyes, Abyss Eyes, **Ripple Core** (renamed), **Blood Sigil** (renamed), Elemental Eyes, Dragon Eyes, Spirit Eyes, Matrix Eyes, Galaxy Eyes | planet + orbit ring; pixel-glitch pink/cyan; white wisps on black; see below; see below; one ice eye + one fire eye; scaled teal dragon eyes; ghostly blue wisp eyes; green code-bar pupils; swirling galaxy iris |

Renamed so they're our own:
- **Ripple Core** (was the purple ripple-ring style): teal-to-gold iris with a bright core and 3 thin rings that are broken into arcs and slowly orbit at different speeds. Not purple, not solid concentric rings.
- **Blood Sigil** (was the red three-mark style): deep red iris with a black original sigil (a four-point star with a hook on each point, or the game's own rune) that spins and sharpens when the pet activates. No comma/teardrop marks.

Rarity colours (cards, crate, labels): Common grey, Uncommon green, Rare blue, Epic purple, Legendary gold, Secret red. If a game's bible has its own rarity list, map these rows onto it from the bottom up (bible wins on colours).

New styles: mix mechanical, magical, realistic, creepy, cute; vary shape, colour, number of eyes and animation. Keep the rules above.

## Animations (every glowing style gets at least idle + blink)
| Animation | What it does | Roblox |
|---|---|---|
| Idle | iris drifts slowly | tween the iris part a few hundredths of a stud inside the socket |
| Blink | smooth close/open every 3–6 s (random) | tween the eye's Y scale to ~0.1 and back (0.12 s), or a lid part sliding down |
| Look around | iris follows the nearest player | each Heartbeat aim the iris offset toward the player, clamped to the socket |
| Pulse | glow breathes | tween emission / SurfaceGui `Brightness` or a small PointLight |
| Activate | special effect on hatch, equip, attack | quick scale-up + bright flash + particle burst, then back |
| Rotating iris / spinning symbol | Ripple Core, Blood Sigil, Cyber Lens | `ImageLabel.Rotation` on a SurfaceGui (LightInfluence 0) on the iris disc |
| Colour shift, expanding pupil, energy flow, particle glow, dripping ooze, cracked lens, floating shards, glitch, multi-layer iris, orbiting rings | per style | layered ImageLabels, ParticleEmitters, Beams; handoff to vfx-artist (`roblox-vfx`) |

## Prompt words (part 4 "Face" of the 8-part prompt, before the mouth line)
"Eyes: <style look from the table>, only on the front face, set in shallow recessed sockets with a thin rim, glossy eyeballs with depth, placed in the upper half of the face, each about one fifth of the face width, leaving the lower half clear for the mouth; sharp confident shape, subtle <colour> glow, not googly, not flat painted dots."

Eye-only picture for a separate eye part (crate accessory or crisp texture): "a pair of <style> pet eyes, front view, flat, on a plain #00FF00 green background", then `scripts/chroma-key.py`.

## On the 3D model
1. Picture → Customuse as usual; the sockets come from the picture. In Unity, the `eyes` rule in `PaintRegions` gives them gloss + glow.
2. Crisp, separate and animated (needed for anything above Common, and for crate eyes): build an **Eyes** model welded to the body's front face: socket rim MeshPart (body colour, glossy) + eyeball MeshPart (smooth 0.95) + iris disc with a SurfaceGui (LightInfluence 0) holding the iris picture(s). One eye rig per base body; styles swap the iris pictures and small extra meshes (flames, wings, shards).
3. Animation script lives in the Eyes model (the animator or vfx-artist writes it, using the table above). Keep it cheap: one Heartbeat loop per pet, pause when far from the camera.
4. Keep the game's eye picks per tier in the bible ("Eyes" section, local).
