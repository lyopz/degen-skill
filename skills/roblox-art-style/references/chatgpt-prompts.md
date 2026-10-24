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
4. **Face:** pets use the eye line from `pet-eyes.md` (style by rarity, recessed sockets, front face, upper half). Pets always get the sketchy grin from `pet-mouths.md` (base line + rarity tier line).
5. **Surface & markings:** "smooth toy-like soft-touch material, painted soft gradients, glowing cyan rune markings carved into the sides (wave and spiral symbols)."
6. **Colors (hex from the bible):** main / secondary / glow / accent — max 2 glow colors.
7. **Style words:** bible's prompt suffix + "stylized 3D game asset, Pixar-like toy render, clean shapes, high detail on the design parts, simple readable silhouette".
8. **Framing (for 3D later):** "single full-body object, three-quarter front view, whole object visible, centered, pure plain white background (#FFFFFF), nothing else in the image, soft even studio lighting, no text, no watermark, no other objects."
Extra lines when useful: "matching the style of the attached reference" (tell lyopz to attach `reference/target-look.webp` in ChatGPT), "same character as before but …" for edits, "turnaround: front, side, back" for rigging.

## Premium polished pets (default for pets, lyopz 2026-10-23)
lyopz wants pets that look polished and premium, **not cartoonish**. What the top Roblox pet games do for their best (legendary / huge) pets:
- **Sleek, confident silhouette** instead of a round blob: a clear head, chest, and pose; one strong shape idea you can read from far away.
- **Sharp eyes in recessed sockets** (almond, slanted, slit or gem-like with a glint), front face only, upper half, never huge googly eyes. Style + size by rarity: `pet-eyes.md`.
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
- Hash-check every result against the project (stop on a duplicate; < 25 s is suspicious) — once the reference came back as the "result". One-at-a-time queue + same STYLE/FRAME text on every prompt = a matching set without -Ref. Create output dirs in the queue script itself.
- A -Ref edit keeps camera angle and proportions — put view + proportions in the FIRST prompt. Dark/glowing subjects ignore "white background" → fix with a -Ref edit, flatten any transparent PNG onto white.
- Metal/scrap subjects: add "smooth clean painted surfaces (no rust, grunge or scratch textures)". Symmetric pairs: "show the pair as one object, spread from an empty middle gap".
- Neon signs: "flat front view, dark navy board + gunmetal frame with bolts, chunky rounded neon tubes, glow tight around the tubes, max 2 neon colors, text spelled exactly as written, no wall/poles/shadow, white bg" (10/10 first try); cut out with `cutout-white.ps1 -KeepAspect -Size 1024`. Top rarity: "most insane design but still clean and readable; holo rainbow-shift glow only on small accents".

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
