# Get it right the first time (spec → build → check)

Most redo loops come from building before the target is clear. Every Roblox job follows these 3 gates.

## Gate 1 — Spec (before touching Studio)
Write a short spec and keep it in the game folder (`spec-<thing>.md`):
- **What & where:** one sentence + where it lives in the place (zone, service, ScreenGui).
- **Style:** game's style bible preset, palette hexes used, shape language, scale in studs. No bible → make one first (`roblox-art-style`).
- **Reference:** 1 approved picture (concept or anchor) or 1–2 example screenshots/game studies. "Looks like *this*."
- **Numbers:** sizes (studs/px), counts, timings, prices, triangle/texture budget.
- **Done means:** 3–6 checks that must be true (e.g. "readable on phone portrait", "palm leaves match anchor green #3cae5a", "≤ 2k tris").
- **Credits:** estimate; cheapest pristine route chosen.

## Gate 2 — Build small, then look
- Build ONE piece first (one tree, one button, one zone corner), **screenshot it** (Studio MCP `screen_capture`), compare to the reference and spec, fix, *then* duplicate/scale up.
- Use presets and templates instead of inventing values: lighting presets (`maps.md`), UI sizes + ButtonFeel (`ui.md`), VFX layers (`roblox-templates/templates/VFX.lua`), rarity colors (`roblox-art-style`).
- Keep everything grouped and named (`Model` per thing, clear names) so fixes are one edit.

## Gate 3 — Check before saying done
- Screenshot from the player's view (spawn camera) + one wide shot. Phone-size check for UI (device emulator).
- Tick every "Done means" line; list anything that's off and fix it.
- Output window clean (no red errors). Triangle/texture/particle budgets OK.
- Then log lessons in `roblox-dev/lessons.md` (what would have made it right sooner).

## Common first-try misses (avoid)
- Wrong scale (trees as tall as the player, doors too small) → always measure against a 5-stud character.
- Off-palette colors and mixed styles → only bible colors; side-by-side with anchors.
- Flat lighting → apply a preset before judging how anything looks.
- UI built in Offset only → breaks on phones; use Scale + constraints.
- Floating/clipping props → snap to ground with raycasts.
- Effects too big/bright on mobile → check particle counts and LightEmission.
