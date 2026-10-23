---
name: customuse-design
description: Makes Roblox designs with lyopz's Customuse account (concepts, 3D meshes, textures, layered/classic clothing, thumbnails, direct Roblox upload) and learns his taste. Every design gets a like/dislike rating with a reason, saved to a log, and the patterns go into a taste file that every future design (Customuse or ChatGPT) must follow. Use when lyopz says "use Customuse", asks for clothing, a thumbnail, or a 3D asset via Customuse, rates a design ("I like/hate this", "too dark", "love the eyes"), or asks what he likes.
---

<!-- from: lyopz (2026-10-23). Customuse MCP announced by Customuse ("concept, mesh, textures, all wired"). -->

# Customuse designs + taste memory

Two jobs: **make the design in Customuse**, and **learn from what lyopz thinks of it**.

## Files
- `references/taste.md` — lyopz's taste, all games (likes, dislikes, rules). **Read before every design.** General lines only: no game names, pet names or game details (it is pushed to GitHub).
- `~/RobloxGames/<project>/designs/feedback.jsonl` — one line per rated design (written by `design-feedback.ps1`).
- `~/RobloxGames/.degen/taste-log.jsonl` — same lines, all projects.
- The project's style bible (`~/RobloxGames/<project>/art-style.md`, local only) — game-specific rules go in its **Learned rules**.

- `styles/<name>/` (repo root) — whole looks lyopz liked and named in the app's **Save for later** tab, with the prompts used. Use the one the brief names; otherwise use them as examples of prompts that worked.

## Making a design
1. **Load taste:** `references/taste.md` + the project's style bible. Every "Never" is a hard rule; every "Likes" goes into the prompt if it fits.
2. **Write the prompt** the same way as ChatGPT pictures (`roblox-art-style/references/chatgpt-prompts.md`: one asset, full detail, white background) and add the matching taste lines. Write which taste lines you used in one line of the report.
3. **Make it in Customuse:**
   - **Customuse MCP tools present** (names start with `mcp__customuse`): use them. Concept → mesh → texture, or clothing / thumbnail. Pass approved anchor pictures as references. Check the credit cost first if a tool shows one; follow the Lead's credit rules.
   - **No MCP tools:** tell lyopz in one line to connect it (README of this skill, "Connect"), and fall back to the ChatGPT route (`gpt-image.ps1`) so work doesn't stop.
4. **Save** the result into `~/RobloxGames/<project>/customuse/<name>.<ext>` (picture or a render of the 3D model). The rating card needs a picture.
5. **Rate it:** run
   `powershell -NoProfile -File "$env:DEGEN_APP\design-feedback.ps1" -Project <project> -Name <name> -Image "<picture path>" -Tool customuse -Prompt "<prompt used>" -From <agent>`
   It shows the picture in the Degen app with **Love it / Like it / Change something / Don't like it** and logs the answer. Prints the answer (or `APP_CLOSED` → ask in the terminal, then run it again with `-Answer "<his words>"` to log it).
6. **Act on the answer:**
   - Love it / Like it → it's an anchor: add it to the style bible's Anchors, hand to the modeler / upload.
   - Change something / Don't like it → fix exactly what he said (edit, don't restart, unless he says "redo") and rate again.
7. **Learn** (every time, takes 1 minute): turn his words into short rules and add them to `references/taste.md`:
   - What he praised → **Likes** ("thick soft bevels on cube pets").
   - What he disliked → **Dislikes** ("eyes too small", "muddy dark colors").
   - Same point 2+ times, or he says "always/never" → promote to **Rules** (hard). Game-only points go to that game's style bible instead.
   - Keep the date + design name next to each line. Merge duplicates; if a new rating contradicts an old line, keep the newest and delete the old one.
   - Commit + push `~/.claude/degen-skill` with the other end-of-task commits (taste.md only; the bible and feedback logs stay local).

## Also for ChatGPT pictures and Blender models
The taste file is for **every** design, not only Customuse. Any agent showing lyopz a design can use `design-feedback.ps1 -Tool chatgpt` (or `blender`) so the log covers all of it.

## Picture → low-poly 3D (the default model route)
1. ChatGPT makes the picture (`gpt-image.ps1`, one asset, white background).
2. Customuse turns it into a **low-poly, textured** model: image-to-3D, pets ~1.5–3k tris, props ≤ 5k, export **.glb**.
   - MCP tools loaded → use them (upload the picture, image-to-3D, low poly, texture, export).
   - Not loaded → `powershell -NoProfile -File "$env:DEGEN_APP\customuse-3d.ps1" -Project <project> -Name <thing> -Image "<picture>" -From <agent>`: the picture is copied to the clipboard, Customuse opens, a card in the app shows the steps, and the exported .glb is picked up from Downloads into `~/RobloxGames/<project>/customuse/`.
3. Import the .glb into Studio (scale to the bible's studs, origin at base). Blender only for small fixes.
4. Rate it (`design-feedback.ps1`) and learn (step 7 above).

## Also good in Customuse
- Roblox **layered clothing** and **classic clothing**, **thumbnails** and icons, **direct upload** to Roblox.

## Connect (once, on the PC)
See `references/connect.md`.
