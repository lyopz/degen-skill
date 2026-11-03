---
name: roblox-portals
description: "Builds themed Roblox portal zones that look premium: a rounded, weathered low-poly arch (picture → Customuse 3D), an animated swirl, matching props around it (e.g. falling-code pillars for a digital/Matrix world), and glow that breathes. Each portal keeps the same base look but gets its own theme and unique damage details. Includes the picture prompt and the PortalFX template. Use for any portal, gate, teleporter or island entrance, \"make the portal look like its island\", or \"add swirl animations\"."
---

<!-- from: lyopz (2026-10-24). He liked a dark arch with thin neon circuit lines, a glowing spiral and a gem on top; asked for rounder edges, swirl animations, falling Matrix code around it, the area dressed to match its island, and for every portal: same base look + unique, weathered details. General only: no game names. -->

# Themed portals

Read first: `customuse-design/references/taste.md` (portal lines), the game's style bible, `roblox-vfx` (particles), `roblox-asset-shapes`.

## The base look (every portal, keep it)
- **Rounded arch**: chunky stone-metal bricks with thick soft bevels. No sharp blocky corners.
- **Swirl** in the opening that is always animated: a spinning spiral plus particles spiralling in, in the destination's color.
- **Gem or keystone** on top in a rounded socket, with a slow glow pulse.
- **Thin glowing lines** (circuits, runes or cracks) in the theme color. Use lines, not glowing sheets. Keep the glow subtle.
- **Rounded pedestal** with 1-2 soft steps.

## Make each one unique (depth)
- **Weathered, not perfect**: a few bricks stick out or hang loose, edges are chipped or eroded, one corner is crumbling, and rubble chunks sit at the base, as if it has been worn down or tampered with over time. Damage goes in different places on each portal.
- **Theme dressing from its island** (2-4 props, low poly): digital/Matrix = falling-code pillars, code curtains and glyph panels; fire = lava cracks and embers; ice = frost shards; nature = vines and mushrooms; void = floating rocks and purple cracks; spooky = pumpkins and graves.
- Copy the island's dominant color, its signature prop and its ground material, so the portal reads as "the way to that island".

## Pipeline
1. **Picture**: one asset per picture on a white background, with the opening EMPTY (the swirl is done in-game). ChatGPT (`gpt-image.ps1`), or Customuse `gptImage25Flare` if ChatGPT is signed out. Use the prompt below.
2. **Props**: one picture per prop (pillar, panel, rubble) with the same material words.
3. **3D**: Customuse `customuseCr1Mesh3d` from the picture, low poly: arch ≤ 5k tris (faceLimit ~4500), props ≤ 2k.
4. **Studio**: `roblox-upload.ps1` + `insert_asset` (`roblox-3d-pipeline/references/roblox-import.md` Route A); no key yet → `customuse_upload_to_roblox` if Roblox is linked in Customuse, else the Import 3D card. Scale the arch so its opening covers the old portal's fill/teleport part. Keep the game's teleport part and scripts, and hide the old blocky arch parts instead of deleting them.
5. **Animate** with `roblox-templates/templates/PortalFX.lua` (server/edit time builds the effects, one client LocalScript calls `Animate()`):
   - `Swirl(fill)` + `SwirlParticles(fill)`: the spinning spiral and the spiral-in particles.
   - `CodeRain(part, face)` on screens, and `CodeCurtain(cf, size)` for floating code beams around the portal.
   - `GlowPulse(gem)`: a PointLight inside, Brightness ≤ 1.
   - The game's own textures (swirl, glyph flipbooks) go in `opts.Texture`.
6. **Check**: screenshot it in the game's lighting, compare it to the picture, rate it (`design-feedback.ps1`), and write his words into taste.md.

## Project lessons (2026-11-03)
- **Swirl with depth, not a sticker:** a flat opaque Neon oval + straight Neon spiral bars reads as "choppy, you wouldn't jump in" (lyopz). Recipe: dark funnel MeshPart + 3 greyscale spiral textures on SurfaceGuis at different depths, all one spiral hand and rotation sign, faster toward the centre (~18/35/60 °/s), shrink-and-fade zoom rings, a hot core dot, inward disc particles, a SurfaceLight + soft decal spilling colour on the steps; matte frame, glowing hole. A square FixedSize canvas on an oval face stretches the circle into a clean oval. ~7 curved irregular arms beat 3 broad ones. Main swirl SurfaceGui Brightness ~1.6 keeps yellow saturated (2+ goes pale); dark fills stay value ≥ 0.5 tinted (a darkened yellow reads brown), lifted with Brightness ~2.8. Rim streak emitters → soft wisps LockedToPart on the rotating part.
- **Locked state:** veil dimmed ~60 % toward navy, transparency 0.6, particles LightEmission 0.1–0.3; store the open values as `Unlocked<Prop>` attributes. A client look that only reacts to attribute changes never shows the starting state: apply it once at attach too. Under streaming, pick "next unlock" from the highest rank ever seen available + 1 (kept across stream-out), not from whatever locked portal is streamed in.
- **Frame model:** faces seen THROUGH the opening (tunnel back wall, backing cap) must face the viewer (recalc normals got a back fan wrong and Roblox culled it). Prove a removed cap is gone with a raycast through the hole (set CanQuery=true on visual parts for the probe, restore after), then put a dark end dome behind the opening. Oval sweeps: sample at equal arc length (equal-angle sampling facets the tight curves). Glossy trim without SA: SmoothPlastic + Reflectance 0.2–0.3 on gold/chrome, 0.08–0.16 dark metal, 0 body; drips on the band front, not hanging inside the rim (teeth). Neon yellows read lemon under bloom; SmoothPlastic warm gold lit by the vortex reads as a gold lip. One shared frame mesh across N colour ranks: shared parts in UV u 0..0.5, rank parts u 0.5..1, one atlas per rank; parts around a glow-spill emitter bake near-white (leave untextured). Light bakes paint the shadow of parts hidden in game (padlock): bake with it hidden and copy its own texels back.
- **Proportion check:** measure the opening's share of the frame vs the concept (65 % vs 35 % built looked "right" to the builder). Rows of portals: raise back rows on a stepped dais, uneven slot spacing so gaps line up, and check sight lines with raycasts from the 3rd-person camera (12 behind, feet + 7.5) on each walkway.
- **Triggers:** art never moves a trigger — the server accepts a portal anchor only within ~2 studs of its config CFrame; derive arrival/exit landings from the door CFrames in config. One door used both ways = one `doorUnit(...)` builder; the inside copy at `InsideDoor * Angles(0, π, 0)` with its anchor flipped back toward the walker. Front/back tests compare flat (XZ) distances. Changing what gates a portal (reached → rank): switch every reader (can-use, use, spawn, movement checks) and fail closed.
- **Walk-through travel:** the client detects the crossing in anchor space (`prevZ < 0 <= Z` inside a generous box, step < 4 studs); the server re-checks rank, range from the anchor and a token bucket; refused = push back out the front, never a dead stop. Put the anchor plane INSIDE the doorway with a ~5-stud recess (flush on a wall, the HRP never reaches Z ≥ 0); ~2 s silent exit grace for fresh arrivals. Test by box probe AND by walking the character through (probes miss CanTouch/CanQuery gaps).
- **Pictures:** say door size in players ("door 2 players wide", "brass only on trims") and set exact studs in the notes; multi-portal sheets drift neighbouring hues together — fix colour from exact hexes in the build table instead of re-rolling; crests: "cut out in the emblem's own outline, never inside a shield frame; every crest a different shape".
- Build the vortex as one client module (spiral SurfaceGuis + core + particles, distance-culled); distance-culled vortex FX look black in a `screen_capture` that moves only the shot camera — move the real camera first.

## Picture prompt (fill the [brackets])
> Single game asset, 3/4 front view, pure white background, nothing else in the picture. A stylized low-poly cartoon portal gate for a Roblox game, [THEME] theme. A tall ROUNDED arch built from chunky [MATERIAL + COLOR] bricks with soft thick bevels (no sharp blocky corners). The arch is weathered and imperfect: a few bricks sticking out or hanging loose, chipped and eroded edges, one corner crumbling away, as if worn down over a long time, but still clean stylized low poly. Thin glowing [GLOW COLOR] [circuit lines / runes / cracks] and small [theme symbols] etched into the brick faces (thin lines and small round nodes, not glowing sheets). [1-2 THEME DETAILS from its island]. A rounded pedestal base with two soft steps, and a faceted [GLOW COLOR] crystal gem in a rounded [METAL] socket on top of the arch. The arch opening is EMPTY (the swirl effect is added later in-game). Chunky readable silhouette, glossy finish, smooth soft shading, rich deep colors, subtle glow only, high-end mobile game hero asset.

Prop prompt: the same opening and closing sentences, with the middle replaced by the prop (e.g. "a tall rounded obelisk pillar … with a vertical dark-glass screen showing columns of falling green code characters").
