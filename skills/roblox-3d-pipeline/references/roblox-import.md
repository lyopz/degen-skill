# Into Roblox Studio (stage 4)

No MCP tool uploads meshes (lesson 2026-10-23), so a persistent MeshId needs **File > Import 3D**. lyopz does one click per asset. Make it painless:

1. Run `ask.ps1 -Q "Import into Studio: File > Import 3D > <full path to export/asset.glb>. Merge Meshes: OFF. Then click Import." -O "Done|Skip" -I "<shots/asset_view0.png>" -From roblox-3d-designer`.
   It's a rig for the animator → add "Rig type: Custom" (creatures) or "R15" (humanoids).
2. After "Done", find the new model in Workspace with `Roblox_Studio` execute_luau. Look for the newest Model or MeshPart with the asset's name.
3. Check each MeshPart for a **SurfaceAppearance** with ColorMap, NormalMap, MetalnessMap and RoughnessMap. The glTF import usually makes it. If it's missing or flat, tell lyopz in the same card next time to also import the PNGs listed in `export/roblox.json`, then set the maps.
4. Scale to the bible's studs (`model:ScaleTo(...)`) and set the pivot at the base. Name it `<Asset>`, put it in the folder the spec says (e.g. `ReplicatedStorage.Pets`), set Anchored / CanCollide / CollisionFidelity (Box for decor, Hull for pets).
5. Glow parts: SurfaceAppearance can't light the scene. For the crystal glow, add a small PointLight (Brightness ≤ 1, Range 4–8, crystal colour). Elemental pets: tell the vfx-artist in the handoff (elemental = animated rule).
6. Take one screenshot in the game's lighting next to the Unity view0. It must look as good as the Unity shot.

Customuse-only route (when Unity is skipped): `customuse_upload_to_roblox` can upload the Customuse mesh straight to lyopz's account. Check with `customuse_validate_roblox_upload` first, then insert by asset id. Otherwise use the same Import 3D card with the raw .glb.
