---
name: roblox-publishing-discovery
description: Prepare Roblox games for publishing and discovery. Use for icon, thumbnail, name, description, store copy, launch positioning, genre fit, CTR improvement, first impression review, and pre-launch page readiness.
---

# Roblox Publishing Discovery

## Goal

Get the right players to click and understand the game promise immediately.

## Discovery Surface

Review:

- Game name: searchable, memorable, genre-clear.
- Icon: readable at small size, high contrast, clear subject.
- Thumbnail: shows real gameplay fantasy, not vague atmosphere.
- Description: first lines explain what players do and why to return.
- Update notes: make fresh content visible.
- Age and platform expectations.

## Platform changes (dated, with source)
- **2026-10-22 test — new Home layout on PC/console/tablet:** game details open in a narrow right-side pane instead of full screen (ranking and ads unchanged). Check that the icon, the first thumbnail and the first description lines still read in that narrow pane. https://devforum.roblox.com/t/test-new-home-layout-with-more-built-in-utility/4950387
- **2026-10-23:** a Sponsored ad and a Recommended For You tile for the same game can both show on Home (spaced apart), so read ad vs organic numbers with that in mind; created games now show on the creator's main web profile page. https://devforum.roblox.com/t/weekly-recap-october-19%E2%80%9323-2026/4953263
- Homepage recommendations need a custom 16:9 thumbnail (see `roblox-dev` §8).

## Positioning

- State the player fantasy plainly.
- Match genre conventions without becoming generic.
- Make the first 30 seconds align with the promise in the icon and thumbnail.
- Avoid misleading monetization or overpromising features.

## Launch Checklist

- Core loop works and is fun quickly.
- Mobile UI is readable.
- No console errors in smoke test.
- Data save/load works.
- Purchases and grants are server-authoritative.
- First live update or event is already planned.

## Output

Return:

- Name options.
- Icon/thumbnail direction.
- Store copy.
- Discovery risks.
- Pre-publish fixes ranked by click-through and retention impact.

## Next

Drive traffic to the finished page with `roblox-growth-marketing`, and gate the launch on `roblox-release-operations`.

