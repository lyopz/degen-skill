# Roblox maps — what's in meta (2026) and how to build them

## Top games right now (March 2026 peaks) and why they work
| Game | Genre | Peak CCU | What to learn |
|---|---|---|---|
| Brookhaven RP | Social roleplay | ~400k | Open town, houses, cars, spatial voice; freedom > goals |
| Blox Fruits | Adventure RPG | ~350k | Islands as zones, bosses, collectible powers, frequent updates |
| Adopt Me! | Social trading | ~300k | Pet economy, rarity tiers (Neon/Mega), safe for new players |
| Grow a Garden | Cozy simulator | ~250k | Plant → wait → harvest → pets; low skill, phone-first, daily loop |
| Escape Tsunami for Brainrots! | Meme survival | ~200k | Meme characters + simple survival pressure |
| Pet Simulator 99 | Simulator | ~180k | Grind + collect + trade, huge number upgrades |
| Jujutsu Shenanigans | Anime fighter | ~150k | Flashy moves, deep progression |
| RIVALS | FPS | ~130k | Tight competitive shooting |
| Fish It! | Idle sim | ~110k | Auto-fishing → very long sessions |
| BedWars | Strategy PvP | ~100k | Team bases, resource generators, short rounds |

Trend data (creation.dev): **brainrot** games lead (~1.4M CCU across 29 games), escape/survival ~764k, simulators ~336k (highest earning), anime/fighting ~143k, horror ~78k (+68% week over week), town/city RP +65%, tower defense ~59k, competitive parkour with vote-based maps, management tycoons moving from button-press to strategy. **Hybrids** are winning.

## Layout patterns per genre
- **Simulator / tycoon:** hub lobby (shops, leaderboards, rebirth altar, codes) → ring/line of zones unlocked by currency gates, each zone a new biome + color; collect spots spread so players walk past shops; teleport pads between zones; plot grid for tycoons with clear "build here" glow.
- **Obby / parkour:** single vertical tower or linear course, checkpoints every 5–10 jumps, difficulty ramps with rest platforms, color-coded hazards (red = kill, blue = bounce, yellow = moving), stage counter UI, skip-stage product; competitive: procedural or vote-selected courses so memorizing doesn't win.
- **Fighting / arena:** compact arenas with cover and verticality, clear spawn zones, readable floor; lobby with dummies to test moves.
- **Horror / escape:** tight corridors + few big reveal rooms, darkness with strong local light sources, randomized clue/monster placement per run, sound-driven tension, anomaly-spotting loops.
- **Survival / brainrot:** small maps that force interaction, rising threat (tsunami, lava, waves), safe high ground, day/night or wave cycles.
- **RPG / adventure:** islands or regions as levels, quest givers at entrances, boss arenas visible from afar, fast travel unlocked by discovery.
- **Roleplay:** town grid, landmark at center, houses players can claim, roads for vehicles, many interactable props.
- Everywhere: **spawn facing the best view**, one landmark visible from anywhere (tower, giant tree, volcano), paths lit or neon-edged, invisible walls disguised as cliffs/fences.

## Build style that reads well on Roblox
- Chunky stylized shapes, bevelled edges, bright saturated palette (1 main + 1 accent + neutrals per zone), Neon material for interactables only.
- Big scale: player is ~5 studs tall; doors 8–10 studs, corridors ≥ 8 wide (cameras clip in tight spaces).
- Terrain for land/water (Terrain Editor: Generate, or Import heightmap from Blender); MeshParts for detailed props (see `roblox-assets`).
- Ambient motion: swaying trees, moving clouds, waterfalls with particle mist, floating crystals (Motion.Bob), flags.

## Lighting presets (Lighting service) — starting points, then tweak by eye
Always: `Technology = Future`, add `Atmosphere`, `BloomEffect`, `ColorCorrectionEffect`, `SunRaysEffect` under Lighting, and a matching `Sky`.

| Preset | Lighting | Atmosphere | Bloom | ColorCorrection | SunRays |
|---|---|---|---|---|---|
| **Bright cartoon (sim/obby)** | ClockTime 14, Brightness 3, EnvironmentDiffuseScale 1, EnvironmentSpecularScale 1, Ambient (70,70,80), OutdoorAmbient (120,120,130), ShadowSoftness 0.2 | Density 0.3, Offset 0.25, Haze 1, Glare 0.3, Color (199,220,255), Decay (106,112,125) | Intensity 0.6, Size 24, Threshold 1.2 | Saturation 0.15, Contrast 0.1, Brightness 0.02 | Intensity 0.05, Spread 0.6 |
| **Golden hour (RP/adventure)** | ClockTime 17.6, Brightness 2.5, Ambient (90,70,60), ExposureCompensation 0.2 | Density 0.35, Haze 2, Glare 1, Color (255,200,160) | Intensity 0.8, Size 30, Threshold 1 | Saturation 0.1, Contrast 0.15, TintColor (255,240,225) | Intensity 0.15, Spread 0.8 |
| **Neon night (degen / cyber, red)** | ClockTime 0, Brightness 1, Ambient (20,10,15), OutdoorAmbient (40,20,30), ExposureCompensation 0.3 | Density 0.45, Haze 1.5, Color (60,20,30), Decay (20,5,10) | Intensity 1.2, Size 40, Threshold 0.8 | Saturation 0.2, Contrast 0.2, TintColor (255,225,230) | off |
| **Horror** | ClockTime 2, Brightness 0.5, Ambient (5,5,8), OutdoorAmbient (15,15,20) | Density 0.6, Haze 3, Color (40,45,55) | Intensity 0.3, Threshold 1.5 | Saturation −0.3, Contrast 0.25, TintColor (210,220,230) | off; use flicker PointLights/SpotLights |

Notes: lower ExposureCompensation needs higher Brightness to look normal (DevForum). Keep post effects modest and offer a "Low graphics" setting that disables Bloom/SunRays/DoF on phones.

## Sources
EJAW charts (Mar 2026) https://ejaw.net/roblox-charts/ · creation.dev trends https://www.creation.dev/learn/best-roblox-game-ideas-2026 · Kitsblox genres https://kitsblox.com/blog/popular-roblox-game-genres-2026 · DevForum lighting https://devforum.roblox.com/t/improve-lighting-step-by-step/1387033 · Lighting preset values are starting points from Roblox lighting practice (tune by eye).
