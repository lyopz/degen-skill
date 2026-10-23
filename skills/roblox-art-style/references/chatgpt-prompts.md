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
4. **Face:** "two big glossy rounded-square jewel eyes in cyan, dark pupils #1B1530, big white highlight top-left; no mouth."
5. **Surface & markings:** "smooth toy-like soft-touch material, painted soft gradients, glowing cyan rune markings carved into the sides (wave and spiral symbols)."
6. **Colors (hex from the bible):** main / secondary / glow / accent — max 2 glow colors.
7. **Style words:** bible's prompt suffix + "stylized 3D game asset, Pixar-like toy render, clean shapes, high detail on the design parts, simple readable silhouette".
8. **Framing (for 3D later):** "single full-body object, three-quarter front view, whole object visible, centered, pure plain white background (#FFFFFF), nothing else in the image, soft even studio lighting, no text, no watermark, no other objects."
Extra lines when useful: "matching the style of the attached reference" (tell lyopz to attach `reference/target-look.webp` in ChatGPT), "same character as before but …" for edits, "turnaround: front, side, back" for rigging.

## Automation notes (gpt-image.ps1 / gpt-image.mjs)
- Edge with `--remote-debugging-port=9333` + Playwright `connectOverCDP` works (raw PowerShell websockets were unreliable).
- Never force-kill the ChatGPT window (sign-in cookies get lost); close it gently.
- The stop button can stay visible after the image is done: save once the picture is unchanged for ~12 s.
- "Verify you are human" / sign-in: lyopz does it himself; never try to get around it.

## Good / bad
- Bad: "a cool water pet cube". Good: the 8-part description above.
- Name sizes relative to the body ("horns as tall as half the body"), positions ("on top, slightly back"), counts ("3 crystal spikes").
- Say what NOT to add: "no extra limbs, no realistic fur, no background scenery".
- Eggs: shell shape (wider bottom, 1.25× tall), bands (count, metal, gems), top crown, rune symbol, pedestal (stone, rune ring color), glow.
- Props (bush, tree, rock): count of clumps/branches, sizes big/medium/small, base sits flat, 2 shades + highlight (`roblox-asset-shapes`).
