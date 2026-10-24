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
| **Ambient zone** | fireflies/dust/snow: one emitter on a big invisible Box part, Rate 3–10, long Lifetime, slow; disable when far |

## 5. Pet-game effects (what top simulators do)
Server decides (pet, rarity, reward) → fires a RemoteEvent → **client plays** the effect. Never play big effects on the server.
- **Egg stand:** floating egg + slow spin/bob, soft sparkles, PointLight in the egg color; premium eggs add a light pillar (`PetFX.Pillar`) visible from far away.
- **Hatch:** egg moves in front of the camera (not a ViewportFrame), 3–4 shakes getting faster and stronger with rising sound, then white flash + burst in the rarity color + pet pops in (Back-out scale) + rarity banner. **Legendary+**: longer build-up, colored flash, bloom pulse, pillar, camera shake, confetti, server-wide chat/announce. ≤ 3 s, skippable, fast mode for auto-hatch. `PetFX.HatchInFront(egg, rarity, onReveal)`.
- **Rarity auras:** Common/Uncommon none, Rare+ sparkle motes, Legendary+ ground ring + light, Mythic/Secret rainbow color + trail. Rarity colors are reserved for rarity and identical everywhere (UI, banner, aura, pillar). `PetFX.RarityAura(part, rarity)`.
- **Variants without new models:** Golden = gold material + sparkle; Rainbow = rainbow `ColorSequence` on particles + hue-shifting highlight; Shiny/Dark = dark color + dark aura with additive rim.
- **Level up / rebirth / evolve:** ground shockwave + spiral column + flash on the character, big floating text, sound sting. `PetFX.LevelUp(character)`.
- **Rewards:** coins/gems burst out of the source and fly to the HUD counter (3D fountain with `PetFX.Reward`, then ImageLabels tweened along a curve to the counter, counter bumps); bigger reward = more coins, not longer animation.
- **Other players' pets:** cheaper or no auras, and a "hide others' effects" setting.

## 6. Gotchas
- **Particles don't render inside ViewportFrames or ScreenGuis.** Hatches: put the egg in front of the camera. UI sparkles: tween ImageLabels or use a 2D emitter module (DevForum: Spark2D plugin, UIEmitter, "2D ParticleEmitter").
- **Edit mode shows no particles**; capture in Play with quality forced high (`game-feel.md` → checking VFX).
- Parts/effects parented to `workspace.CurrentCamera` are local to that client (good for hatch scenes).
- Attachments: parent first, then set `WorldPosition` (before parenting, world values become local offsets).
- Free models/packs: check for Scripts after inserting (backdoors) — `roblox-dev` §2.
- A grey square around particles = the texture has no alpha. Fix the PNG (`vfx_texture.py alpha`) or use LightEmission 1 to hide the dark parts.

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
