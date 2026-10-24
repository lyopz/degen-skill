---
name: roblox-assets
description: Makes Roblox game assets that import cleanly into Roblox Studio and can MOVE — props, creatures, characters, rigged/animated models (walk, idle, attack), and effects like fireballs, flaming legs, auras, trails and explosions. Picks the cheapest route that still looks pristine (Roblox VFX and Blender first, Higgsfield credits only where they add real value). Use when lyopz asks for a Roblox asset, model, NPC, pet, weapon, animation, effect/VFX, or "make ___ walk / move / on fire" for a Roblox game. For 3D on websites use `3d-assets`; for making a game look/feel better use `roblox-design`.
---

<!-- from: lyopz (own workflow). Research sources listed at the bottom. -->

# Roblox Assets
- **Unity first, always (lyopz, 2026-10-24).** For any 3D work (polish, materials, fixes, scale/pivot, scene/prop assembly, previews, export) use Unity (`unityMCP` + `roblox-3d-pipeline` / `unity-mcp` skills). Use Blender only for what Unity can't do (bone rigging + weights, reshaping a mesh) or when lyopz asks for Blender.

Two kinds of 3D work in this library:
- **Web 3D** (`3d-assets`): looks only; one GLB on a web page.
- **Roblox 3D** (this skill): must import into Studio, stay under Roblox limits, and usually **move** — rigged animation, scripted motion, or particle effects.

## 0. Match the game's style first
Before making anything, load the project's style bible with **`roblox-art-style`** (look up the real subject → translate it into the game's style → anchors as references → consistency check). Every route below uses the bible's palette, shapes, prompt suffix and budgets.

## 1. Pick the cheapest route that still looks great

Decide per piece, top to bottom. Stop at the first route that can do it well.

| Need | Best route | Credits |
|---|---|---|
| Fire, fireball, smoke, sparks, magic, aura, lightning, trails, explosions, "legs on fire" | **Roblox VFX** (ParticleEmitter, Beam, Trail, Light, Attachments) — not a 3D model | 0 |
| Simple shapes: crates, walls, platforms, coins, orbs, buttons, low-poly rocks | **Roblox parts / Unity ProBuilder** (Blender fallback) | 0 |
| Spinning, bobbing, flying, opening doors, conveyor, projectiles | **Scripted motion** (TweenService / CFrame in a script) | 0 |
| Detailed unique prop, creature, pet, weapon, statue | **Higgsfield**: picture (few) → `image_to_3d` textured (30) | ~35 |
| That model needs to walk / attack / idle | **Blender rig + animation** (free) — or Higgsfield `3d_rigging` only for human-shaped bodies | 0 (or rig cost) |
| Many copies (10 trees) | 1–3 variants, duplicated with random rotation/scale | — |

Always tell lyopz the credit estimate before spending, and generate the cheap picture first so he can approve the look before the 3D step.

## 2. Make the model (when one is needed)
Follow `3d-assets` steps 2–4 (picture → `image_to_3d` → `shrink_glb.py --size 1024`), with Roblox prompt words: `low-poly stylized game asset, chunky readable shapes, bright saturated colors, clean silhouette`. For anything that will be rigged: **T-pose / legs straight and apart, arms out, mouth closed**, plain background, three-quarter view.

## 3. Make it Roblox-ready (Unity first via `roblox-3d-pipeline`; Blender connector as fallback)
Limits and budgets (2026):
- **20,000 triangles max per mesh**; rigid accessories 4,000. Budgets: tiny prop 50–500, normal prop 1k–10k (repeated props ~3–4k), big environment piece 10–18k, hero asset 10–20k.
- **Textures 1024×1024 max** in practice; 256 for small (~5 stud) props, 512 for medium (~10 stud).
- Decimate: Merge by Distance → Limited Dissolve → Decimate (Collapse) starting ratio 0.5, step down, stop when the silhouette breaks, add back 10–15%. Bake a normal map from the high-poly if detail matters.
- Apply all transforms (scale 1,1,1, rotation 0). Origin at the base/feet. Watertight mesh with thickness.
- Export **GLB** (keeps textures) or FBX (Selected Objects, Apply Scalings = FBX Units Scale, Forward −Z/Z Forward, Up Y). Set import Scale Unit to match (usually Meter). ~1 stud ≈ 0.28 m; a character is ~5 studs tall.

## 4. Make it move

### A. Rigged animation (walk, idle, attack) — free in Blender
1. Armature in Blender: root bone at origin with **no weights**; bones at real joint pivots (hip, knee, ankle, neck, wing…). Bone names must not match object names.
2. Parent mesh → armature with Automatic Weights, fix in Weight Paint (max **4 bone influences per vertex**). Bones frozen at scale 1 / rotation 0.
3. Animate a loop in Blender (walk = 24–32 frames, contact → passing → contact; add head bob and body sway for creatures). Or animate later in Studio's Animation Editor.
4. Export GLB/FBX (one animation per file if baking animations).
5. Studio → **Import 3D** → Rig type **Custom** (creatures/NPCs) or **R15** (humanoids) → Constraint Type **Joint Upgrade (AnimationConstraints)** (2026 default; don't use Motor6D with bones).
6. Non-humanoid models use an **AnimationController + Animator** inside the model; humanoids use Humanoid + Animator. Publish the animation from the Animation Editor, then play it:
```lua
local animator = model:FindFirstChildWhichIsA("AnimationController"):FindFirstChildOfClass("Animator")
local walk = Instance.new("Animation"); walk.AnimationId = "rbxassetid://YOUR_ID"
local track = animator:LoadAnimation(walk); track.Looped = true; track:Play()
```
- Higgsfield `3d_rigging` (Meshy) auto-rigs and can apply one of 678 clips (walk id 30, run 16, idle 0, jump 466) — **only good for human-shaped bodies**. Birds/animals/creatures: rig in Blender.
- Roblox Adaptive Animation (GA April 2026) lets one animation drive different rig types via HumanoidRigDescription.

### B. Scripted motion (no rig needed)
Pets that follow, bobbing pickups, spinning coins, flying birds, swinging doors, projectiles: `scripts/motion.lua` (spin, bob, follow, launch projectile).

### C. Effects (VFX) — fireball, legs on fire, auras
Built from `ParticleEmitter` + `Beam` + `Trail` + `PointLight` on **Attachments**. Layer **3–5 emitters** per effect (core glow, outer flame, sparks, smoke, light) — one emitter looks flat. Ready-made: `scripts/vfx.lua`:
- `Fireball(origin, direction)` — glowing core, flame, sparks, trail, light, explosion + camera shake on hit.
- `IgniteLegs(model)` — finds leg bones/parts (names containing Leg/Foot/Shin/Thigh) and attaches flame + ember emitters + light.
- `Aura(part, color)` — ring of rising particles.
Full guide and pet/reward effects: `roblox-vfx` skill + `roblox-templates/templates/PetFX.lua`. Keep under ~50 particles alive per emitter on mobile, use `LightEmission = 1` for fire/magic (additive glow), `LightInfluence = 0`, flipbook textures for richer fire, and turn effects off when far from the camera.

## 5. Check before handing over
- Triangle count per mesh, texture sizes, CollisionFidelity (**Box** for decor + CanCollide off; Hull for simple props), `RenderFidelity = Performance` for background props, Anchored for static pieces.
- Free Creator Store models: list `LuaSourceContainer` descendants after inserting; decor with scripts = backdoor → delete (`roblox-dev` → Security). Searching, picking and cleaning store models: `roblox-store-models`.
- Test on phone size in Studio's Device Simulator.
- Save source picture, .blend, GLB/FBX and the Luau scripts with the project.

## Examples
- Robot chicken (model): see `3d-assets/examples/robot-chicken.md`. To make it walk for Roblox: Blender rig (hip, knee, ankle per leg + neck + head), 28-frame walk with head bob, export GLB, import as Custom rig, AnimationController. Flaming legs: `IgniteLegs(chicken)`.

## Sources (researched 2026-10-22)
- Nilo — Roblox polygon limits & optimization: https://nilo.io/articles/optimize-3d-models-roblox-limit
- Nilo — Rigging for Roblox (Studio & Blender): https://nilo.io/articles/rig-3d-assets-roblox
- Meshy — AI model to Roblox Studio workflow: https://www.meshy.ai/tutorials/3d-model-for-roblox-workflow
- Kitsblox — Roblox VFX: https://kitsblox.com/blog/how-to-add-visual-effects-roblox
- Roblox docs — basic visual effects: https://create.roblox.com/docs/tutorials/curriculums/core/building/create-basic-visual-effects
