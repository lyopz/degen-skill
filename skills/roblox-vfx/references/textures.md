# Making particle textures (ChatGPT → Roblox)

The built-in `rbxasset://textures/particles/*` textures are fine for a first pass. Custom textures in the game's style are what make effects look "made for this game". They cost 0 credits through lyopz's ChatGPT.

## The exception to "white background"
Normal asset pictures use a pure white background. **VFX textures use a pure BLACK background**: glow and sparks are drawn as light, and the black turns into transparency. `vfx_texture.py` does that conversion, so the texture gets a real alpha channel.

## Rules for a good particle texture
- **One shape per picture**, centered, nothing touching the edges (a soft fade before the border, or square edges show).
- **White or light grey on black.** Tint in Studio with `Color` so one texture serves every rarity. Only keep colors (`--keep-color`) for multi-colored things like coins or gems.
- **Soft falloff** for glows and smoke (bright core fading to black). Hard edges for stylized/cartoon games (stars, hearts, sparkles, toon smoke puffs).
- **Size:** 256 or 512 is plenty for single textures (they're small on screen). **Flipbooks must be 1024×1024** (other sizes show as `NotCompatible`).
- Square, power of two. Keep **≥ 12 px of empty margin per 256 px frame** on every side, or neighbours bleed in (a flame cut flat at its tile's bottom drew thin dashes above every particle) — check with numpy that each tile's first/last rows and columns have alpha 0 before uploading.
- Reuse textures: one sparkle, one glow, one ring, one smoke puff, one star cover most effects. Each flipbook costs memory and low-memory phones can turn flipbooks off.

## Prompts (fill `<...>`; send through `gpt-image.ps1` like any other picture)
Single texture:
"A single <soft round glow | four-point sparkle star | cartoon smoke puff | thin glowing ring | magic rune circle | heart | coin with a star> as a game particle texture. Pure white shape on a pure black background (#000000), centered, nothing touching the edges, <soft glowing falloff | crisp cartoon edges with a soft outer glow>, flat, no shading on the background, no text, no watermark, no other objects, square image."

Flipbook (4×4, ChatGPT is OK at small grids; for 8×8 make frames another way):
"A 4 by 4 grid sprite sheet of 16 animation frames of a <cartoon explosion puff | magic burst | electric spark | toon fire flicker>, read left to right, top to bottom, frame 1 small and bright, growing, frame 16 almost faded out. Every frame centered in its own equal square cell with empty black space around it. Pure white on a pure black background (#000000), no grid lines, no numbers, no text, square image."

Style match: add the game's style words from its `art-style.md` (e.g. "chunky cartoon", "soft pastel glow", "crisp neon edges") — never another game's.

## Convert (on the PC, after the picture is saved)
```powershell
pip install pillow   # once
$s = "$HOME\.claude\degen-skill\skills\roblox-vfx\scripts\vfx_texture.py"
python $s alpha    "<saved picture>.png" "$HOME\RobloxGames\<project>\vfx\sparkle.png" --size 512
python $s split    "<saved sheet>.png"   "$HOME\RobloxGames\<project>\vfx\burst-4x4.png" --grid 4
python $s flipbook "$HOME\RobloxGames\<project>\vfx\fire-4x4.png" f1.png f2.png f3.png f4.png --grid 2
```
`--gamma 1.5` makes soft edges more see-through if the texture looks like a grey square in game.

## Upload and use
1. Studio → **Asset Manager → Import** (or Bulk Import) the PNGs → right-click → Copy Asset ID. Image assets give the right id directly (a Decal id would need converting).
2. Set `Texture = "rbxassetid://<id>"`. For flipbooks also set `FlipbookLayout` (Grid2x2/4x4/8x8) and `FlipbookMode` (Loop for fire/idle, OneShot for bursts, PingPong for pulses, Random for variety like sparks or debris).
3. Put the ids in the game's `art-style.md` (local) under "VFX textures" so every effect in the game reuses them. With the `PetFX` template, overwrite `PetFX.Textures.Spark/Glow/Ring/Shock/Smoke` once at startup.

## Animated surface overlays (Texture/Decal on parts) (2026-11-03)
- **Shine sweep, zero particles:** a Sheen `Texture` per face, StudsPerTileU ~2.2× the piece, hidden (T 1) except a ~0.55 s window every ~3 s where OffsetStudsU slides one tile; one seed per item so all its pieces flash together.
- **Animator cost:** read each texture's attributes ONCE into a cache (`GetAttributes`), keep runtime state in the cache, not attributes; ~525 Textures at 20 Hz ≈ 0.65 ms client. Surface flipbook = swap `Texture.Texture` between pre-uploaded frames.
- **Rounded / multi-part bodies:** each face projects separately, so anchor U offsets along the perimeter, give Top a FaceBasis that continues Front, snap the tile size to the body, and add motion as deltas to the anchored phase (never absolute offsets). Multi-part bodies: one body-anchored tile size + offset with faces picked by world direction, so one skin runs across all parts.
- **Locked layers** (glyph-rain heads on their trails, wear on a moving pattern): same Tile / scroll / FrameRate / seed, no Random on either, the top one at a higher ZIndex. Static wear (grime, chips, scratches) sits under the pattern (ZIndex 1) with random offsets, tinted from the base, and is excluded from palette recolour passes.
- **Loops stay up (lyopz):** Surge/Pulse/Flicker layers rest at a floor (~0.8 transparency) and brighten on top; only travelling glints sit at 1 between passes. Overlay gloss: Reflectance ≤ 0.05 total.
- **Spin flipbooks:** a rotating log spiral reads as ZOOM. Give the art rigid landmarks (bar, knots, arm ends), keep it 2-fold symmetric so a 180° loop has no pop, small steps (24 frames × 7.5°) and crossfade frame i → i+1 with a twin Texture. 24 frames at 256 px cost half of 12 at 512. Swirls on SurfaceGuis: all layers share one spiral hand and rotation sign (that sets inward vs outward pull).
- **Glow rim behind 2D art:** offset copies smear a dark keyline — make one white silhouette per picture (alpha dilated + blurred), upload, tint. Use a Texture, not a Decal, if code must animate it.
- **Sprite eyes/faces:** mirror a sheet cell with `ImageRectOffset = ((col+1)*cell, row*cell)`, `ImageRectSize = (-cell, cell)`. Blink = squash the eye toward a line under its centre AND move/flatten its bloom with it (a bloom that only dims leaves a smudge). Glare stays inside each eye (no streak across the face, no growing halo — two blooms bridge over the nose).

## Other sources
- Free flipbooks: particlefx.studio/roblox. Free plugin library: Effect Designer Suite (~5,800 flipbooks and textures).
- Paid packs (BuiltByBit and similar): check the license, and check every model for scripts after inserting (`roblox-dev` backdoor rule).
- Blender: render a simple sim or shader to frames on black, then `flipbook` mode packs them.
