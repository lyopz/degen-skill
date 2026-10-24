---
name: roblox-map-builder
description: "Roblox map and level builder. Plans and builds maps, lobbies, zones, obbies and arenas: layout per genre, terrain (Roblox Terrain, or a Unity/Blender heightmap), prop placement, lighting presets, ambient motion and streaming/performance setup. Use for 'build a map / island / lobby / level'."
---

# Roblox Map Builder

Skills: `roblox-design/references/maps.md` (layouts, lighting presets) + `performance.md`, `3d-assets` (scene breakdown, Blender assembly), `roblox-art-style`.

## Steps
1. Layout from the genre pattern (hub → zones, tower obby, arena…), spawn facing the best view, one landmark visible everywhere.
2. Break into pieces: terrain/big shapes (Roblox Terrain, Unity ProBuilder, Blender fallback), detailed props (hand to roblox-modeler specs), repeats (1–3 variants duplicated).
3. Assemble (Unity via unityMCP, or a Luau build script; Blender fallback), scatter with random rotation/scale, snap to ground.
4. Lighting preset from `maps.md` + ambient motion (scripted, client-side).
5. Performance: StreamingEnabled, Box collisions on decor, anchored, shadows off on decorative lights.
- Terrain rules (custom materials, thickness, island recipe, sea-level shelves, LOD-safe hills) and decor scatter: `maps.md` → Terrain / Build style. Check every free Creator Store model for hidden scripts.

## Learn as you go (every job)
- **Before:** read `~/.claude/skills/roblox-dev/lessons.md` (and the lessons section of any skill you use).
- **After:** add 1–3 lines for anything learned — a bug and its fix, a Studio/MCP quirk, a pattern that worked, a number that needed tuning. Reusable code that worked well → propose it as a template for `roblox-templates`.
- Report the lessons you added in your final message so the main session can save them.

## Always
- **Unity first, always (lyopz, 2026-10-24).** For any 3D work (polish, materials, fixes, scale/pivot, scene/prop assembly, previews, export) use Unity (`unityMCP` + `roblox-3d-pipeline` / `unity-mcp` skills). Use Blender only for what Unity can't do (bone rigging + weights, reshaping a mesh) or when lyopz asks for Blender.
- Genre packs: for a pet simulator, also read `~/.claude/skills/roblox-design/references/pets-and-eggs.md` and your section of `~/.claude/skills/roblox-game-study/studies/pet-simulator-99.md` ("takeaways per agent").
- Follow `~/.claude/skills/roblox-design/references/first-try.md`: write the spec first, build one piece and screenshot it, check the "done means" list before reporting done.
- Read `~/.claude/skills/roblox-art-style/SKILL.md` and the game's style bible (`~/RobloxGames/<project>/art-style.md`, local only, never commit game content; never open another project's folder unless lyopz approved it) before making or changing anything visual. No bible → stop and return "needs a style bible" with a 3-question proposal.
- Cheapest route that still looks pristine (Roblox built-ins / Unity / scripts = 0 credits (Blender only as a fallback); Higgsfield only for detailed unique models). **Never spend Higgsfield credits beyond the budget the main session gave you.** No budget given → preflight with `get_cost: true` and return the estimate instead of generating.
- Roblox limits: ≤ 20k triangles per mesh (accessories 4k), textures ≤ 1024, transforms applied, phones first.
- You can't ask lyopz questions. Make the most reasonable choice, write it down, and report it.
- Finish with a short report: what you made, files/paths, credits spent, anything that needs his approval, and what to add to the style bible.

## App + quality rules (2026-10-23)
- Don't ask lyopz questions or for approvals on routine work — execute and report. (Rare must-ask cases only:) Approvals with pictures: save the images in the project folder, then `powershell -NoProfile -File "$env:DEGEN_APP\ask.ps1" -Q "..." -O "Approve|Change something|Redo" -I "<path>|<path>" -From <your name>`; wait for the answer (`APP_CLOSED` → ask the lead). Choices → AskUserQuestion (shows in the app).
- Build it exactly as lyopz describes and as the approved picture shows; his changes become rules in the project's style bible. Models follow `roblox-asset-shapes` (silhouette, layered shapes, bevels — never "a circle on a circle").
- Save tokens: query only what you need, screenshot at checkpoints, pass paths not contents.
- Pictures: ALWAYS made in lyopz's ChatGPT (never Higgsfield) — one asset per picture, pure white background; describe the thing in full detail per `roblox-art-style/references/chatgpt-prompts.md` and run `gpt-image.ps1` — lyopz makes it in ChatGPT, the script brings the image into the project.
- ChatGPT pictures: the path `gpt-image.ps1` prints is the picture to use — the art-director passes it straight to roblox-modeler (in the brief: picture path, project folder, style bible, budget); the modeler builds the 3D asset from it and saves outputs in the same project folder.
- Project folder = the Studio place name (`~/RobloxGames/<place-name>`).
