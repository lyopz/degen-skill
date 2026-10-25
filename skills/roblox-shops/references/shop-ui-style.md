# Shop UI style (lyopz, 2026-10-25)

<!-- from: lyopz (2026-10-25): 4 shop sheets in shop-ui/ (exclusive crates, exclusive eggs, gamepasses, boosts) + "remove tokens". Default look for every game's shop; build on it. -->

## Frame
- Full-screen panel over a blurred game background. Top-left: big **SHOP** title (chunky bevelled gradient font) with a shopping-bag icon. Top-right: big red **X** close button.
- **Tab row** of chunky icon tabs with labels (Featured · Exclusive Eggs · Exclusive Crates · Gamepasses · Boosts). The active tab is lit up. No currency-pack tab unless the game has a currency to sell.
- Under the tabs: a **header bar** with a big icon, the tab title in the title font, a one-line pitch, and 3–4 small benefit badges on the right (e.g. "Permanent upgrade · Stacks · No cooldowns · Great for all players").

## Cards
- Thick, rounded, glowing cards, each coloured by its theme (fire red, void purple, crystal blue, tech cyan, gold for premium). A big 3D render of the item fills the card. Name in bold caps + a one-line description.
- **Price button** at the bottom: big glossy green (or the theme colour) with the Robux icon + price. Eggs/crates also get a **gift button** next to it.
- Badges: diagonal "LIMITED" ribbon, "10% OFF" tag on multi-buys (1 / 3 at a real discount), "BEST VALUE" ribbon on the best bundle, and a struck-through old price only when it's honest (the real sum of the parts).
- Gamepasses: a grid of square cards (icon, name, effect "+50% luck on all eggs!", price). Bundles go in two wide cards at the bottom with a ✓ list of what's inside and the real total struck through.
- Boosts: grouped into themed sections (Hatch, XP, Fusion, Drop, Jump...), each with 15 min / 1 hour / 3 hours buttons. Longer = better value per minute, and never a higher per-minute price than the shorter one.

## Paid random items (eggs + crates bought with Robux)
- Always show **every rarity and its % odds** on the card or detail view, plus 4–6 example items with rarity tags, and a highlighted "Secret (X% chance)" showcase of the top prize.
- Odds must add up to exactly 100%. Check before shipping (the sheets' examples add up to 100.9% on some cards, so fix the numbers, don't copy them).
- PolicyService `ArePaidRandomItemsRestricted` → hide/disable these for restricted players (`roblox-shops` SKILL.md).
- Exclusive eggs/crates follow the game's rules (e.g. eggs give only bodies) and say so on the header badges.

## Detail view (selected item)
Big render on the left, rarity/odds table in the middle, example items row + top-prize showcase on the right, and the buy + gift buttons under the render.
