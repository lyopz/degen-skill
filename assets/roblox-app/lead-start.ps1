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
$mcp = Join-Path $app 'roblox-mcp.json'; $lead = Join-Path $app 'lead.md'
$cmd = "Remove-Item Env:ANTHROPIC_API_KEY -ErrorAction SilentlyContinue; `$env:DEGEN_APP='$app'; Set-Location '$games'; `$host.UI.RawUI.WindowTitle='Roblox Lead'; claude --strict-mcp-config --mcp-config '$mcp' --settings '$sf' --append-system-prompt (Get-Content -Raw '$lead') (Get-Content -Raw '$TaskFile')"
Start-Process powershell.exe -ArgumentList @('-NoExit', '-NoProfile', '-Command', $cmd)
