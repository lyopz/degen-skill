# Game feel / motion for Roblox ("juice")

## Movement & camera
- Sprint FOV kick: tween `Camera.FieldOfView` 70 → 80 over 0.2 s when sprinting, back on stop.
- Dash: short burst `AssemblyLinearVelocity` or `LinearVelocity` for 0.15 s + trail + whoosh + FOV kick.
- Landing from height: small camera dip + dust particles at feet.
- Camera shake: small (0.2–0.5°) and short (0.15–0.3 s); scale with impact size; offer a setting to turn it off. (`roblox-assets/scripts/vfx.lua` → `VFX.Shake`)
- Never fight the player's camera for long; cutscenes ≤ 3 s and skippable.

## Combat hits
1. **Anticipation:** wind-up pose/glow 0.1–0.2 s.
2. **Impact:** hit-stop 2–3 frames (pause attacker+target animation speed to 0 for ~0.05 s), white/red flash on target (Highlight with FillTransparency 0.3 → 1 over 0.15 s), damage number pop (BillboardGui, rise + fade 0.6 s, crits bigger + yellow).
3. **Reaction:** knockback, small camera shake, layered VFX (core flash, sparks, smoke ring), impact sound with ±5% pitch.
4. **Recovery:** follow-through animation, trail fades.

## Rewards & progression
- Coins/gems: pickup scale-pop + fly toward the HUD counter (UI tween from world-to-screen point), counter counts up over 0.4 s, sound pitch rises with streak.
- Level up / rebirth: full-screen flash 0.1 s, big text slam (scale 1.4 → 1 Back Out), confetti/sparkle burst, fanfare, aura on the character for a few seconds.
- Rare drops: beam from the sky on the item, rarity color glow (common grey, rare blue, epic purple, legendary gold, mythic red/rainbow), server announcement.
- Eggs/gacha: shake 3 times with increasing intensity, crack, light burst, reveal with rarity color — the wait builds excitement (keep ≤ 3 s, add skip for repeats).

- Clicker feel (seen in Tap Simulator REBORN): `+amount` popups float up from every tap, crits burst coins, rare hatches get a giant floating multiplier sign; live boss events announced by a top banner with a countdown, then a shared health %.
- World events as cheap juice (same game): "Balloon Party" (coin/gem balloons float up, pop for loot) and "Blood Moon" (sky tint red + luck boost for secrets), each announced by a small toast with an icon.

## Effects layering
- 3–5 emitters per effect: core glow, main body, sparks, smoke, light.
- Fire/magic/energy: `LightEmission = 1`, `LightInfluence = 0`; smoke: LightEmission 0.
- Size and Transparency NumberSequences: fire starts big + bright, shrinks + fades; explosions start small, expand fast, vanish.
- Beams for lasers/lightning between Attachments; Trails on swords/dashes/projectiles.
- Full VFX guide (properties, recipes, pet effects, performance, textures): `roblox-vfx` skill.
- Use flipbook textures (`FlipbookLayout`, 1024×1024 sheets) for rich fire/explosions; free flipbook packs exist (e.g. particlefx.studio/roblox).
- Toggle post-processing (Bloom/ColorCorrection) briefly for ultimates or boss phases.
- Emitter tuning (from projects): `Drag` also damps `Acceleration` (Drag 2–4 → motes never rise; use Drag 0 + Speed ~1.5, or Drag 1.5 + Acceleration 7–9). Flat ground rings: `Orientation = VelocityPerpendicular`, Speed 0.01, EmissionDirection Top, **ZOffset 0** (negative sinks into the floor); `forcefield_vortex_main.dds` + RotSpeed = free rune ring. `Squash` > 0 taller, < 0 flatter (−3..3). Auras around a body need radial speed to clear the mesh (emit at the feet, EmissionDirection Right + SpreadAngle (0,180) = horizontal ring).
- Attachments: parent first, then set `WorldPosition`/`WorldCFrame` (before parenting, world values become local offsets).
- Checking VFX: Edit-mode screenshots never show particles. Test in Play with a Scriptable camera bound on RenderStep and `settings().Rendering.QualityLevel = Level21` (Automatic throttles low-rate emitters), wait 2–3 s, capture, stop quickly.

## Physics impacts (new 2026-10)
`BasePart:BindToCollisionSummaries(cb)` gives per-frame contacts with `Point`, `Normal`, `RelativeVelocity`, `Area` — impact speed = `|RelativeVelocity:Dot(Normal)|`. Use it for thuds, dust, cracks and fall/crash damage scaled by speed. Only fires on the part's network owner and isn't replicated. Template: `roblox-templates/templates/ImpactFX.lua`. Docs: https://create.roblox.com/docs/workspace/collisions

## Ambient life (cheap, always on)
Swaying trees/grass (scripted rotation), drifting clouds, birds circling, water texture offset scroll, floating pickups bobbing, NPC idle animations, flickering torches (PointLight brightness noise), ambient particles (fireflies, dust, snow) per zone.

## Sound design
Every action gets a sound; layer a low "thump" under big hits; ambient loops per zone; music changes at boss/zone; footsteps by material. Keep UI sounds quiet and short.
- **Peaceful/"magical" reveals (2026-10-25, projects):** gentle float + sway instead of shake, star motes orbiting on moving Attachments (Rate ~28), soft chime arpeggio (one ping at pitch 1/1.12/1.26/1.5/1.68), pieces drift off with drag and almost no gravity, then bloom + thin ring + sparkles. Rarity tells stay honest (more motes/late colour shift only for the real result). Track live Sounds and fade them on close instead of a fixed Destroy.
- Free Roblox-licensed reveal layers (APM / Pro Sound Effects): Silver Dreams 1841180330 (pad), Magical Meetup 9048764286, Glass Tinks 2 9114619050, Boink Pop 9113537815, Rising Together 9043511769 (epic), Happy Orchestral 9040233685 + Bell Rings 5 9113421788 (legendary), Quest for the Truth 9043512845 (mythic), A Place To Dream 1847240504 (secret).

## Sources
Kitsblox VFX https://kitsblox.com/blog/how-to-add-visual-effects-roblox · Roblox docs VFX tutorials https://create.roblox.com/docs/tutorials/curriculums/core/building/create-basic-visual-effects · ParticleFX flipbooks https://particlefx.studio/roblox · Standard game-feel practice (hit-stop, anticipation, juice) applied to Roblox APIs.
