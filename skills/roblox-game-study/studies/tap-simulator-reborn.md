# Study: Tap Simulator REBORN — 2026-10-23

Source: a "Watch me play" session lyopz recorded (~7 min, 66 frames, no spoken notes). He said afterwards he **liked all of it**; the 23 dislike marks were misclicks, so every marked screen counts as a like. Ideas only, our own words; screenshots stay on his PC.

**One-liner:** clicker/pet sim — tap a giant button for clicks → buy eggs → pets multiply click power → rebirth (huge numbers: billions of rebirths, "SP"/"QN" suffixes) → unlock island portals and event eggs.

## Map
```
           [Desert] [Crystal Cave] [Shadow Realm] [Volcano]      ← back row of portals (later islands)
     [Sky Island]     [Autumn]      [Mushroom]   [Double Jumps machine]
                   \      |       /
                    stairs up from plaza
 [Season Pets podium + leaderboards]   [Eggs row]   [Gem Upgrades hut]   [Halloween portal]
                     [Spawn plaza: fountain + statue, Golden Crafting, Collection pad]
```
- Small grassy **hub island** (waterfall, river, wooden bridges, checker stone paths). Everything is within ~100 studs of spawn.
- **Portal hub:** a terrace of stone arches, each portal a glowing biome color with its theme dressed around it (pumpkins, mushrooms, autumn trees). You can see what's coming from the spawn path.
- Islands are **vertical**: "Height 11,579 m" counter, **double jumps** (7, bought at a machine with gems) to reach floating islands. Each island has 1–2 egg pedestals.
- Biome islands seen: **Volcano** (orange lava floor, dark rock, glow), **Shadow Realm** (dark slate rock with **neon purple cracks** running across the ground, giant crystal flowers, floating rock chunks, laser beams).
- In-world **leaderboard boards** with gold crown frames (Eggs Hatched, F2P Pet Power, Rebirths) and a **Season Pets** podium with a countdown (6 d 19 h) showing the season's top pets on pedestals.

## Core loop & progression
- Tap (button or click anywhere) → clicks (+1.55T per tap, crits). Pets multiply click power ("Team Power ×27M").
- Clicks → eggs → pets → more clicks. Rebirth resets for permanent multiplier.
- **Offline hatching:** your egg keeps hatching while you're away (4 h at ¼ speed, cap 10,000 eggs). On return: big "While you were away" card → egg count ticks up → **Reveal Results** → grid of everything hatched (kept vs auto-deleted, ×count per pet) → Awesome. Then "Welcome back! auto-hatching the Draconic Egg again".
- Side tracks: Mastery (Hatching, Secret Hatching, Clicking, Goldens, Enchanting; Lv 100 each), Golden Crafting machine, Gem Upgrades, Double Jumps, quests, daily, codes, titles.
- Live **boss event:** "THE HALLOW LORD AWAKENS" banner + countdown (2 min warning) → "HAS RISEN / ATTACKS" with health % on Halloween Island.

## Economy & monetization
- Currencies: Clicks (SP/QN huge numbers), Gems (3.10T), Rebirths, event Candy Corn, Tokens (Robux-bought soft currency, packs 200–2,700).
- Shop tabs: Featured (Hatch Bundle 3/6 owned, Secret Hunter, **"SOLD OUT" Robux-only limited pet, 2,000 copies**), **limited Chronos Egg** (1/3/10 eggs, 399 → 3,200 R$), Godly Hatches (×100 luck, 49–299 R$), 10 gamepasses (Octo Hatch, Fast Hatch, Magic Eggs, Lucky, Super Lucky, +pet equip, storage), Creator Code.

## UI/HUD
- **Bottom center:** one giant square **tap button** (blue, galaxy cursor icon) with the per-tap amount above it; left of it a pet/inventory face button with a red count badge, right of it an auto-tap toggle.
- **Bottom left:** stacked counters (Rebirths, Clicks with +/s rate, Gems), big bold numbers with icon.
- **Left middle:** two big labeled buttons (Shop, Trade). **Right:** icon column (rebirth, quests, inventory, crown) that opens **side panels** (Rebirth, Quests, Items, Profile with multipliers list).
- **Top center:** active boosts row (luck %, potions with timers) and event banner with timer. Top right: mini leaderboard (rebirths, eggs, rarest hatch).
- Panels: white cards with thick blue border, chunky outlined title text, red X, green primary buttons, tabs as pills. Cards colored by rarity; variant ribbons (Golden / Diamond / Rainbow) on pet cards.
- **Pets menu:** equipped row on top (5/5), "Other Pets" grid below, each card shows its multiplier (×9m), stack count (×37); Equip Best / Unequip All, delete / mass-select / lock, storage 108/230 with + buttons.
- **Pet Index:** tabs per variant (Normal / Golden / Diamond / Rainbow), one row per egg (egg art on the left, pets with hatch counts), progress bar 6/6 → claim reward (coins + gems), **secret pets as black silhouettes with ???**. "Found 56/99".
- Egg prompt (press E): small card with each pet's icon and %, secrets as silhouettes with "1 in 500,000".

## How each system works
- **Egg:** walk up → E → odds card → buy 1 / auto-hatch (with Octo Hatch pass: 8 at once) → reveal row of eggs that crack and show name + "1 in N" → auto-delete filters drop low pets.
- **Offline hatch:** server stores last-seen time + egg; on join compute `min(hours × rate × 0.25, 10,000)` eggs, roll in bulk, apply auto-delete, keep the rest, show summary.
- **Variants:** Normal → Golden (Golden Crafting machine, combine) → Diamond → Rainbow; same mesh with material/color.
- **Pet levels:** "PET LEVELED UP! Volcanic Devil Lv 56" toast; pets show "Lv 76" and a weight ("Large 50 kg") tag.
- **Double jumps:** bought one by one at a machine (gem cost, last +7 = 100m gems), "Double Jumps: 5/7" counter mid-screen while airborne.
- **Boss event:** timed global event on an island, banner countdown, then a shared health bar.

## Feel
- Constant `+2.32T` popups floating up from the tap point, crit popups with a coin burst, coins flying around the player.
- Rare hatch: giant "$ ×97.73M" sign and floating name tags.
- Big pets fly in a loose ring around the player with glow and particles; names float above in rarity colors ("Volcanic Devil / Mythical / Rainbow").

## Art style
- Hub: bright cartoon (closest preset: "bright cartoon simulator"), saturated green/orange, chunky stylized rocks, low-poly trees.
- Pets: **elemental demon/dragon creatures**: horns, bat/feather wings, crystal shards, glowing eyes, neon edge glow, elemental color variants (fire orange, ice blue, void purple, toxic green). Large (2–4× player).
- Zones: one dominant color + neon accent each (lava orange, void purple).

## What lyopz liked (everything he marked)
| Mark | On screen | Why it works |
|---|---|---|
| 43 | Offline "While you were away" hatch summary grid | Returning feels like a gift; one clear card, big number, one button. |
| 57, 140, 152 | Big glowing winged demon/dragon pets around the player, rarity name tags, giant rare-hatch popup | Strong silhouette (horns + wings + spikes), elemental glow, rich saturated colors, large size; reads as premium and exciting. |
| 93–103 | Pet Index with per-egg rows and ??? silhouettes | Collection goal is visible; silhouettes tease secrets. |
| 173, 272 | Spawn plaza with eggs row, balloons, boss banner "HAS RISEN" | Busy, lively hub; event drama in one banner. |
| 177–184 | Shop: limited egg showcase, godly hatches, passes, tokens | Rich, glossy cards: big art, clear price buttons, "best value" tags, tabs. |
| 196, 202–210 | Trade list, Rebirth / Quests / Items / Profile side panels | Everything one tap away; profile shows all multipliers. |
| 216–234 | Mastery menu: 5 tracks with level rings and reward rows | Long-term goals per activity, rewards shown up front. |
| 242, 244 | Pets menu, Equip Best, team power, rarity-colored cards with variant ribbons | One tap to optimize; power numbers on every card. |
| 257 | Golden Crafting machine | Upgrade sink with a big glowing station. |
| 282, 332, 341, 351 | Gem Upgrades hut with glow pad, Halloween portal, **portal hub terrace** | Portals with themed dressing; you see every future island from spawn. |
| 293, 309–321 | Season Pets podium with countdown, crown-framed in-world leaderboards | Social proof + "come back before it ends". |
| 371–401 | Shadow Realm: dark rock + neon purple cracks, crystal flowers, floating rocks | Moody contrast zone; neon lines guide the eye; one color. |

## Why players stay
- Numbers always go up (huge suffixes, +/s rate visible).
- Offline progress turns logging back in into a reward.
- Collection index with silhouettes + season podium + leaderboards.
- Timed boss events and limited eggs.

## Weak spots (our opportunity — our read, not lyopz's)
- Many panels; some text is small on phone (check with Device Simulator).
- Big pets can hide the player in crowded servers (offer a "hide others' pets" setting).

## Steal the idea, not the content
1. **Offline hatch summary** card on join (cap + ¼ speed, one Reveal button, kept vs auto-deleted grid).
2. **Pet Index** per egg with ??? silhouettes and a claim reward per completed row.
3. **Portal hub terrace** near spawn: every future island visible, each portal dressed in its theme.
4. **One-color neon zone** (dark rock + glowing cracks) as a contrast area after bright zones.
5. **In-world crown leaderboards + Season podium with countdown** on the main path.
6. Big premium elemental pets (horns, wings, crystals, glow) shown off around the player, with a "hide others' pets" setting.
7. **Mastery tracks** per activity (hatch, tap, craft…) with level rings and rewards listed up front.
8. Glossy tabbed shop: one big featured/limited card on top, clear price buttons, "best value" tags.
9. Giant tap button bottom-center with the per-tap number above it; counters bottom-left with a +/s rate.
