# ChatGPT picture prompts (free route, lyopz's ChatGPT)

lyopz makes great pictures in ChatGPT. The ONLY picture route (always — never Higgsfield for pictures): the agent writes a **detailed** prompt → `gpt-image.ps1` shows it in the app (Copy + Open ChatGPT) → lyopz saves the image to Downloads → the script copies it into the project and prints the path → continue (approve → 3D → Blender → Studio).

```powershell
powershell -NoProfile -File "$env:DEGEN_APP\gpt-image.ps1" -Project <project> -Name <thing>-concept -From <agent> -Prompt "<prompt>"
```
**One asset per picture, white background, every time.** Several assets → several calls, one after another. No approval step — hand the picture to the modeler.

## How to describe it (always all 8 parts, plain words, 120–250 words)
1. **What + purpose:** "A single collectible pet for a Roblox pet simulator game: a Kappa (Japanese water spirit)."
2. **Body shape & proportions:** exact form from the style bible + lyopz's words ("soft rounded cube body, ~25% bevel, slightly squished, head merged into the body, 1:1:1").
3. **Identity features (4–6), each with shape, size, position, material, color:** "a teal-blue turtle shell on its back made of hexagon plates with lighter cyan edges; a cream water-dish ring on top of the head, filled with glowing cyan swirling water; a short yellow duck beak at the front; leafy blue hair fringe around the dish; webbed yellow feet, two tiny nubs."
4. **Face:** pets use the eye line from `pet-eyes.md` (glowing animated eyes, no outlines, front face, upper half). Pets always get the sketchy grin from `pet-mouths.md` (base line + rarity tier line).
5. **Surface & markings:** "smooth toy-like soft-touch material, painted soft gradients, glowing cyan rune markings carved into the sides (wave and spiral symbols)."
6. **Colors (hex from the bible):** main / secondary / glow / accent — max 2 glow colors.
7. **Style words:** bible's prompt suffix + "stylized 3D game asset, Pixar-like toy render, clean shapes, high detail on the design parts, simple readable silhouette".
8. **Framing (for 3D later):** "single full-body object, three-quarter front view, whole object visible, centered, pure plain white background (#FFFFFF), nothing else in the image, soft even studio lighting, no text, no watermark, no other objects."
Extra lines when useful: "matching the style of the attached reference" (tell lyopz to attach `reference/target-look.webp` in ChatGPT), "turnaround: front, side, back" for rigging.
**Every prompt stands alone (lyopz, 2026-10-28):** never "previous picture / same as before / the set / the family"; paste STYLE + FRAME in full and describe the whole object every time. Edits of one picture go through `-Ref` ("keep everything, only change 1) 2) 3)").

## Premium polished pets (default for pets, lyopz 2026-10-23)
lyopz wants pets that look polished and premium, **not cartoonish**. What the top Roblox pet games do for their best (legendary / huge) pets:
- **Sleek, confident silhouette** instead of a round blob: a clear head, chest, and pose; one strong shape idea you can read from far away.
- **Sharp glowing animated eyes, no outlines** (almond, slanted, slit), front face only, upper half, never huge googly eyes. Style + size by rarity: `pet-eyes.md`.
- **Mouth = the sketchy grin (lyopz 2026-10-24, every pet):** wide hand-drawn grin, chunky uneven white teeth, black ink crosshatch shading; rarer = more dramatic. Never a round open cartoon mouth or a smooth coloured-outline mouth. Tier lines: `pet-mouths.md`.
- **Back + top accessories** (wings, back pieces, auras): upper-back hub, top aura space, never on the face. `pet-accessories.md`.
- **Separate materials**: matte soft body + glossy armor/shell + polished metal trim (gold, silver) + glowing crystal or rune parts. Material contrast is what makes it look expensive.
- **Clean hard edges with small bevels** that catch a thin highlight. Crisp panel lines and trim, not fuzzy or noisy detail.
- **Limited palette**: 1 main color, 1 dark secondary, 1 metal, 1 glow color. Darker values and richer colors, not pastel candy.
- **Rim light + soft studio light** so the edges glow and the form reads. Emissive parts glow a little, not blown out.
- **Big detail only where it counts** (head piece, wings, tail tip, chest gem); the rest stays simple so Customuse can build it low-poly.

Add these lines to part 7 (style words) for every pet:
"premium collectible game pet, polished stylized 3D, not cartoonish, sleek confident silhouette, small sharp gem eyes, matte body with glossy armor plates and polished gold trim, glowing crystal accents, crisp beveled edges catching thin highlights, rich deep colors, rim lighting, high-end mobile game hero asset, clean low-poly-friendly shapes, no fur strands, no noisy detail"

Template (fill the <...>; still one pet, white background):
"A single premium collectible pet for a Roblox pet game: <creature>. Sleek, confident stylized body in a proud standing pose, <body shape and proportions>, head about one third of the body. Identity features: <3 to 5 features, each with shape, size, position, material, color>. Face: <eye line from pet-eyes.md for this rarity, in <eye color>>, no big cartoon eyes. <mouth base line + rarity tier line from pet-mouths.md>. Materials: soft matte <main color> body, glossy <secondary color> armor plates with crisp beveled edges, polished gold trim lines, glowing <glow color> crystal accents and thin rune lines. Colors: <hex list, max 4>. Style: premium collectible game pet, polished stylized 3D, not cartoonish, high-end mobile game hero asset, clean low-poly-friendly shapes, rim lighting, soft studio light, rich deep colors, no fur strands, no noisy detail. Single full-body object, three-quarter front view, whole pet visible and centered, pure plain white background (#FFFFFF), nothing else in the image, no text, no watermark, no shadow scenery."

## Automation notes (gpt-image.ps1 / gpt-image.mjs)
- Edge with `--remote-debugging-port=9333` + Playwright `connectOverCDP` works (raw PowerShell websockets were unreliable).
- Never force-kill the ChatGPT window (sign-in cookies get lost); close it gently.
- The stop button can stay visible after the image is done: save once the picture is unchanged for ~12 s.
- "Verify you are human" / sign-in: lyopz does it himself; never try to get around it.
- Same STYLE/FRAME text on every prompt = a matching set without -Ref. Create output dirs in the queue script itself. Checking results: "Running gpt-image" below.
- A -Ref edit keeps camera angle and proportions — put view + proportions in the FIRST prompt. Dark/glowing subjects ignore "white background" → make "Pure plain white background, no dark backdrop." the FIRST sentence (white in the FRAME block alone isn't enough), else a -Ref edit; flatten any transparent PNG onto white.
- Metal/scrap subjects: add "smooth clean painted surfaces (no rust, grunge or scratch textures)". Symmetric pairs: "show the pair as one object, spread from an empty middle gap".
- Neon signs: "flat front view, dark navy board + gunmetal frame with bolts, chunky rounded neon tubes, glow tight around the tubes, max 2 neon colors, text spelled exactly as written, no wall/poles/shadow, white bg" (10/10 first try); cut out with `cutout-white.ps1 -KeepAspect -Size 1024`. Top rarity: "most insane design but still clean and readable; holo rainbow-shift glow only on small accents".

- **(promoted 2026-10-28)** Ears: "two upright cupped ear shells, rim, recessed panel" (else antennas/horns). Check `im.mode` before a white cut-out (some results are already RGBA; re-cutting eats highlights — just trim + square-pad those). Fill enclosed holes from the border with PIL `ImageDraw.floodfill` (no scipy).

## Running gpt-image (2026-11-03)
- **One run at a time across ALL agents.** The window is shared and the script takes the newest image, so overlapping runs swap pictures, return a copy of the previous one (also on -Ref fixes and a session's first run) or another agent's picture (unique MD5, the hash check misses it). Before a run check no other `gpt-image.ps1`/`.mjs` process is alive (exclude your own `$PID`). After it, open the file by eye AND md5/size-check it against the folder; never copy over a target before that; rerun only the missing names.
- **Calling it.** Prompt files via the Write tool (heredocs break on quotes), LF endings (a CRLF order file sent an empty prompt; refuse empty prompts). Quotes/newlines break `powershell -File ... -Prompt` (spills into -Minutes): use `node .app/roblox-app/gpt-image.mjs <promptFile> <out>`, or `"`→`'` and newlines → spaces. `-Project` is relative to the game folder. Start runs with run_in_background (a shell `&` dies), stderr to a log, never `| tail`. Queues: `_order.txt`, skip files already present, resume from the first missing name. `-Ref` takes one file: montage several refs into one PNG.
- **Stalls.** One short picture before a long queue (signed-out fails only after the full timeout). "message box not found" in ~60 s is often a loading CDP page or a Cloudflare check: poll `curl -s 127.0.0.1:9333/json/list` until the title is "ChatGPT". "Watch Downloads", or busy=false with no new picture for 10+ min = stalled: stop and resend (`-Minutes 5`, smaller ref ~1600×900). For a batch of fixes, re-render from corrected text instead of chained -Ref edits.

## Prompt craft (2026-11-03)
- **Ban what ChatGPT adds, by name, up front:** faces/eyes on anything called ghost/phantom/soul; faces or emblems on egg/chest fronts; teeth whenever "teeth" appears ("ink grin line, no teeth"); domes, pipes and corner caps on machinery in a box ("flush, nothing above the top"); rarity-reserved colours. Name misread shapes with a NOT ("clearly a CUBE, six flat faces, never a ball"). Say which face is the front and record it for the modeler. A ban list alone gives a sparse smooth object: add new density ("thick overlapping slabs with visible side thickness, deep shadow gaps" + a new small repeat detail).
- Glow: "the hue glows ONLY as thin outline lines tracing the rims and seams" (metal-heavy: "clearly brighter than the brass"). Cel fire: "three flat colour bands, crisp edges, a 1.3× black-brown shadow flame behind each tongue".
- Sets: one fixed family-mark sentence in every prompt lands on every picture. Look-alikes: each its own hue + main material + silhouette tell + "must look completely different". Lineup sheets (two rows, a numbered line per item with the exact label; or LEFT/MIDDLE/RIGHT) show a whole ladder in one approval; "TRANSPARENT background (PNG with alpha)" gives real alpha. Cut finals from an approved sheet for free (border-connected matte, or largest component per crop).
- Scenes and rooms: state the sky and the layout per piece and they work first try, but ChatGPT blows hero props up (~3×), flattens heights, lines things up and draws island tops as perfect circles: put real numbers in the build brief and ship an exact-scale plan image beside the painting. Ask for a named action per creature, not pads.
- UI mockups: name every region in order with hex + font, end with "only the names, numbers and labels listed"; give the currency per price.
- **(2026-11-03) Sets, sheets, UI pictures:**
  - Sets: one shared STYLE (+ SKY) block appended to every prompt (450–550 words is fine for set prompts). "Same layout so they read as a set" gives recolours → name a different outline per item (a CAPS primary shape + a closing "Silhouette: ..." line), its own element, motion and main colour, share only kit pieces, ban the existing set's elements. Colour-coded sheets drift neighbouring hues → exact hexes in the build table. Name glyph shapes (a bag medallion read as a padlock).
  - Numbered 4×2 white-background sheets ("shared base + ONE theme + its own door shape") gave 8 distinct buildings first try; sheet 2 says "the exact same base as sheet 1 (...)" with sheet 1 attached, or the base drifts.
  - Fix lineups with -Ref "keep everything exactly, change/ADD ONLY 1–3 named things" instead of re-rolling; add small flat marks with PIL (abstract, never a real letter/kanji). A -Ref swapping many props into a scene packs them wall to wall → ask for gaps, plazas, slot width; per-item sheets, not the hero shot, are the design source.
  - UI/card pictures: allow only the named words + "no title banner, no game name"; list the current currency icons by name in every UI-bearing prompt (it paints removed ones); per-picture refs via an order file `name|ref-montage` (approved lineup + a scene shot matched colours first try).
  - Object lines: leaderboard "solid stone monument with a flat reading face, not a door, no portal"; houses "no clocks / gauges with dials"; doors sized in players + "brass only on trims"; crests cut in their own outline, never in a shield frame.
## Good / bad
- Bad: "a cool water pet cube". Good: the 8-part description above.
- Name sizes relative to the body ("horns as tall as half the body"), positions ("on top, slightly back"), counts ("3 crystal spikes").
- Say what NOT to add: "no extra limbs, no realistic fur, no background scenery".
- Eggs: shell shape (wider bottom, 1.25× tall), bands (count, metal, gems), top crown, rune symbol, pedestal (stone, rune ring color), glow.
- Props (bush, tree, rock): count of clumps/branches, sizes big/medium/small, base sits flat, 2 shades + highlight (`roblox-asset-shapes`).

## UI icons and transparent cut-outs
- UI icon prompt that worked (consistent set of 11): "A single game UI icon for a futuristic cartoon Roblox pet game … glossy bold 3D game icon, chunky rounded shapes, thick dark navy outline, soft gradients, polished plastic and metal, small glowing cyan and violet neon accents, subtle rim light, gold trim only where noted, premium mobile game icon quality, readable at 48 pixels, one clear silhouette, slight three-quarter tilt" + "Subject: …" + framing "only the icon object, centered, ~80% of frame, no background panel, no button frame, no text, pure white background". Same style text for every icon = matching set without -Ref.
- Cut out the white background (no PIL needed): `powershell -NoProfile -File skills/roblox-art-style/scripts/cutout-white.ps1 -In <png> -Out <png> -Size 512` (border flood fill over near-white, soft edge, trim + square pad). Enclosed white areas stay (flood starts at the borders). Check on a dark background before uploading.

- **Locked base body:** if the game has a locked pet base body in its style bible, every pet uses it at the same size and shape. Never change body size or shape unless lyopz says so; species differ by color, markings and parts only. (lyopz 2026-10-24)
- **(promoted 2026-10-25)** Bare body picture: list every slot to leave out ("no wings, horns, ears, tail, armor or accessories of any kind") + "real recesses with visible depth (never painted on)"; skip -Ref to an accessorised anchor. Sets: reuse the approved base prompt per slot and change only the style lines. ChatGPT overdoes "barely visible" details — note the drift for the modeler instead of spending a redo unless a hard rule breaks. Quote sign/label text with single quotes (double quotes break nested `powershell -File`).

- **(2026-11-05) Effects:** ChatGPT draws effect pieces ~2× the asked size and restyles the pet — write the real sizes in SPEC.md and build from the spec, not the picture. Ask for "SOLID stars, NOT outlines, NOT sunbursts" or you get line art. Run `gpt-image.ps1` in the foreground with `-Minutes 6` and stop on "Automatic save did not finish" (background runs can stall into the 30-min Downloads fallback).
