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
