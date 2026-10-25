# Roblox maps — what's in meta (2026) and how to build them

## Top games right now (live CCU snapshot, Oct 24 2026) and why they work
| Game | Genre | Live players | What to learn |
|---|---|---|---|
| Steal An Egg | Steal + hatch sim | ~1.25–1.6M (#1 since Sep) | Steal eggs from NPC pets/other players → hatch rarer pets that earn money; treadmill speed training; PvP stealing = constant drama |
| Murder Mystery 2 | Social deduction | ~1.1–1.2M (Halloween surge, was ~500k) | Short rounds, hidden roles, knife/gun cosmetics economy; seasonal event + new map = 2x players |
| Brookhaven RP | Social roleplay | ~400–470k | Open town, houses, cars, spatial voice; freedom > goals |
| Adopt Me! | Social trading | ~190–290k | Pet economy, rarity tiers (Neon/Mega), safe for new players |
| Jujutsu Shenanigans | Anime fighter | ~160–245k | Flashy moves, deep progression |
| 99 Nights in the Forest | Co-op survival | ~215–240k | Night cycle pressure, base fire, friends vs monster |
| RIVALS | FPS | ~190–215k | Tight competitive shooting |
| Blox Fruits | Adventure RPG | ~160–190k | Islands as zones, bosses, collectible powers, frequent updates |
| Steal a Brainrot / Break and Steal an Egg | Steal sims | ~150k / ~130k | Steal-from-bases loop; the egg version keeps cloning upward |
| DOORS / Flee the Facility / Dandy's World / Evade | Horror survival | ~75–155k each (DOORS +266%, Flee +392% in 24 h) | Halloween spike: short co-op runs vs a monster, chase + hide |
| Climb For Animals Eggs / Fish It! / Anime Dice / Sell Fries! | Climb-hatch / idle / RNG / sell tycoon | ~60–80k each | Climb-for-eggs hybrid and "Sell ___" tycoons are rising |

**Oct 24 read:** steal/hatch pet hybrids still own #1 and are spreading into climb-for-eggs. October = horror: every survival/horror game is spiking (Roblox's own **The Hollow** event runs Oct 22 – Nov 2, finale Oct 31: https://devforum.roblox.com/t/the-hollow-new-platform-wide-survival-event-for-halloween/4948535). A seasonal map + event in a social game (MM2) can double CCU — plan a Halloween/holiday reskin for every live game. Pet sims should add a social risk loop (steal/defend) on top of collect → hatch → earn.

Earlier trend data (creation.dev, Mar 2026): **brainrot** games lead (~1.4M CCU across 29 games), escape/survival ~764k, simulators ~336k (highest earning), anime/fighting ~143k, horror ~78k (+68% week over week), town/city RP +65%, tower defense ~59k, competitive parkour with vote-based maps, management tycoons moving from button-press to strategy. **Hybrids** are winning.

**House style (lyopz, 2026-10-25):** islands and buildings follow `floating-islands.md` unless lyopz asks otherwise.

## Layout patterns per genre
- **Simulator / tycoon:** hub lobby (shops, leaderboards, rebirth altar, codes) → ring/line of zones unlocked by currency gates, each zone a new biome + color; collect spots spread so players walk past shops; teleport pads between zones; plot grid for tycoons with clear "build here" glow.
- **Obby / parkour:** single vertical tower or linear course, checkpoints every 5–10 jumps, difficulty ramps with rest platforms, color-coded hazards (red = kill, blue = bounce, yellow = moving), stage counter UI, skip-stage product; competitive: procedural or vote-selected courses so memorizing doesn't win.
- **Fighting / arena:** compact arenas with cover and verticality, clear spawn zones, readable floor; lobby with dummies to test moves.
- **Horror / escape:** tight corridors + few big reveal rooms, darkness with strong local light sources, randomized clue/monster placement per run, sound-driven tension, anomaly-spotting loops.
- **Survival / brainrot:** small maps that force interaction, rising threat (tsunami, lava, waves), safe high ground, day/night or wave cycles.
- **RPG / adventure:** islands or regions as levels, quest givers at entrances, boss arenas visible from afar, fast travel unlocked by discovery.
- **Roleplay:** town grid, landmark at center, houses players can claim, roads for vehicles, many interactable props.
- **Portal hub terrace** (seen in Tap Simulator REBORN, lyopz liked): stone arches in rows up a slope near spawn, each portal glowing its island's color and dressed in its theme (pumpkins, mushrooms, autumn trees), labels above; every future island visible from the spawn path. Floating islands reached by bought double jumps + a height counter.
- **One-color contrast zone** (same game): after bright grass zones, a dark slate island with neon cracks in the floor, crystal flowers, floating rocks and beams; one hue + glow.
- **In-world social** (same game): crown-framed leaderboard boards (eggs hatched, pet power, rebirths) and a season podium with countdown and top pets on pedestals, on the main path.
- **Themed portal arches** (same game, liked 2nd session): each arch built from its island's material (dark crystal rock, graves + pumpkins, mushrooms), swirl in the island color, bold label; dark realms add neon crack lines on the floor that converge on the portal.
- **Countdown billboards** over landmarks ("NEW UPDATE … 10h 25m") + an in-world event board near spawn; big walkable cartoon clouds high above the hub as a lookout/goal.
- Everywhere: **spawn facing the best view**, one landmark visible from anywhere (tower, giant tree, volcano), paths lit or neon-edged, invisible walls disguised as cliffs/fences.

## Build style that reads well on Roblox
- Chunky stylized shapes, bevelled edges, bright saturated palette (1 main + 1 accent + neutrals per zone), Neon material for interactables only.
- Big scale: player is ~5 studs tall; doors 8–10 studs, corridors ≥ 8 wide (cameras clip in tight spaces).
- Terrain for land/water (Terrain Editor: Generate, or Import heightmap from Blender); MeshParts for detailed props (see `roblox-assets`).
- Ambient motion: swaying trees, moving clouds, waterfalls with particle mist, floating crystals (Motion.Bob), flags.
- Decor scatter: one clean asset, `ScaleTo` 0.45–0.62 per copy, random yaw + ±5–8° lean, all Anchored, leaves CanCollide off — variety for free. Place on ground with a raycast (`Include={Terrain}`, `IgnoreWater=true`), sink trunks/poles 1–5 studs so nothing floats. Spawns on slopes: raycast 4 corners + center, sit on the highest hit.
- Free Creator Store models: check for hidden scripts before use (see `roblox-dev` → Security).
- **From projects (2026-10-24):** R15 jump height ≈ 1.15 × JP²/(2g), double jump 2×; for jump-gated routes make every gap bigger than the previous tier's double jump and test "drift to rim, then step over". Place jump-gated islands by an offline search (inside walls, gaps ≤ reach, plan-separated: centre distance > R1+R2) before building. Moving stepping clouds: anchored still walk disc, bob only a visual child client-side. Keep tall props out of the spawn→portal ray. City bounds: visible walls 16–30 studs + invisible walls (CanQuery off) to Y 1000 + a server bounds check. Lock/unlock props by one `Unlocked` attribute + per-part Locked/Unlocked color attributes and a tiny client applier. Windows on recolored store buildings: one procedural window Texture on Front/Left/Right, Color3 = accent, small cells ~35% unlit. One-sided thin banners show a bright sheet from behind — give them a dark back.

## Terrain (islands, hills, water)
- **Custom terrain materials are live (full launch 2026-10-22):** Workspace → `Expanded Terrain = Enabled`, save, close and reopen the place (Team Create: exit, wait ~15 s). Up to 62 editable materials, terrain has its own 250 MB limit (no longer counts toward place size), ~90% less CPU memory. Water/Air are still read-only, Material Variant physics don't apply yet. https://devforum.roblox.com/t/full-launch-publish-games-with-custom-terrain-materials-and-performance-improvements/4950620
- Voxels are 4 studs, one material each. Terrain thinner than 16 voxels (64 studs) can vanish in play with streaming + a small radius — build solid, thick ground.
- Island recipe: height map + one `WriteVoxels` call (coastline R(θ) = base + 3 sines; beach/plateau/hill profile; material by height and slope) beats stacking FillBalls; the same R(θ) can drive shore foam. Quick version: `Clear` → water FillBlock (−28..0) → sand seafloor → shelf → 2–3 overlapping sand FillBalls with centers far below the surface.
- Keep underwater shelves ≤ −8 (tops ~−10): sand inside the top water layer (−4..0) shows as a dry pit. Let island slopes cross sea level steeply.
- Landmark hills: broad with flat tops. Narrow peaks render as flat mesas at low terrain LOD (phones, captures) while raycasts still hit the real peak.
- Cartoon sea: sand (246,205,120), WaterColor (40,200,220), WaterTransparency 0.6 + bright cartoon preset. Terrain water stays visible even at WaterTransparency 1, so a wave mesh must stay above it (Ocean kit in `roblox-templates`).
- After a big terrain edit, check voxels (raycast grid / `ReadVoxels`) before trusting a screenshot — captures can be stale.

## Lighting presets (Lighting service) — starting points, then tweak by eye
Always: `Technology = Future`, add `Atmosphere`, `BloomEffect`, `ColorCorrectionEffect`, `SunRaysEffect` under Lighting, and a matching `Sky`.

| Preset | Lighting | Atmosphere | Bloom | ColorCorrection | SunRays |
|---|---|---|---|---|---|
| **Bright cartoon (sim/obby)** | ClockTime 14, Brightness 3, EnvironmentDiffuseScale 1, EnvironmentSpecularScale 1, Ambient (70,70,80), OutdoorAmbient (120,120,130), ShadowSoftness 0.2 | Density 0.3, Offset 0.25, Haze 1, Glare 0.3, Color (199,220,255), Decay (106,112,125) | Intensity 0.6, Size 24, Threshold 1.2 | Saturation 0.15, Contrast 0.1, Brightness 0.02 | Intensity 0.05, Spread 0.6 |
| **Golden hour (RP/adventure)** | ClockTime 17.6, Brightness 2.5, Ambient (90,70,60), ExposureCompensation 0.2 | Density 0.35, Haze 2, Glare 1, Color (255,200,160) | Intensity 0.8, Size 30, Threshold 1 | Saturation 0.1, Contrast 0.15, TintColor (255,240,225) | Intensity 0.15, Spread 0.8 |
| **Neon night (degen / cyber, red)** | ClockTime 0, Brightness 1, Ambient (20,10,15), OutdoorAmbient (40,20,30), ExposureCompensation 0.3 | Density 0.45, Haze 1.5, Color (60,20,30), Decay (20,5,10) | Intensity 1.2, Size 40, Threshold 0.8 | Saturation 0.2, Contrast 0.2, TintColor (255,225,230) | off |
| **Horror** | ClockTime 2, Brightness 0.5, Ambient (5,5,8), OutdoorAmbient (15,15,20) | Density 0.6, Haze 3, Color (40,45,55) | Intensity 0.3, Threshold 1.5 | Saturation −0.3, Contrast 0.25, TintColor (210,220,230) | off; use flicker PointLights/SpotLights |

Notes: lower ExposureCompensation needs higher Brightness to look normal (DevForum). Brightness also multiplies vertex/mesh colors: under Bright cartoon (3) use colors ~1/3 as bright (mid-blue rendered cyan). `Lighting.Technology` can't be read or set from MCP `execute_luau` — set Future by hand in Properties. Keep post effects modest and offer a "Low graphics" setting that disables Bloom/SunRays/DoF on phones.

## Sources
livecounts.nl charts (Oct 24 2026) https://livecounts.nl/roblox-charts/ · Endgame Tools top 50 (Oct 24 2026) https://endgametools.com/en/roblox/charts · Endgame Tools top 10 + Steal An Egg loop (Sep 27, upd. Oct 9 2026) https://endgametools.com/en/roblox/news/roblox-most-popular-games · EJAW charts (Mar 2026) https://ejaw.net/roblox-charts/ · creation.dev trends https://www.creation.dev/learn/best-roblox-game-ideas-2026 · Kitsblox genres https://kitsblox.com/blog/popular-roblox-game-genres-2026 · DevForum lighting https://devforum.roblox.com/t/improve-lighting-step-by-step/1387033 · Lighting preset values are starting points from Roblox lighting practice (tune by eye).
