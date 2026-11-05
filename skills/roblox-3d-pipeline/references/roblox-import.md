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
3. Pictures: `roblox-upload.ps1` returns a **Decal id** for PNGs. SurfaceAppearance maps, game Decals and ImageLabels need the **image id**: resolve once with `InsertService:LoadAsset(decalId):FindFirstChildWhichIsA("Decal", true).Texture` (or `imageId` in roblox-assets.json) and bake the image id into the installer. A decal id renders plain white/flat with no error ("white for a while after upload" was this). UI images: Studio `upload_image` (Open Cloud decal ids failed in ImageLabels). Then `Content.fromAssetId(id)` for Content properties or `"rbxassetid://"..id` for string ones. Identical PNGs dedupe to one image.
4. Sounds: `Sound.SoundId = "rbxassetid://"..id` (or `AudioPlayer.Asset`). Audio: 10 uploads a month unless lyopz is ID-verified (100), so only upload sounds that will ship.

## Then (both routes)

5. Find the new model (Route A: what step 2 returned). Check each MeshPart for a **SurfaceAppearance** with ColorMap, NormalMap, MetalnessMap, RoughnessMap. glTF textures usually come with it. Missing or flat → upload the PNGs in `export/roblox.json` with `roblox-upload.ps1` and set the maps from `execute_luau` with `Content.fromAssetId`.
6. Scale to the bible's studs (`model:ScaleTo(...)`), pivot at the base. Name it `<Asset>`, put it in the folder the spec says (e.g. `ReplicatedStorage.Pets`), set Anchored / CanCollide / CollisionFidelity (Box for decor, Hull for pets).
7. Glow parts: SurfaceAppearance can't light the scene. Add a small PointLight (Brightness ≤ 1, Range 4–8, crystal colour). Elemental pets: tell the vfx-artist in the handoff.
8. So lyopz sees it: `game.Selection:Set({model})`, point `workspace.CurrentCamera.CFrame` at it (`CFrame.lookAt(pivot + Vector3.new(1, 0.6, 1).Unit * size * 2.2, pivot)`), one screenshot in the game's lighting next to the Unity view0. It must look as good as the Unity shot.
9. Write the asset ids into HANDOFF.md (asset → id) so later edits replace the right thing. Copy id lists out of the scratchpad into the project (they vanish on restart).

## Import gotchas (2026-11-03)
- **Upload holds:** new GLB Models are HELD until you render them front/back/side/top (a part of a bigger model: render it alone, as the scanner sees it); some PNGs are held as "skin tone" (copper atlases, gold eyes, ivory teeth). Check by eye, rerun that file with `-Reviewed`. "WriteAllText ... user-mapped section" = json open elsewhere, retry.
- **Embedded textures:** a GLB with an embedded base-colour texture auto-uploads it and arrives with `MeshPart.TextureID` set (texture = colour); copy it onto MeshParts sharing the atlas. GLB water/glass has no alpha → SurfaceAppearance, AlphaMode Transparency.
- **Orientation:** the raw insert is turned 180° about Y around each mesh's own bbox centre (Blender x, y, z arrives as −x, z, y). `CFrame.new(centre) * CFrame.Angles(0, math.pi, 0)` restores geometry AND orientation, so map onto a live asset by translation only (a full `orig * ref⁻¹` adds a second turn). Never trust an axis formula: assert one asymmetric front-only part (front Z < 0) and one off-axis part before placing attachments/FX. Place each mesh from the GLB accessor min/max centre. Unity GLBs import in metres and `ScaleTo` scales about the bbox centre: move the bottom centre to the origin before placing attachments.
- **Names and meshes:** glTF object ≠ mesh name → Model "<object>" > MeshPart "<mesh>": key loaders by the parent Model. Scripts can't set MeshId (clone the MeshPart or `ApplyMesh`, restore Size/CFrame/TextureID) or CollisionFidelity. A flat mesh (MeshSize.Y = 0) is never drawn: add a hidden keel sliver. Raycasts hit the collision hull, not the visible mesh: probe hollow bodies with `CreateMeshPartAsync(id, {CollisionFidelity = PreciseConvexDecomposition})` or a test plate + screenshot.
- **Maps that won't show:** preload the SurfaceAppearance instances and wait ~2 s before a capture; in Edit `PreloadAsync` reports Failure even for working ids, so verify by screenshot. A fresh image can stay white/grey for good: keep the last good id, re-upload with one pixel changed. One bad map turns the whole SA plain grey (even when Open Cloud says Active): bisect by swapping maps back one at a time. "Not approved for the requester" can be moderation Rejected (`assets/v1/assets/<id>?readMask=moderationResult`), even on a flat 8×8: re-upload 16 px with a 1-level dither. `SA.Color` multiplies and clamps at 1 (only darkens): re-bake the ColorMap to warm or brighten.
- **roblox-assets.json:** the uploader rewrites it wholesale (key order, absolute paths). Restore the committed text and append only the new entries in the same format (or PowerShell `ConvertFrom-Json` → add → `ConvertTo-Json -Depth 20`, UTF-8 no BOM; Python `json.dump` reformats every line).
- **Placing:** raycast a big piece's footprint for ground and `GetPartBoundsInBox` for clashes; list what's inside for the map-builder instead of moving others' models. Reinstall in place: build the new Model fully, Destroy the old one just before parenting the new.

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

- **(2026-11-05) Swapping a re-baked mesh into a placed model:** clone the new raw part, `CFrame = placedRoot.CFrame * rawPart.CFrame`, copy props, attributes, tags and children from the old part, destroy the old one — and swap EVERY mesh sharing that atlas (a rebuild re-unwraps them all). Blender `.blend` zstd files can hold several frames: decompress with `stream_reader(..., read_across_frames=True)`. Neon see-through halo shells render opaque white in Cycles sheets — render them out.
