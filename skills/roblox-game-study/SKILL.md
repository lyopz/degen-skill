---
name: roblox-game-study
description: Studies a Roblox game lyopz points to and writes a design breakdown he can learn from — rough map layout, zones and flow, core loop, progression, economy, UI/HUD layout, button style, effects, art style, monetization and what makes it fun — then turns it into ORIGINAL ideas and templates for his own games. Watches gameplay through screenshots on his PC (computer use) while he plays or with his OK, plus wikis/videos. Never extracts or copies the game's files, maps, models or scripts. Use when lyopz says "study / break down / reverse engineer / analyze this Roblox game" or wants a game "as an example".
---

<!-- from: lyopz (own). -->

# Roblox Game Study

Goal: understand **why a game works** and reuse the *ideas*, not the *content*.

## Hard limits (protect his account and games)
- **No extracting:** no place/asset downloaders, "saveinstance", decompilers, exploits/executors, or memory/network tools. These break Roblox's Terms (account ban risk) and copied content gets games taken down.
- **No botting:** don't grind, farm, or play long sessions with automated input. Observe; at most move around briefly to see the map, open menus, look at the shop.
- **No purchases or Robux**, no trades, no chatting with players, no accepting friend requests.
- Everything in the study is described in our own words; recreations use our own assets, style and code.

## Sources (cheapest first)
1. **Research:** the game's Roblox page (description, genre, updates), wiki/fandom pages (maps, zones, items, prices, rarities), and top gameplay/guide videos (descriptions and chapters). Often enough for 80% of the study.
2. **Watch on his PC** (computer use, `mcp__remote-devices__computer_*`; read the `computer-use` skill first): with lyopz's go-ahead for that game, open it in the Roblox app (or watch while he plays), take screenshots of: spawn/lobby, each zone, the HUD, every menu (shop, inventory, pets, rebirth, settings), a few interactions (hit, pickup, purchase screen without buying), and the map from high points. Keep it short (~5–10 minutes). He can also screen-record and send the video instead.
3. **Ask him** what he liked about it; that's the part to keep.

## Write the study → `studies/<game-name>.md`
- **One-liner:** genre + hook ("brainrot survival: outrun a rising tsunami, collect meme pets").
- **Map:** rough layout sketch (ASCII or a simple diagram), spawn → zones → loops, sizes in studs (estimate from the 5-stud player), landmarks, how zones gate (price/level), where shops sit relative to the grind path.
- **Core loop & progression:** what you do every 30 s / 5 min / session, upgrades, rebirth, unlock curve, rough numbers seen.
- **Economy & monetization:** currencies, sinks, passes/products seen (names, prices if shown), where purchase prompts appear.
- **UI/HUD:** layout (where currency, menus, main buttons sit), button style (shape, stroke, color, motion), popups, reward feedback.
- **Feel:** effects, sounds, camera, hit feedback, what feels satisfying.
- **Art style:** preset closest match (from `roblox-art-style`), palette impression, scale.
- **Why it's fun / why players stay:** 3–5 bullets.
- **Weak spots:** what's annoying or missing (our opportunity).
- **Steal the idea, not the content:** 5–10 original takeaways for lyopz's games (e.g. "gate zones by rebirth instead of coins", "put the shop on the grind path").

## Turn it into his games
- Feed takeaways into `roblox-design/references/maps.md` (layout patterns) and `ui.md`/`game-feel.md` when they're general, with "seen in <game>".
- Build our own versions with the Roblox agents (map-builder, ui-designer, scripter…) in the project's style bible — and save reusable pieces as `roblox-templates`.
- Study files stay in `studies/` as examples for future games.
