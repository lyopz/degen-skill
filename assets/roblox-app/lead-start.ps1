# Opens a Roblox Lead window (Claude Code) with a task file. Used by the app server, the degenroblox:// link and launch.ps1.
param([string]$TaskFile)
$app = $PSScriptRoot
$games = Join-Path $env:USERPROFILE 'RobloxGames'; New-Item -ItemType Directory -Force -Path (Join-Path $games '.degen') | Out-Null
$ps = 'powershell -NoProfile -ExecutionPolicy Bypass -File '
$act = @{ type = 'command'; command = $ps + '"' + (Join-Path $app 'activity-hook.ps1') + '"' }
$ask = @{ type = 'command'; command = $ps + '"' + (Join-Path $app 'ask-hook.ps1') + '"'; timeout = 3600 }
$settings = @{ hooks = @{
  PreToolUse       = @(@{ matcher = '*'; hooks = @($act) }, @{ matcher = 'AskUserQuestion'; hooks = @($ask) })
  SubagentStop     = @(@{ hooks = @($act) }); Stop = @(@{ hooks = @($act) })
  UserPromptSubmit = @(@{ hooks = @($act) }); Notification = @(@{ hooks = @($act) }) } }
$sf = Join-Path $app 'roblox-hooks.json'
[IO.File]::WriteAllText($sf, ($settings | ConvertTo-Json -Depth 8), (New-Object Text.UTF8Encoding $false))
if (-not $TaskFile -or -not (Test-Path $TaskFile)) {
  $TaskFile = Join-Path $env:TEMP 'degen-roblox-task-open.md'; [IO.File]::WriteAllText($TaskFile, '/roblox', (New-Object Text.UTF8Encoding $false))
}
Start-Process powershell.exe -ArgumentList @('-NoExit', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $app 'lead-run.ps1'), $TaskFile, $sf)
