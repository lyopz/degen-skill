---
name: roblox-portals
description: Builds themed Roblox portal zones that look premium: a rounded, weathered low-poly arch (picture → Customuse 3D), an animated swirl, matching props around it (e.g. falling-code pillars for a digital/Matrix world), and glow that breathes. Each portal keeps the same base look but gets its own theme and unique damage details. Includes the picture prompt and the PortalFX template. Use for any portal, gate, teleporter or island entrance, "make the portal look like its island", or "add swirl animations".
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

## Picture prompt (fill the [brackets])
> Single game asset, 3/4 front view, pure white background, nothing else in the picture. A stylized low-poly cartoon portal gate for a Roblox game, [THEME] theme. A tall ROUNDED arch built from chunky [MATERIAL + COLOR] bricks with soft thick bevels (no sharp blocky corners). The arch is weathered and imperfect: a few bricks sticking out or hanging loose, chipped and eroded edges, one corner crumbling away, as if worn down over a long time, but still clean stylized low poly. Thin glowing [GLOW COLOR] [circuit lines / runes / cracks] and small [theme symbols] etched into the brick faces (thin lines and small round nodes, not glowing sheets). [1-2 THEME DETAILS from its island]. A rounded pedestal base with two soft steps, and a faceted [GLOW COLOR] crystal gem in a rounded [METAL] socket on top of the arch. The arch opening is EMPTY (the swirl effect is added later in-game). Chunky readable silhouette, glossy finish, smooth soft shading, rich deep colors, subtle glow only, high-end mobile game hero asset.

Prop prompt: the same opening and closing sentences, with the middle replaced by the prop (e.g. "a tall rounded obelisk pillar … with a vertical dark-glass screen showing columns of falling green code characters").
