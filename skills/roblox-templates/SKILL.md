---
name: roblox-templates
description: lyopz's library of reusable Roblox Studio templates (ModuleScripts, scripts, UI kits, systems) and how they reach his Roblox Studio — every template is packed into the "Degen Templates" Studio plugin and a "Roblox Templates" folder on his PC each time the Degen Skills app opens. Use when adding a reusable Roblox script/system/kit, when the daily Roblox refresh finds an important template, or when lyopz asks for a template or "save this to my Roblox Studio".
---

<!-- from: lyopz (own). -->

# Roblox Templates

## What's here
`templates/` — one `.lua` file per template:
- `Name.lua` → ModuleScript (goes to ReplicatedStorage), `Name.server.lua` → Script (ServerScriptService), `Name.client.lua` → LocalScript (StarterPlayerScripts).
- Current: `VFX` (fireball, flaming legs, aura, explosion, camera shake), `Motion` (spin, bob, pet follow, waddle, collect pop), `ButtonFeel` (button hover/press/bounce/sounds, panel open/close, deny shake), `PetFX` (pet/reward effects: hatch in front of camera, rarity auras, level up, coin fountain, light pillar, trail, `Play` for plugin-built effects, distance culling; see `roblox-vfx`), `ImpactFX` (physics hits → thud + dust + callback scaled by impact speed; Collision Summaries API, Touched fallback; `BindTagged` for tagged props), `ConfirmToken` (server: preview → one-use token → non-yielding idempotent commit for fuse/craft/upgrade machines), `DevContentGuard` (Script: strips everything tagged DevOnly — test labs, preview stands — on live servers, keeps it in Studio), `PortalFX` (portal swirl/glow effects), `PetMoves` (client: procedural attack moves for rig-less/anchored pets — Tackle, Slam, Spin, Beam, Shoot, Swoop, Combo, Hurt — with hit-stop, VFX cues and pop scale; timings in `roblox-art-style/references/pet-movement.md`).
- Ocean kit (use all three together): `Waves` (shared Gerstner wave math), `OceanMesh` (animated EditableMesh ocean with depth colors, whitecaps, shore foam), `OceanClient` (runs the ocean, floats `FloatOnWaves`-tagged ships, sways `Sway`-tagged trees). Needs EditableMesh enabled in Game Settings > Security; falls back to terrain water.

No template fits? Look in the Creator Store next (`roblox-store-models`): insert, scan, clean, restyle. A cleaned store system lyopz likes can become a template here (keep `source: Creator Store <id> by <creator>` in the header).

## How templates reach his Roblox Studio
1. Add/update the `.lua` in `templates/`, keep a header comment with usage.
2. Run `python skills/roblox-templates/make_rbxmx.py` → rebuilds `templates/rbxmx/*.rbxmx` (one model file per template) and `DegenTemplates.rbxmx` (Studio plugin with all templates inside).
3. Commit + push. When lyopz opens the Degen Skills app, `assets/app/launch.ps1` pulls and copies:
   - `DegenTemplates.rbxmx` → `%LOCALAPPDATA%\Roblox\Plugins\` (Studio loads it as a local plugin: **Plugins tab → Degen Templates → Templates** opens a list; click one to insert it — into the selected object, or its default service).
   - every `.rbxmx` → `Documents\Roblox Templates\` (also usable via right-click → Insert from File).
4. Restart Studio (or reload plugins) to see new templates.

## Templates are examples, and they improve
Templates are **starting points**: copy one into the game, adapt it, and make it better. When lyopz says he likes an improved version (only then), save it back:

| Situation | What to do |
|---|---|
| Same job, just better (bug fix, cleaner, faster, nicer feel), works the same way for existing games | **Overwrite** `templates/<Name>.lua`, bump `-- version: N` in the header, add a `-- changelog:` line, and keep the old file as `templates/archive/<Name>@v<old>.lua` |
| Different behavior, look or options (e.g. a punchier button style, a pet follow that orbits) | **Save as a variant**: `templates/<Name>-<variant>.lua` (e.g. `ButtonFeel-squishy.lua`), with its own header saying when to use it vs the original |
| Only makes sense for one game | Keep it in that game's folder, not in templates; add a lesson if something general was learned |
| Not sure | Ask lyopz in one line: "overwrite <Name> or save as <Name>-<variant>?" |
After saving: run `make_rbxmx.py`, add a line to `roblox-dev/lessons.md` ("improved <Name>: …"), commit + push. `archive/` is not packed into the Studio plugin.

Header every template keeps at the top:
```lua
-- <Name>.lua — one-line what it does
-- version: 1
-- use: <how to require/use it>
-- changelog: v1 2026-10-23 first version
```

## Rules for adding a template
- Only reusable, tested, general things (systems, kits, effects, UI pieces) — not one game's content.
- Must follow `roblox-design` (UI sizes, feel), `roblox-art-style` (palette is passed in, not hard-coded), and `roblox-scripter` rules (server authority, pcall on DataStores/Marketplace).
- Templates sourced from the web: only if the license allows reuse (MIT/CC0/Roblox-created); keep the source link and license in the header. Never copy paid/closed assets.
- Scripts/LocalScripts are stored **disabled** inside the plugin so they never run in Studio's plugin context; inserted copies keep the class and must be enabled by the user where needed.
