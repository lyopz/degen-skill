---
name: roblox-design
description: lyopz's Roblox design playbook — what's in meta for Roblox games in 2026 (genres, map layouts, lighting, game feel/motion, UI and button sizes, click/hover feedback, sounds, mobile/console rules, performance) plus a "make it 10,000x cooler" upgrade checklist. Use when building or reviewing any Roblox game, map, lobby, UI, shop, HUD or effect, or when lyopz says "make it cooler", "10,000x cooler", "make it pop", "make it feel better" about a Roblox project.
---

<!-- from: lyopz (own research, 2026-10-22). Living document: add findings as we build. Sources at the bottom. -->

# Roblox Design Playbook

Read the reference that matches the job:
- `references/first-try.md` — **spec → build one piece → check**, so designs come out right the first time. Always.
- `references/ui.md` — sizes, layout, buttons, click/hover feedback, sounds, mobile/console. **Includes a ready button-feel script.**
- `references/pets-and-eggs.md` — egg stands (floating vs grounded), egg designs per theme, hatching sequence, odds/rarity, pet styles, golden/rainbow/huge variants, pet movement.
- `references/maps.md` — genres in meta, map layouts per genre, lighting presets, building style.
- `references/game-feel.md` — motion, camera, hit feedback, VFX layering, rewards.
- `references/performance.md` — budgets so it runs on phones (most players).
- Keeping every asset in one look: `roblox-art-style` (per-project style bible).
- Assets/effects to build things: `roblox-assets` (models, rigs, VFX scripts). 3D source images: `3d-assets` prompt library.

## The 2026 meta in one screen
- **Most players are on phones.** Design touch-first: big thumb-reachable buttons, readable at small sizes, and test portrait + landscape phone, tablet, 21:9 PC, and console (gamepad).
- **Top genres:** brainrot/meme hybrids (biggest category), escape & survival, simulators (highest earning), anime fighting (fastest growing), horror (fast growth), town/city RP, tower defense, competitive parkour/obby, management tycoons. Hybrids win (brainrot + fighting, tycoon + horror, simulator + RPG).
- **Winning structure:** understandable in the first minute → simple core loop (collect → upgrade → rebirth / fight → unlock) → deeper systems revealed later → social + collectibles + seasonal/limited events for retention.
- **Look:** bright, saturated, chunky stylized shapes with clear silhouettes; Future lighting with Atmosphere + Bloom + ColorCorrection; neon accents for interactables; every interaction has motion + sound.

## "Make it 10,000x cooler" checklist
When asked, go through every line, apply what fits, then tell lyopz what changed (short list).
1. **First 10 seconds:** spawn faces the most impressive view; a clear goal on screen; one big glowing "PLAY"/objective; music starts.
2. **Lighting pass:** apply a preset from `maps.md` (Future + Atmosphere + Bloom + ColorCorrection + SunRays). Add colored PointLights/SpotLights at landmarks; neon trims on paths and interactables.
3. **Silhouette & color:** big landmark visible from everywhere; 1 main color + 1 accent + neutrals; contrast between walkable/interactive/decor.
4. **Every button feels alive:** hover grow 1.05–1.08, press squash 0.92–0.95, release Back-ease bounce, click sound, selected state for gamepad (`references/ui.md` script).
5. **Rewards pop:** numbers count up, items fly into the inventory icon, screen-edge flash, coin pickups scale-pop + sound pitch rising with streaks, confetti/sparkle bursts on level-up.
6. **Motion everywhere (cheap):** spinning/bobbing pickups, swaying trees (scripted), moving clouds/skybox, conveyor/water texture scroll, idle animations on NPCs/pets.
7. **Hits feel heavy:** 2–3 frame hit-stop, small camera shake, flash the target white/red, knockback, layered VFX (3–5 emitters), impact sound + slight pitch randomization.
8. **VFX layer pass:** trails on fast movement, auras on rare things, fire/magic with LightEmission 1, explosions with light flash (`roblox-assets/scripts/vfx.lua`).
9. **Sound pass:** UI clicks, footsteps per material, ambient loop per zone, reward stingers, music that changes per area/boss.
10. **UI polish:** one consistent corner radius (8–16 px), UIStroke 2–3 px on buttons, gradient fills, drop shadow, icons at 2× resolution, tween panels in (0.25–0.35 s, Quint/Back Out) instead of popping.
11. **Juice for progress:** progress bars that ease and glow, rebirth/upgrade screens with big before→after numbers.
12. **Social proof:** leaderboards in the lobby, rare-item announcements, visible other players' cosmetics/trails.
13. **Performance check:** still smooth on a low-end phone (`performance.md`). Cool that lags isn't cool.

## How to use this file going forward
- Add every new finding, trend, rule or snippet lyopz approves to the right reference file (keep the source link).
- When the meta changes (new top games, new Studio features), refresh the genre/meta notes and date them.

## Sources (researched 2026-10-22)
- Roblox UI systems across phone, console, PC — simplified.media: https://simplified.media/guides/roblox-ui-systems
- Roblox GUI size guide 2026 — Vizzbees: https://vizzbees.com/blog/roblox-gui-size-guide
- Roblox charts March 2026 — EJAW: https://ejaw.net/roblox-charts/
- Popular genres 2026 — Kitsblox: https://kitsblox.com/blog/popular-roblox-game-genres-2026
- Game ideas & trend data 2026 — creation.dev: https://www.creation.dev/learn/best-roblox-game-ideas-2026
- VFX guide — Kitsblox: https://kitsblox.com/blog/how-to-add-visual-effects-roblox
- Button bounce tweens — Roblox DevForum: https://devforum.roblox.com/t/adding-bounce-animations-to-ui/205970
- Lighting step by step — Roblox DevForum: https://devforum.roblox.com/t/improve-lighting-step-by-step/1387033
- Mesh limits & optimization — Nilo: https://nilo.io/articles/optimize-3d-models-roblox-limit
