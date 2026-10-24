# Pet back + top accessories and auras (lyopz, 2026-10-24)

<!-- from: lyopz (2026-10-24): sent 3 sheets after the mouth and eye sheets: wings with auras, back pieces (drone dock, blade wings, reactor, tentacles), and attach-zone views. Done the same way as `pet-mouths.md` and `pet-eyes.md`. -->

References: `pet-accessories/wings-sheet.jpg`, `pet-accessories/back-pieces-sheet.jpg`, `pet-accessories/attach-zones-sheet.jpg`.

## Attachment zones (every cube pet)
| Zone | What goes there |
|---|---|
| Front | eyes (`pet-eyes.md`) + mouth (`pet-mouths.md`). Nothing else. |
| Sides | mouth wrap only. Wing roots may poke past the side edges, but nothing is mounted on the sides. |
| Back (upper half) | wings and back pieces, mounted on a **mechanical hub**: a round metal socket with a glowing core in the accessory's colour, gold/gunmetal trim, short pipes or arms out to each wing. |
| Top | aura space: halos, orbiting rings, floating shards, a floating core. Hovers above the body and never touches it. |

- Same base body for every pet. Accessories fit it and never cover the face. From the front the eyes and grin must stay fully visible.
- Big pieces read from the front: the wings/blades spread wider than the body and above it, so you see them behind the cube.
- Materials follow the premium block: gunmetal + gold hub, glossy plates, subtle glow (emission ≤ 0.6). The sheets glow brighter than our rule, so glow stays on edges and cores, never as whole neon sheets.
- Low poly: accessory ≤ 1.5k tris (taste rule). Wings are left + right copies of one mesh.

## Pieces by rarity (from the sheets, + suggested lower tiers)
Rarity colours: Common grey, Uncommon green, Rare blue, Epic purple, Legendary gold, Mythic pink, Secret red.

| Tier | Piece | Look | Aura animations (idle / move / orbit / attack) |
|---|---|---|---|
| Common | Fin Antenna (suggested) | small metal fin with a glowing tip on the upper back | tip pulse / sway / none / tip flash |
| Uncommon | Mini Thrusters (suggested) | two small rocket pods on the hub | soft flame / boost / none / burst |
| Rare | Celestial Wings | pink-purple feather wings with blue edges, gold hub, halo ring on top | feather flow / flap with light trails / ring orbit / energy burst |
| Rare | Mech Blade Wings | white-silver mech arms with fanned cyan glass blades, blue core | blade glint / blades fan open-close / none / blade slash |
| Epic | Void Wings | black smoky feather wings, purple edge glow, black orb on top | smoke flow / void trails / shadow ring orbit / void explosion |
| Epic | Lava Bat Wings | torn bat wings with glowing lava veins, horned hub with a slit eye | lava drip glow / heavy flap / none / fire breath burst |
| Epic | Drone Dock | back dock with 2–3 small floating round drones on rings | drones hover + bob / drones follow / drones orbit / drones zap |
| Epic | Toxic Tanks | two green liquid tanks with pipes and a green core, smoke out the top | bubbling + smoke / slosh / none / gas cloud |
| Legendary | Spirit Flame Wings | blue ghost-fire wings on metal arms, flame orb above | flame flow / wave trails / flame orbit / fire burst |
| Legendary | Aurora Blade Wings | big crystal blades in a fan, colour-shifting green-to-purple, floating shards | colour shift / blades open-close / shard orbit / blade storm |
| Legendary | Crystal Orb Gyro | gold gyroscope rings around a purple crystal orb, floating shards | orb pulse / rings tilt / rings spin + shards orbit / crystal burst |
| Mythic | Fusion Reactor | spinning blue energy core in gold orbit rings, floating shards | pulsing glow / rings spin / shards orbit / energy wave |
| Secret | Neon Oblivion Wings | black feather wings with green + purple neon, chains, rift orb on top | aura spiral / chain trails / colour-shift orbit / dimension rift |
| Secret | Void Tentacles | segmented tentacles from a gold hub, each tipped with a glowing purple eye-crystal | each tentacle sways on its own / reach / tips circle / tentacles strike |

Pick by the pet's element (fire → Lava Bat / Spirit Flame, void → Void Wings / Tentacles, toxic → Toxic Tanks, tech → Drone Dock / Mech Blades / Reactor) and match the eye + mouth colour. New pieces: same zones, hub, and four animations.

## Faces on these sheets
Every example uses **glowing eyes + a wide clean white grin** (bold white teeth, black gaps, no crosshatch). That counts as the same grin family as `pet-mouths.md`. Use the clean version with big accessories, where a busy ink mouth would fight the wings, unless lyopz says otherwise.

## Prompt words (add to part 3 "Identity features")
"<piece look from the table>, mounted on the upper back on a round gunmetal and gold mechanical hub with a glowing <colour> core; wings spread wider than the body and above it so they are visible from the front; top aura: <halo / orbit ring / floating shards> hovering above the body; nothing on the front or sides; subtle glow on edges and cores only."
For a separate accessory model: picture of **only the accessory**, back view and front-three-quarter view, white background (or #00FF00 for glowing parts, then `scripts/chroma-key.py`).

## On the 3D model + in Roblox
1. Build the accessory as its **own model** (picture → Customuse → Unity polish, ≤ 1.5k tris), never baked into the body. It fits every pet with the same base body and can be a crate item.
2. Body has two Attachments: `BackMount` (centre of the upper back) and `AuraTop` (about 0.6× body height above the top). The accessory's hub welds to `BackMount`, and top aura parts follow `AuraTop` (they float, so no weld to the body).
3. Wings: left + right MeshParts with their pivot at the hub. Flap = tween the rotation ±15–25° (idle slow, flap faster). Blades open/close = tween each blade's rotation from the hub.
4. Auras: Trails on wing tips (flap trails), ParticleEmitters (feathers, smoke, flames, shards), Beams for chains/rings, and orbiting parts on a rotating CFrame. Attack = one-shot burst (particles `:Emit`, scale pop, light flash).
5. One animation script per accessory with `Idle()`, `Move()`, `Orbit()`, `Attack()`; the pet's controller calls them. Pause when far from the camera. Elemental = animated (taste rule), so every piece gets at least idle.
6. Handoff: animator (flap/open), vfx-artist (`roblox-vfx`: auras, trails, bursts), scripter (hooks to attack/equip).
