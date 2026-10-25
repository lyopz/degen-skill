# Trading, player marketplace and soft-currency economy (lyopz, 2026-10-25)

<!-- from: lyopz (2026-10-25): wants a token currency, a player marketplace (only player listings, never random/system ones) and 1-on-1 trades, with a real economy. General rules for any game. -->

## Marketplace (player listings only)
- Only items players list. No bot, system or random listings.
- Listing = item moves into escrow right away (out of the inventory). Sold, cancelled or expired → paid out or returned. Offline sellers get a pending payout on their next join.
- Cross-server: listings in MemoryStore (sorted maps by category/price) + DataStore backup; buying claims the listing atomically (UpdateAsync, one winner), then debits/credits in one save.
- Browse UI: category + rarity filters, search, sort, item preview (stats, variant), Buy Now, my listings, purchase + price history, recently sold, average price per variant.
- Price band per item (≈0.25×–5× recent average) against laundering and scams; listing fee + sales tax as a currency sink.

## 1-on-1 trades
Request → both add items/currency → both Ready → countdown (any change resets it) → both Confirm → server swaps. Show both sides' market value and warn on lopsided trades (players are mostly kids).

## Anti-dupe (must have)
Server owns every inventory and balance; the client only sends intents. Every item has a GUID and lives in exactly one place (inventory / escrow / trade). Session-locked player data, save after every trade, log every move. Account-age + playtime gate and cooldowns for trading. Currency can never be traded for Robux or anything off-platform.

## Economy (sources vs sinks)
- Sources: island drops (main), chests, daily quests/check-in, capped PvP rewards, Robux packs. Trading moves currency, never creates it.
- Sinks: hatching (main, priced per island), crates, fusing/variant rolls, upgrades, rebirth, daily deals, marketplace fee + tax, rerolls.
- Sinks take a bit more than free sources at every stage. Log every source/sink with `AnalyticsService:LogEconomyEvent`, watch circulation and average prices weekly, tune.
- Robux packs save time (≈15–45 min of play per smallest pack) but don't break the market.
