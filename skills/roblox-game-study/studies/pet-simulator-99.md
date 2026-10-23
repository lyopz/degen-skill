# Study: Pet Simulator 99 (BIG Games) — 2026-10-23

Example game for pet-simulator projects. Ideas only, our own versions. Researched from wikis/guides (sources at the bottom) — the fandom page lyopz linked blocked our reader, so mirrors were used.

**One-liner:** break things for coins → hatch eggs → stronger pets break things faster → unlock the next area → rebirth into new worlds. Collection + trading + events keep it going for years.

## 1. Map & world structure
- **Huge linear chain of small areas**, each a new biome: Home World = Areas 1–99 (Spawn → forests → beach → desert → snow → dungeon → candy → clouds → heaven → **Rainbow Road** at 99). Tech World = 100–199 (futuristic, space, cyberpunk → **Void Spiral** at 199).
- **Gates between areas** you buy with coins (later worlds: finish gate tasks first, then buy).
- **World travel = big moments:** a **Rocket** at Area 99 (after Rebirth 4) and the **Void** at 199 (after Rebirth 8). The Void is a **hub** with cannons to small 5-area worlds (Prison, Obby, Hacker hub-and-spoke, Millionaire, Kawaii, Elemental, Olympus, Doodle), then Fantasy World (240+).
- **Rebirth shrines** (first at Area 25) reset coins/area progress for permanent strength + unlocks (teleport, Trading Plaza, shops).
- Many areas are just "farm space" (no machine): the map is mostly **breakables fields** with a new look.
- **Shortcuts/warp portals** link far areas; later, teleport after Rebirth 2.
- **Super Computer** at hubs gives remote access to every machine of earlier worlds (so you don't walk back).

**Take:** chain of small themed areas + coin gates; a dramatic "new world" transport every big milestone; hubs with every service; remote machine access once unlocked.

## 2. Core loop & economy
- **Breakables** (crates, presents, coin piles, chests) give **Coins**; the newest area pays most.
- **Coins → eggs**; **Diamonds** = rare currency (enchants, trading, machines); event tokens and keys (e.g. Crystal Keys from quests open Crystal Chests).
- **Quests** pay far more than farming and drive **Ranks (18)**; daily / 3-day / weekly quest machines.
- **Upgrades** (per player/area): Magnet, Diamonds, Tap Damage, Pet Speed, Luck, Coins, Drops, Pet Damage.
- **Passive income:** Daycare (timed pet runs), Exclusive Daycare (Huge/Titanic → diamonds).
- **Boosts:** potions, enchants, Comet Shower, Area Surge (5× coins), Boost Exchange.
- **Free chests** (diamonds, potions, enchants, items) + boss/crystal/locked chests sprinkled through areas.

## 3. Eggs & pets
- Eggs in most areas; **Egg Machine** upgrade = open more eggs at once (multi-hatch).
- Rarity ladder from Common → Legendary, plus chase tiers **Huge**, **Titanic**, **Gargantuan**.
- **Huge Rotation:** featured Huges change every 2 days with boosted odds in your best egg; a **"Huge Party" billboard near spawn** shows the current rotation (reason to log in).
- Huge sources: quests, rotation hatches, events, minigames, and the **Huge-A-Tron / Garg Machine** (feed pets for points → guaranteed Huge; fed pets are lost).
- **Pets Equipped** machine raises team size; **Index Machine** tracks collection.
- Huge pets' damage scales with your strongest pet → old Huges stay useful.

## 4. Machines (where they sit = pacing)
Unlock order tells you how to pace a pet sim: team size early, multi-hatch soon, Gold at 10, then upgrades, Fuse ~28, Rainbow ~31.
| Area | Machine | Job |
|---|---|---|
| 1 | Pet Box / Index | migrate pets / collection |
| 3 | Huge-A-Tron | exclusive pets → Huge egg |
| 4 | Pets Equipped | bigger team |
| 8 | Egg Machine | open more eggs at once |
| 10 | **Gold Pets** | pets → Gold |
| 13 / 16 | Upgrade Potions / Enchants | combine into better tiers |
| 20 | Daycare | timed passive rewards |
| 28 | **Fuse** | combine pets into a new pet |
| 29 / 60 / 111 | Quest machines | daily / 3-day / weekly |
| 31 | **Rainbow** | Gold → Rainbow |
| 44 | Comet Shower | area event |
| 52 | Upgrade Fruits | fruits → Rainbow/Shiny fruits |
| 76 / 77 | Index / Magic Machine | collection / craft from shards |
| 120 / 156 | Item Creator / Forge | craft items |
| 145 | Exclusive Daycare | Huge/Titanic → diamonds |
| 162 | Empower / Essence | 8-hour enchant boost / books → essence |
| 166 | XP Potion Machine | XP potions for Huge/Titanic |
| 177 | Area Surge | 5× coins |
| Void | **Evolve** | 5 normal Huges → evolved Huge (irreversible) |
| events | Combine-O-Matic | event recipes → higher tiers incl. Huge/Titanic |
Every machine = **a physical station in the world** (landmark), plus a hub computer for remote use later.

## 5. UI & feel (observed genre patterns)
- Big currency counters with fly-in pickups, constant number popups from breakables, pets visibly attacking breakables, glowing egg stands with odds, billboards for events/rotations, quest tracker, heavy use of rarity colors.

## 6. Social & retention
- **Trading Plaza** (after rebirth), **clans** and clan battles, minigames (Red Light Green Light, Glass Bridge, Minefield, Obby, Fishing) with token rewards and small Huge chances, limited-time events with exclusive eggs, daily rotation billboards.

## 7. Why it works
1. Always a next number: next area, next egg, next rank, next variant.
2. Chase items with visible scarcity (Huge/Titanic, rotation, events).
3. Every system is a sink for the last one (coins → eggs → pets → machines → better pets).
4. Big world-travel moments break up the grind.
5. Social proof: trading, clans, flexing Huges.

## 8. Weak spots (our opportunity)
- Overwhelming amount of systems for new players → **reveal systems slowly**, one machine at a time.
- Lots of empty "farm only" areas → give each area one small surprise (hidden chest, NPC, view).
- Loss-heavy machines (fed pets lost) feel bad → add guarantees / pity / partial refunds.

## 9. Steal the idea, not the content — takeaways per agent
- **art-director:** one strong pet style for the whole game; egg = area theme; rarity colors everywhere; machines each have a color identity.
- **map-builder:** chain of small themed areas with coin gates; breakable fields; machines as landmarks at milestone areas; hub with all services; dramatic world-travel object every ~25–100 areas; shortcuts; teleport unlock.
- **modeler:** breakables in 3–5 sizes per area theme (reuse meshes, recolor); egg base mesh recolored per area; machine shells (chamber + tubes + screen).
- **vfx-artist:** coin bursts + fly-to-counter, pet attack hits, egg stand sparkles, machine charge/flash, rarity auras, world-travel sequence.
- **ui-designer:** currency top-center with fly-in, quest tracker, egg odds panel with previews, machine panels (select grid + odds bar), rotation billboard, index book.
- **scripter:** breakable spawner + damage from equipped pets (server), coin economy config, area gates, rank/quest system, weighted egg rolls + pity, machines (chance/timed/fuse) with one-step saves, daycare timers, rebirth reset, data via ProfileStore.
- **reviewer:** check first-session onboarding (one system at a time), mobile readability of numbers, economy curve, exploit-proof pickups.

## Sources
- Bloxodes — all machines in Pet Simulator 99: https://bloxodes.com/wiki/pet-simulator-99/machines
- Pet Simulator wiki — List of Machines (PS99): https://pet-simulator.fandom.com/wiki/List_of_Machines_(Pet_Simulator_99)
- petsimulator99.wiki — beginner guide (loop, currencies, ranks, Huge rotation, rebirth, minigames): https://petsimulator99.wiki/guide/pet-simulator-99-beginner-guide/
- HoldToReset — areas list (worlds, gates, hubs, area contents): https://holdtoreset.com/pet-simulator-99-areas-list-and-whats-in-them/
- Linked by lyopz: https://pet-simulator.fandom.com/wiki/Pet_Simulator_99
