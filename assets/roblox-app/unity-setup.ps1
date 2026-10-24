# One-time setup: connect Unity (MCP for Unity, CoplayDev/unity-mcp) to the Lead window.
# Usage (normal PowerShell, after making the Unity project in Unity Hub):
#   powershell -ExecutionPolicy Bypass -NoProfile -File "$HOME\.claude\degen-skill\assets\roblox-app\unity-setup.ps1"
# Options: -Project "<unity project folder>" (default ~/RobloxGames/.degen/degen-polish), -Http (use Unity's own HTTP
# server on 127.0.0.1:8080 instead; default is stdio: the Lead starts the server itself and Unity's bridge auto-starts),
# -Remove (disconnect). Every Lead start opens the project minimized (unity-open.ps1; it pops up while designing) so it connects by itself.
# Saves only on this PC (~/RobloxGames/.degen/unity-mcp.json + unity-project.txt), never in the repo.
param([string]$Project = '', [switch]$Http, [switch]$Remove)
$D = Join-Path $env:USERPROFILE 'RobloxGames\.degen'; New-Item -ItemType Directory -Force -Path $D | Out-Null
$cfgFile = Join-Path $D 'unity-mcp.json'
if ($Remove) { Remove-Item $cfgFile, (Join-Path $D 'unity-project.txt') -Force -ErrorAction SilentlyContinue; 'Unity MCP removed.'; exit 0 }
if (-not $Project) { $Project = Join-Path $D 'degen-polish' }
$utf8 = New-Object Text.UTF8Encoding $false

# 1. The Unity project
if (-not (Test-Path (Join-Path $Project 'Assets'))) {
  "No Unity project at $Project yet."
  "Make it in Unity Hub: Projects > New project > Universal 3D, name degen-polish, location $D. Then run this again."
  exit 1
}
[IO.File]::WriteAllText((Join-Path $D 'unity-project.txt'), $Project, $utf8)

# 2. Packages: add MCP for Unity if missing, report the two Unity ones
$man = Join-Path $Project 'Packages\manifest.json'
$json = [IO.File]::ReadAllText($man) | ConvertFrom-Json
$deps = $json.dependencies
$missing = @()
if (-not $deps.'com.coplaydev.unity-mcp') {
  $deps | Add-Member -NotePropertyName 'com.coplaydev.unity-mcp' -NotePropertyValue 'https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main' -Force
  [IO.File]::WriteAllText($man, ($json | ConvertTo-Json -Depth 10), $utf8)
  'Added MCP for Unity to the project (Unity downloads it when the project opens; needs Git installed).'
}
if (-not $deps.'com.whinarn.unitymeshsimplifier') {
  # Low-poly cuts (UnityMeshSimplifier, MIT, ~2k stars; pinned tag)
  $deps | Add-Member -NotePropertyName 'com.whinarn.unitymeshsimplifier' -NotePropertyValue 'https://github.com/Whinarn/UnityMeshSimplifier.git#v3.1.1' -Force
  [IO.File]::WriteAllText($man, ($json | ConvertTo-Json -Depth 10), $utf8)
  'Added Unity Mesh Simplifier (low-poly cuts).'
}
foreach ($p in 'com.unity.cloud.gltfast', 'com.unity.formats.fbx') { if (-not $deps.$p) { $missing += $p } }

# 3. The polish helpers
$ed = Join-Path $Project 'Assets\Editor'; New-Item -ItemType Directory -Force -Path $ed | Out-Null
Copy-Item (Join-Path $PSScriptRoot '..\..\skills\roblox-3d-pipeline\unity\DegenPolish.cs') $ed -Force
'Copied DegenPolish.cs into Assets\Editor.'

# 4. uv (runs the MCP server)
$uvx = (Get-Command uvx -ErrorAction SilentlyContinue).Source
if (-not $uvx) {
  foreach ($c in "$env:USERPROFILE\.local\bin\uvx.exe", "$env:LOCALAPPDATA\Microsoft\WinGet\Links\uvx.exe") { if (Test-Path $c) { $uvx = $c; break } }
}
if (-not $uvx) {   # winget sometimes skips the Links shim; uvx then sits only in its package folder
  $uvx = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\astral-sh.uv_*\uvx.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $uvx) { 'uv is not installed. Run: powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"  then run this again.'; exit 1 }

# 5. Lead config
[Environment]::SetEnvironmentVariable('UNITY_MCP_DISABLE_TELEMETRY', 'true', 'User')
$srv = if (-not $Http) {
  [ordered]@{ command = $uvx; args = @('--from', 'mcpforunityserver', 'mcp-for-unity', '--transport', 'stdio'); env = [ordered]@{ UNITY_MCP_DISABLE_TELEMETRY = 'true' } }
} else { [ordered]@{ type = 'http'; url = 'http://127.0.0.1:8080/mcp' } }
[IO.File]::WriteAllText($cfgFile, ($srv | ConvertTo-Json -Depth 5), $utf8)

''
if ($missing) { 'Still to add in Unity (Window > Package Manager > + > Add package by name): ' + ($missing -join ', ') }
if (-not $Http) { 'Done. Every Lead window now opens Unity minimized on this project (it pops up while designing) and connects to it by itself.' }
else { 'Done (HTTP). Every Lead window opens Unity on this project; DegenPolish turns on Auto-Start so the server starts with it.' }
'Check: open a Lead window from the app, type /mcp, and unityMCP should say connected.'
