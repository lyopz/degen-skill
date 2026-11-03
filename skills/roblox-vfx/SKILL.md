---
name: roblox-vfx
description: How to make Roblox particle effects and VFX look great and run on phones — ParticleEmitter (every property that matters, flipbooks, shapes, Squash, Emit bursts), Beam, Trail, lights and post effects; recipes with numbers; pet-game effects (egg hatch, rarity auras, level up, rewards, light pillars); performance budgets; VFX plugins; making textures in ChatGPT on black. Includes the PetFX template. Use for any Roblox effect, particle, glow, aura, trail, beam, explosion, hatch or reward animation, or "make it sparkle / pop / glow".
---

<!-- from: lyopz (own research, 2026-10-24). General only: no game names. Sources at the bottom. -->

# Roblox VFX

Read with: `roblox-design/references/game-feel.md` (feel, timing, testing VFX in Studio) and `roblox-design/references/pets-and-eggs.md` (hatch sequence, rarity colors). Textures: `references/textures.md`.
Ready code: `roblox-templates/templates/PetFX.lua` (hatch, rarity aura, level up, reward fountain, light pillar, trail, Play, distance culling) and `VFX.lua` (fireball, flaming legs, aura, explosion, camera shake).

## 1. The parts of an effect
| Piece | Use it for | Notes |
|---|---|---|
| `ParticleEmitter` | sparks, glows, smoke, fire, motes, coins, confetti, rings | parent to an `Attachment` (a point) or a `BasePart` (emits from its volume/surface) |
| `Beam` | light pillars, lasers, lightning, ropes of energy, portal swirls, god rays | between two Attachments; `CurveSize0/1` bend it; `TextureSpeed` scrolls the texture; `FaceCamera` for pillars |
| `Trail` | dashes, swings, pet/player speed trails, projectile tails | two Attachments on a moving part; `WidthScale` taper, short `Lifetime` (0.2–0.5) |
| `PointLight`/`SpotLight` | sells every glow; flash at bursts | `Shadows = false`; tween Brightness to 0 |
| Neon parts + tweens | shockwave spheres/rings, orbs, slashes | Neon material glows with Bloom; tween Size + Transparency |
| `BloomEffect`, `BlurEffect`, `ColorCorrectionEffect` | big moments only (legendary hatch, boss, ultimate) | add briefly on the client, tween back, destroy |
| ScreenGui flash / ImageLabels | full-screen flash, UI sparkles, coins flying to the counter | particles don't render in ScreenGuis or ViewportFrames (see §6) |

**Layer 3–5 pieces per effect** — one emitter looks flat. The standard stack: **flash** (1 big glow, 0.15 s) → **shockwave** (flat ring) → **sparks** (fast, fall, Squash) → **motes/smoke** (slow, linger) → **light**.

## 2. ParticleEmitter properties that matter
| Property | What it does | Good values |
|---|---|---|
| `Rate` | particles per second. **Live particles ≈ Rate × Lifetime** | ambient 2–10, auras 5–20, fire 20–40. Bursts: Rate 0 + `:Emit(n)` |
| `Lifetime` | seconds each lives (NumberRange) | sparks 0.3–0.9, motes 1–2, smoke 1–3 |
| `Speed` / `SpreadAngle` | launch speed / cone (X,Y degrees). `(180,180)` = all directions | flat rings: Speed 0.01 |
| `Drag` | slows particles over time (**also damps Acceleration**) | bursts 3–10 (fast out, then hang) |
| `Acceleration` | constant force (studs/s²) | falling sparks/coins (0,−20..−50,0); rising motes (0,2..9,0) |
| `Size`, `Transparency`, `Color` | sequences over the lifetime | grow-then-shrink sizes; fade out at the end; white-hot → rarity color |
| `Squash` | stretch: > 0 taller/thinner, < 0 flatter (−3..3) | sparks/rain 1–3 (with speed = streaks) |
| `Orientation` | `FacingCamera` (default), `VelocityParallel` (streaks), `VelocityPerpendicular` (flat to the ground — rings) | rings: VelocityPerpendicular + EmissionDirection Top + ZOffset 0 |
| `LightEmission` | 0 normal, 1 additive (glows, overlaps get brighter) | fire/magic/sparks 1, smoke/dust 0 |
| `LightInfluence` | how much world light affects it | 0 for glows (and `Brightness` only works at 0) |
| `Brightness` | multiplies emitted light (HDR) | 1–3 for neon pops with Bloom |
| `ZOffset` | pushes toward/away from camera (render order) | flash +1..2 in front; never negative on ground rings |
| `LockedToPart` | particles move with the parent | auras/rings on moving pets: true |
| `VelocityInheritance` | particles take the parent's velocity | 0.2–0.5 for trails of moving things |
| `Shape`, `ShapeStyle`, `ShapeInOut`, `ShapePartial` | Box/Sphere/Cylinder/Disc, Volume/Surface, Outward/Inward | Sphere/Cylinder need a **BasePart** parent (they don't show right on Attachments). Inward = implosion/charge-up |
| `TimeScale` | 0–1 slows the emitter's simulation | hit-stop / slow-mo: 0.1 for 0.1 s |
| `Rotation`, `RotSpeed` | start angle / spin (deg/s) | random 0–360 start always; spin rings 40–90 |
| `Flipbook*` | animated texture sheet | §3 |
| `:Emit(n)` / `:Clear()` | instant burst / remove all live particles | bursts on events; Clear when skipping a hatch |

## 3. Flipbooks (animated textures)
- Texture **1024×1024**, frames in a grid: `FlipbookLayout` Grid2x2 (4), Grid4x4 (16), Grid8x8 (64), or Custom (`FlipbookSizeX/Y`).
- `FlipbookMode`: **Loop** (fire, idle), **OneShot** (explosion — plays once over the particle's lifetime), **PingPong** (pulse), **Random** (sparks/debris variety).
- `FlipbookFramerate` max 30 fps (randomizable). `FlipbookStartRandom = true` so particles don't animate in sync. `FlipbookBlendFrames` smooths frames; turn it **off** for crisp cartoon sprites.
- Leave a margin around each frame. They cost memory and low-memory devices can disable them — keep a static-texture fallback look and reuse sheets.

## 4. Recipes (start here, then tune to the style bible)
| Effect | Build |
|---|---|
| **Pickup sparkle** | Rate 4, Lifetime 0.6–1, Speed 1, SpreadAngle 180, star/sparkle texture, Size 0→0.4→0, LightEmission 1 |
| **Burst / pop** | `PetFX.Burst`: glow flash (1), flat shockwave (1), sparks 20–50 with Drag 5 + gravity + Squash, motes 6–15, light 0.6 s fade |
| **Ground ring** | ring texture, Orientation VelocityPerpendicular, Speed 0.01, EmissionDirection Top, ZOffset 0, RotSpeed 60, Size grows, fade in/out |
| **Rising aura** | at the feet, Rate 5–20, Speed 1.5, Drag 0, Acceleration (0,2,0), SpreadAngle 25, LockedToPart, + flat ring + soft light |
| **Light pillar** | 2 Beams bottom→top (core 1–2 wide + halo 4–6 wide at 0.75 transparency), FaceCamera, fade out at the top, + rising sparks |
| **Trail** | Lifetime 0.3, WidthScale 1→0, Transparency 0.2→1, LightEmission 1, FaceCamera |
| **Coin fountain** | coin texture, Speed 14–22 up, SpreadAngle 30, Acceleration (0,−45,0), RotSpeed ±180, LightEmission 0 (keep coin colors) |
| **Charge-up** | Sphere shape on a part, ShapeInOut Inward, Speed 4–8, Lifetime 0.4 (particles suck in), light rising, then burst |
| **Explosion** | flipbook OneShot core + Drag 6 fire + gravity sparks + smoke (LightEmission 0) + light + shake (`VFX.Explosion`) |
| **Lightning** | Beam with a lightning texture, re-randomize `CurveSize0/1` every 0.05 s, or chain short Beams through jittered attachments |
| **Confetti** | Rate 0 + Emit 40, rectangle texture, RotSpeed ±300, Speed 20–30 up, gravity −25, Drag 1, LightEmission 0, multicolor `Color` |
| **Ambient zone** | fireflies/dust/snow: one huge low-rate box reads EMPTY — use a small Box (~70×14×50) that follows the camera ~30 studs ahead (flat LookVector, clamped to the zone; particles are world space so moving it drags nothing), Size 1.5–2.4, Brightness ~2.2 on a bright sky; firefly orbs need Size peak ≥ 0.6 (0.32 is invisible at play distance); disable when far |
| **Waterfall (beams)** | a long opaque white beam = flat slab: blue body ~0.7× the drop, transparency 0.1 → 1 along it, a shorter white core, foam puffs at the lip, mist emitters top and bottom |
| **Steam (never fire)** | white-alpha wisp texture, cream F2E3CF → copper C98B5A, transparency ~0.5, LightEmission ≤ 0.2, slow TextureSpeed 0.35–0.55 |

## 5. Pet-game effects (what top simulators do)
Server decides (pet, rarity, reward) → fires a RemoteEvent → **client plays** the effect. Never play big effects on the server.
- **Egg stand:** floating egg + slow spin/bob, soft sparkles, PointLight in the egg color; premium eggs add a light pillar (`PetFX.Pillar`) visible from far away.
- **Hatch:** egg moves in front of the camera (not a ViewportFrame), 3–4 shakes getting faster and stronger with rising sound, then white flash + burst in the rarity color + pet pops in (Back-out scale) + rarity banner. **Legendary+**: longer build-up, colored flash, bloom pulse, pillar, camera shake, confetti, server-wide chat/announce. ≤ 3 s, skippable, fast mode for auto-hatch. `PetFX.HatchInFront(egg, rarity, onReveal)`.
- **Rarity auras:** Common/Uncommon none, Rare+ sparkle motes, Legendary+ ground ring + light, Mythic/Secret rainbow color + trail. Rarity colors are reserved for rarity and identical everywhere (UI, banner, aura, pillar). `PetFX.RarityAura(part, rarity)`.
- **Aura craft (2026-11-03, lyopz reviews):** the pet stays the hero — big layers sit BEHIND it (BillboardGui `StudsOffset` Z −(r+0.6), emitter/beam ZOffset −(r+0.8..1), colours through a vivid clamp sat ≥ 0.62, value ≤ 0.92) and a ~50° front window stays clear (warp azimuths out of a ±30° window leaning toward the camera and fade width by it — skipping the arc leaves a hard gap). Higher rarity = more coverage, not just brighter: coverage as data (azimuth arc × latitude × radius band per rarity) + a per-level density; low tiers own a small arc on a flank (a back arc hides behind the body) but fill it densely. Card-style auras = 2–3 tilted rings of strand bundles; each aura gets its own motion signature in code (snaps, gusts, freezes, sway, breathe, stepped glitch). **Banned by lyopz:** rotating sunburst/disc textures and expanding ring/shockwave pulses as the "moment" (even short gold ones) — use rising flares, crack flashes, aurora curtains or structure that opens/holds/folds. Secret reads at distance from one big camera-facing 4-point sparkle + a bigger core, not more particles; a solid gold mesh wheel out-reads thin neon rings. Looping layers never fade to 1 and back: rest at a floor (~0.8) and brighten on top (only travelling glints sit at 1). Size caps: measure each instance's max XZ distance over 6+ s per quality row (20 s for jittery bolts), incl. idle events, choreo swells / equip overshoot (cap via a proxy) and glow half-widths. Before calling an effect worse, shoot it alone at full quality beside the latest approved picture.
- **Variants without new models:** Golden = gold material + sparkle; Rainbow = rainbow `ColorSequence` on particles + hue-shifting highlight; Shiny/Dark = dark color + dark aura with additive rim.
- **Level up / rebirth / evolve:** ground shockwave + spiral column + flash on the character, big floating text, sound sting. `PetFX.LevelUp(character)`.
- **Rewards:** coins/gems burst out of the source and fly to the HUD counter (3D fountain with `PetFX.Reward`, then ImageLabels tweened along a curve to the counter, counter bumps); bigger reward = more coins, not longer animation.
- **Other players' pets:** cheaper or no auras, and a "hide others' effects" setting.
- **Pet combat hits (research 2026-10-25):** heavy-feeling hits = hit-stop + a matching sound + camera shake ([action-game study](https://arxiv.org/pdf/2208.06155)). Shake direction follows the move: vertical for slams/knockdowns, horizontal for side slashes/spins. Telegraph: show the danger arc/ring early with a few smeared frames and leave it up — the swing then feels snappier ([source](https://babel.speldesign.uu.se/?p=843961)). Pair each move with its VFX via `PetMoves` cues (table in `roblox-art-style/references/pet-movement.md`).
- **Impact frame (finisher/KO/crit):** for ~0.1 s add a ColorCorrectionEffect (Saturation −1, Contrast way up for white/black), turn the hit parts Neon in one tint and hide their decals, then restore. Highlight isn't used because of mobile support. Reveal variant with no full-screen white (2026-11-03): 2 beats × 0.06 s of Saturation −1 + Contrast 1.1–1.6 (dark world, then light) with a Highlight (Fill 0, AlwaysOnTop) on the subject white then black, then the normal soft flash. (Idea from the ImpactFrame DevForum module, no licence stated — write your own: https://devforum.roblox.com/t/open-source-impactframe-module/2963136)
- **Mesh slashes:** an animated crescent mesh (Blender) with a painted texture is easy to rotate to the swing angle; particles stay lighter for fire-type effects (https://devforum.roblox.com/t/how-to-make-animated-slashes-20/1880010). Scrolling textures on meshes: a Texture covers one face, so a box needs six (loop `Enum.NormalId`) and you move `OffsetStudsU/V` each frame (https://devforum.roblox.com/t/make-a-texture-move-on-a-mesh/944731).

## 6. Gotchas
- **Particles don't render inside ViewportFrames or ScreenGuis.** Hatches: put the egg in front of the camera. UI sparkles: tween ImageLabels or use a 2D emitter module (DevForum: Spark2D plugin, UIEmitter, "2D ParticleEmitter").
- **Edit-mode captures (2026-11-03):** they can show particles and beams, but often miss Trails/emitters, freeze `:Emit()` particles as stray blobs, jump Beam scroll time between stills, and script-stepped effects only move if you step them from Heartbeat yourself. Judge particles, flow direction and auras in Play (~1.5 s warm-up, inside the effect's cull distance); for Edit stills disable + `:Clear()` emitters. Final checks in Play with quality forced high (`game-feel.md` → checking VFX).
- Parts/effects parented to `workspace.CurrentCamera` are local to that client (good for hatch scenes).
- Attachments: parent first, then set `WorldPosition` (before parenting, world values become local offsets).
- Free models/packs: check for Scripts after inserting (backdoors) — `roblox-dev` §2.
- A grey square around particles = the texture has no alpha. Fix the PNG (`vfx_texture.py alpha`) or use LightEmission 1 to hide the dark parts.
- **From projects (2026-10-24):** Beam texture X runs ACROSS the width, Y along the length. Clean comic lightning = chain of short Beams (own attachment pair per segment, overlapping), white core + 1.9× colored outline, LightEmission 0, width ~0.1× target size. Orbits/arcs use the bbox half-diagonal, not half-width. Dark "void" cores: a BillboardGui ImageLabel (LightInfluence 0) pinned behind the target from the camera — dark particles vanish. Silhouette glow on any mesh: Highlight (budget ~6 nearest) + a ForceField-material clone a hair larger (Transparency ~0.45). Shiny twinkle: Box emitter per big piece (blocks `ShapeStyle Surface`; MeshParts Volume + ZOffset = half thinnest dim), Size ≈ 0.17× middle dim, cap total rate per model. Emitter helpers default Speed to 0. Texture `OffsetStudsV` increasing moves UP on side faces.
- **Colors under Brightness 3 + Bloom:** Reflectance ≤ 0.05 (more washes colors to sky), Foil reads as noise at pet scale; neon greens go cyan (use ~#14B832 / (45,180,40)), light violet goes pink, gold goes lemon (use (100,50,235), (235,150,20)); light floor tints read white. Big Neon sheets blow out → dark SmoothPlastic + scrolling glowing Texture (Color3 > 1 = fake glow). Dimmed glow on a same-hue body vanishes — contrast the glow. Shiny hue-shift breaks whites: light neutrals get a pearl tint (sat ≤ 0.09).
- **(2026-10-25) Studio colour drift:** Studio lighting can push saturation hard (#2A1F5C → navy-black). Fit a per-channel line from two test renders and solve for the target colour; pale shells (#E8F0FF) render lilac under blue/purple light (drop red ~8%); bronze A8613A reads orange, 8E5232 reads bronze; SurfaceAppearance teeth/whites: tint green-warm (0.94,1,0.84) to cancel a purple stage. Small glow pieces in a flat accent read dark olive → lighten toward white, finer tile (×0.55). Category tints must be vivid and on big surfaces (panels), not pastel on emblems. Night lighting turns downward faces black → lift stone ~40% + an unlit SurfaceGui gradient (LightInfluence 0) on the visible underside. Corona/sunburst textures with a dark fill need LightEmission 1. Never recolour by attribute or part name across shared folders — walk only your own models.
- **Hatch scenes:** parent the stage to the Camera (~8 studs ahead); ScreenGui dims hide 3D, so dim with a big translucent Part behind the stage + DepthOfField (FocusDistance = egg); multi-hatch eggs in SCREEN slots (u,v → camera space via tan(FOV/2) and aspect); hide own avatar with LocalTransparencyModifier. Some rbxasset sounds are "not approved" — check Output.

- **(promoted 2026-10-28) Beams:** positive TextureSpeed scrolls A0 → A1 (A0 at the source for falls/flows) — one later project measured the opposite, so prove the sign once per setup with a vertical test beam (A0 top, star texture, Wrap) in Play. FaceCamera=false spreads width along the attachments' UpVector — a flat ground beam needs `CFrame.fromMatrix(pos, beamDir, horizontalPerp)` per attachment (re-set when spinning). Upward arc: both attachments' X axis (Attachment.Axis) up, CurveSize0 = h, CurveSize1 = −h.
- **(promoted 2026-10-28) Embers over a glowing beam/pool** vanish at LightEmission 1 / size ≤ 0.4: use LightEmission ~0.6, Brightness 3, size 0.8 → 0, Drag 0.5, gravity ~−14. In amber-lit areas cap LightEmission ~0.4.
- **(promoted 2026-10-28) Skins on effects:** store each original ColorSequence/Color in an attribute before tinting and test that Clear restores every value; don't tint SA.Color twice (mesh skin path already did). Rigs parented outside the item need a `Tint(host, map)` hook; honour `TintOnly` on ancestors too. Aura sizing from an invisible stand-in: Transparency 0.999, not 1. Find a spout/pipe mouth from mesh vertices (`CreateEditableMeshAsync` + Size/MeshSize), not the marker part. Effect runners: own pausable clock + self-clean watchdog (template `FXRunner`).

## 6b. Project lessons (2026-11-03)
**Beams**
- Bezier control points = `A0 + CurveSize0*A0.Axis` and `A1 − CurveSize1*A1.Axis`. Ring of n curved segments: `CurveSize = r·4/3·tan(π/2n)`, fade ends next to gaps; braid = 2 extra beams on the same attachments at CurveSize ×1.16 / ×0.84. Fit polylines (cracks) with adaptive cubic spans (grow while max deviation < ~0.14 stud). TextureMode Stretch: TextureLength = repeat count; Wrap = studs per tile.
- Every TextureSpeed write jumps the scroll: write it only on coarse steps, ignore intensity changes < 0.05 (state machines call SetIntensity every frame).
- A straight beam samples only a few keys of its Color/Transparency sequences (narrow bands vanish): paint bands as separate beams. `Texture = ""` draws nothing (void = dark-tinted disc texture). A beam only hides at visibility 0: floor tiny multiplied visibilities (< 0.006) to 0 or set Enabled false.
- Width: cores < 0.06 stud read as hairlines at 10–16 studs — route every beam/trail width through one LineWeight multiplier (~2×). FaceCamera flares: 0.3–0.6 wide, soft continuous core (Stretch, Brightness 3, LightEmission ~0.35) + a 1-particle hot flick at the root; sparse tiled streaks and 0.16-wide additive flares vanish in daylight. Ribbons need width along the whole length + a scrolling strands layer (tapering from ~0 reads as a slash); one thin beam ring reads as wire — use strand bundles (white-hot core + coloured haze + strands). Put a moving piece's beam attachments on a non-spinning part so the beam stays upright.
- Sorting: a world BillboardGui hides every Beam behind its whole rectangle (even transparent pixels); beams sort by chord midpoint. Beam skies: FaceCamera quads (TextureSpeed 0), end keys ≤ 0.97, a shell of cone facets sharing edges at ~1.2× radius with ZOffset ≈ −400; check layers one at a time when a sky vanishes. The Lighting sun disc draws over beams/parts (hide it via Sky), Atmosphere swallows parts/beams past ~500 studs, and a normal camera sees sky only from el 0 to ~35° → sky features at el 12–30, drifting with camera yaw.
- Budgets: count Beams + Trails together against one cap, every frame through every phase (record the PEAK; check none are left on at the end). At Build count per handle, destroy support layers past the quality cap (keep layer 1 + its glow) and guard later handle calls (`if not self.made`).

**Particles**
- Rate-based emitters are thinned by the client graphics level (Rate 12 showed 1–2); `:Emit(n)` counts are kept. Effects that must read: emit by hand from the step (`acc += dt*rate; Emit(floor(acc))`). Rate-0 emitters still Emit while disabled. Budget analytically (rate × life + bursts), counting skin/Shiny emitters even when LOD disabled them.
- Size/Color edits apply to particles already alive: multi-spot bursts from one pooled emitter share params per burst; re-aim the attachment right before each Emit. Fit burst lifetimes (and their floor) to the timing window from config — a fixed 0.4 s minimum left particles over a fast-mode reveal; log LastEmit/LastAlive and test both against the reveal.
- Placement: emit glows from a centre Attachment (a big host part scatters bokeh blobs). Sparkle flecks off a ring = one emitter on an attachment that hops to a random ring point per emit. Arcs behind orbiting beads = emitter on the spinning attachment, LockedToPart=false, Speed 0; LockedToPart=true to ride a spinning hub. Evenly spaced rim emitters with squashed VelocityParallel streaks draw a star web — use soft wisps LockedToPart on the rotating part, or give each slot a random angle re-rolled after its streaks fade.
- On bodies: clamp skin particles (Speed ≤ 0.12, life ≤ 0.5, LockedToPart, box ×0.8 of the host, Squash ≥ −0.3, size ≤ 0.22× host min dim — a Squash −1 line texture drew 10-stud scanlines). Camera-facing sprites behind a body clip into it and the floor: lift them; flat hit sparks pull ~2 studs toward the camera (in a camera-facing CFrame, −Z points at the camera). `TimeScale = 0` = cheap "time stop" (but it won't hold a staged reveal — lengthen the hold instead).

**Daylight, Bloom, colour**
- Additive LightEmission 1 vanishes in daylight: saturated colours, LightEmission 0.2–0.35, Brightness 2–3. Big additive layers within ~6 studs of the camera on a bright plaza wash white: fade by camera distance (1 at ≥ 12 studs → ~0.35 at ≤ 4), Bloom ≤ 0.35, tint the front layer with the saturated tier colour. Many big god-ray sprites tint the whole screen → 5–6 narrow rays per layer (≈ 1× subject height, min transparency ≥ 0.52, LightEmission 0.2) behind the subject + a dark smoke puff (same flipbook, LightEmission 0). Speed-line sprites cap ~45 % opacity, size ~6R. A gold additive disc over a flipbook flattens it into a target — glow behind (ZOffset < 0), orange, LightEmission ~0.35.
- Under Bloom: Neon amber/yellow goes lemon — use F0761A / E8A21C (never FFD640); SmoothPlastic warm gold beside a glow reads gold. Neon brightens and shifts hues (author darker); a Neon core inside glass is a white blob (dark SmoothPlastic core lerped ~55 % to black); HDR texture Color3 ≤ ~1.45; Neon pure black still shades grey (void = stacked black soft-disc BillboardGuis, LightInfluence 0). White crystals: PointLight ≤ 0.4, tinted. A main light above ~1.2 blows out a pet body; a PointLight inside a body doesn't light its faces — offset it toward the camera. Ground glow pools ≥ 0.65 transparency, ~70 % saturation (0.4–0.5 read as stickers). Tinted glass hides cool-coloured particles behind it. Brass on Material Metal reads orange under a warm key; SmoothPlastic keeps it brass.
- Highlight: outline only (FillTransparency 1, or ≥ 0.88) — any fill tints the model AND every welded effect part; pulse OutlineTransparency for rim pop; rim + moved back light + a ZOffset −2 glow behind separates a dark body. Only to lift a dark SurfaceAppearance body in a dimmed reveal: light fill (rarity lerp white, ~0.78); a pale body in daylight reads "lit" with a ~0.84 fill pulsed with its aura (2026-11-03).
- Colour maths: hue rotation takes the shortest path (cyan → orange passes green) — snap far hues to the nearest palette colour by lightness. Recolour a multi-colour effect by its MAIN hue only (24 bins weighted sat × value × rate, skip gold 0.09–0.17 and greys, pull colours within 0.08); Shiny = hue +0.5 keeping each colour's value. Inverting: glows 1 − c then lift value ≥ 0.75 (near-greys take the key colour); solid parts flip hue but cap value at original + 0.15; surfaces take the plain negative; dark unlit veils fade out instead of inverting; a darkened pale negative goes khaki — lock hue to the key with a saturation floor across the whole gradient. BasePart.Color stores 8-bit: snap with `fromRGB(round(c*255))` before equality. Colour baked into a texture can't be hue-shifted: author recolourable textures white.
- Two-tone black flame: one texture with opaque BLACK body + WHITE rim/halo, tinted by `Color`, LightEmission 0 (rim takes the hue; LightEmission 1 hides the body). For a ViewportFrame, the same sheet as an ImageLabel flipbook (ImageRectOffset steps) in a sibling Frame behind it.
- SurfaceAppearance: hides BasePart.Color (store it, restore on Clear); a cloned SA MeshPart ignores `part.Color` — set `SA.Color` too; painted SAs (white Color, design in ColorMap) can't show a Color-multiply Shiny → explicit tint/overlay; ColorMap is unreadable without plugin capability — read `ColorMapContent.Uri` (pcall). `MeshPart.TextureID` ignores alpha (transparent texels show their RGB, Color doesn't show through) → SA with AlphaMode Overlay for one tinted shared texture.

**Runtime structure**
- Zero-hitch moments: build every emitter/beam/trail/Highlight/stand-in once at attach (a pool); the moment only moves + Emits + toggles Enabled. `TweenService:Create` makes an Instance per call → a ~30-line manual tweener stepped in one BindToRenderStep with `TweenService:GetValue` (+0 instances per play). Test with a DescendantAdded counter that ignores known instances (reparenting fires it). Pooled BaseParts go in a folder under CurrentCamera, never inside the subject model.
- Glued effect parts on a moving host: Weld + animate `Weld.C0` (setting CFrame lags a frame). Ground glows: anchored part + SurfaceGui placed by a ~0.12 s raycast with `SurfaceGui.MaxDistance` = the idle distance; floor rays use RespectCanCollide=false and skip hits with Transparency ≥ 0.9 and your own pool. Top-face SurfaceGui: image top = part −X, width along Z. Fake ground light = thin part + Top-face SurfaceGui (LightInfluence 0, Brightness ~1.5) holding a white/alpha-shape ImageLabel tinted by ImageColor3: any Technology, no measurable cost at 200+ pools. Hover pets: seat ground FX on the mount root, fade only well above the rest gap. Ground rings: size from the base/pedestal radius (≈ 2r + 0.8, grow to 1.1–1.3×), never from effect height; find the base by name.
- Streaming: resolve endpoints/bodies lazily at bounded intervals from the existing step, disable the moment one leaves, reuse the same instances on recovery; tags can arrive before descendants — wait for the targets (Atomic streaming for compact animated assets). Convert saved world points to host-local when captured, never lazily later (bolts thousands of studs long).
- Template meshes: keep the asset id in code (FileMesh or a stable asset), never borrow a mesh from a body/accessory another job may replace (fallbacks silently turned gears into cylinders); grep effect code for an asset path before deleting it. One-sided mesh → mirrored twin (negative X scale).
- Hide a part another script keeps writing: `LocalTransparencyModifier = 1` + animate a client clone; restore 0 on finish AND teardown (own avatar: re-set it every RenderStep, TransparencyController rewrites it). Cosmetic motion yields when joints/animation drivers appear later; cleanup never restores over the new owner's pose. `Show(on)` guards also check the instance's Enabled (culling flips it). Clone-based rims sized at build must follow the host's per-frame scale. Inverted-hull SmoothPlastic copy = clean cel outline.
- **(2026-11-03) Bodies + auras:** afterimages = clone the body (strip children + tags), Neon, weld — cleans up with the host. A white PointLight ~2 blows out a white pet → tint it, ≤ 1.2 at rest. A Neon part lerped to white reads white under bloom: dark between pulses, white only on the flash. Measure aura width at ~30 Hz over a full pulse (rings swell ~1.25× at peak). Move sets: one frame template per archetype, real 3D shapes (no flat rings). A ViewportFrame has one light: a glowing offset copy behind the model inside the same VF reads as a blurry double outline.
- Local screen moments: one named ColorCorrectionEffect under CurrentCamera (never Lighting), only for viewers within ~30 studs; remove on end, on hide and on host Destroying, plus a Debris backstop.
- Test hooks: random-interval effects expose `Trigger()`; timed tasks pause on a freeze flag; quality tests set a per-model attribute on a clone, never a global flag. Effect helpers accept ready Number/ColorSequences as well as key tables — a bad call inside a pcall'd step silently kills the rest, so read console warnings after every preview.

## 7. Performance (phones first)
- **Budget:** ≤ ~50 live particles per emitter, a few hundred on screen total. One emitter maxes at 400/s (100/s on mobile).
- **Fill rate beats count:** a few huge overlapping transparent particles cost more than many small ones. Keep big glows short-lived; avoid stacking smoke layers in front of the camera.
- Bursts over continuous emitters; turn emitters off (`Enabled = false`) instead of destroying/re-creating; reuse effect templates (clone from ReplicatedStorage).
- **Distance culling:** disable effects beyond ~100–150 studs (`PetFX.Cull(container, 120)`); scale counts with the player's graphics level (`PetFX` does this automatically: low settings/touch get fewer).
- Reuse textures; few flipbooks; `Shadows = false` on effect lights, ≤ 1 light per effect.
- Check with F9 → MicroProfiler / Developer Console render stats on a real phone.

## 8. Tools
- **Effect Designer Suite** (free, open source DevForum plugin): emit count/delay/duration, scale effects, bezier/tween animation of attachments/beams/trails, ~5,800 preset flipbooks and textures, Oklab color sequences, curve editor.
- **VFX Editor**, **Sine VFX** (DevForum plugins): all-in-one emitter editing/previewing. **Emit()** plugin (Creator Store): burst-preview in Studio.
- **Emit attributes convention** used by VFX plugins: `EmitCount`, `EmitDelay`, `EmitDuration` on each emitter. Build the effect in Studio, then play it in code with `PetFX.Play(effect)`.
- **RbxCameraShaker** (Sleitnick, **MIT**): presets Bump/Explosion/Earthquake/Vibration, `ShakeOnce`/`ShakeSustain` — directional shake per move scaled by damage. https://github.com/Sleitnick/RbxCameraShaker
- **spr** (fraktality, **MIT**): spring any property (CFrame, Color3, numbers) for bouncy recoveries. https://github.com/fraktality/spr
- Paid / no licence stated (look, don't copy): VFX Forge (zilibobi, mesh VFX, Bézier, lightning, rocks, emit module) https://zilibobi.itch.io/vfx-forge · BuiltByBit "1000 Scripted Ability VFX", "BeamPack".
- Free flipbooks: particlefx.studio/roblox. Paid packs: BuiltByBit and similar (check license + scripts).
- Textures in our pipeline: ChatGPT white-on-black → `scripts/vfx_texture.py` → Asset Manager (`references/textures.md`).

## 9. Snippets
Burst on a server event (server fires, client plays):
```lua
-- Server (after validating): Remotes.PlayFX:FireAllClients("Burst", position, "Epic")
-- Client (StarterPlayerScripts):
local RS = game:GetService("ReplicatedStorage")
local PetFX = require(RS.PetFX)
RS.Remotes.PlayFX.OnClientEvent:Connect(function(kind, pos, rarity)
	if kind == "Burst" and typeof(pos) == "Vector3" then PetFX.Burst(pos, rarity) end
end)
```
Hatch on the client after the server rolled:
```lua
RS.Remotes.HatchResult.OnClientEvent:Connect(function(eggName, petName, rarity)
	local egg = workspace.Eggs:FindFirstChild(eggName); if not egg then return end
	PetFX.HatchInFront(egg, rarity, function(cf)
		local pet = RS.Pets[petName]:Clone(); pet:PivotTo(cf); pet.Parent = workspace.CurrentCamera
		-- pop: tween a scale from 0.2 to 1 (Model:ScaleTo) with Back-out, show the rarity banner, then remove after 1.5 s
		task.delay(1.5, function() pet:Destroy() end)
	end)
end)
```
Hit-stop (freeze the effect for a beat on a big hit):
```lua
local function hitStop(effect: Instance, t: number)
	for _, e in effect:GetDescendants() do if e:IsA("ParticleEmitter") then e.TimeScale = 0.05 end end
	task.delay(t or 0.08, function()
		for _, e in effect:GetDescendants() do if e:IsA("ParticleEmitter") then e.TimeScale = 1 end end
	end)
end
```
Rainbow (Secret) color for any emitter/beam/trail: `PetFX.Rarity.Secret` → `ColorSequence` with 6 hue keypoints (in `PetFX.lua`).

## Learn with time
After a VFX job, add what needed tuning (numbers that looked right, mistakes) to `roblox-dev/lessons.md`; promote general findings here. Game-specific texture ids and looks go in the game's local `art-style.md`, never in this repo.

## Sources
Roblox docs: ParticleEmitter https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter · Particle emitters guide https://create.roblox.com/docs/effects/particle-emitters · Flipbook compatibility https://create.roblox.com/docs/reference/engine/enums/ParticleFlipbookTextureCompatible · Beam https://create.roblox.com/docs/reference/engine/classes/Beam · Explosion tutorial https://create.roblox.com/docs/tutorials/use-case-tutorials/vfx/use-particles-for-explosions
DevForum: Flipbook release https://devforum.roblox.com/t/particles’-flipbook-release/2029388 · Particles in ViewportFrames https://devforum.roblox.com/t/particles-in-viewport-frames/263785 · Effect Designer Suite https://devforum.roblox.com/t/effect-designer-suite-%E2%80%94-vfx-tooling-assets-and-more/4754553 · VFX Editor https://devforum.roblox.com/t/3103467 · Sine VFX https://devforum.roblox.com/t/plugin-sine-vfx-a-vfx-plugin-for-roblox-studio/4803771 · Spark2D https://devforum.roblox.com/t/plugin-spark2d-make-particleemitter-style-effects-work-inside-a-screengui/4830864 · UIEmitter https://devforum.roblox.com/t/uiemitter-module-ui-particles-version-2-recoded-update/2913477 · Pet hatching framework https://devforum.roblox.com/t/pet-hatching-framework-part-1/1480291

## See also
- `roblox-animation-audio-feedback`: which moments need feedback (hits, rewards, UI) and how sound and motion back it up.
