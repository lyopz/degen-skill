# Opened by the degenroblox:// link (fallback when the app server isn't running): starts a Roblox Lead window with the task.
param([string]$Url)
$task = ''
if ($Url -match '[?&]b=([^&]+)') {
  $b = $Matches[1].Replace('-', '+').Replace('_', '/'); while ($b.Length % 4) { $b += '=' }
  try { $task = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b)) } catch { $task = '' }
}
$f = Join-Path $env:TEMP ("degen-roblox-task-" + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.md')
[IO.File]::WriteAllText($f, $(if ($task) { $task } else { '/roblox' }), (New-Object Text.UTF8Encoding $false))
& (Join-Path $PSScriptRoot 'lead-start.ps1') $f
