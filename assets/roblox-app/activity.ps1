# The "Roblox Activity" window: live, plain-English feed of what the Roblox team is doing.
$host.UI.RawUI.WindowTitle = 'Roblox Activity'
$log = Join-Path $env:USERPROFILE 'RobloxGames\activity.log'
if (-not (Test-Path $log)) { New-Item -ItemType File -Force -Path $log | Out-Null }
Write-Host '  DEGEN ROBLOX - what the team is doing' -ForegroundColor Red
Write-Host '  ------------------------------------' -ForegroundColor DarkGray
Get-Content $log -Tail 12 -Wait | ForEach-Object {
  $c = if ($_ -match 'Done') { 'Green' } elseif ($_ -match 'Started|finished') { 'Yellow' } elseif ($_ -match 'Higgsfield') { 'Magenta' } elseif ($_ -match 'error') { 'Red' } else { 'Gray' }
  Write-Host ('  ' + $_) -ForegroundColor $c
}
