# Runs inside the Roblox Lead window. Passes the lead rules + task to Claude Code safely
# (Windows PowerShell 5.1 breaks arguments that contain double quotes, so they are escaped here).
param([string]$TaskFile, [string]$Settings)
$app = $PSScriptRoot
Remove-Item Env:ANTHROPIC_API_KEY -ErrorAction SilentlyContinue
$env:DEGEN_APP = $app
Set-Location (Join-Path $env:USERPROFILE 'RobloxGames')
$host.UI.RawUI.WindowTitle = 'Roblox Lead'
function Q([string]$s) { ($s -replace '(\\*)"', '$1$1\"') }   # escape quotes for native arguments
$rules = Q ([IO.File]::ReadAllText((Join-Path $app 'lead.md')))
$task = [IO.File]::ReadAllText($TaskFile).Trim()
$prompt = if ($task -eq '/roblox' -or -not $task) { '/roblox' } else { Q ("Do this task now (full brief below; also saved at $TaskFile):`n`n" + $task) }
& claude --strict-mcp-config --mcp-config (Join-Path $app 'roblox-mcp.json') --settings $Settings --append-system-prompt $rules $prompt
