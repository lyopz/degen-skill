---
name: roblox-shops
description: lyopz's Roblox monetization and shop playbook — what players spend real money (Robux) on, shop layouts and designs that convert, game pass / developer product / subscription ideas per genre, pricing ladders, starter packs, where buy buttons go, how top games get people to buy, and the Roblox rules (paid random items, PolicyService, honest discounts, no pushy wording for kids). Grows from games lyopz approves us to study. Use when building or reviewing any Roblox shop, store UI, game pass, developer product, premium currency, VIP, starter pack, battle pass, or when lyopz asks "what can people buy", "how do I make money", "make the shop better".
---

<!-- from: lyopz (own research, 2026-10-23). Living document: add every game study to studies/ and fold the patterns into this file. -->

# Roblox Shops & Monetization

**Goal:** players buy because the item is fun and fair, not because they were tricked. Roblox down-ranks and players downvote predatory games, and most players are kids — so pushy = bad for money too.

## 1. What people actually spend on (by genre)
| Genre | Best sellers | Notes |
|---|---|---|
| Pet sim / collector | Egg luck (2x / 3x / Super luck), auto-hatch, triple/octuple hatch, extra pet slots, extra storage, Huge/exclusive pets (via exclusive eggs), auto-farm, teleport, VIP zone | Luck + speed of collecting = core value. Paid eggs = **paid random item → PolicyService + show odds** |
| Simulator / clicker | 2x currency, auto-click/auto-collect, speed boost, rebirth boost, currency packs | Multipliers stack; show the "before → after" number |
| Tycoon | 2x cash, auto-collect, VIP droppers, fast build, exclusive upgrades | Sell time savings |
| Obby | Skip stage (dev product), checkpoints, speed/gravity coil, trails, revive | Skips are the #1 seller; price low, repeatable |
| Fighting / PvP | Cosmetic skins, emotes, kill effects, ability slots, XP boost, battle pass | Never sell raw power that ruins PvP fairness; sell style + speed of unlocking |
| Brainrot / meme | Exclusive characters, luck, boosts, limited drops | Limited items work only if the limit is real |
| Horror / story | Revives, cosmetics, chapter early access | Small, impulse-priced |
| RP / town | Houses, cars, VIP areas, cosmetics, private servers | Status + self-expression |

Universal winners: **VIP pass** (perks bundle), **2x currency**, **auto-features**, **cosmetics (trails, auras, pet skins, titles)**, **private servers**, **starter pack**, **subscriptions/battle pass** for longer-term players.

## 2. Product types (Roblox)
- **Game pass** — one-time, permanent (VIP, 2x, auto-hatch, extra slots). Most revenue is usually here early.
- **Developer product** — repeatable (currency packs, skips, boosts, revives, eggs). Use `PurchaseHandler` template (`roblox-templates`) — grant on `ProcessReceipt`, save, return `PurchaseGranted` only after saving.
- **Subscription** — monthly perks (daily gems, VIP+). Must give ongoing value.
- **Private servers**, **Paid access**, **Immersive ads**, **UGC/catalog commissions**.
- Price optimization / managed pricing (regional) — opt in once in Creator Hub.

## 3. Pricing ladder (starting points — test with price optimization)
- Impulse: 25–99 R$ (skips, small boosts, revives)
- Core passes: 99–399 R$ (2x coins, auto-collect, +slots, luck)
- Premium passes: 499–1,499 R$ (VIP bundle, Super luck, exclusive pet)
- Currency packs (dev products): 5–7 tiers, each tier gives **more per Robux** (e.g. +10%, +20%, +35%, +50%, +75%, +100%); label the best value and most popular honestly.
- Starter pack: one-time, big real value (~3–5x normal value), shown after the first few minutes of fun — **never on first spawn**.

## 4. Shop layout & design (what converts)
- **Open button** on the left menu stack (and a world shop building near spawn). Big, icon + label, notification dot when something new.
- **Panel:** centered, 70–80% height on phone, close button top-right (big), tabs across the top: **Featured · Passes · Currency · Boosts · Cosmetics**. Remember the last tab.
- **Featured hero card** on top: one item, big render, short benefit line, price button. Rotates; never fake timers.
- **Cards:** 2 columns phone / 3–4 PC. Each: icon at 2x res with rarity glow, name, ONE benefit line with a number ("2x coins forever"), price button with Robux icon. Owned → "Owned ✓" greyed, sorted last.
- **Value badges:** "Best value", "Most popular" — only if true.
- **Before → after:** for boosts show the player's own numbers ("120/s → 240/s").
- **Try-before-buy:** preview cosmetics on the player / pet in a 3D viewport (ViewportFrame) with rotate.
- **Contextual prompts** (best converting, still fair): out of storage → "+50 slots" card; failed rare hatch → luck pass card once per session; obby fail 3x on a stage → skip offer. One soft prompt, easy to close, not repeated every minute.
- **Juice:** cards hover-grow 1.05 + glow, press squash, purchase = confetti + sound + item flies to inventory (`ButtonFeel`, `VFX` templates; `roblox-design/references/ui.md`).
- **Social proof:** server-wide "X just hatched a Huge!" / owners' VIP tag and trail — makes passes visible to others.
- **Gifting:** let players buy passes/products for friends (more sales, wholesome).
- **Free path visible:** show what can be earned free (daily rewards, codes, quests) in the same shop — keeps it fair and keeps players around long enough to buy.

## 5. Rules (Roblox policy — always)
- **Paid random items** (eggs/crates bought with Robux or with currency bought with Robux): show odds clearly; check `PolicyService:GetPolicyInfoForPlayerAsync` → `ArePaidRandomItemsRestricted` and hide/disable for those players.
- Also check PolicyService for trading, subscriptions, ads as needed.
- Discounts must be real; no countdowns that reset; no "permanent sale".
- Calm wording: "Open Shop", "Get 2x Coins" — not "BUY NOW BEFORE IT'S GONE!!!".
- Don't lock basic fun behind paywalls or add timers whose only job is to sell skips.
- Record every purchase yourself (DataStore) and make grants idempotent (receipt id).

## 6. Shop build checklist
1. List products (type, price, benefit with a number, icon) in a config module.
2. Server: `PurchaseHandler` + pass checks (`UserOwnsGamePassAsync` cached + `PromptGamePassPurchaseFinished`), grants saved.
3. UI per section 4, phone first; test on phone emulator.
4. PolicyService gates for paid random items.
5. Contextual prompts (max 1 per trigger per session).
6. Analytics: log shop opens, card views, purchases (Roblox Analytics custom events) to see what works.

## 7. Learning loop (grows over time)
- When lyopz approves a game to study (`roblox-playtest` walk-through, `roblox-game-strip` video/file): write `studies/<game>.md` with: shop entry points, tabs, every product + price, how/when it's prompted, layout screenshot notes, what felt fair vs pushy, ideas to borrow (ideas only, never copied assets).
- Fold repeated patterns into sections 1–4 here and date them. Keep sources.

## Sources (researched 2026-10-23)
- Roblox docs — Monetization overview (methods, paid random items, PolicyService, honest discounts, wording for minors): https://create.roblox.com/docs/production/monetization
- Roblox Shop GUI devlog (customizable pass store, icons/descriptions): https://kwstudioorg.itch.io/roblox-shop-gui-custom-gamepass-store-monetization-system/devlog/1088891/roblox-shop-gui-a-sleek-system-for-selling-gamepasses
- Monetization shop kits (tab/card layouts reference): https://builtbybit.com/resources/plug-play-roblox-monetization-shop.106712/
- Studies: `studies/` (Pet Simulator 99 notes also in `roblox-game-study/studies/pet-simulator-99.md`)
