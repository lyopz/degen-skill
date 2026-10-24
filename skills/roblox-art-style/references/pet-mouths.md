# Pet mouths: the sketchy grin (lyopz, 2026-10-24, hard rule)

<!-- from: lyopz (2026-10-24): "see how this mouth is? and the other is slop. i want all mouths to have the same feel, some rarer than others" -->

Every pet mouth has the same feel: a **wide hand-drawn grin**. Rarer pets get a more dramatic version of the same grin. Reference he loves: `pet-mouths/liked-grin.jpg` (attach it in ChatGPT, or use it as `-Ref`, when the mouth comes out wrong).

## The look (all rarities)
- **Wide crescent grin**, corners curving up toward the cheeks. Sits low on the front face, under the eyes.
- **Chunky, uneven white teeth**, each a slightly different size and tilt, like hand-cut paper. Upper and lower rows meet (closed bite) on lower tiers.
- **Black ink drawing style**: thin black gaps between teeth, **crosshatch / pen-scratch shading** at the corners and along the gumline, rough sketchy edges. It looks drawn on with a pen, on top of the glossy 3D body.
- **No outline in another colour, no lips, no tongue, no pink.** Mouth is only white teeth + black ink + the body colour.
- Flat, matte teeth. The body around it stays glossy and premium (`chatgpt-prompts.md` → "Premium polished pets").

## Slop (never)
- A plain rounded open mouth: smooth capsule/oval hole, dark inside, with a smooth coloured outline (orange/gold ring). Clean vector shapes with no ink.
- Cartoon smiles: simple curved line, "U" smile, tongue, pink inside, cute small mouth.
- Perfect identical teeth in a neat row (looks like a zipper or a keyboard).

## Rarity tiers (same grin, more drama)
| Tier | Width of the front face | Teeth | Ink + extras |
|---|---|---|---|
| Common | ~55% | 8–10 chunky flat teeth, closed bite | light crosshatch only at the two corners |
| Uncommon | ~60% | 10–12, one tooth a bit crooked | crosshatch at corners + thin gumline scratches |
| Rare | ~70%, corners curl up higher | 12–14, one chipped tooth, one small gap | heavier crosshatch, sketch lines trailing from corners |
| Epic | ~85%, wraps slightly round the front bevel | mix of square teeth and 2–4 short pointed fangs | dense ink shading, rough scribble edge |
| Legendary | wraps onto both side faces | jagged teeth, slightly parted bite showing a black inked inside, 2 long fangs | ink cracks spreading from the corners; thin glow line in the pet's element colour along the ink (subtle, ≤ 0.4) |
| Mythic / Huge / Secret | full "Cheshire" grin wrapping most of the way round | most jagged, uneven rows, longest fangs | ink drips/scratches leaking from the corners, glowing element-colour edge on the teeth; animated (slow grin widen or ink shimmer, handoff to vfx-artist) |

Keep it readable from far away: the grin is the face's main shape, eyes stay small and sharp. When a game's bible names its own rarities, map them onto these rows from the bottom up.

## Prompt words (part 4 "Face" of the 8-part prompt)
Base line, every pet:
"Mouth: a wide hand-drawn grin across the lower front face, corners curving up, chunky uneven white teeth of slightly different sizes, thin black ink gaps between the teeth, black pen crosshatch shading at the corners and along the gumline, rough sketchy ink edges, like an ink illustration drawn onto the glossy body; matte white teeth; no lips, no tongue, no coloured outline, not a round open cartoon mouth."

Then add the tier line:
- Common: "grin about half the face wide, closed bite, light crosshatch only at the corners."
- Uncommon: "grin a bit wider than half the face, closed bite, one crooked tooth."
- Rare: "grin about 70% of the face wide with corners curling up high, one chipped tooth and a small gap, heavier crosshatch, sketch lines trailing from the corners."
- Epic: "grin almost edge to edge, wrapping slightly around the front bevel, a few short pointed fangs among the square teeth, dense ink shading."
- Legendary: "grin wrapping onto both side faces, jagged teeth slightly parted showing a black inked inside, two long fangs, ink cracks spreading from the corners with a thin <element colour> glow line."
- Mythic/Huge/Secret: "huge Cheshire grin wrapping most of the way around the body, very jagged uneven teeth, longest fangs, ink drips and scratches leaking from the corners, thin glowing <element colour> edge on the teeth, still clean and readable."

## On the 3D model (Customuse → Unity → Studio)
Image-to-3D bakes the mouth into the texture, but a 1024 texture often blurs the ink. Check it in the Unity shots:
1. **Ink still crisp in the shots?** Keep it. In `PaintRegions`, put the teeth rule **before** silver so the teeth don't turn metal: `{"label":"teeth","hueMin":0,"hueMax":360,"satMin":0,"satMax":0.12,"valMin":0.85,"metal":0,"smooth":0.3,"glow":0}` (see `roblox-3d-pipeline/references/unity-polish.md`).
2. **Blurry, melted or lumpy teeth?** Make the mouth a separate face texture: ChatGPT picture of **only the grin, flat front view, on a plain #00FF00 green background** (white teeth won't cut out from white), same prompt words + tier line. Key out the green to a transparent PNG (`python skills/roblox-art-style/scripts/chroma-key.py in.png out.png`), save it in `~/RobloxGames/<game>/models/<pet>/mouth.png` (local only).
3. **Studio:** upload `mouth.png` with `roblox-upload.ps1` (decal) and add a `Decal` on the body MeshPart, `Face = Front`. For a strongly rounded body, or a grin that wraps onto the sides (Legendary+), use a thin curved mouth MeshPart that follows the front bevel with the texture on it instead, so it doesn't stretch.
4. Keep one mouth per rarity per game in the game's bible ("Mouths" section, local) so every pet of that tier uses the same grin.
