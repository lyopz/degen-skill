# Floating sky islands + buildings: the house style (lyopz, 2026-10-25)

<!-- from: lyopz (2026-10-25): Scrap / Cyber / Frost / Nature island sheets (floating-islands/*.jpg): "and designs like this going forwards for buildings and such". -->

**Default for every game's islands, zones and buildings from now on**, unless lyopz asks for something else. Quality level 6–7 (`roblox-art-style/references/creation-quality.md`).

## The island
- A big **floating island in a bright sky**: a thick rock underside with hanging roots, vines and icicles (whatever fits the theme), **several waterfalls** pouring off the edges, and soft clouds below.
- Around it: **small floating rock platforms** and distant floating islands for depth. Every island is visible from the one below it.
- One theme, everything matching: buildings, rock, plants, lamps, banners, platforms (industrial scrapyard, futuristic city, winter fortress, lush forest...). One main colour + glowing accents in the theme colour.
- Rich environment details: trees/plants/snow pines, lanterns and lamp posts, banners with the theme icon, crates, pipes or gears, crystals, birds. No empty floor.

## Trees, bushes, plants (themed foliage, sheet `floating-islands/foliage-sheet.jpg`)
Every island gets its own trees, bushes and plants, built from its theme's materials. Mix and match shapes, sizes, colours and styles so no two islands share foliage. Keep the stylized low-poly look: chunky canopies, thick curvy trunks, soft bevels, a glow accent in the theme colour.
| Theme | Trees | Bushes | Plants |
|---|---|---|---|
| Scrap / industrial | rusty riveted metal-plate canopies on twisted trunks, glowing seams | scrap piles, crates and gears with sprouts | pipe "cactus" with glowing lamps |
| Cyber / tech | white disc-canopy trees with blue light rings | cube planters with glowing panels | crystal plants in tech pots |
| Frost / ice | snow-loaded pines | snowy bushes with ice crystals | ice crystal clusters |
| Nature / forest | big round leafy trees, vines, glowing lanterns, palms | flowering bushes | ferns, tropical leaves |
| Inferno / lava | dark rock trees with lava veins and dripping lava, red flame-leaf trees | charred rock bushes with glowing cracks | magma crystals, flames |
| Void / dark | twisted purple trees with floating canopy chunks | dark crystal bushes | floating rocks with purple crystals |
| Quantum / cosmic | white-gold trees with faceted glowing gem fruit | gold-trimmed orbs and gyroscopes | gem crystals in gold mounts |
New themes: same recipe (theme materials + one glow accent). Mix in autumn, palm, willow and mushroom trees for variety. Scatter in clusters of 3 sizes, never evenly spaced.

## Layout (top-down)
- Round plaza. The **Hatchery is the landmark at the back centre**: the biggest building, with the island's egg on show in a glowing archway and wide stairs leading up.
- **Shop** (gold, coin sign) on the left, **Crates** (purple, crate sign) on the right, **Upgrades** (blue, arrow sign) at the front right. More stations go around the ring.
- Paths from the plaza edge to each building, and a spawn/arrival point at the front where the parkour lands.
- Building signs: big glowing icon on the roof + name plate in the game's title font (bold caps, coloured by building). Every building is themed to its island but keeps its colour code (Shop gold, Crates purple, Upgrades blue, Hatchery theme colour).
- The main/hub island can hold extra buildings (Fuse, Battle, Rebirth, ...).

## Getting there: parkour up
- Each next island is **higher up, reached by parkour from the island below**. It needs **double-jump upgrades** (sold at Upgrades), so progress = jump power.
- Parkour pieces (themed per island): static platforms, moving platforms, rotating platforms/rings/logs, disappearing (glass/ghost) platforms, boost pads, bounce pads (bounce crystal on ice, bounce mushroom in a forest).
- Readable: glowing top edges or arrows show where to land, and each kind of piece has its own colour. Checkpoints along the way; a fall drops you back to the island below, never to spawn.

## Progression per island
Starter island = Common–Uncommon, mid islands = Uncommon–Epic, later islands = Rare–Epic and higher. Each island has its own egg, its own themed parts in the crates, and (later islands) themed enemies/quests.

## Build notes
- Island underside: a few big rock meshes (not terrain), low poly with soft bevels. Waterfalls = scrolling-texture mesh strips + mist particles at the bottom. Clouds = soft billboard sprites.
- Floating platforms bob slowly (client side). Moving/rotating/disappearing pieces run on TweenService, client-predicted.
- Build at gameplay scale first (jump distances from the double-jump height), then dress it.
