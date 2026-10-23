---
name: roblox-dev
description: How to script Roblox games so they're stable, cheat-resistant and don't lose data — why scripts matter, server/client structure, RemoteEvent validation and rate limits, safe player data (ProfileStore / session locking, DataStore limits), purchases (ProcessReceipt / BindReceiptHandler, game passes), performance and testing. Includes templates (RemoteGuard, PurchaseHandler). Use for any Roblox scripting, systems, saving, shops/purchases, anti-exploit, or "why is my game breaking / losing data / getting exploited".
---

<!-- from: lyopz (own research, 2026-10-23). Sources at the bottom. -->

# Roblox Dev (scripting)

## Why scripts matter
Everything that *happens* in a Roblox game is a script: movement rules, combat, money, pets, shops, saving, UI, effects. Parts and models are just the stage. Scripts decide:
- **Fun:** the core loop, rewards, feel (tweens, VFX, sounds are all scripted).
- **Stability:** no errors, no lag, no broken states when players join/leave or servers shut down.
- **Fairness:** exploiters run their own code on their client — only server scripts stop them from giving themselves money or killing everyone.
- **Trust & money:** lost data or failed purchases = angry players, refunds and bad ratings. Saving and purchases must be bulletproof.

## 0. Learn with time
- Read `lessons.md` (this folder) before writing code; it's the log of what broke and what worked in lyopz's past projects.
- After every Roblox job, append lessons (format at the top of the file). The session that adds them **commits and pushes** the degen-skill repo (`~/.claude/degen-skill`) so every computer, agent and the daily refresh get them: `git -C ~/.claude/degen-skill add -A && git -C ~/.claude/degen-skill commit -m "roblox: lessons" && git -C ~/.claude/degen-skill push`.
- Repeated or general lessons get promoted into this SKILL.md or a template; reusable code goes to `roblox-templates` (run `make_rbxmx.py`).

## 1. Structure (where code lives)
| Place | Runs on | Put here |
|---|---|---|
| `ServerScriptService` | server | game systems: data, money, damage, drops, purchases, round logic |
| `ReplicatedStorage` | both | shared ModuleScripts (config, utility, VFX/Motion), RemoteEvents in a `Remotes` folder |
| `ServerStorage` | server only | items/maps to clone, secret config |
| `StarterPlayerScripts` | each client | input, camera, UI controllers, cosmetic effects/motion |
| `StarterGui` | each client | ScreenGuis (+ their LocalScripts) |
- One `Main` Script per side that `require`s ModuleScript systems (each system = one module with `Init/Start`), not dozens of loose scripts.
- Config (prices, odds, cooldowns) in one shared module so balancing is one file.
- Cosmetic stuff (spin, bob, VFX, UI tweens) on the **client**; anything that matters on the **server**.
- Use `--!strict` / typed Luau in modules where practical; `task.spawn/defer/wait` (not `spawn/wait`); disconnect connections; `pcall` every DataStore / Marketplace / HTTP / Badge call.

## 2. Security — never trust the client
Exploiters can: fire any RemoteEvent/ProximityPrompt/ClickDetector from anywhere at any time, ignore client-side `Enabled`/`MaxActivationDistance`, send wrong types, huge strings, fake "instance" tables, NaN/inf, and take network ownership of unanchored parts.
**Server rules:**
- Server owns money, items, health, damage, cooldowns, ammo, team, alive state. Client only *asks*.
- Validate every remote: types and table shape, string/collection size caps, Instance class + `IsDescendantOf(expected folder)`, `math.isfinite` (NaN passes range checks silently — check `x ~= x` on Vector3 parts), value ranges, ownership/permissions (owns item, enough coins, alive), **distance** (server-side, with latency slack), line-of-sight for shots.
- Never let the client pick a path/instance for the server to modify/delete, or a module to `require`/asset to load.
- **Rate-limit** on the server (token bucket per player per remote; clear on `PlayerRemoving`), especially currency grants, teleports, DataStore/Badge calls.
- ProximityPrompt: only `Triggered` gets a server distance check; ClickDetector: none — validate yourself.
- Validate before `FireAllClients` — the server is a gatekeeper, not a relay.
- Critical physics: anchor parts or manage network ownership.
Template: `roblox-templates/templates/RemoteGuard.lua` (validated + rate-limited remotes).

## 3. Player data (saving)
- **Use ProfileStore** (loleris; successor to ProfileService): session locking + autosave + reconcile in one ModuleScript. Install from its DevForum/GitHub page. Session locking stops two servers editing the same player (= duplication exploits).
- If hand-rolling: `UpdateAsync` (not `SetAsync`) with a session lock field, autosave every 60–120 s, save on `PlayerRemoving`, `game:BindToClose` to save everyone (Studio: skip/short), retry with backoff, **never** overwrite real data with a default template after failed loads (kick with "data failed to load, rejoin" instead).
- Data shape: one table per player with a `Version` number; migrate old versions on load; no Instances, no NaN/nil keys; sanitize strings (`utf8.len`, length caps).
- Limits (per server per minute): Get/Set/Remove **60 + players×40**, List 5 + players×2, ordered write 30 + players×5. Per key: 4 MB value max, 4 MB/min writes, 25 MB/min reads; key name ≤ 50 chars. Queues hold 30 requests then drop (errors 301–306). Experience-wide: reads 300 + CCU×40, writes 300 + CCU×20.
- Trades/multi-step changes: validate everything first, commit together, revert all on any failure.

## 4. Purchases
- **Developer products:** grant only in the receipt handler — `MarketplaceService:BindReceiptHandler` (newer) or `ProcessReceipt`. Never on `PromptProductPurchaseFinished` (doesn't confirm a sale).
- Handler must be **idempotent**: record `PurchaseId` in the player's saved data (UpdateAsync/ProfileStore) before/with the grant; if already recorded, just return granted. Return `NotProcessedYet` if the player isn't in this server or saving failed — Roblox retries later. Only one handler for the whole game.
- **Game passes:** `UserOwnsGamePassAsync(userId, passId)` (pass ID, not asset ID) in `pcall` on join; listen to `PromptGamePassPurchaseFinished` to grant instantly. Results are cached; purchases made outside the game can take minutes to show.
Template: `roblox-templates/templates/PurchaseHandler.server.lua`.

## 5. Performance
- No `while true do` busy loops without waits; prefer events (`Changed`, `Touched` with debounce, `Heartbeat` only when needed).
- Throttle UI updates; pool objects (projectiles, damage numbers) instead of creating/destroying every frame.
- Server does logic; clients do visuals. Keep remote traffic small (send IDs/numbers, not big tables), batch where possible.
- Use `StreamingEnabled` for big maps; check the MicroProfiler / Developer Console (F9) for spikes.

## 6. Testing
- Studio: Play (solo), and **Test → Local Server with 2–3 players** to catch replication and join/leave bugs.
- Watch Output (errors/warnings), F9 console on live servers, Error Report/analytics on the Creator Dashboard.
- Test data: join, earn, leave, rejoin; shut down a server mid-session; buy a product in Studio test mode; try firing remotes with bad values (it should be ignored, not crash).
- Before publishing: run `roblox-reviewer`.

## Sources (researched 2026-10-23)
- Roblox docs — client-server boundary & security tactics: https://create.roblox.com/docs/en-us/scripting/security/client-server-boundary.md
- Roblox docs — data store error codes & limits: https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits
- Roblox docs — MarketplaceService (ProcessReceipt, BindReceiptHandler, UserOwnsGamePassAsync): https://create.roblox.com/docs/reference/engine/classes/MarketplaceService.md
- DevForum — ProfileStore: https://devforum.roblox.com/t/profilestore/3190543
- DevForum — Datastore best practices: https://devforum.roblox.com/t/datastore-best-practices/2845439/14
