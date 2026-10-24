---
name: roblox-game-study
description: Studies a Roblox game lyopz points to (or a "Watch me play" session he recorded in the Degen Roblox app) and writes a design breakdown he can learn from — rough map layout, zones and flow, core loop, progression, economy, UI/HUD layout, button style, effects, art style, monetization and what makes it fun — then turns it into ORIGINAL ideas and templates for his own games. Watches gameplay through screenshots on his PC (computer use) while he plays or with his OK, plus wikis/videos. Never extracts or copies the game's files, maps, models or scripts. Use when lyopz says "study / break down / reverse engineer / analyze this Roblox game" or wants a game "as an example".
---

<!-- from: lyopz (own). -->

# Roblox Game Study

Goal: understand **why a game works** and reuse the *ideas*, not the *content*.

## Hard limits (protect his account and games)
- **No extracting:** no place/asset downloaders, "saveinstance", decompilers, exploits/executors, or memory/network tools. These break Roblox's Terms (account ban risk) and copied content gets games taken down.
- **Recordings stay on his PC** (`~/RobloxGames/.degen/watch/`): never copy screenshots into the repo.
- **No botting:** don't grind, farm, or play long sessions with automated input. Observe; at most move around briefly to see the map, open menus, look at the shop.
- **No purchases or Robux**, no trades, no chatting with players, no accepting friend requests.
- Everything in the study is described in our own words; recreations use our own assets, style and code.

## Sources (cheapest first)
1. **Research:** the game's Roblox page (description, genre, updates), wiki/fandom pages (maps, zones, items, prices, rarities), and top gameplay/guide videos (descriptions and chapters). Often enough for 80% of the study.
2. **Watch on his PC** (computer use, `mcp__remote-devices__computer_*`; read the `computer-use` skill first): with lyopz's go-ahead for that game, open it in the Roblox app (or watch while he plays), take screenshots of: spawn/lobby, each zone, the HUD, every menu (shop, inventory, pets, rebirth, settings), a few interactions (hit, pickup, purchase screen without buying), and the map from high points. Keep it short (~5–10 minutes). He can also screen-record and send the video instead.
3. **Ask him** what he liked about it; that's the part to keep.
4. **A "Watch me play" session** (best source, see below): he plays, the app records.

## Learn from a play session ("Watch me play")
lyopz plays a game normally; the Degen Roblox app's **Watch me play** bubble runs `assets/roblox-app/watch-play.ps1`, which saves a screenshot every 5 s while Roblox is the active window (near-identical frames skipped), `like-*.jpg` / `dislike-*.jpg` when he presses F7 / F8, and what he says or types. When he presses **Learn from it**, the brief gives you the session folder (`~/RobloxGames/.degen/watch/<date>-<game>/`, local only):
- `session.json` (game, start, shots), `notes.jsonl` (one line each: `s` = seconds from start, `kind` = like / dislike / say / note, `text`, `shot`)
- `f-<sec>.jpg` (1280 px wide), `like-<sec>.jpg`, `dislike-<sec>.jpg`
- `sheets/sheet-NN.jpg`: 9 shots per picture with the time (and LIKE / DISLIKE) on each

If `sheets/` is missing, make it: `powershell -NoProfile -File "$HOME\.claude\degen-skill\skills\roblox-game-study\scripts\make-sheets.ps1" -Dir "<session folder>"` (System.Drawing, no Python needed).
F8 marks can be misclicks: if lyopz corrects them ("I liked them all"), treat every marked shot as a like and add no dislike rules.
F7-only sessions: marks come in bursts — treat a burst as one strong like for that screen; open the first shot of each burst + 1 per distinct screen. Repeat session of a studied game → append a dated "Session N" to the same study, only what's new. If `watch-play.ps1` left no notes/sheets, build sheets with `make-sheets.ps1`.

Steps (save tokens: sheets first, full shots only where it matters):
1. Read `notes.jsonl` and `session.json`. His words and F7/F8 marks are the most important data.
2. Look at **every contact sheet** (one pass) to see the whole session: spawn, zones, menus, pets, effects, UI. Write down the times worth a closer look.
3. Open full-size shots only for: every like/dislike, shots within ~5 s of each note, and ~10 more for key screens (HUD, shop, pet inventory, egg hatch, best-looking pets). Cap ~40 full shots.
4. Write the study as normal (`studies/<game-name>.md`, sections above), in our own words, no screenshots in the repo. Add a **"What lyopz liked / disliked"** section: each mark or note → what's on screen → why it works or doesn't (shape, color, detail level, motion, layout).
5. Turn his reactions into general rules:
   - Design/looks (pets, models, UI looks) → `customuse-design/references/taste.md` Likes / Dislikes (no game names; e.g. "pets with layered detail, glossy materials and a glow rim, not flat cartoon"; 2+ times or "always/never" → Rules).
   - Patterns (pet presentation, hatch flow, HUD layout, feel) → `roblox-design/references/` (`pets-and-eggs.md`, `ui.md`, `game-feel.md`, `maps.md`) with "seen in <game>".
6. Write `learned.md` in the session folder (5–10 lines: what you learned and which files you changed) so the app shows it as learned.
7. Commit + push only the skill files (`git -C ~/.claude/degen-skill add skills`), never the session folder.
8. Report to lyopz in ≤ 6 lines: the 3–5 biggest takeaways and what will change in his next designs.

## Write the study → `studies/<game-name>.md`
- **One-liner:** genre + hook ("brainrot survival: outrun a rising tsunami, collect meme pets").
- **Map:** rough layout sketch (ASCII or a simple diagram), spawn → zones → loops, sizes in studs (estimate from the 5-stud player), landmarks, how zones gate (price/level), where shops sit relative to the grind path.
- **Core loop & progression:** what you do every 30 s / 5 min / session, upgrades, rebirth, unlock curve, rough numbers seen.
- **Economy & monetization:** currencies, sinks, passes/products seen (names, prices if shown), where purchase prompts appear.
- **UI/HUD:** layout (where currency, menus, main buttons sit), button style (shape, stroke, color, motion), popups, reward feedback.
- **How each system works (mechanics, in detail):** for every system seen (combat, pets, eggs, trading, building, quests, vehicles, tools…) write it as a spec we could rebuild: trigger → what happens → numbers/timings → feedback → edge cases. E.g. "Egg: walk up → prompt shows odds → press E (cost 250) → egg shakes 3× over ~2 s → crack → pet reveal with rarity color → pet joins follow slots (max 3, +1 per pass)". Note what's server-side (money, drops) vs client-side (effects) as best we can infer.
- **Feel:** effects, sounds, camera, hit feedback, what feels satisfying.
- **Art style:** preset closest match (from `roblox-art-style`), palette impression, scale.
- **Why it's fun / why players stay:** 3–5 bullets.
- **Weak spots:** what's annoying or missing (our opportunity).
- **Steal the idea, not the content:** 5–10 original takeaways for lyopz's games (e.g. "gate zones by rebirth instead of coins", "put the shop on the grind path").

## Rebuild in our own style
Each system spec → a build ticket for the Roblox agents: same *behavior*, our art style bible, our code, our numbers tuned for our game. Reusable systems become `roblox-templates`.

## Turn it into his games
- Feed takeaways into `roblox-design/references/maps.md` (layout patterns) and `ui.md`/`game-feel.md` when they're general, with "seen in <game>".
- Build our own versions with the Roblox agents (map-builder, ui-designer, scripter…) in the project's style bible — and save reusable pieces as `roblox-templates`.
- Study files stay in `studies/` as examples for future games.
