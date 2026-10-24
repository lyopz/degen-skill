# Pets, eggs & upgrades (pet simulators, Adopt Me–style, Grow a Garden–style) — 2026-10-23

How the genre's eggs and pets are designed, so ours feel right on the first try. "Seen in" = observed genre pattern; numbers marked *(source)* come from the sources at the bottom; the rest are common practice to tune per game.

## 1. Egg stands (the egg in the world)
- **Placement:** eggs live at **egg stands/pedestals** along the grind path or in an "egg zone" of each world, never hidden. Each world has **2–3 eggs**; launch with **3–5 egg types** *(creation.dev)*.
- **Price ladder:** each new egg costs noticeably more; the **first egg of a new world must hatch pets stronger than the best of the previous world** *(creation.dev)*.
- **Floating vs grounded — pick one per game (style bible) and keep it:**
  | Style | Look | Motion | Fits |
  |---|---|---|---|
  | **Floating showcase** (most simulators) | egg hovers 1–2 studs over a glowing pedestal/ring | slow bob 0.4–0.8 studs, 2–3 s cycle; slow spin 10–20°/s; soft particle sparkles; PointLight in the egg's color | Pet Sim–style, bright cartoon, neon |
  | **Grounded / nest** | egg sits in a nest, crate, basket, pot or machine | no hover; tiny idle wobble every few seconds; dust/leaf particles | cozy (garden/farm), horror, realistic-lite |
  | **Machine / capsule** | egg inside a gacha machine, cauldron, portal or capsule dispenser | machine animates, egg drops out on hatch | sci-fi, factory, brainrot |
- **Readability:** big (egg 3–5 studs tall, players are 5), **egg color = its theme**, a **BillboardGui** above it with name + price (icon + number), and a **"3 E" / tap prompt**. Within ~12 studs show the **odds panel**.
- **Odds panel (trust):** show **every pet in the egg with its % chance**, rarity color and a spinning preview (ViewportFrame) *(creation.dev; DevForum framework)*. Add owned/unowned markers and the pity counter if there is one.
- Cost: keep egg stands cheap — one egg mesh reused with different colors/decals, particles + light for the rest.

## 2. Egg designs (how each egg looks)
- **One theme per egg = one world/biome or event:** Grass egg (green, leaves), Desert egg (sand, cracks), Ice egg (frost, crystals), Lava egg (dark with glowing veins), Candy egg (sprinkles), Space egg (stars, galaxy swirl), Golden/Event egg (gold, sparkles), Garden-themed eggs in Adopt Me–style games. The pets inside match the theme.
- **Shape language:** the classic rounded egg with a slightly wider bottom, chunky outline/bevel; pattern bands, spots or zigzag "crack" lines; accent gems/ribbons for premium eggs; event eggs get a unique silhouette (pumpkin, present, crystal).
- **Tier language:** cheap eggs plain + matte; better eggs add patterns; premium/Robux eggs add gold trim, Neon accents, extra particles, a beam/ray from the stand.
- **Colors:** from the game's palette + the theme color; the rarity colors stay reserved for pets.
- Build route: eggs are simple shapes → **Blender or Roblox parts (0 credits)**; save one base egg mesh in the style bible and recolor.

## 3. Hatching (the moment)
1. **Confirm & cost** on the server: distance check, cooldown, enough currency, then deduct. Server rolls the pets (weighted random; scale chances ×10,000 for decimals) and fires the result to the client *(DevForum framework)*.
2. **Lift:** egg moves to the screen center (UI ViewportFrame or camera in front), ~0.6 s ease out *(DevForum: ~0.65 s)*.
3. **Shake:** 3–4 shakes, each faster and stronger; tension sound rising in pitch.
4. **Crack + flash:** white flash, crack sound, particles; screen dim/blur behind.
5. **Reveal:** pet pops in with Back-out scale, spins once; **rarity banner + color** (name, rarity, chance %); legendary+ gets extra beam, confetti, camera shake and a server announcement.
6. **Done:** "Equip / Delete / Auto-delete" buttons; pet flies into the inventory icon.
- Total ≤ ~3 s per hatch, **skip/fast mode** after the first few, **auto-hatch** and **multi-hatch** (x3, x8 via game pass) show several eggs side by side in fixed slots *(DevForum framework: slots for up to 3)*.
- Effects: `PetFX.HatchInFront` (shake → flash → rarity burst, legendary+ bloom + pillar), `PetFX.RarityAura`, `PetFX.Reward` (how-to in `roblox-vfx`).
- Use templates: `VFX` (sparkles/explosion/shake), `ButtonFeel` (buttons), `RemoteGuard` (hatch remote), `PurchaseHandler` (luck/multi-hatch passes).

## 4. Odds & rarity
- Tiers: **Common, Uncommon, Rare, Epic, Legendary, Mythical, Secret** with colors grey, green, blue, purple, gold, red, rainbow/holo — same everywhere *(creation.dev)*.
- Typical per-egg odds: Common 50–60%, Uncommon 20–25%, Rare 10–15%, Epic 4–6%, Legendary 1–2%, Mythical 0.1–0.5%, Secret 0.01–0.05% *(creation.dev)*.
- Each tier dramatically rarer and stronger than the one below.
- **Pity system:** guaranteed minimum rarity after N hatches without one; show the counter *(creation.dev)*.
- **Luck boosts:** potions, events, game passes (e.g. a "lucky" pass raising rainbow odds 0.5% → 2.5% in Pet Sim X *(gfinity)*). Show active boosts on the egg panel.
- **Limited/seasonal eggs** with exclusive pets for urgency and spikes *(creation.dev)*.

## 5. Pets inside (styles)
Pick ONE pet style per game (style bible) — mixing breaks the look.
| Style | Looks like | Notes |
|---|---|---|
| **Cube / blocky** | rounded cube body, painted face, paddle limbs/wings | cheapest (Blender, 300–2k tris), reads at any size, great for sims |
| **Chunky round cartoon** | big head, tiny body, soft shapes (Adopt Me–like) | most "cute"; needs good silhouettes |
| **Low-poly faceted** | angular, flat shaded | matches low-poly maps |
| **Plushie / toy** | stitched seams, soft fabric look | cozy games |
| **Meme / brainrot** | exaggerated meme characters, glossy toy look | brainrot games; keep the same gloss + proportions across all |
| **Elemental / energy** | pets made of fire/ice/void with particle bodies | higher tiers; VFX-heavy, watch mobile budget |
- **Rule:** identity traits of the real animal/thing, translated into the game's shape language (see `roblox-art-style`).
- **Size by tier:** normal pets ~2–3 studs; **Huge** pets ~2–3× bigger (rare, shown off); **Titanic**-style mega pets as event chase items.
- **Variants without new models:** **Golden** (gold material, sparkle), **Rainbow** (animated hue shift), **Shiny/Dark Matter** (dark + aura) — material/color swaps + particles on the same mesh. Golden ≈ 3× a normal pet's stats in Pet Sim X; rainbow stronger still *(gfinity)*. Evolution chain Normal → Golden → Rainbow → Dark Matter, each needing the previous at max + resources *(creation.dev)*. Crafting machines (e.g. combine 6 golden for a 100% rainbow) are a common sink *(gfinity)*.
- **Movement:** most pets **float/bob** beside or behind the player (cheap, no rig, `Motion.Follow`), flying pets flap, ground pets hop/waddle (`Motion.Waddle`) or use a simple walk rig. Pets spread around the player in a small arc (e.g. 3–5 slots), never stack.
- **Readability:** pet name + rarity color on hover/inventory; rare pets get an aura/trail (`VFX.Aura`) — limit effects on other players' pets for performance, and offer "hide others' pets" on low-end devices *(creation.dev)*.

## 6. Systems around eggs/pets
- Inventory with sort/filter by rarity, equip slots (+ passes for more), mass delete, lock favorite pets.
- Index/collection book (rewards for completing an egg's set).
- Trading (later; server-validated, both sides confirm, logs).
- Data: pets saved by ID + variant + level, never as models (`roblox-dev`).
- **Offline hatching** (seen in Tap Simulator REBORN, lyopz liked): the last egg keeps hatching while offline at ¼ speed, capped (e.g. 4 h / 10,000 eggs). Server: `eggs = min(secondsAway × rate × 0.25, cap)`, roll in bulk, apply auto-delete, save. On join: "While you were away" card → count ticks up → **Reveal Results** → grid (kept vs auto-deleted, ×count per pet) → one button; then resume auto-hatch.
- **Index with silhouettes** (seen in Tap Simulator REBORN): tabs per variant (Normal/Golden/Diamond/Rainbow), one row per egg with hatch counts, unfound/secret pets as black ??? silhouettes, row complete → claim coins + gems. Egg prompt shows secrets as silhouettes with "1 in 500,000".
- **Pets menu** (seen in Tap Simulator REBORN): equipped row on top, rest in a grid; each card shows its multiplier and stack count (×37); Equip Best / Unequip All, mass delete, lock, storage count with a + button.
- **Mastery tracks** (seen in Tap Simulator REBORN): one level track per activity (hatching, secret hatching, tapping, goldens, enchanting), XP from doing it, rewards at set levels (+hatch speed, luck, a cosmetic ring at Lv 100), all listed with locks.


## 7. Upgrading pets (evolve · fuse · merge · enchant)

### The systems the big games use
| System | How it works | Seen in |
|---|---|---|
| **Chance machine** (Golden / Rainbow) | put **1–6 of the same pet** in; more pets = higher chance and higher cost; fail = pets are lost. Golden machine: 1 pet 13% (250 💎) · 2 = 29% (400) · 3 = 47% (600) · 4 = 63% (800) · 5 = 88% (1,000) · 6 = 100% (1,250) | Pet Simulator X *(GGRecon)*; Rainbow machine: 1 golden 13% … 6 golden 100% (2,250 💎) *(Gfinity)* |
| **Timed machine** (Dark Matter) | always succeeds, but **takes time**; more pets = shorter wait (1 pet 5 days … 6 pets 30 min); collect from a "view" queue; Robux skip that gets cheaper as time runs down; 6 slots, 8 with a pass | Pet Simulator X *(Pet Sim wiki)* |
| **Ritual fuse** (Neon / Mega Neon) | **4 fully-grown** pets of the same kind on **4 glowing circles** in a hidden cave → 1 neon pet (starts small again); 4 max-age neons → Mega Neon that cycles rainbow colors every 1–2 s | Adopt Me *(Pro Game Guides)* |
| **Fuse / combine any pets** | throw several (often lower-tier) pets in → one random better pet; doubles as a pet-trash sink | Pet Sim 99 style fusers |
| **Enchant circle** | pay coins to roll **perks** onto a pet (Coins +15%…+100%, Strength, Luck…; tiers I–V; 2–4 slots by rarity); fusing can re-roll them | Pet Simulator X *(Pet Sim wiki)* |
| **Level / feed / age up** | pets gain XP from use or food; max level unlocks the next evolution | Adopt Me ages, many sims |

**Variant ladder (pick one, keep it everywhere):** Normal → **Golden** (~3× stats) → **Rainbow** (stronger) → **Dark Matter / Mega** (~20× normal in Pet Sim X) *(Gfinity, Pet Sim wiki)*. Same mesh, new material + effects each step (see section 5).

### Which to use (recommended defaults for lyopz's games)
- **Main path:** Chance machine for Golden and Rainbow (simple, exciting, a strong currency + pet sink), plus a **guarantee at max slots** so it never feels like a scam.
- **Top tier:** Timed machine for the highest variant (always succeeds, creates a reason to come back, optional skip).
- **Cozy games:** Ritual fuse (4 circles) instead of chance; no losing pets.
- **Extra depth later:** Enchants for perks; a "fuse anything" machine as a trash sink.
- Show the exact **odds, cost and time** before confirming, and the **result preview** (ghost of the upgraded pet).

### A cool place to upgrade (the "Forge")
Make the upgrade spot a **landmark**, not a menu button:
- **Location:** a special area next to the hub or at the end of each world (the reward for getting there), visible from spawn with a beam of light / particles.
- **Look per game style:**
  - *Simulator / neon:* a glowing **Pet Forge** — big machine with a transparent chamber, conveyor or tubes feeding pets in, energy rings, screen showing odds; each variant has its own colored machine (gold, rainbow, dark void).
  - *Cozy / garden:* a **Moon Shrine / Fairy Ring** — 4 stone circles that light up, fireflies, soft music (Adopt Me–style ritual).
  - *Fantasy:* an **Enchanting Altar** with floating runes and books.
  - *Sci-fi / brainrot:* a **Mutation Lab** — tubes of goo, warning lights, a big lever.
- **Interaction:** walk up → prompt → pick pets in a grid (only valid pets selectable; auto-fill best combo) → slot count + live odds bar fills as you add pets → big **FUSE** button (hold 1 s to confirm, ButtonFeel).
- **The moment (≤ 4 s):** pets fly from the player into the machine → machine charges (rising hum, shake, lights speed up) → flash + camera shake → upgraded pet pops out on a pedestal with variant colors, beam, confetti; fail = sad fizzle + smoke (short, never mocking). Legendary results get a server-wide announcement.
- **Timed machines:** pets visible "cooking" inside, countdown above the machine (BillboardGui), "Collect" glow when ready, optional skip product.

### Rules (stable + fair)
- **Server does everything:** validate pet ownership, same-type rules, levels, cost, and roll the result on the server; remove input pets and add the output in **one save step** (no duplication); log it. Use `RemoteGuard` + the data rules in `roblox-dev`. Robux skips/boosts via `PurchaseHandler`.
- Lock favorite pets so they can't be fused by accident; confirm before using rare pets.
- Balance: each upgrade should feel worth it (big stat jump, clear new look) and cost enough to matter; check the math in one config module.

### Sources (upgrades)
- GGRecon — Golden machine odds and costs (Pet Simulator X): https://ggrecon.com/guides/pet-simulator-x-how-to-make-golden-pets
- Gfinity — Rainbow machine (Pet Simulator X): https://www.gfinityesports.com/roblox/rainbow-pets-pet-simulator-x
- Pet Simulator wiki — Dark Matter machine: https://pet-simulator.fandom.com/wiki/Dark_Matter_Machine_(Pet_Simulator_X)
- Pet Simulator wiki — Enchants: https://pet-simulator.fandom.com/wiki/Enchants_(Pet_Simulator_X)
- Pro Game Guides — Neon & Mega Neon pets (Adopt Me): https://progameguides.com/roblox/how-to-make-a-neon-pet-in-adopt-me

## Sources
- creation.dev — how to make a pet simulator (tiers, colors, odds, eggs per world, pity, evolutions, limited eggs, performance): https://www.creation.dev/learn/how-to-make-pet-simulator-roblox
- Roblox DevForum — Pet Hatching Framework Part 1 (egg containers, odds frame with viewport previews, server weighted random, lift/shake/flash/reveal animation, multi-hatch slots): https://devforum.roblox.com/t/pet-hatching-framework-part-1/1480291
- Gfinity — Rainbow pets in Pet Simulator X (golden ≈3× stats, rainbow machine odds, lucky pass): https://www.gfinityesports.com/roblox/rainbow-pets-pet-simulator-x
