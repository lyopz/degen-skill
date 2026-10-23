---
name: roblox-templates
description: lyopz's library of reusable Roblox Studio templates (ModuleScripts, scripts, UI kits, systems) and how they reach his Roblox Studio — every template is packed into the "Degen Templates" Studio plugin and a "Roblox Templates" folder on his PC each time the Degen Skills app opens. Use when adding a reusable Roblox script/system/kit, when the daily Roblox refresh finds an important template, or when lyopz asks for a template or "save this to my Roblox Studio".
---

<!-- from: lyopz (own). -->

# Roblox Templates

## What's here
`templates/` — one `.lua` file per template:
- `Name.lua` → ModuleScript (goes to ReplicatedStorage), `Name.server.lua` → Script (ServerScriptService), `Name.client.lua` → LocalScript (StarterPlayerScripts).
- Current: `VFX` (fireball, flaming legs, aura, explosion, camera shake), `Motion` (spin, bob, pet follow, waddle, collect pop), `ButtonFeel` (button hover/press/bounce/sounds, panel open/close, deny shake).
- Ocean kit (use all three together): `Waves` (shared Gerstner wave math), `OceanMesh` (animated EditableMesh ocean with depth colors, whitecaps, shore foam), `OceanClient` (runs the ocean, floats `FloatOnWaves`-tagged ships, sways `Sway`-tagged trees). Needs EditableMesh enabled in Game Settings > Security; falls back to terrain water.

## How templates reach his Roblox Studio
1. Add/update the `.lua` in `templates/`, keep a header comment with usage.
2. Run `python skills/roblox-templates/make_rbxmx.py` → rebuilds `templates/rbxmx/*.rbxmx` (one model file per template) and `DegenTemplates.rbxmx` (Studio plugin with all templates inside).
3. Commit + push. When lyopz opens the Degen Skills app, `assets/app/launch.ps1` pulls and copies:
   - `DegenTemplates.rbxmx` → `%LOCALAPPDATA%\Roblox\Plugins\` (Studio loads it as a local plugin: **Plugins tab → Degen Templates → Templates** opens a list; click one to insert it — into the selected object, or its default service).
   - every `.rbxmx` → `Documents\Roblox Templates\` (also usable via right-click → Insert from File).
4. Restart Studio (or reload plugins) to see new templates.

## Rules for adding a template
- Only reusable, tested, general things (systems, kits, effects, UI pieces) — not one game's content.
- Must follow `roblox-design` (UI sizes, feel), `roblox-art-style` (palette is passed in, not hard-coded), and `roblox-scripter` rules (server authority, pcall on DataStores/Marketplace).
- Templates sourced from the web: only if the license allows reuse (MIT/CC0/Roblox-created); keep the source link and license in the header. Never copy paid/closed assets.
- Scripts/LocalScripts are stored **disabled** inside the plugin so they never run in Studio's plugin context; inserted copies keep the class and must be enabled by the user where needed.
