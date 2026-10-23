---
name: roblox-game-strip
description: Reverse-engineers a Roblox game from a video, screenshots, a walk-through, or a game file (.rbxl/.rbxlx/.rbxm) lyopz gives us — core loop, systems, map layout, UI, art style, VFX, sounds, monetization (what players can spend real money on) — then remakes the parts lyopz wants in our own way and files every finding into the right Roblox skill. Use when lyopz imports a video or game file in the Degen Roblox app, sends a YouTube/TikTok link or gameplay clip, says "strip this game", "how does this game work", "remake this", "study this video".
---

<!-- from: lyopz (2026-10-23). Ideas only — never copy another game's assets, scripts or names. -->

# Roblox Game Strip

## 0. Rules
- **Ideas, not copies.** Learn the concept, numbers and design patterns; build our own versions in our style. Never rip meshes, scripts, audio, UI art or names from other games.
- **Only files lyopz owns or has rights to** get opened as game files (his own places, free/open-sourced kits, uncopylocked places with a license that allows it). Anything else → study from video/screenshots only.
- If something would break Roblox's Terms (exploits, stolen places, copying a game) → don't; learn from the video and say so in one line.

## 1. Input → how to read it
- **Video** (imported in the app → `~/RobloxGames/imports/<date>/`): get frames with ffmpeg (`ffmpeg -i v.mp4 -vf "fps=1/3,scale=960:-1" f_%03d.png`; scene changes: `-vf "select='gt(scene,0.35)'" -vsync vfr`). Look at key frames; grab audio cues if useful. Long video → sample sparsely first, then zoom into the interesting parts.
- **Screenshots** → read directly.
- **Game file (.rbxl/.rbxlx/.rbxm)** → open in Studio and inspect with the Roblox_Studio tools (tree, scripts, UI, lighting). .rbxlx is XML — can also be read as text. Summarize; don't dump.
- **Live game** → `roblox-playtest` (walk through, look and learn, no purchases).

## 2. Strip sheet (write `strips/<game>.md`)
1. **One-line pitch** + genre/hybrid.
2. **First 60 seconds:** what the player sees, does, earns.
3. **Core loop** + session loop + long-term loop (rebirth/prestige/collection).
4. **Systems:** currencies, upgrades, eggs/odds, rarities, quests, trading, events, data saved.
5. **Numbers** seen (prices, costs, rates, odds, timers) — estimate if needed and mark "~".
6. **Map:** layout, zones/gates, landmarks, spawn view, lighting look.
7. **UI:** HUD layout, buttons, menus, feel (bounce, sounds), phone layout.
8. **Art style:** shapes, palette (hex guesses), materials, scale; standout assets and why they look good.
9. **VFX + sound:** hatch, rewards, hits, ambience.
10. **Monetization:** every buyable thing, price, where/when it's offered, shop layout → also add to `roblox-shops/studies/<game>.md`.
11. **What to borrow** (top 5 ideas for lyopz's game) and **what to avoid**.

## 3. Where findings go (file every one)
| Finding | Skill / file |
|---|---|
| Pets, eggs, hatching, odds, upgrades | `roblox-design/references/pets-and-eggs.md` |
| Map layouts, zones, lighting | `roblox-design/references/maps.md` |
| HUD, buttons, menus, feel | `roblox-design/references/ui.md` |
| Motion, juice, camera, rewards | `roblox-design/references/game-feel.md` |
| Performance tricks | `roblox-design/references/performance.md` |
| Shop, products, prices, prompts | `roblox-shops` (+ `studies/`) |
| Asset shapes / modeling tricks | `roblox-asset-shapes` |
| Art style / palette for a project | `roblox-art-style` (project bible) |
| VFX recipes, rigs, animation | `roblox-assets` |
| Scripting patterns, bugs | `roblox-dev/lessons.md` (+ `roblox-templates` for reusable code) |
| Whole-game breakdown | `roblox-game-study/studies/<game>.md` |
| Nothing fits | new reference file in the closest skill, or a new `roblox-<topic>` skill — add it to the registry |
Keep the source (video name/link, date) next to each finding.

## 4. Remake (when lyopz asks)
1. He picks what to remake (a system, a map area, a UI, an effect).
2. Spec it (`roblox-design/references/first-try.md`) in **our** project's style bible.
3. Lead splits it to the agents; build one piece, check against the reference frames, then scale.
4. Show side-by-side (reference frame vs ours) for approval in the app.

## 5. Learn
After each strip: add 1–3 general lessons to the skill files above. Repeated patterns across 3+ games become rules.
