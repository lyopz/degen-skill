# Runs inside the Roblox Lead window. Passes the lead rules + task to Claude Code safely
# (Windows PowerShell 5.1 breaks arguments that contain double quotes, so they are escaped here).
param([string]$TaskFile, [string]$Settings, [string]$Resume)
$app = $PSScriptRoot
Remove-Item Env:ANTHROPIC_API_KEY -ErrorAction SilentlyContinue
$env:DEGEN_APP = $app
Set-Location (Join-Path $env:USERPROFILE 'RobloxGames')
$host.UI.RawUI.WindowTitle = 'Roblox Lead'
function Q([string]$s) { ($s -replace '(\\*)"', '$1$1\"') }   # escape quotes for native arguments
$rules = Q ([IO.File]::ReadAllText((Join-Path $app 'lead.md')))
$task = [IO.File]::ReadAllText($TaskFile).Trim()
$prompt = if ($task -eq '/roblox' -or -not $task) { '/roblox' } else { Q ("Do this task now (full brief below; also saved at $TaskFile):`n`n" + $task) }
# Add Customuse if lyopz set it up (customuse-setup.ps1 saves the address outside the repo)
$mcp = Join-Path $app 'roblox-mcp.json'
$cu = Join-Path $env:USERPROFILE 'RobloxGames\.degen\customuse-mcp.json'
if (Test-Path $cu) {
  $srv = [IO.File]::ReadAllText($cu) | ConvertFrom-Json
  if ($srv.url -match '^https://') {
    $cfg = [IO.File]::ReadAllText($mcp) | ConvertFrom-Json
    $cfg.mcpServers | Add-Member -NotePropertyName customuse -NotePropertyValue $srv -Force
    $mcp = Join-Path $env:USERPROFILE 'RobloxGames\.degen\lead-mcp.json'
    [IO.File]::WriteAllText($mcp, ($cfg | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding $false))
  }
}
# "Continue last task": reopen that project's last Lead conversation if Claude Code still has it, else start fresh with the task file
if ($Resume -and @(Get-ChildItem (Join-Path $env:USERPROFILE '.claude\projects') -Recurse -Filter "$Resume.jsonl" -ErrorAction SilentlyContinue).Count) {
  & claude --resume $Resume --strict-mcp-config --mcp-config $mcp --settings $Settings --append-system-prompt $rules
  return
}
& claude --strict-mcp-config --mcp-config $mcp --settings $Settings --append-system-prompt $rules $prompt
