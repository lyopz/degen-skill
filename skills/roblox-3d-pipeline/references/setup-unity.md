# Set up Unity polish (once, on the PC)

1. **uv:** `winget install --id=astral-sh.uv -e`
   If winget fails: `powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"`. Then reopen PowerShell.
2. **Git** (Unity needs it for git packages): `winget install --id Git.Git -e`, then restart Unity Hub.
3. **Unity Hub → Installs → Install Editor → Unity 6 LTS.** Sign in first and accept the free Personal licence. You don't need any modules.
4. **Projects → New project → Universal 3D.** Name it `degen-polish` and set Location to `C:\Users\<you>\RobloxGames\.degen`.
5. **Pull and run the setup:**
   `cd $HOME\.claude\degen-skill; git pull --no-edit`
   `powershell -ExecutionPolicy Bypass -NoProfile -File "$HOME\.claude\degen-skill\assets\roblox-app\unity-setup.ps1"`
   It adds MCP for Unity to the project, copies `DegenPolish.cs`, checks uv and saves the Lead config.
6. **In Unity:** Window → Package Manager → + → **Add package by name**: `com.unity.cloud.gltfast`, then `com.unity.formats.fbx`. (The script lists them if they're missing.)
7. **Done.** From now on every Lead window opens Unity on this project (visible, so you can watch it design) and connects by itself (stdio; `DegenPolish.cs` sets it). No Start Server click.
8. **Check:** open a Lead window, wait about a minute for Unity, type `/mcp`, and **unityMCP** should say connected.

Problems:
- "No 'git' executable" → step 2, then fully close and reopen Unity Hub and Unity.
- unityMCP not connected → Unity was still loading: type `/mcp` → unityMCP → Reconnect. Still nothing: run `unity-open.ps1` (prints why) and check the Unity Console for `[Degen]` lines.
- Disconnect: run the setup with `-Remove`.
