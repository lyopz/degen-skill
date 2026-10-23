# Pets & eggs (pet simulators, Adopt Me–style, Grow a Garden–style) — 2026-10-23

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

## Sources
- creation.dev — how to make a pet simulator (tiers, colors, odds, eggs per world, pity, evolutions, limited eggs, performance): https://www.creation.dev/learn/how-to-make-pet-simulator-roblox
- Roblox DevForum — Pet Hatching Framework Part 1 (egg containers, odds frame with viewport previews, server weighted random, lift/shake/flash/reveal animation, multi-hatch slots): https://devforum.roblox.com/t/pet-hatching-framework-part-1/1480291
- Gfinity — Rainbow pets in Pet Simulator X (golden ≈3× stats, rainbow machine odds, lucky pass): https://www.gfinityesports.com/roblox/rainbow-pets-pet-simulator-x
