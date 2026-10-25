# Pet follow + movement (lyopz, 2026-10-25)

<!-- from: lyopz (2026-10-25): "Pet Floating & Movement Animation Example" sheet (pet-movement/movement-sheet.jpg). Style baseline: extend it, keep the feel. -->

Pets float around the player with natural bobbing and a smooth wobble. It works with every body, aura, wing, halo, horn and accessory (`pet-parts.md`). Parts keep their own animations on top (wings flap faster when running, tails swing, and so on).

## Follow slots (around the player)
- Default slots: **front-left, front-right, back-left, back-right**, hovering at about shoulder height, a little out from the player so they never clip.
- More than 4 pets: add a wider second ring (or a curve behind the player). Keep spacing so auras and wings don't overlap much.
- Pets orbit slightly in their slots (small, slow drift), so they look alive, not pinned.

## States
| State | Motion |
|---|---|
| Idle / float | hover in the slot, slow bob |
| Start moving | ease (smooth acceleration) into the follow position; no snapping |
| Walk | follow + gentle bob + wobble |
| Run | keep up, faster bob, tilt into the direction, trails |
| Jump | stretch up, then squash down |
| Turn | smooth rotation toward the move direction |
| Land | squash + small bounce |
| Teleport / dash | stretch along the path + trail FX, then settle |

**Wobble cycle (one loop):** float → bob down → tilt left → bob up → tilt right → back to centre. Small angles (about 5–10°), so it reads as alive and not drunk.

## Roblox build notes
- Client-side visuals: each client moves the pets every frame (RenderStepped) with spring/lerp smoothing toward the slot CFrame; the server only owns which pets are equipped. No physics bodies for followers.
- Bob/wobble = sine offsets on the pet's model pivot. Squash/stretch = scale tweens on the body model (`Model:ScaleTo` or per-part sizes), quick in, eased out.
- Speed comes from the player's velocity: idle < 1 stud/s, walk, run > ~18 studs/s. Lerp between state amplitudes so changes are smooth.
- Trails: Trail on the body attachments, on only while running or dashing.
- Performance: far pets (> ~80 studs) update at a lower rate and skip effects. Phone check with 4+ pets.
- If the game already has float code (for example a FloatMotion module), extend it instead of starting over.

New states or styles (sit, sleep, celebrate, attack swoop...) are fine; keep the same smooth, bouncy feel.

## Rig gotchas (promoted from projects, 2026-10-25)
- Anchored rigs (everything anchored + PivotTo): joints do nothing → move accessory groups with `workspace:BulkMoveTo(parts, cfs)` as `body.CFrame * pivotXform * restRel`, `pivotXform = rest * R * rest:Inverse()` (hinge drift ~0). Unanchored: `Motor6D.Transform = R` in Play, `C0 = C0rest * R` in Edit; set the piece to `body*C0*C1:Inverse()` before parenting the motor.
- Spring lag for short parts: drive = lever × (−accel) × gain / max(leverLen, 1); gain ~0.45 gives ears ~12°, wings ~15° on a hard stop (gain 1 pins them at the clamp). Add a camera-distance LOD, but turn it off in Edit tests (far Edit camera = looks frozen).
- Spinners: integrate the angle (`ang += dt * rate(speed)`), never `t * rate` (speed changes snap); ~140°/s idle, ~2× moving. Give them their own Motor6D (not `AnimPivot_*`, which the float system overwrites) driven from a small client script in the asset.
- Floating ornaments that follow without welds: anchored, store a body-space CFrame attribute per part, rewrite with BulkMoveTo each frame. Floating display props: one client `PivotTo(home * bob * spin)` per frame is safe beside the prop's own idle script if that script re-reads `GetPivot()` every frame; on pause, `PivotTo(home)` once.
- Hinged reveals on scaled assets: store `origin = newPivot:ToObjectSpace(assetPivot)` + scale0, map hinge points with `origin:PointToWorldSpace(p) * (GetScale()/scale0)`; read pieces by name every reveal.

## Attack moves (research 2026-10-25) — template `roblox-templates/templates/PetMoves.lua`
Every attack = **anticipation → strike → recovery**, with a short freeze (hit-stop) on contact. Fighting-game data: light moves start in 3–6 frames, heavy in 12–20, hit-stop 7–16 frames at 60 fps, shorter for each hit of a multi-hit move ([Capcom SF](https://game.capcom.com/cfn/sfv/column/131545?lang=en), [Smash hitlag](https://www.ssbwiki.com/Hitlag)). Pets are seen small on phones, so stretch the anticipation ~1.5–2× (our synthesis, not from a pet game: no reliable source shows how PS99-style games animate attacks).

| Move | Anticipation | Strike | Recovery | Hit-stop | Knockback | VFX + shake |
|---|---|---|---|---|---|---|
| Tackle / lunge | 0.18 s crouch back, lean back | 0.08 s dash, lean in | 0.35 s hop back | 0.10 s | 2–3 studs | speed trail, small burst, horizontal |
| Slam | 0.3 s rise ~5 studs | 0.1 s drop | 0.45 s squash + bounce | 0.22 s | radial 4–6 | ground ring + dust, vertical |
| Spin | 0.15 s twist back | 0.45 s, 3 turns, 3 hits | 0.45 s wobble | 0.05 / 0.05 / 0.12 | small, bigger on last | spinning slash, sparks per tick |
| Beam | 0.6 s gather (glow grows, motes pull in) | 0.5 s Beam held, pet recoils | 0.3 s | 0.13 s at start | push while held | Beam (TextureSpeed), muzzle flare, flash |
| Shoot | 0.2 s rear back | instant spawn | 0.25 s | on projectile contact | light | trail on projectile, burst |
| Swoop (flyers) | 0.3 s rise + hover | 0.12 s diagonal dive | 0.6 s arc back up | 0.15 s | diagonal | wind streaks, slash mesh |
| Combo | 0.1 s | jab, jab, 0.15 s wind-up, finisher | 0.3 s | 0.05 / 0.05 / 0.2 | finisher only | small sparks, big burst + impact frame on finisher |
- **Layering:** the attack is an offset on top of the follow/bob pose (pet-local timeline), so the pet drifts back to its slot by itself. Server says "pet X used move Y on Z"; clients animate; damage never comes from the animation.
- **Victim:** flinch away from the attacker for ~0.06 s, wobble back (`PetMoves.Hurt`); defender pop 0.9 → 1.03 → 1.
- **Hit-stop is visual only** and can scale with rarity (Common ~0.8× → Secret ~1.7×) so rare pets feel heavier without changing damage.
- Motor6D/Bone rigs can use Animation Graphs instead (full release 2026-07-15: blend, select, mask nodes, parameters via `AnimationTrack:SetParameter`, replicate automatically; state machines still beta) — anchored PivotTo pets can't. https://devforum.roblox.com/t/full-release-animation-graphs-create-complex-character-motion-visually/4739840
- Springs for wobble/recovery: `spr` (MIT, `spr.target(obj, damping, freq, props)`, damping < 1 overshoots) — it springs properties, so drive a CFrameValue and PivotTo from it. https://github.com/fraktality/spr

### Move ideas to try
Part-aware movesets (horns → charge, wings → swoop, tail → spin, big jaw → bite) · parts spring apart on a hit and settle (reuse the ear/wing spring lag) · team combo: two pets hitting within ~0.2 s play a shared finisher with a longer hit-stop · telegraph ring/arc that appears during anticipation (also a dodge hint) · beam clash (two beams meet at a moving Attachment, tapping pushes it) · KO impact frame (0.1 s black/white flash, both pets frozen mid-pose, defeated pet pops into coins) · rarity-tier finishers (Mythic+ get a camera punch-in) · idle "taunt" between attacks (hop + spin 0.4 s) · element skins on the same move (fire tackle = ember trail, ice = frost burst) · moves as data tables so new pets reuse them and one Studio preview scrubs all.
