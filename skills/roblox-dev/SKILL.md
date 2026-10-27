---
name: roblox-dev
description: How to script Roblox games so they're stable, cheat-resistant and don't lose data — why scripts matter, server/client structure, RemoteEvent validation and rate limits, safe player data (ProfileStore / session locking, DataStore limits), purchases (ProcessReceipt / BindReceiptHandler, game passes), performance and testing. Includes templates (RemoteGuard, PurchaseHandler, ImpactFX). Use for any Roblox scripting, systems, saving, shops/purchases, anti-exploit, or "why is my game breaking / losing data / getting exploited".
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
- Pull first (`git -C ~/.claude/degen-skill pull`) — a stale clone misses new rules and lessons.
- Read `lessons.md` (this folder) before writing code; it's the log of what broke and what worked in lyopz's past projects.
- After every Roblox job, append lessons (format at the top of the file). The session that adds them **commits and pushes** the degen-skill repo (`~/.claude/degen-skill`) so every computer, agent and the daily refresh get them: `git -C ~/.claude/degen-skill add skills agents commands && git -C ~/.claude/degen-skill commit -m "roblox: lessons" && git -C ~/.claude/degen-skill push`. Lessons are general: no game names, pet names or game details (game content stays in `~/RobloxGames/<project>/`).
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
- **Free Creator Store models can carry backdoors** (a "low poly palm" hid Scripts under `Humanoid > HumanoidDescription`). After every insert, list `LuaSourceContainer` descendants; decor with scripts → delete the model. MCP `insert_asset` returning `sandboxed:true` = it found scripts. Keyword-stuffed names are usually reuploads; plain names + older IDs are safer. Full insert → scan → clean → restyle flow and scanner: `roblox-store-models`.
- **Gates the client can't fake:** the client owns its Humanoid (JumpPower, flying), so gate jump/area unlocks on server data AND a server-sampled HRP position in that area; put the check in the shared station-distance helper so every station gets it.
- **Item machines (fuse, craft, upgrade):** rules in a pure shared module (client preview = server check); preview returns a one-use token bound to (player, inputs, choice, 120 s); commit re-validates, mutates in one non-yielding block, caches the result per token (repeat = same result). Template `ConfirmToken`.
- A RemoteEvent can later become a RemoteFunction without breaking clients if all calls go through one request helper that checks `ClassName`.
Template: `roblox-templates/templates/RemoteGuard.lua` (validated + rate-limited remotes).

## 3. Player data (saving)
- **Use ProfileStore** (loleris; successor to ProfileService): session locking + autosave + reconcile in one ModuleScript. Install from its DevForum/GitHub page. Session locking stops two servers editing the same player (= duplication exploits).
- If hand-rolling: `UpdateAsync` (not `SetAsync`) with a session lock field, autosave every 60–120 s, save on `PlayerRemoving`, `game:BindToClose` to save everyone (Studio: skip/short), retry with backoff, **never** overwrite real data with a default template after failed loads (kick with "data failed to load, rejoin" instead).
- Data shape: one table per player with a `Version` number; migrate old versions on load; no Instances, no NaN/nil keys; sanitize strings (`utf8.len`, length caps).
- Limits (per server per minute): Get/Set/Remove **60 + players×40**, List 5 + players×2, ordered write 30 + players×5. Per key: 4 MB value max, 4 MB/min writes, 25 MB/min reads; key name ≤ 50 chars. Queues hold 30 requests then drop (errors 301–306). Experience-wide: reads 300 + CCU×40, writes 300 + CCU×20.
- Trades/multi-step changes: validate everything first, commit together, revert all on any failure.

- **Patterns that worked (projects, promoted 2026-10-24):**
  - New per-item roll (aura, shiny): one optional field + a pure config module (`{Chance, RareBoost}` per source + an `Odds()` the UI reuses); roll in the ONE item-creation service, before any auto-delete decision; carry through fusion as "rarest input"; migration only fixes bad types and keeps unknown ids. Store rolled stats as 0–1 quality so rebalancing rescales owned items.
  - Trading needs globally unique item ids (per-player counters collide): upgrade to a GUID when first offered and repoint team/equip refs.
  - Two-player trade without a central store: save a PendingTrades record (gives + exact copies of gets) to both → apply both in one non-yielding block → save both; on load, read the partner's record and roll forward/undo with the same apply function. Safe for one server crash, not every rejoin race — keep trading Studio-only until a 2-client + published crash test passes.
  - Big per-item data blows up client sync: pack items with a codec (only fields the client can't derive from config), round-trip test, then move to delta sync.
  - Tests: assert `Version >= n` for old migrations and keep ONE "current version" check. Migration tests with injected profiles touch only the in-memory store (with Studio API access on they'd overwrite the dev's real save).
  - A Config folder whose init requires every child: helpers (odds, boosts) go in their own child module — functions added to a data table break `pairs()` loops. Don't name a service's own function `Start` if the boot loader calls `svc.Start()`.
  - **(promoted 2026-10-25)** Retiring a mechanic: migrate the old field into the new one on the SAME item (keep ids), also run it in the every-load repair so stale copies (pending-trade records) convert; rebuild derived books (collections) with an add-only backfill and test idempotency by migrating twice.
  - Equip-one-of-many (body/skin per pet): the item field (`pet.Body = uid`) is the only truth; DERIVE "equipped on" in the sync codec so trade/delete/rekey need no bookkeeping (strip it from traded copies).
  - Passive income ticking every second: update the currency attribute live (no sync) and MarkDirty at most every ~10 s from income alone — never a full snapshot per tick.

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

## 7. Studio MCP & engine gotchas (from projects)
- `start_stop_play` spawns like "Play Here" (where the edit camera looks): aim the camera at the spawn first. Keep SpawnLocations flat and invisible on top of a decorative part (a sideways-rotated one spawns players off to the side).
- `screen_capture` can hang > 120 s on models with 1000+ parts (too heavy for phones anyway); captures right after terrain edits can be stale; Edit mode shows no particles (`roblox-design/references/game-feel.md`).
- `Lighting.Technology` errors in `execute_luau` even when read: `pcall` it, set Future by hand.
- EditableMesh in play needs Game Settings > Security > allow Mesh/Image APIs ("EditableMesh is not accessible"). Server/edit can create one when clients can't, so pick fallbacks on the client. Max extent 2048 studs; the MeshPart keeps its creation size (add tiny hidden triangles at ±max height for flat meshes). Client `WriteVoxels` didn't apply in MCP play tests.
- **MCP `execute_luau` runs in its own VM:** `_G` from game scripts is invisible, threads it spawns die when the call returns, `require` gives a fresh module copy (Edit mode also caches require — clone the ModuleScript to test edits). Drive dev tools through a Studio-only DevCommand remote / Debug BindableFunction from the Client DM; test long animations through the real remote; LocalScripts gated on a LocalPlayer attribute keep running.
- Can't set from MCP: `Lighting.Technology`, Workspace streaming properties (StreamingTargetRadius etc.) → set by hand, say so in the report.
- Movement tests: `Humanoid.Jump` is overwritten each frame → `ChangeState(Jumping)` + drive HRP velocity on Heartbeat. Prompts: `prompt:InputHoldBegin()/InputHoldEnd()` on the Client after `character_navigation`. Under Device Simulator `user_mouse_input` misses GUI buttons → use shortcuts or toggle Visible. Teleport tests must stay inside any map bounds check.
- Device simulator: service is `StudioDeviceSimulatorService`; named presets can break → `CreateDeviceAsync({Name, Width=800, Height=360, PixelDensity=96})` + `SetDeviceAsync` from the Client DM (SetOrientationAsync needs a mobile device first).
- `screen_capture`: can hang or time out for a whole session (then verify by AbsolutePosition/Size per device and report shots as pending); lands 1–3 s after return (add a "hold" switch for timed effects); BillboardGuis drift sideways at wide FOV; far SurfaceGui text can be blank first time.
- Spatial queries (`GetPartBoundsInRadius` etc.) skip CanQuery=false decor — to find a stray bright part, loop the model's descendants by distance. Temporary tagged parts made during Play are a clean way to test unplaced stations.
- StreamingEnabled: a tagged Model can arrive before its children — client decorators retry for a few seconds.
- Script sync: serve files with `python -m http.server --bind 127.0.0.1` (one port per agent; two on one port fail silently), HttpGet with HttpEnabled on only for the fetch, normalize CRLF, `loadstring` compile-check before setting `.Source`, sync whole files (anchor patches break on CRLF). Big UI builders hit the 200-locals limit → wrap sections in `do ... end`. Map builds: one file per building + shared lib, each chunk clears + rebuilds itself.
- Shared Studio: save the place to file/Roblox before building (unsaved places can close); check `list_roblox_studios` before long jobs; lock finished map parts (`Locked=true`). Many agents: Play lock file (`_studio_play.lock` "<role> <unix-time>", ≤ 3 min, re-read before each capture, same clock that wrote it), sync only an allow-list of your files after diffing Studio vs disk.
- Meshes: no MCP tool uploads meshes. EditableMesh → `CreateMeshPartAsync` is an unsaved preview; persistent ids need `CreateAssetAsync` (local plugin only, can say "not available yet" — test one asset first) or Open Cloud upload → `insert_asset` (drop the PackageLink), else File > Import 3D (Merge Meshes off). `upload_image` needs an http URL; `PreloadAsync` can report Failure for images that render.
- **(promoted 2026-10-25) Engine traps:** archived Scripts with `RunContext = Server` still run in ServerStorage → set `Enabled = false` on everything you archive (an old bounds script kept teleporting players). `Model.WorldPivot` is ignored while a PrimaryPart is set — clear it before re-centring. Several same-name modules under one parent: `require/FindFirstChild` take the first in GetChildren order. `return s:gsub(...)` returns 2 values (leaks an extra arg as a last call arg) — wrap in `()`. "Still in game" = `model:IsDescendantOf(workspace)`, not `.Parent`. Other players' jump/land: read HRP vertical velocity (Humanoid states don't replicate reliably). Gameplay tags on Cylinder parts point sideways (Shape=Cylinder is X-up) → tag an invisible upright Box at the walk surface. Model:ScaleTo pops: always `ScaleTo(baseScale * k)` from `GetScale()` at track time.
- **(promoted 2026-10-25) MCP/test traps:** game scripts can't read `.Source` (pcall, run source checks from Edit). Edit `require` caches for the whole session → require a `:Clone()` parented next to the original (or a fresh `Shared:Clone()` for new Config children). Setting a Script's Source during Play doesn't change what clients run — edit in Edit, restart Play. `execute_luau` resets CameraType after the call → re-assert a Scriptable camera in RenderStepped; walk tests: drive Move from `BindToRenderStep` after `RenderPriority.Character` (ControlModule overwrites it). `InsertService:LoadAsset` of store models fails in execute_luau ("not authorized") — use MCP `insert_asset`. Self-timing for perf: accumulate `os.clock()` per frame, write avg ms to an attribute once a second.
- **(promoted 2026-10-25) Shared Studio:** re-read the Play lock right before EVERY `start_stop_play`; never stop someone else's Play — do Blender/Unity work and poll `get_studio_state`. One shared camera: hold it with a ~6 s Heartbeat loop inside the same call and grab with `-Delay 1500`. Background grabs: `PrintWindow(hwnd, hdc, 2)` never steals focus while lyopz types; check every grab's size/mean (a black or 237×39 grab = minimized window, `ShowWindow(h,3)` and retry; delete grabs that caught desktop windows). Sync = pull every Studio Source to disk first, then push with a drift guard (Studio length == pulled length) + `loadstring` compile check. `python -m http.server` on Windows sets SO_REUSEADDR: a duplicate port starts silently and the OLD server answers → random high port + curl one known file first.
- Windows tooling: PowerShell vars are case-insensitive, `R` is an alias (Invoke-History), `-File` can't take arrays (pass a comma string), double quotes inside native args split (use single quotes), `Set-Content -Encoding utf8` adds a BOM Luau rejects (use `[IO.File]` + `UTF8Encoding($false)`), PS 5.1 `Get-Date -UFormat %s` is local time. Python: `open(..., newline="\n")` for Luau files. Write patch scripts to files instead of inline `python -c`/heredocs.

## 8. Platform updates to know (2026-10)
- **Collision Summaries** (`BasePart:BindToCollisionSummaries`): contact point/normal/speed per frame on the network owner → impact sounds, VFX, crash damage. Template `ImpactFX`.
- **Luau `if local` / `if const`** (declare a variable in an `if` condition): Studio beta only — don't use in games you publish until it's released. https://devforum.roblox.com/t/beta-if-local-statements-and-expressions/4918297
- **Animation Graph state machines + Luau expression nodes**: Studio beta (File > Beta Features); keep state logic in Luau for live games until release. https://devforum.roblox.com/t/studio-beta-introducing-state-machines-and-luau-expressions-for-animation-graphs/4921939
- **Text-to-speech auto-translates** (11 languages): `AudioTextToSpeech.AutoLocalize` defaults to true — set false for lines that must stay as written.
- **Age check API:** `Player.AgeChecked` (read-only) + `Player:PromptAgeCheck()`; US 18+ Paid Access spend pays a higher DevEx rate. https://devforum.roblox.com/t/introducing-the-us-18-devex-rate-earn-42-more-on-spend-from-18-us-players/4607091
- **Publishing:** homepage recommendations now require a custom thumbnail (https://devforum.roblox.com/t/homepage-recommendation-eligibility-now-requires-a-custom-thumbnail/4945086; upload 16:9, 1920×1080, 2+ for personalization; keep text off the bottom edge); new guided publish flow lets you invite up to 10 friends/group members as early testers. https://devforum.roblox.com/t/a-simpler-path-to-publish-plus-invite-early-testers/4930524 · https://create.roblox.com/docs/production/publishing/thumbnails
- **(2026-10-24) Server logs → Studio:** server error stack traces now deep-link to the exact script, line and version in Studio — check Creator Dashboard error reports first when a live bug appears. https://devforum.roblox.com/t/announcing-studio-deep-links-on-stack-traces-for-server-logs/4953062
- **(2026-10-24) Chat:** TextChatService is going native; custom chat must migrate by **May 2027** — build new games on default TextChatService, don't write a custom chat system. https://devforum.roblox.com/t/important-textchatservice-updates-how-to-test-and-what%E2%80%99s-next/4948433
- **(2026-10-24) In-game creation publishing:** `AssetService:PromptCreatePlatformContentAsync` (takes an Object, e.g. an `EditableImage`) replaces `PromptCreateAssetAsync` for publishing player creations to their inventory. https://devforum.roblox.com/t/in-game-editable-image-publishing/4944421
- **(2026-10-24) Voice lines (beta):** `AssetService:CreateAssetAsync` accepts `AudioTextToSpeech` in Studio → saved audio assets with no play-time TTS rate limits. Beta: don't depend on it in published games yet. https://devforum.roblox.com/t/studio-beta-text-to-speech-asset-creation-support-in-lua/4950480
- **(2026-10-25) Community tools (check the licence before copying code):** Noid — open-source state machine for custom character controllers without a Humanoid (fits server-authority / custom rigs) https://devforum.roblox.com/t/open-source-noid-states-transitions-without-the-humanoid/4949044 · Output+ plugin — dockable Output with script channels, colours and expandable tables https://devforum.roblox.com/t/plugin-output-script-channels-colored-outputs-rich-text-support-and-more/4950229
- **(2026-10-27) Package Overrides (Studio beta, 743+, File > Beta Features):** local edits to a package copy (properties, attributes, parent, added children) are kept and re-applied when the source package updates; Explorer shows a blue dot (changed) / green plus (added); Package → Revert Overrides. Your value wins on conflicts (can block a source fix), everyone in Team Create needs the beta or edits get lost, nested packages can go stale, turning the beta off can drop overrides. Good for shared kits across games (lobby, shop UI) — keep live games on plain packages until release. https://devforum.roblox.com/t/studio-beta-package-overrides-and-usability-improvements/4936628 · https://gamineai.com/blog/what-roblox-package-overrides-beta-changed-for-indies-2026
- **(2026-10-26) Game-specific Quick Words:** Creator Hub → Configure → Chat → Quick Words: up to 3 custom categories × 3–10 phrases (< 25 chars, English only, auto-translated, reviewed before going live; gameplay coordination only, no open questions). Set them for co-op/horror/team games ("Follow me", "Monster here!", "Need revive"). https://create.roblox.com/docs/chat/quick-words
- **(2026-10-25) Dev stages:** tag dev-only rigs/stages `DevOnly`; template `DevContentGuard` destroys them on live servers (they ship on Publish otherwise).
- **(2026-10-25) SLIM avatars** (`Workspace.EnableSLIMAvatars`) now support StarterHumanoids/StarterCharacters; changes made via StarterCharacterScripts/StarterPlayerScripts still aren't supported — test custom characters with SLIM off and on. https://devforum.roblox.com/t/introducing-support-for-platform-avatars-in-slim/4632702
- **(2026-10-24) Avatars:** `AvatarUnificationMode` is deprecated on **Dec 1 2026** (remove any use); body validation now standardizes scaling — competitive games should enable Custom Height + Consistent Gameplay. https://devforum.roblox.com/t/weekly-recap-october-19%E2%80%9323-2026/4953263

## Sources (researched 2026-10-23)
- Roblox docs — client-server boundary & security tactics: https://create.roblox.com/docs/en-us/scripting/security/client-server-boundary.md
- Roblox docs — data store error codes & limits: https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits
- Roblox docs — MarketplaceService (ProcessReceipt, BindReceiptHandler, UserOwnsGamePassAsync): https://create.roblox.com/docs/reference/engine/classes/MarketplaceService.md
- DevForum — ProfileStore: https://devforum.roblox.com/t/profilestore/3190543
- DevForum — Datastore best practices: https://devforum.roblox.com/t/datastore-best-practices/2845439/14
- DevForum weekly recaps (Oct 5–9, Oct 12–18 2026): https://devforum.roblox.com/t/weekly-recap-october-5-october-9-2026/4924062 · https://devforum.roblox.com/t/weekly-recap-october-12-18-2026/4938638
- Roblox docs — collisions / collision summaries: https://create.roblox.com/docs/workspace/collisions

## See also
- Deeper guides: `roblox-luau-architecture`, `roblox-datastore-persistence`, `roblox-security-economy`, `roblox-debugging-bugfix`, `roblox-performance-optimization`. Lessons still go to `lessons.md` here.
