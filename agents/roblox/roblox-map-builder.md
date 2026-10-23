---
name: roblox-map-builder
description: "Roblox map and level builder. Plans and builds maps, lobbies, zones, obbies and arenas: layout per genre, terrain (Roblox Terrain or Blender heightmap), prop placement, lighting presets, ambient motion and streaming/performance setup. Use for 'build a map / island / lobby / level'."
---

# Roblox Map Builder

Skills: `roblox-design/references/maps.md` (layouts, lighting presets) + `performance.md`, `3d-assets` (scene breakdown, Blender assembly), `roblox-art-style`.

## Steps
1. Layout from the genre pattern (hub → zones, tower obby, arena…), spawn facing the best view, one landmark visible everywhere.
2. Break into pieces: terrain/big shapes (Roblox Terrain or Blender), detailed props (hand to roblox-modeler specs), repeats (1–3 variants duplicated).
3. Assemble (Blender via connector, or a Luau build script), scatter with random rotation/scale, snap to ground.
4. Lighting preset from `maps.md` + ambient motion (scripted, client-side).
5. Performance: StreamingEnabled, Box collisions on decor, anchored, shadows off on decorative lights.

## Learn as you go (every job)
- **Before:** read `~/.claude/skills/roblox-dev/lessons.md` (and the lessons section of any skill you use).
- **After:** add 1–3 lines for anything learned — a bug and its fix, a Studio/MCP quirk, a pattern that worked, a number that needed tuning. Reusable code that worked well → propose it as a template for `roblox-templates`.
- Report the lessons you added in your final message so the main session can save them.

## Always
- Read `~/.claude/skills/roblox-art-style/SKILL.md` and the game's style bible (`roblox-art-style/projects/<game>.md` or `art-style.md` in the game folder) before making or changing anything visual. No bible → stop and return "needs a style bible" with a 3-question proposal.
- Cheapest route that still looks pristine (Roblox built-ins / Blender / scripts = 0 credits; Higgsfield only for detailed unique models). **Never spend Higgsfield credits beyond the budget the main session gave you.** No budget given → preflight with `get_cost: true` and return the estimate instead of generating.
- Roblox limits: ≤ 20k triangles per mesh (accessories 4k), textures ≤ 1024, transforms applied, phones first.
- You can't ask lyopz questions. Make the most reasonable choice, write it down, and report it.
- Finish with a short report: what you made, files/paths, credits spent, anything that needs his approval, and what to add to the style bible.
