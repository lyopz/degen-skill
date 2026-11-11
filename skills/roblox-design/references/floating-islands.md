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
- **(2026-11-09) Organic plans:** an "even but wobbly" plan still reads round once built — push the plan itself (aspect > 1.3, bays, set-backs, odd plot polygons) before building, and check the built pads keep the plan's odd shapes, not just its positions.

## Getting there: parkour up
- Each next island is **higher up, reached by parkour from the island below**. It needs **double-jump upgrades** (sold at Upgrades), so progress = jump power.
- Parkour pieces (themed per island): static platforms, moving platforms, rotating platforms/rings/logs, disappearing (glass/ghost) platforms, boost pads, bounce pads (bounce crystal on ice, bounce mushroom in a forest).
- Readable: glowing top edges or arrows show where to land, and each kind of piece has its own colour. Checkpoints along the way; a fall drops you back to the island below, never to spawn.

## Progression per island
Starter island = Common–Uncommon, mid islands = Uncommon–Epic, later islands = Rare–Epic and higher. Each island has its own egg, its own themed parts in the crates, and (later islands) themed enemies/quests.

## Build notes
- Island underside: a few big rock meshes (not terrain), low poly with soft bevels. Waterfalls = scrolling-texture mesh strips + mist particles at the bottom. Clouds = soft billboard sprites.
- Floating platforms bob slowly (client side). Moving/rotating/disappearing pieces run on TweenService, client-predicted.
- **(promoted 2026-10-28) Organic island outlines:** star-shaped r(θ) = smoothed radius × (1 + seeded harmonics k=2..7 + gaussian points/bays), max() with protected circles (footprints, route samples, poles, trees) and pinned to the old radius at each bridge landing (blend ~17 studs); stepped strata bands 1.2–2.6 studs. 1.4–4.5k tris per island. Circle-union decks: check every route point is inside a lobe (R−2) — the notch between lobes is air.
- **(promoted 2026-10-28) Walkable mesh tops:** don't trust PreciseConvexDecomposition — invisible WedgePair fan floors on the deck plane + invisible wall segments at r+0.3 (gaps at bridges). A MeshPart's collision hull bevels ~0.7 stud down at the rim → sample trim height ~3 studs inside the rim.
- **(promoted 2026-10-28) Spawn view:** no poles/props beside the spawn camera or in front of the landmark; backdrop islands = scaled clones of existing island meshes, far and low (tops near the horizon).
- **(promoted 2026-10-28) Checks:** jump windows — cast rays rim to rim at several heights/offsets (a box overlap flags the side walls); measure gaps/rises lip to lip from placed parts (build-script numbers ran up to 0.9 stud low). Fall recovery — stand ≥ 1.5 s, drop, log Y every 0.4 s. **(2026-11-09) Holes:** checking pads/doors/spawns misses coast gaps — raycast a 2-stud grid down onto the walkable colliders, flood-fill misses from outside the bounding box; any miss the fill can't reach is a hole under visible ground (found 173 between ground and rim colliders).
- Build at gameplay scale first (jump distances from the double-jump height), then dress it.
- **(2026-11-03)** Underside: stacked flat strata fans read as a "wedding cake" — hang ~6 big inverted rocks (height ~1.3× band thickness) off each band's lower edge and end in an inverted spike + crystal tip (~+12 parts). Add-on areas should "grow out of the island's own rock" (same strata, paving and plants flowing across, bases sunk into rock plinths; terraces stepping DOWN read more natural than a raised deck). A waterfall must visibly feed water below it (stream or splash pool in view) or it reads as a decal.
- **(2026-11-03)** Decks: a rim-lip cylinder can be the real visible floor (top above the deck) → raycast the CanQuery top before laying tiles. Stairs off a deck start OUTSIDE the deck radius (the cylinder is solid below its top): hang steps outside the rim with stringers + invisible side walls. Jump-gap rays need `RespectCanCollide = true` or decor (orbit stones, vines) fakes "land".
- **(2026-11-10) Edges:** chunky coping stones every 6–10 studs with height steps + 2–3 strata bands read as cliff; stacked smooth ring prisms read as a wedding cake. Give copied islets 2–3 lobes/bays so they don't read as plates from above.
- **(2026-11-10) Walk floors on islets/kit pieces:** replace buried "Top" unions with a few invisible walk boxes or one flat oval collider; a plus of 3 boxes under an oval top leaves 10–19 % floorless at the diagonals → add a ring of edge boxes (16 gave 98–99.7 %). Prove it with a 0.5-stud down-ray grid against the kit report's outline (not the Body bbox — underside spikes skew it; Box-fidelity MeshParts can't be raycast for their real top) and report coverage % AND overhang % (floor outside the outline). Ignore Transparency-1 / fence / post hits. Overhang is usually a few bad vertices: refit each edge radius, don't inset uniformly (a flat 0.5 inset dropped coverage to 93 %). Stacked invisible step boxes → one union with PreciseConvexDecomposition keeps tops exact (±0.01 stud) and cut 389 parts to 3 per plot.
- **(2026-11-10) Jump chains per plot:** free span from raycasts, enumerate piece mixes, gap = (free − Σ collider lengths)/(n+1), keep 9.5–14.5 studs (aim 12) under the tri cap; prove with a down-ray every 0.5 stud along the lane, both ways (miss runs = gaps, top deltas = rises) — 8 chains passed first try. Fit each clone's rim gap from the same centre the lane/bearings use (a gap fitted on Plot_1 sat 2 studs from a wall on Plot_4) and check side clearance on every copy. Rim walls: compare height with the jump config — a 4-stud invisible wall only stops walking; say which one it's meant to stop.
