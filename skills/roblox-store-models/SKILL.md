---
name: roblox-store-models
description: Start Roblox builds from free community models and modules in the Creator Store (Toolbox) instead of from scratch — pet eggs, hatch animations, buttons/pads, proximity prompts, doors, shops, pet follow, leaderstats, kits and systems. Search, pick a well-rated free one, insert it, scan and remove malicious scripts (backdoors, require of unknown IDs, loadstring, getfenv), then restyle it to lyopz's style (saved style, game bible, taste file) and adapt it to the game. Use whenever the Lead or an agent is about to build a system, prop or animation that probably already exists in the store, or lyopz says "use a store/community/free model".
---

<!-- from: lyopz (own rule, 2026-10-24). General only: no game names. -->

# Build from Creator Store models

lyopz's rule: **don't build what already exists.** For systems and common props, check the Creator Store first, insert the best free one, make it safe, then change it to fit the game. Build from scratch only when nothing good turns up.

## 1. When to look in the store first
| Look first | Usually build/make ourselves |
|---|---|
| Egg hatch systems + hatch animations, pet follow/inventory, button pads ("step on to buy"), ProximityPrompt/ClickDetector kits, doors/gates/zones, leaderstats/currency, shops, codes, daily rewards, tycoon droppers/conveyors, obbies parts, NPC dialog, sword/tool kits, R15 animations (emotes, idle, walk) | Hero assets the game is known for (main pets, eggs' look, mascots) — these go through ChatGPT → Customuse so they match the style bible |
| Generic decor (rocks, fences, crates, lamps) when it can be recolored to the palette | Anything a `roblox-templates` template already does well (use the template) |

Order: `roblox-templates` template → Creator Store → build new. Mix freely (store system + our own art).

## 2. Search
**A. Studio (always works):** run `scripts/search.luau` with `execute_luau` (set `QUERY`, `PAGES`). It prints `assetId | name | creator` for free models. Try 2–3 queries ("egg hatch system", "pet hatching", "egg hatch animation").

**B. With ratings (better picks):** `powershell -NoProfile -File "$HOME\.claude\degen-skill\skills\roblox-store-models\scripts\store-search.ps1" -Query "egg hatch system" -Count 20`. Prints id, name, creator, verified creator, up/down votes, and a score. Uses Roblox's public toolbox web API (no login, no key).

**C. Browser fallback:** https://create.roblox.com/store/models?keyword=<words> — read the IDs off the result links.

## 3. Pick one
Score each candidate, keep the top 1–2:
- **Free and public** (paid = skip; never spend Robux).
- **Rated well:** ≥ 80% up votes and ≥ 20 votes; verified creator or Roblox-made is a big plus.
- **Plain name, real creator.** Keyword-stuffed names ("FREE PET EGG HATCH SYSTEM WORKING 2024 OP") and brand-new uploads copying a popular model = likely reuploads with backdoors.
- **Small and readable:** a few clear scripts beats 40 obfuscated ones.
- **Works with today's Roblox:** no `FilteringEnabled = false` assumptions, no `wait()`-spam loops, uses RemoteEvents properly.
Say which ID you picked and why in one line of the report.

## 4. Insert — never straight into the live game
1. Insert with the Studio MCP `insert_model`/`insert_asset` tool, or `execute_luau`: `game:GetService("InsertService"):LoadAsset(<id>)` → parent the model to `ServerStorage.StoreQuarantine` (a Folder) — **not** Workspace/ServerScriptService, so nothing runs yet.
2. If the MCP result says `sandboxed:true`, it found scripts — scan before moving anything.

## 5. Scan for malicious code (every insert, no exceptions)
Run `scripts/scan.luau` with `execute_luau` (set `TARGET` to the quarantined model). It lists every Script/LocalScript/ModuleScript with its path and flags:

| Flag | Why it's bad | Action |
|---|---|---|
| `require(<number>)` / `require(tonumber(...))` | loads someone else's code from the store at runtime (classic backdoor) | delete the line or the script |
| `loadstring`, `getfenv`, `setfenv`, `string.reverse`/`char` building code, long `\x`/`\ddd` escapes, huge base64/hex blobs | hidden/obfuscated code | delete the script |
| `HttpService` / `GetAsync` / `PostAsync` to unknown sites, `MarketplaceService:Prompt...` with an ID that isn't ours | phones home / steals sales | delete the line |
| `TeleportService`, `:Kick(`, `Players:BanAsync`, admin commands, `game:GetService("Chat")` spam | admin/backdoor | delete unless it's the feature we wanted |
| `InsertService:LoadAsset` inside scripts | pulls more models at runtime | delete |
| Scripts where none should be: inside decor, inside `Humanoid`/`HumanoidDescription`, `Configuration`, `Sound`, `Decal`, tiny named scripts like "Fix", "Anti-Lag", "Vaccine", "ThumbnailCamera", "Weld" in a model with no welds needed | hidden backdoor | delete |
| `Disabled = false` scripts in a model that should be decor only | runs on insert | delete all scripts |

Rules:
- Decor-only model with any script → delete every script.
- System model → keep only scripts you've read and understand. Read the whole flagged script, not just the line.
- After cleaning, re-run `scan.luau` until it prints `CLEAN`.
- Also check: no `RemoteEvent` lets the client pick an amount/item/instance for the server (fix per `roblox-dev` → Security), no `PlayerGui` hacks, no `_G` writes other scripts depend on.
- Never trust a module because it's popular; scan it anyway.

## 6. Adapt it to the game
1. **Move into place** using `roblox-dev` layout (ModuleScripts → ReplicatedStorage/ServerScriptService, one Main per side requiring them). Rename to our names.
2. **Restyle to lyopz's style — always, never ship the store look.** Read, in this order (later wins on conflicts):
   - the saved style if the brief names one (`~/.claude/degen-skill/styles/<name>/style.md` + `prompts.md` + its pictures),
   - the game's bible `~/RobloxGames/<project>/art-style.md` (`roblox-art-style`),
   - `customuse-design/references/taste.md` (Rules are hard, avoid every Dislike),
   - for pets/eggs: the "Premium polished pets" block in `roblox-art-style/references/chatgpt-prompts.md` (polished and premium, not cartoony),
   - and lyopz's own words in the brief (beat everything).
   Then: recolor parts to the palette, swap materials, replace the store's visible meshes (egg, pet, pad, sign) with our ChatGPT → Customuse model when they don't match, replace UI with `ButtonFeel`/our UI style, fonts, sounds. Keep the store's *logic and animation timing* if they're good. Check side by side against the bible's anchor pictures before showing lyopz, and rate it with `design-feedback.ps1` like any design.
3. **Upgrade feel** with our templates where better: hatch → `PetFX`, buttons → `ButtonFeel`, motion → `Motion`, hits → `ImpactFX`.
4. **Wire config** into the game's shared config module (prices, odds, cooldowns).
5. **Test**: Play + Local Server 2 players (`roblox-playtest`); check Output for errors and the scan once more.
6. **Credit**: write `source: Creator Store <id> by <creator>` in a header comment of each kept script and in the project's HANDOFF.md.

## 7. Keep what worked
- A store system that turned out great after cleanup and lyopz likes it → save the *cleaned, general* version as a template (`roblox-templates`, header with the store ID + creator), so next time we start from our safe copy, not the store.
- Good IDs and bad ones (backdoored, broken) → add one line to `references/picks.md` (general categories only, no game names).

## Limits
- Store meshes/animations owned by others can be used in our game when they're free/public, but uploaded **animations** only play if the creator allows it (Roblox animation permissions) — if it won't play, rebuild the animation from its timing or use ours.
- Never insert paid items, never buy anything, never paste the store model's scripts into `roblox-templates` without scanning and cleaning.
- Game-specific picks and edits stay in the project folder, not the repo.

## See also
- `roblox-creator-store-security-audit`: wider audit checklist (capabilities, plugins, HttpService prompts) for risky store assets.
