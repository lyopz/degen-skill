# Runs inside the Roblox Lead window. Passes the lead rules + task to Claude Code safely
# (Windows PowerShell 5.1 breaks arguments that contain double quotes, so they are escaped here).
param([string]$TaskFile, [string]$Settings, [string]$Resume)
$app = $PSScriptRoot
Remove-Item Env:ANTHROPIC_API_KEY -ErrorAction SilentlyContinue
$env:DEGEN_APP = $app
Set-Location (Join-Path $env:USERPROFILE 'RobloxGames')
$title = 'Roblox Lead ' + (Get-Date -Format 'HH:mm'); $host.UI.RawUI.WindowTitle = $title
# Register this window so a newer Lead can take over its task (lead-handoff.ps1). activity-hook.ps1 adds chat id, project, busy.
$LD = Join-Path $env:USERPROFILE 'RobloxGames\.degen\leads'; New-Item -ItemType Directory -Force -Path $LD | Out-Null
$env:DEGEN_LEAD = [string]$PID; $leadFile = Join-Path $LD "$PID.json"
[IO.File]::WriteAllText($leadFile, ([ordered]@{ pid = $PID; ticks = (Get-Process -Id $PID).StartTime.Ticks; title = $title; busy = $true; sid = ''; p = ''; task = '' } | ConvertTo-Json -Compress), (New-Object Text.UTF8Encoding $false))
function Q([string]$s) { ($s -replace '(\\*)"', '$1$1\"') }   # escape quotes for native arguments
# Windows caps a command line at 32,767 characters, so the rules go in as a file and a long task as a pointer to its file
$rulesFile = Join-Path $app 'lead.md'
$rulesArg = if ((& claude --help 2>$null | Out-String) -match 'append-system-prompt-file') { @('--append-system-prompt-file', $rulesFile) }
            else { @('--append-system-prompt', (Q ([IO.File]::ReadAllText($rulesFile)))) }   # older Claude Code
$task = [IO.File]::ReadAllText($TaskFile).Trim()
$prompt = if ($task -eq '/roblox' -or -not $task) { '/roblox' }
          elseif ($task.Length -gt 6000) { Q "Do this task now. The full brief is long, so read all of it first: $TaskFile" }
          else { Q ("Do this task now (full brief below; also saved at $TaskFile):`n`n" + $task) }
# Add Customuse / Unity if lyopz set them up (customuse-setup.ps1 / unity-setup.ps1 save them outside the repo)
$mcp = Join-Path $app 'roblox-mcp.json'
$extra = [ordered]@{}
$cu = Join-Path $env:USERPROFILE 'RobloxGames\.degen\customuse-mcp.json'
if (Test-Path $cu) {
  $srv = [IO.File]::ReadAllText($cu) | ConvertFrom-Json
  if ($srv.url -match '^https://') { $extra.customuse = $srv }
}
$un = Join-Path $env:USERPROFILE 'RobloxGames\.degen\unity-mcp.json'
if (Test-Path $un) { $extra.unityMCP = [IO.File]::ReadAllText($un) | ConvertFrom-Json }
# Blender: a blender-mcp.json override if saved, else the Claude app's Blender extension (rigging, reshaping, fixes)
$bl = Join-Path $env:USERPROFILE 'RobloxGames\.degen\blender-mcp.json'
if (Test-Path $bl) { $extra.Blender = [IO.File]::ReadAllText($bl) | ConvertFrom-Json }
else {
  $bx = Get-ChildItem "$env:LOCALAPPDATA\Claude-Data\*\Claude Extensions\ant.dir.gh.blender.blender-mcp\.venv\Scripts\blender-mcp.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
  if ($bx) { $extra.Blender = [ordered]@{ command = $bx; args = @() } }
}
if ($extra.Count) {
  $cfg = [IO.File]::ReadAllText($mcp) | ConvertFrom-Json
  foreach ($k in $extra.Keys) { $cfg.mcpServers | Add-Member -NotePropertyName $k -NotePropertyValue $extra[$k] -Force }
  $mcp = Join-Path $env:USERPROFILE 'RobloxGames\.degen\lead-mcp.json'
  [IO.File]::WriteAllText($mcp, ($cfg | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding $false))
}
# Unity set up -> open the polish project minimized so unityMCP connects by itself (it pops up while designing)
if ($extra.Contains('unityMCP')) { & powershell -ExecutionPolicy Bypass -NoProfile -File (Join-Path $app 'unity-open.ps1') | Out-Null }
# "Continue last task": reopen that project's last Lead conversation if Claude Code still has it, else start fresh with the task file
if ($Resume -and @(Get-ChildItem (Join-Path $env:USERPROFILE '.claude\projects') -Recurse -Filter "$Resume.jsonl" -ErrorAction SilentlyContinue).Count) {
  & claude --resume $Resume --strict-mcp-config --mcp-config $mcp --settings $Settings @rulesArg
} else {
  & claude --strict-mcp-config --mcp-config $mcp --settings $Settings @rulesArg $prompt
}
Remove-Item $leadFile -Force -ErrorAction SilentlyContinue
