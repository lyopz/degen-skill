# Degen Roblox launcher: pull updates, build roblox-data.js, sync Studio templates, open the app,
# and (unless -AppOnly) open a FAST Roblox Claude Code window (only the Roblox_Studio connection, no claude-flow).
param([switch]$AppOnly)
if (-not $PSBoundParameters.ContainsKey('AppOnly')) { $AppOnly = $true }  # app opens alone; start tasks from the app (or use -AppOnly:$false)
$ErrorActionPreference = 'SilentlyContinue'
$app  = $PSScriptRoot
$repo = Split-Path -Parent (Split-Path -Parent $app)
if (-not $env:DEGEN_NO_PULL) { git -C $repo pull --quiet --ff-only 2>$null | Out-Null }

& (Join-Path $app 'refresh.ps1')

# local app server (two-way link with the Lead window)
$alive = Join-Path $env:USERPROFILE 'RobloxGames\.degen\server.alive'
# server.ps1 changed (git pull) since the running server started? stop the old one so the new code runs
$ver = Join-Path $env:USERPROFILE 'RobloxGames\.degen\server.ver'
$cur = [string](Get-Item (Join-Path $app 'server.ps1')).LastWriteTimeUtc.Ticks
if (-not (Test-Path $ver) -or ([IO.File]::ReadAllText($ver).Trim() -ne $cur)) {
  Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -like '*roblox-app*server.ps1*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
  Remove-Item $alive -Force; Start-Sleep -Milliseconds 600
}
if (-not (Test-Path $alive) -or ((Get-Date) - (Get-Item $alive).LastWriteTime).TotalSeconds -gt 20) {
  Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', (Join-Path $app 'server.ps1'))
  Start-Sleep -Milliseconds 1200
}
$url = 'http://localhost:7777/'
$dataDir = Join-Path $env:LOCALAPPDATA 'DegenRobloxApp'
$argList = @("--app=$url", "--user-data-dir=$dataDir", '--window-size=1300,880', '--no-first-run', '--autoplay-policy=no-user-gesture-required')
$edge = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe", "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($edge) { Start-Process $edge -ArgumentList $argList } else { Start-Process $url }

if (-not $AppOnly) { & (Join-Path $app 'lead-start.ps1') }
