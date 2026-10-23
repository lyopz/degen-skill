# Opened by the degenroblox:// link from the Degen Roblox app: starts a Roblox Claude lead window with the task.
param([string]$Url)
$app = $PSScriptRoot
$games = Join-Path $env:USERPROFILE 'RobloxGames'; New-Item -ItemType Directory -Force -Path $games | Out-Null
$task = ''
if ($Url -match '[?&]b=([^&]+)') {
  $b = $Matches[1].Replace('-', '+').Replace('_', '/'); while ($b.Length % 4) { $b += '=' }
  try { $task = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b)) } catch { $task = '' }
}
$f = Join-Path $env:TEMP ("degen-roblox-task-" + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.md')
[IO.File]::WriteAllText($f, $(if ($task) { $task } else { '/roblox' }), (New-Object Text.UTF8Encoding $false))
$mcp = Join-Path $app 'roblox-mcp.json'; $lead = Join-Path $app 'lead.md'
$cmd = "Remove-Item Env:ANTHROPIC_API_KEY -ErrorAction SilentlyContinue; Set-Location '$games'; `$host.UI.RawUI.WindowTitle='Roblox Lead'; claude --strict-mcp-config --mcp-config '$mcp' --append-system-prompt (Get-Content -Raw '$lead') (Get-Content -Raw '$f')"
Start-Process powershell.exe -ArgumentList @('-NoExit', '-NoProfile', '-Command', $cmd)
