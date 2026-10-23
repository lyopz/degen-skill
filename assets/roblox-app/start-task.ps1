# Opened by the degenroblox:// link from the Degen Roblox app: starts a Roblox Claude lead window with the task.
param([string]$Url)
$app = $PSScriptRoot
function Start-Activity($app) {
  $logDir = Join-Path $env:USERPROFILE 'RobloxGames'; New-Item -ItemType Directory -Force -Path $logDir | Out-Null
  $hook = (Join-Path $app 'activity-hook.ps1')
  $cmdline = 'powershell -NoProfile -ExecutionPolicy Bypass -File "' + $hook + '"'
  $h = @{ type = 'command'; command = $cmdline }
  $settings = @{ hooks = @{ PreToolUse = @(@{ matcher = '*'; hooks = @($h) }); SubagentStop = @(@{ hooks = @($h) }); Stop = @(@{ hooks = @($h) }); UserPromptSubmit = @(@{ hooks = @($h) }) } }
  $sf = Join-Path $app 'roblox-hooks.json'
  [IO.File]::WriteAllText($sf, ($settings | ConvertTo-Json -Depth 8), (New-Object Text.UTF8Encoding $false))
  # live feed shows in the Degen Roblox app (Activity panel); activity.ps1 is an optional separate window
  return $sf
}

$games = Join-Path $env:USERPROFILE 'RobloxGames'; New-Item -ItemType Directory -Force -Path $games | Out-Null
$task = ''
if ($Url -match '[?&]b=([^&]+)') {
  $b = $Matches[1].Replace('-', '+').Replace('_', '/'); while ($b.Length % 4) { $b += '=' }
  try { $task = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b)) } catch { $task = '' }
}
$f = Join-Path $env:TEMP ("degen-roblox-task-" + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.md')
[IO.File]::WriteAllText($f, $(if ($task) { $task } else { '/roblox' }), (New-Object Text.UTF8Encoding $false))
$mcp = Join-Path $app 'roblox-mcp.json'; $lead = Join-Path $app 'lead.md'; $sf = Start-Activity $app
$cmd = "Remove-Item Env:ANTHROPIC_API_KEY -ErrorAction SilentlyContinue; Set-Location '$games'; `$host.UI.RawUI.WindowTitle='Roblox Lead'; claude --strict-mcp-config --mcp-config '$mcp' --settings '$sf' --append-system-prompt (Get-Content -Raw '$lead') (Get-Content -Raw '$f')"
Start-Process powershell.exe -ArgumentList @('-NoExit', '-NoProfile', '-Command', $cmd)
