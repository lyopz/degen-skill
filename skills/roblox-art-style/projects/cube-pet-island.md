# Style bible: Cube Pet Island (working title)

Every new asset for this game must follow this file. Update it when lyopz approves something new.

## Identity
- Genre / vibe words: pet collector simulator · sunny tropical · toy-like · bouncy · glossy-cartoon
- Preset: Cube (blocky toy pets) on a chunky-cartoon island
- Games/pictures it should feel like: Pet Simulator 99 pets, Adopt Me island brightness, Animal Crossing beach colors

## Shape language
- Base shapes: rounded cubes everywhere (pets, eggs on pedestals, crates, signs). Map props chunky, slightly oversized.
- Proportions: pets = one body cube (head and body merged), 1:1:1, ~2.5 studs; features stuck on the faces
- Limbs: flat rounded paddles (wings, flippers, fins), stubby nubs for feet, tails as small wedges
- Eyes/faces: two big black rounded squares with a white highlight square (top-left), on the front face; small mouth/beak below
- Edges: rounded (Studio: Part shape Block with small bevel look via 0.1 inset trims; or Blender bevel 15%)

## Color
- Palette (hex): sand #F6CD78 · sea turquoise #28C8DC · deep sea #0A4A7A · palm green #3FB34F · jungle green #1F7A3A · coral #FF6F61 · sunset orange #FF9F1C · cream #FFF4DC · outline dark #2B2D42
- Rarity colors: Common #9ca3af · Uncommon #22c55e · Rare #3b82f6 · Epic #a855f7 · Legendary #f59e0b · Mythical #ef4444 · Secret rainbow/holo
- Coins: gold #FFC83D with lighter rim #FFE38A
- Never use: pure black #000, neon green, grey "default plastic" #A3A2A5 on anything the player looks at

## Surface
- Shading: flat colors, SmoothPlastic. Neon only for glows on interactables (eggs, coins, gate runes, rarity trims).
- Textures: none needed (built from parts/vertex colors). If a texture is used: small 256 · medium 512 · large 1024
- Materials allowed: SmoothPlastic, Neon (interactables only), Sand/Grass/Rock terrain, Wood for docks/signs, Glass (ForceField for egg shine)

## Budgets
- Parts/tris: pets ≤ 25 parts or ≤ 1.5k tris · eggs ≤ 15 parts · coin ≤ 3 parts · map props ≤ 40 parts each
- Scale (studs): player 5 · pets 2–3 (Legendary 3.2) · eggs 6 tall on a 10-wide pedestal · coins 2 wide · gate 16 tall

## Prompt (only if credits are approved later)
- Template: `A single full-body [THING], cute blocky toy shaped like a rounded cube, flat solid colors, Roblox pet style, tropical island palette (sand, turquoise, palm green, coral), big square black eyes with white highlight, three-quarter view, whole object fully visible, centered, plain neutral grey background, soft even lighting, no text`
- Negative / avoid: realistic fur, photo, pixel art, text, extra limbs, gradients

## Lighting & effects
- Lighting preset: bright cartoon (Brightness 3, ClockTime 14) already set on the island; remember it multiplies colors, so keep base colors a bit darker than they look in the picker
- Effects style: soft round particles, palette colors, LightEmission 1, short bursts (≤ 1 s), mobile-safe (≤ 60 particles per burst)

## Anchors (approved assets)
| Asset | File / place | Notes |
|---|---|---|
| Island | Studio place "Untitled Experience" (87731235938790) | island-test scene, turquoise sea, palms, pirate ship |
| Pet style | `examples/pigeon-cube-pet.md` | reference for cube-pet translation |

## Learned rules
- (add as we go)
