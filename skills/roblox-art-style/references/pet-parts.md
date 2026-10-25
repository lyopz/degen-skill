# Modular cube pets: parts, zones, animations (lyopz, 2026-10-25)

<!-- from: lyopz (2026-10-25): parts catalog, body, tail and animation sheets; "the assets given as examples will be the only assets in the game, no feet accessories yet". -->

A pet = one **base body** + one item per slot. Every game keeps its own item list in `~/RobloxGames/<game>/pet-catalog.md` (local, never in the repo). **Only the items in that file exist in the game.** Don't invent items. The style lists in `pet-mouths.md`, `pet-eyes.md` and `pet-accessories.md` are ideas for upgrades and new designs, used only when lyopz asks for new ones.

## Slots (choose 1 each)
Base body · Eyes · Mouth · Horns · Ears · Wings · Back accessory · Tail · Aura (coming: lyopz is sending aura sheets, so don't make aura items before they arrive).
**No feet slot.** The 4 stubby feet are part of the body.

## Zones
| Zone | Holds |
|---|---|
| Front, upper | eyes (recessed sockets, `pet-eyes.md`) |
| Front, lower | mouth (`pet-mouths.md`); may curve round the front corners |
| Top | horns and ears (near the top front corners); aura space floats above |
| Back, upper | wings + back accessory (hub, `pet-accessories.md`) |
| Back end, lower centre | tail. Same attach point for every tail. No part of the tail shows on the sides or front except when it swings. |
| Sides | nothing mounted |

Base body: same rounded cube and size for every body, with corner bolts and 4 stubby feet. Bodies differ by theme and detail only (cracks and leaks, crystal growths, tech panels, code, galaxy). Face area stays clear on every body. Every body is animated (idle + its signature effect).

Rarity colours: Common grey, Uncommon green, Rare blue, Epic purple, Legendary gold, Mythic pink/magenta, Secret red.

## Animations (smooth, looping, work with every combination)
| Part | Animations |
|---|---|
| Whole pet | idle (float + bob) · walk (float forward) · turn (smooth rotate) · jump (squash + stretch) · land (soft bounce) · attack (burst effect) · skill (big effect) |
| Body | idle · pulse · signature (code flow, sparkle, shine wave, prism, scan) · intensify |
| Eyes | idle (subtle glow) · blink · look around · happy (brighter) · angry (intensify) · skill (pulse + effect) |
| Mouth | idle (subtle movement) · talk/bob (open + close) · happy (wide smile) · angry (snarl) · skill (glow + effect) |
| Horns | idle (glow) · pulse (light wave) · spin (rotating parts) · skill (energy burst) |
| Ears | idle · twitch (quick flick) · spin/float · skill (ring pulse) |
| Wings | idle (gentle flap) · walk (slow flap) · run (faster flap) · attack (wide spread) · skill (full effect) |
| Back accessory | idle (float/rotate) · pulse · charge (build-up) · skill (big effect) |
| Tail | idle (hang/drift) · walk (sway) · run (bigger swing) · turn (follow body) · attack (whip/slash/burst) · skill (full effect) |

Each part's script exposes the same calls (`Idle`, `Walk`, `Run`, `Turn`, `Attack`, `Skill`, plus `Happy`/`Angry` on the face), so the pet's controller drives any mix. Pause loops when the pet is far from the camera.

## Making changes
- Upgrading an existing part or body ("make it 10,000x cooler"): `pet-upgrades.md`.
- Picture prompts: one part per picture, show it mounted on the plain base body (front + side + back views) so the fit reads.
