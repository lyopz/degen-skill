# Into Roblox Studio (stage 4) — no clicks for lyopz

Also used for any file the game needs: pictures (decals, UI, SurfaceAppearance maps), sounds, videos.

## Route A (default): upload with Open Cloud, insert by asset id

1. Upload (from the Lead or any agent):
   `powershell -ExecutionPolicy Bypass -NoProfile -File "$env:DEGEN_APP\roblox-upload.ps1" -Project <project> -Path "<export/asset.glb>" -Name "<Asset>"`
   - Several files at once: `-Path "a.glb|a_color.png|roar.mp3"`.
   - `.glb .gltf .fbx .rbxm .rbxmx` → Model, `.obj` → converted to .glb with Blender first, `.png .jpg .bmp .tga` → Decal, `.mp3 .ogg .wav .flac` → Audio, `.mp4 .mov` → Video. 20 MB max per file.
   - Prints one JSON line per file: `{"file","type","assetId","state"}`. Same file again → `CACHED` (ids kept in `~/RobloxGames/<project>/roblox-assets.json`, local only). `-Force` uploads again.
   - `NO_KEY` → setup not done. Tell lyopz once (one line, no pop-up) to run `roblox-cloud-setup.ps1` (see "Setup"), and use Route B for now.
   - `state` REVIEWING is fine for lyopz's own place: own uploads work in Studio while moderation runs. REJECTED → change the picture/name and redo.
2. Insert. Studio MCP `insert_asset` with the assetId, or one `execute_luau` (Edit):
   ```lua
   local id = 123 -- assetId from roblox-upload.ps1
   local box = game:GetService("InsertService"):LoadAsset(id)
   local model = box:GetChildren()[1]
   for _, d in model:GetDescendants() do if d:IsA("PackageLink") then d:Destroy() end end -- Model uploads come as packages; unlink so edits stay local
   model.Parent = workspace; box:Destroy()
   return model:GetFullName()
   ```
3. Pictures: `Content.fromAssetId(id)` for Content properties (`SurfaceAppearance.ColorMapContent`, `Decal.ColorMapContent`, `ImageLabel.ImageContent`) or `"rbxassetid://"..id` for string ones. If it shows blank, the id is the decal wrapper: `LoadAsset(id)` → read the Decal's `Texture`/`ColorMapContent` and use that image id.
4. Sounds: `Sound.SoundId = "rbxassetid://"..id` (or `AudioPlayer.Asset`). Audio: 10 uploads a month unless lyopz is ID-verified (100), so only upload sounds that will ship.

## Then (both routes)

5. Find the new model (Route A: what step 2 returned). Check each MeshPart for a **SurfaceAppearance** with ColorMap, NormalMap, MetalnessMap, RoughnessMap. glTF textures usually come with it. Missing or flat → upload the PNGs in `export/roblox.json` with `roblox-upload.ps1` and set the maps from `execute_luau` with `Content.fromAssetId`.
6. Scale to the bible's studs (`model:ScaleTo(...)`), pivot at the base. Name it `<Asset>`, put it in the folder the spec says (e.g. `ReplicatedStorage.Pets`), set Anchored / CanCollide / CollisionFidelity (Box for decor, Hull for pets).
7. Glow parts: SurfaceAppearance can't light the scene. Add a small PointLight (Brightness ≤ 1, Range 4–8, crystal colour). Elemental pets: tell the vfx-artist in the handoff.
8. So lyopz sees it: `game.Selection:Set({model})`, point `workspace.CurrentCamera.CFrame` at it (`CFrame.lookAt(pivot + Vector3.new(1, 0.6, 1).Unit * size * 2.2, pivot)`), one screenshot in the game's lighting next to the Unity view0. It must look as good as the Unity shot.
9. Write the asset ids into HANDOFF.md (asset → id) so later edits replace the right thing.

## Rigs (animator)
Upload the rigged .glb/.fbx with Route A and check the model has Bones + skinned MeshParts (or an AnimationController for Custom rigs). Bones missing → Route B with Rig type Custom (creatures) / R15 (humanoids), Constraint Type Joint Upgrade.

## Route B (fallback): Import 3D card
Only when there's no key yet, the upload errors twice, or a rig lost its bones:
`ask.ps1 -Q "Import into Studio: File > Import 3D > <full path>. Merge Meshes: OFF. Then click Import." -O "Done|Skip" -I "<shots/asset_view0.png>" -From <agent>` (add the rig type for rigs). After "Done" find the newest Model/MeshPart with the asset's name, then steps 5–9.

## Route C: Customuse straight to Roblox
Unpolished Customuse mesh (Unity skipped): `customuse_validate_roblox_upload` → `customuse_upload_to_roblox` → insert the id as in step 2. Needs Roblox linked in Customuse (`customuse_get_roblox_connection`). Route A works for these too, with the downloaded .glb.

## Setup (lyopz, once)
1. https://create.roblox.com/dashboard/credentials → API Keys → Create API Key. Access Permissions: add **Assets**, tick Read + Write. Accepted IP Addresses: `0.0.0.0/0`. Create and copy the key.
2. Normal PowerShell: `powershell -ExecutionPolicy Bypass -NoProfile -File "$HOME\.claude\degen-skill\assets\roblox-app\roblox-cloud-setup.ps1"` → paste the key (hidden), type the Roblox user id if asked. `-GroupId <id>` if the games belong to a group.
3. Saved encrypted for his Windows user in `~/RobloxGames/.degen/roblox-cloud.json`. Never in the repo, never print it. `-Remove` deletes it.

Why this route: Open Cloud's Assets API takes .glb/.fbx/.gltf as a Model and makes real MeshIds; the Studio MCP can insert by id (`insert_asset`) but has no tool that reads a local mesh file, and plugin `CreateAssetAsync` was unreliable (lessons 2026-10-23/24).
