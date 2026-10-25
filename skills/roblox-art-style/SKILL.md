---
name: roblox-art-style
description: Keeps every asset in a Roblox game in ONE matching art style. Holds a per-project style bible (shapes, proportions, palette, shading, texture size, poly budget, prompt suffix, approved reference assets), looks up what the real subject looks like (e.g. a pigeon), then converts it into the game's style (e.g. a flying cube pet with wings) before any model is made. Use whenever lyopz asks for a new Roblox asset, pet, NPC, item, building or effect ("make a ___ pet", "give it wings", "make it fit the game"), when starting a new Roblox project, or when assets look mismatched. Works with roblox-assets (making/moving) and roblox-design (meta).
---

<!-- from: lyopz (own workflow, researched 2026-10-22). Sources at the bottom. -->

# Roblox Art Style
- **Low poly for Roblox, always (lyopz, 2026-10-24, hard rule).** Stylized low poly over detail: clean chunky shapes, detail from colour/material, not geometry. Budgets (whole model): pet 1.5–3k tris (max 4k), prop 300–2k, accessory ≤ 1.5k, building/big piece ≤ 5k (Roblox's 20k/mesh is a ceiling, never a target). Ask generators for low poly (Customuse face limit), then `DegenPolish.Budget` → over budget = FAIL → `Decimate` or Customuse retopology before export.

**Rule #0: build it exactly how lyopz describes it.** His words and his reference pictures beat the preset ("simple cube pet" is a starting point, not a limit). When he asks for a change (e.g. "good curves on the edges"), apply it AND write it into the project's bible as a rule so every future asset in that project gets it.

**Rule #1: one game = one style.** A realistic dog next to a pixel-slop brainrot looks broken. Every new asset is *translated* into the project's style; never generated "as itself".

## The flow for every new asset
1. **Load the project's style bible** — `~/RobloxGames/<project>/art-style.md` (local only, never in the repo) — plus lyopz's all-games taste file `customuse-design/references/taste.md`. No bible yet → make one first (below). Never skip.
2. **Look up the real subject** (only what's needed): `image_search` / WebSearch "<subject> reference" → note 4–6 **identity traits** that make it read as that thing. Pigeon: plump grey-blue body, small round head, iridescent green-purple neck band, orange eye, short dark beak with white cere, pink feet, two dark wing bars.
3. **Translate** the traits through the bible's **shape language** and **transform rules** (e.g. cube pets: body = rounded cube, head merged into the cube, features as flat painted shapes, wings = flat rounded paddles, feet = 2 tiny nubs). Keep the identity traits, drop everything else. Write the translation as 3–5 bullets and show lyopz if he's around.
4. **Pick the cheapest pristine route** (pictures: lyopz's ChatGPT via `references/chatgpt-prompts.md` is free and high quality — default when credits are 0) (from `roblox-assets`):
   - Simple stylized shapes (cube pets, blocky items, crates, coins) → **Studio parts or Customuse + Unity polish** (Blender fallback), 0 credits, exact match to the bible's palette.
   - Organic or detailed (stylized dog, tree, statue, vehicle) → **Higgsfield picture** with the bible's **prompt template + suffix**, and pass 1–2 **approved anchor images** from the bible as reference media so it copies the look → approve → `image_to_3d` (~30).
   - Variants (golden, rainbow, shiny, dark) → **recolor/material swap**, never a new generation.
5. **Shape check** (`roblox-asset-shapes`): silhouette, primary/secondary/tertiary shapes, bevels — never "a circle on a circle".
6. **Consistency check** (against the anchors, side by side in one scene): silhouette readability, proportions (head/body ratio), palette (only bible colors + rarity accent), shading type, detail density/texel density, outline/edge treatment, poly budget, scale in studs. Fix or regenerate before it goes in the game.
7. **Save** the approved asset in the bible's anchor list (picture job id + file) and add any new rule learned. The bible gets stronger with every asset.

## Making a style bible (new project)

**Saved styles first.** lyopz saves looks he likes in the app's **Save for later** tab, each with his own name: `styles/<name>/` in this repo (`style.md` = what he likes + the look/palette/rules, `prompts.md` = the ChatGPT/Customuse prompts that worked, `pic-*.png` = anchor pictures). If the brief names one, start the new bible from it: copy its shapes, palette and rules, use its pictures as the anchors/reference images, and reuse its prompt wording. These are the best examples of his taste, so check them when writing any prompt for a new game too.
Ask lyopz only what's missing: game genre, vibe words (3), 1–3 games/pictures he likes. Then:
1. Make **one concept picture** (Higgsfield, cheap) of the world + 2–3 sample assets in the chosen preset. Iterate until he says yes — this becomes **anchor #1**.
2. Fill `references/bible-template.md` → `~/RobloxGames/<project>/art-style.md` (palette hexes pulled from the approved picture).
3. **Never commit it.** Bibles, concept pictures and anchors are lyopz's game content and stay on his PC only. Only general rules (no game names or details) go back into this skill.

## Style presets (start from one, then customize)
| Preset | Looks like | Shapes | Shading/texture | Poly / texture | Prompt suffix |
|---|---|---|---|---|---|
| **Cube / blocky** | Pet Sim-style cube pets, blocky worlds | Rounded cubes, flat paddle limbs, big painted eyes | Flat colors / vertex color, 1-tone shadow painted in, no normal maps | 300–2k tris, 256 tex or none | `cute rounded-cube shaped, blocky toy-like, flat solid colors, big simple eyes, soft bevels, Roblox pet style` |
| **Chunky cartoon** | Adopt Me, Grow a Garden | Big heads, short limbs, soft round forms, thick silhouettes | Hand-painted gradients, saturated, minimal texture detail | 1k–8k, 512 | `chunky cartoon, big head small body, soft rounded shapes, saturated colors, hand-painted look, Roblox game asset` |
| **Low-poly flat** | Stylized nature/sim maps | Faceted, angular, few large planes | Flat shaded per face, palette swatches (atlas) | 200–4k, 256 atlas | `low-poly faceted, flat shaded, limited color palette, clean geometric shapes, game asset` |
| **Anime cel** | Anime fighters | Sharp shapes, dramatic proportions | Cel shading: 2 tones + highlight, colored outlines | 3k–15k, 1024 | `anime cel-shaded, two-tone shading, bold clean shapes, vibrant colors, game asset` |
| **Stylized realistic-lite** | Horror, FPS, RP | Real proportions, simplified detail | PBR (SurfaceAppearance) with muted, coherent materials | 5k–20k, 1024 PBR | `stylized semi-realistic, simplified detail, coherent muted materials, game-ready` |
| **3D brainrot meme** | Brainrot games | Exaggerated meme shapes, glossy toy look | Glossy plastic, bright, consistent lighting | 2k–10k, 512 | `glossy toy-like 3D meme character, exaggerated proportions, bright plastic materials, clean render` |
Always end prompts with the framing from `3d-assets`: `single full-body [thing], three-quarter view, whole object visible, centered, plain neutral grey background, soft even lighting, no text`.

## Consistency rules (any style)
- **One palette** per project (6–10 colors + rarity accents); pull every color from it.
- **Same proportions family** (e.g. all pets 1:1 head-body cubes, all NPCs 1:2 head-body).
- **Same detail density & texel density** across assets (one texture resolution per asset size class; reuse texture atlases/materials).
- **Same edge treatment** (all bevelled, or all hard; all outlined, or none).
- **Same shading model** — never mix PBR-realistic with flat-painted in one game.
- **Same scale rules** in studs (pets ~2–3 studs, players 5, doors 8–10).
- **Rarity language** consistent everywhere (inventory, trades, world): Common grey, Uncommon green, Rare blue, Epic purple, Legendary gold, Mythical red, Secret rainbow/holo. Evolutions (Normal → Golden → Rainbow → Dark Matter) are material/color swaps + effects, same mesh.
- **Effects** follow the palette too (fire color, aura color) and the same particle style.
- Check new assets **next to existing ones** in one scene, not alone.

## Pets & eggs
For pet/egg games, also read `roblox-design/references/pets-and-eggs.md` and record in the bible: egg style (floating / grounded / machine), base egg mesh, pet style (one of its 6), pet size by tier, variant looks. Every pet face uses eyes + the sketchy grin by rarity tier: `references/pet-eyes.md`, `references/pet-mouths.md` (lyopz's hard rules). Wings, back pieces and auras: `references/pet-accessories.md`. Modular pets (slots, zones, animations): `references/pet-parts.md`; the game's items: its local `pet-catalog.md`; upgrades: `references/pet-upgrades.md`. Quality bar for every asset (level 5–7): `references/creation-quality.md`.

## Example
`examples/pigeon-cube-pet.md` — real pigeon → flying cube pet with wings, built for 0 credits in Blender (with the Higgsfield alternative).

## Sources (researched 2026-10-22)
- Sloyd — 3D assets with AI in a consistent style (style anchors, fixed prompts, scene check): https://www.sloyd.ai/blog/how-to-style-consistent
- Makko — AI game art: why consistency is the hard part (concept pool, save-to-reference loop, review traits): https://blog.makko.ai/ai-game-art-generator/
- Vasundhara — optimizing Roblox low-poly art (one art direction, flat colors, texel density, atlases, limited materials): https://vasundhara.io/blogs/how-to-optimize-roblox-art-for-better-performance-low-poly-tips
- creation.dev — making a pet simulator (rarity tiers/colors, evolutions, egg odds): https://www.creation.dev/learn/how-to-make-pet-simulator-roblox
- DevForum — stylized low poly showcase/discussion: https://devforum.roblox.com/t/stylized-low-poly/3780170
