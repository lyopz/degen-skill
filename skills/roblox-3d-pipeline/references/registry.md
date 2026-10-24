# 3D tool registry

The roblox-3d-designer reads this first on every job. One row per tool or repo. **Status** is `connected` (in the Lead's MCP config), `setup` (lyopz has to run a setup step), `docs` (knowledge only, nothing to run) or `idea` (not vetted yet).
To see what is really loaded right now, check the tool list: `mcp__customuse__*`, `mcp__higgsfield__*`, `mcp__unityMCP__*`, `mcp__Roblox_Studio__*`.

## Pictures
| Tool | Status | Best at | Fallback |
|---|---|---|---|
| ChatGPT via `gpt-image.ps1` | connected | Every concept picture (lyopz's rule). `-Ref` for edits | none (always this) |

## 3D generators (picture → mesh)
| Tool | Status | Best at | Cost / notes |
|---|---|---|---|
| Customuse image-to-3D (`mcp__customuse__*`) | setup (`customuse-setup.ps1`) | Default. Low poly + texture, Roblox-sized, clean | CR1 "Generate Model & Texture" ≈ 70 credits. Model faces +X. Two parts in one picture split cleanly |
| Customuse retopology (`customuse_start_retopology`) | same | Fixing lumpy or too-dense meshes before Unity | Estimate first (`customuse_estimate_retopology`) |
| Customuse → Roblox upload (`customuse_upload_to_roblox`) | same | Uploading an unpolished Customuse mesh straight to his account | Only for meshes that skip Unity |
| Higgsfield `generate_3d` (`mcp__higgsfield__*`) | connected | Second option for hero assets, detailed organic shapes | Preflight the cost, stay in budget |
| `customuse-3d.ps1` (by hand) | connected | When the Customuse MCP isn't loaded | lyopz clicks through it; picks the .glb up from Downloads |
| MCP for Unity `generate_model` (Tripo / Meshy / fal) | idea | More generators inside Unity | Needs lyopz's own provider keys in Unity; not set up |

## Polish
| Tool | Status | Best at | Notes |
|---|---|---|---|
| **MCP for Unity** (CoplayDev/unity-mcp, MIT, ~13k stars) + `DegenPolish.cs` | setup (`unity-setup.ps1`) | Materials, gloss/metal/glow regions, lighting check, shots vs the picture, GLB/FBX + PBR maps | Lead opens Unity by itself (`unity-open.ps1`) and it auto-connects over stdio. Enable `scripting_ext` group if execute_code is hidden |
| UnityMeshSimplifier (Whinarn, MIT, ~2.1k stars, pinned v3.1.1) + `DegenPolish.Decimate` | setup (`unity-setup.ps1` adds it) | Cutting a model down to the low-poly budget | Big cuts (>60%) can look lumpy: use Customuse retopology instead |
| Unity ProBuilder (`manage_probuilder`) | setup (package `com.unity.probuilder`) | Simple hard-surface edits (bevel a block, extrude a pad) | Not for organic shapes |
| Blender (`mcp__remote-devices__Blender__*`) | connected | Small shape fixes only: origin, scale, delete a bad piece, split parts for rigging | lyopz: Blender struggles with designing, so never use it as the main designer |

## Into Roblox
| Tool | Status | Best at | Notes |
|---|---|---|---|
| Roblox Studio MCP (`mcp__Roblox_Studio__*`) | connected | Placing, naming, SurfaceAppearance, lighting check, screenshots | No MCP tool uploads meshes |
| Studio File > Import 3D (lyopz clicks, via an `ask.ps1` card) | connected | Persistent MeshIds from the polished .glb | Merge Meshes OFF unless one MeshPart is wanted |
| Roblox Open Cloud Assets API | idea | Fully automatic upload (no click) | Needs an Open Cloud API key + user id; not built yet |

## Knowledge (docs, no scripts)
| Source | Licence | Used for |
|---|---|---|
| `unity-mcp` skill (vendored from CoplayDev/unity-mcp) | MIT | Unity MCP tool names, params, workflows |
| gamedev-skills/awesome-gamedev-agent-skills `create-game-assets` (3.5k stars) | Apache-2.0 | Quality gates + 3D pipeline checks (adapted in `quality-gates.md`) |
| `roblox-asset-shapes`, `roblox-art-style`, `customuse-design/taste.md` | ours | Shape rules, prompts, lyopz's taste |

Checked and not adopted (2026-10-24): CoderGamester/mcp-unity (~1.9k stars) and IvanMurzak/Unity-MCP (~3.9k stars) are good but have fewer material/lighting tools than CoplayDev. AnkleBreaker unity-mcp-server is too new and small. ai-forge-mcp is a paid subscription. DavinciDreams 3D team has 1 star and no licence.

## Adding a tool (when lyopz adds a 3D repo)
1. **Vet it.** Check the licence (MIT/Apache/BSD fine; no licence = docs ideas only, don't copy code). Check stars and the last commit (dead for a year = skip). Read every install script: no `curl | sh` of unknown hosts, no obfuscated code, no token grabbing. Make sure any telemetry can be turned off.
2. **Decide the stage** it improves (generator / polish / import / knowledge) and what it beats the current default at.
3. **Add one row** above with status `setup` or `docs`. Secrets and addresses go only on the PC (`~/RobloxGames/.degen/<tool>-mcp.json`), never in this file.
4. **Wire it in.** For an MCP: add a setup script like `unity-setup.ps1` and a merge line in `lead-run.ps1`. For docs: vendor them into `skills/<name>/` with its LICENSE and a "vendored from" line.
5. **Prove it.** On the first real asset, try it next to the current default and log the result below. Better → make it the default.

## Results (what won, newest first)
- (none yet: first Unity-polished asset goes here, e.g. "2026-10-xx pet: Unity regions vs raw Customuse → lyopz: Love it")
