# Style bible: Mythic Cube Pets (working title)

Every new asset for this game must follow this file. Update it when lyopz approves something new.
Brief (lyopz): "cool pets and cool eggs, 3 eggs 10 pets, unique mythical creatures, simple body, complex designs, cube design for the body."

## Identity
- Genre / vibe words: pet collector simulator · mythical · glowing runes · toy-like but epic
- Preset: Cube (blocky toy pets) with a rich "design layer" on top. **Simple body, complex design.**
- Games/pictures it should feel like: Pet Simulator 99 cube pets, with Hearthstone/Clash-style fantasy color and glow accents
- Differs from `cube-pet-island.md`: same cube body rules, but a night/arcane palette, emissive runes and many more design parts per pet

## Shape language
- **Body (fixed for every pet):** ONE rounded cube, head merged in, 1:1:1, bevel ~15% (Blender) / soft. Same body mesh for all 10 pets; only color + design layer changes.
- **Design layer (where the "complex" goes), 3-5 of these per pet:**
  - Horns / antlers / ears: curved or pointed wedges, gold or bone
  - Crests: crystal spikes (faceted, emissive core) or layered flame/ice feather fans (2-3 flat stacked layers, each a shade lighter)
  - Manes / tail plumes: flame or ice as 2-3 layered flat flame shapes, tips glow
  - Wings: layered flat paddles (2-3 overlapping layers: membrane, feathers, tip), never real feathers
  - Tails: wedge or segmented chain of small cubes, ending in a **glowing gem tip**
  - Runes: flat painted symbols on the cube faces (decals/inset parts), one "signature rune" per pet on the front or forehead, Neon
- **Silhouette rule:** each pet must be identifiable from its black silhouette alone (horns vs ears vs crest vs tentacles). Design parts stick OUT of the cube; the cube itself stays clean.
- Limbs: 2-4 tiny nub feet (or none for floaters/swimmers); tentacles = 3-6 short segmented paddles
- Eyes/faces: two big glossy rounded-square **jewel eyes** in the pet's element color (fire = amber/gold, tide = cyan, celestial = blue/magenta), dark pupil #1B1530, big white highlight top-left, soft inner glow (as in anchor #1); no mouth or a tiny wedge snout/beak
- Edges: bevelled everywhere (body and design parts). No outlines.
- Detail density: body = flat; all detail lives on the design layer (keeps the read clean on phones)

## Color
- Palette (hex):
  - Night indigo #1E1B4B (backgrounds, egg shells, dark accents)
  - Deep violet #4C1D95 (eggs, pedestals, rune fills)
  - Stone slate #3B3F5C (pedestals, horns' dark parts)
  - Moonstone cream #FFF3D6 (light bodies, highlights)
  - Ember orange #FF7A1A (fire element)
  - Crimson #D7263D (fire secondary, phoenix)
  - Flame gold #FFC23D (horns, trims, sun runes)
  - Frost cyan #7DE3FF (ice/water element)
  - Tide blue #1E6FD9 (water secondary)
  - Arcane teal #14B8A6 (rune glow, pedestal ring, magic)
  - Rune magenta #E040FB (celestial/spirit accents)
  - Eye dark #1B1530
- Element sets (body + glow): Fire = ember/crimson + gold glow · Tide/Frost = tide blue/frost cyan + teal glow · Celestial = cream/violet + magenta or teal glow
- Rarity colors (reserved for rarity UI, auras and nameplates; not for pet bodies): Common #9ca3af · Uncommon #22c55e · Rare #3b82f6 · Epic #a855f7 · Legendary #f59e0b · Mythical #ef4444 · Secret rainbow/holo
- Never use: pure black #000, neon green, default grey #A3A2A5, realistic textures, more than 2 glow colors on one pet

## Surface
- Shading: flat solid colors + one painted shadow tone (vertex color in Blender). SmoothPlastic. Neon/emissive ONLY on eyes rim, runes, gem tips, crystal cores, flame tips.
- Textures: none by default (vertex colors). If needed for runes: 256 per pet (atlas all rune decals into one 512 sheet). Eggs 512.
- Materials allowed: SmoothPlastic, Neon (glow accents only), Glass/ForceField (egg shine), Slate/Basalt for pedestals

## Budgets
- Pets: ≤ ~2.5k tris (single MeshPart preferred) or ≤ 40 parts if built from Studio parts. Body ≤ 300 tris; design layer gets the rest.
- Eggs: ≤ 1.5k tris or ≤ 20 parts (base egg mesh shared by all 3 eggs; trims/runes/gems differ)
- Pedestal: ≤ 2k tris / ≤ 25 parts. Any mesh ≤ 20k, textures ≤ 1024.
- Scale (studs): player 5 · pets 2.5 (Legendary 3, Mythical 3.2, Huge 6-7) · egg 4.5 tall, floating 1.5 above a 9-wide round pedestal · egg stand total ~8 tall

## Eggs (style: floating showcase)
- Base: classic rounded egg (wider bottom), bevelled gold trim bands, glowing rune lines, small crystal gems. One mesh, recolored per egg.
- Motion: bob 0.6 studs / 2.5 s, spin 15°/s, PointLight in the egg's glow color (Range 12, Brightness 1.5), soft sparkles.
- Pedestal: round slate stone with a glowing rune ring in the egg's glow color.
- Tier language: Ember = plain shell + 1 trim band · Tidefrost = 2 bands + gems · Celestial = gold trim, more gems, beam of light upward.
- BillboardGui above: name + price; odds panel within 12 studs (see `pets-and-eggs.md`).

## Roster (approved 2026-10-23; per-pet builds in `RobloxGames/mythic-cube-pets/designs.md`)
| Egg (theme, colors) | Pets (common → rarest) |
|---|---|
| **Ember Egg** (fire, ember shell, gold glow), starter | Salamander · Cerberus · Phoenix · Dragon |
| **Tidefrost Egg** (sea + ice, tide blue shell, teal/cyan glow) | Kappa · Kelpie · Kraken |
| **Celestial Egg** (moon + spirit, violet shell, magenta/teal glow), premium | Griffin · Unicorn · Kitsune |
Rarity per egg follows `pets-and-eggs.md` odds; the last pet of each egg is that egg's chase pet.

## Variants (same mesh)
Normal → Golden (flame gold body, sparkle) → Rainbow (hue-shift body, glow stays) → Void (night indigo body, glow becomes magenta, dark aura). Runes and gem tips always keep glowing.

## Prompt
- Template: `A single full-body [THING] cube pet, ONE rounded cube body with the head merged in, soft bevels, big glossy rounded-square eyes with a white highlight and a soft [ELEMENT COLOR] glow rim, tiny nub feet, simple body with rich layered design details: [3-5 DESIGN PARTS: horns / crystal crest / layered flame or ice mane / layered wings / tail with glowing gem tip / painted [RUNE] on its front], stylized 3D game asset, blocky toy-like, flat solid colors with one soft painted shadow tone, mythical palette ([BODY COLORS] + [GLOW COLOR] glow accents), emissive glow only on eyes, runes, gems and flame tips, Roblox pet simulator style, three-quarter view, whole object fully visible, centered, plain neutral grey background, soft even lighting, no text`
- Negative / avoid: realistic fur, scales or feathers, photo, pixel art, text, extra limbs, separate head, sphere body, gradients on the body, glow everywhere
- Model: `gpt_image_2_5` (0.25 credits per 16:9 image on 2026-10-23); pass anchor #1 as reference media for every new pet picture.

## Lighting & effects
- Lighting preset: new "Mythic twilight" (between Golden hour and Neon night in `roblox-design/references/maps.md`, tune by eye): ClockTime ~18.8, Brightness 2, Ambient (60,50,90), Atmosphere Color (120,90,200) Haze 1.5, Bloom Intensity 0.8 Threshold 1.1 so Neon runes glow, ColorCorrection Saturation 0.15. Brighter presets multiply colors: keep bodies a bit darker than the picker.
- Effects style: soft round particles + small rune sprites, element colors (fire = ember/gold, tide = cyan/teal, celestial = magenta/cream), LightEmission 1, short bursts ≤ 1 s, ≤ 60 particles per burst, pet auras only on Epic+ and only for your own pets on low-end.

## Anchors (approved assets — pass as reference images)
| Asset | Higgsfield job id / file | Notes |
|---|---|---|
| Concept #1 | `91edb839-f3dc-4546-aaf2-5787bb81f10d` (gpt_image_2_5, 16:9) · https://d8j0ntlcm91z4.cloudfront.net/user_3L4LCHlKifsYxboNYNM03FMJEaN/hf_20261023_062953_91edb839-f3dc-4546-aaf2-5787bb81f10d.png · local `RobloxGames/mythic-cube-pets/concept-01.png` | **APPROVED by lyopz 2026-10-23.** Prompt saved in `3d-assets/prompts.md` (Mythic Cube Pets concept lineup); settings: 16:9, quality low, 1k, 0.25 credits. Dragon, phoenix, kitsune + violet egg floating on slate pedestal with teal rune ring. Hit: cube bodies, jewel eyes, layered horns/crest/wings/tails, painted runes, glow only on accents. |
| Concept Ember set | `03710227-c226-44c3-9d77-8a998c5af069` (gpt_image_2_5, 16:9, low, anchor #1 as image_references) · https://d8j0ntlcm91z4.cloudfront.net/user_3L4LCHlKifsYxboNYNM03FMJEaN/hf_20261023_064501_03710227-c226-44c3-9d77-8a998c5af069.png · local `RobloxGames/mythic-cube-pets/concept-ember.png` | PENDING lyopz approval. Salamander, Cerberus, Phoenix, Dragon + Ember egg. Note: the picture put a sun rune on Salamander too; designs.md (flame rune only) wins. |
| Concept Tidefrost set | `e90aa980-dc9d-4426-a099-b35ef3579971` (gpt_image_2_5, 16:9, low, anchor #1 as image_references) · https://d8j0ntlcm91z4.cloudfront.net/user_3L4LCHlKifsYxboNYNM03FMJEaN/hf_20261023_064501_e90aa980-dc9d-4426-a099-b35ef3579971.png · local `RobloxGames/mythic-cube-pets/concept-tidefrost.png` | PENDING lyopz approval. Kappa, Kelpie, Kraken + Tidefrost egg. Kraken fin crest drawn very tall: good silhouette, keep it. |
| Concept Celestial set | `c7ed826a-29ce-4b0f-b5f4-af85926f1dbf` (gpt_image_2_5, 16:9, low, anchor #1 as image_references) · https://d8j0ntlcm91z4.cloudfront.net/user_3L4LCHlKifsYxboNYNM03FMJEaN/hf_20261023_064501_c7ed826a-29ce-4b0f-b5f4-af85926f1dbf.png · local `RobloxGames/mythic-cube-pets/concept-celestial.png` | PENDING lyopz approval. Griffin, Unicorn, Kitsune + Celestial egg (matches anchor #1 egg). |

## Learned rules
- Fire pets share orange: keep each one apart by silhouette AND body color. Dragon = ember orange body + horns/crystal spikes/bat wings; Phoenix = gold body with crimson markings + tall flame crest. (seen in concept #1, dragon and phoenix read close)
- The concept prompt was ~300 words with a per-object paragraph; gpt_image_2_5 followed every listed design part. Keep naming each design part explicitly.
- Per-egg lineups (3-4 pets + egg) with anchor #1 as `image_references` held the style exactly at 0.25 each; 4 pets + egg in one 16:9 still fits.
- Image models copy runes between neighbours (Salamander got the Phoenix sun rune). The buildable spec in `designs.md` is the source of truth, not the picture.

## lyopz's target look (2026-10-23) — recreate this
- **Target:** `mythic-cube-pets/target-look.webp` (Kappa, Kelpie, Kraken + Tidefrost egg on pedestal). **What we got v1:** `mythic-cube-pets/got-in-studio-v1.png` — too flat/blocky, design parts too simple, eggs read as plain spheres with stripes.
- Gap to close (do these going forward, and on remakes as info grows):
  - Body: cube with **soft, well-rounded edges** (bigger bevel, ~25%), slight squish/taper, not a hard box.
  - Surface: sculpted, toy-like **soft shading** (painted gradients, subtle rim light), glossy jewel eyes with big highlights — not flat single colors.
  - Design parts: **sculpted, layered and curved** (flowing mane, leaf/fin layers, shell plates, crystal tentacle tips) — real 3D curves, not flat wedges.
  - Glowing **rune markings carved/painted into the body**, element-colored.
  - Eggs: faceted/sculpted shell with ornate gold band + gem, crystal crown, glowing swirl rune, on a carved stone pedestal with glowing rune ring.
- Route: approved picture → image-to-3D (Higgsfield or free Tripo/Meshy/Hunyuan3D) → Blender cleanup to budget. Studio parts alone can't reach this look.
- lyopz edits as we go: every change he asks for becomes a rule here.
