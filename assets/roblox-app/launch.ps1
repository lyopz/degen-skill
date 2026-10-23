# Degen Roblox launcher: pull updates, build roblox-data.js, sync Studio templates, open the app,
# and (unless -AppOnly) open a FAST Roblox Claude Code window (only the Roblox_Studio connection, no claude-flow).
param([switch]$AppOnly)
if (-not $PSBoundParameters.ContainsKey('AppOnly')) { $AppOnly = $true }  # app opens alone; start tasks from the app (or use -AppOnly:$false)
$ErrorActionPreference = 'SilentlyContinue'
$app  = $PSScriptRoot
$repo = Split-Path -Parent (Split-Path -Parent $app)
if (-not $env:DEGEN_NO_PULL) { git -C $repo pull --quiet --ff-only 2>$null | Out-Null }

function Read-Text($p) { if (Test-Path $p) { [IO.File]::ReadAllText($p) } else { '' } }
function Get-Desc($file) {
  $lines = Get-Content $file -Encoding UTF8
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^description:\s*(.*)$') {
      $d = $Matches[1].Trim()
      if ($d -in @('|', '>', '|-', '>-')) { $parts=@(); for ($j=$i+1; $j -lt $lines.Count -and $lines[$j] -match '^\s+\S'; $j++) { $parts += $lines[$j].Trim() }; $d = $parts -join ' ' }
      return $d.Trim('"')
    }
  }
  ''
}
$sk = Join-Path $repo 'skills'
$skills = foreach ($d in Get-ChildItem $sk -Directory | Where-Object { $_.Name -like 'roblox-*' -or $_.Name -in @('3d-assets','three-best-practices') } | Sort-Object Name) {
  $f = Join-Path $d.FullName 'SKILL.md'; if (Test-Path $f) { [ordered]@{ n = $d.Name; d = (Get-Desc $f) } } }
$agents = foreach ($f in Get-ChildItem (Join-Path $repo 'agents\roblox') -Filter *.md | Sort-Object Name) { [ordered]@{ n = $f.BaseName; d = (Get-Desc $f.FullName) } }
$tpls = foreach ($f in Get-ChildItem (Join-Path $sk 'roblox-templates\templates') -Filter *.lua | Sort-Object Name) {
  $head = (Get-Content $f.FullName -TotalCount 12 -Encoding UTF8 | Where-Object { $_ -like '--*' }) -join "`n"
  [ordered]@{ n = $f.BaseName; h = $head } }
# Style bibles are local only (~/RobloxGames/<project>/art-style.md), never in the repo
$rgDir = Join-Path $env:USERPROFILE 'RobloxGames'
$bibles = foreach ($d in @(Get-ChildItem $rgDir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike '.*' -and $_.Name -notlike '_*' -and $_.Name -ne 'imports' })) { $f = Join-Path $d.FullName 'art-style.md'; if (Test-Path $f) { [ordered]@{ n = $d.Name; t = (Read-Text $f) } } }
$studies = foreach ($f in Get-ChildItem (Join-Path $sk 'roblox-game-study\studies') -Filter *.md) { [ordered]@{ n = $f.BaseName; t = (Read-Text $f.FullName) } }
$refs = [ordered]@{
  checklist = Read-Text (Join-Path $sk 'roblox-design\references\first-try.md')
  maps = Read-Text (Join-Path $sk 'roblox-design\references\maps.md')
  ui = Read-Text (Join-Path $sk 'roblox-design\references\ui.md')
  feel = Read-Text (Join-Path $sk 'roblox-design\references\game-feel.md')
  pets = Read-Text (Join-Path $sk 'roblox-design\references\pets-and-eggs.md')
  perf = Read-Text (Join-Path $sk 'roblox-design\references\performance.md')
  style = Read-Text (Join-Path $sk 'roblox-art-style\SKILL.md')
  lessons = Read-Text (Join-Path $sk 'roblox-dev\lessons.md')
  prompts = Read-Text (Join-Path $sk '3d-assets\prompts.md')
}
$data = [ordered]@{ skills=@($skills); agents=@($agents); templates=@($tpls); bibles=@($bibles); studies=@($studies); refs=$refs; built=(Get-Date -Format 'yyyy-MM-dd HH:mm') }
[IO.File]::WriteAllText((Join-Path $app 'roblox-data.js'), 'window.RBX=' + ($data | ConvertTo-Json -Depth 6 -Compress) + ';', (New-Object Text.UTF8Encoding $false))

# Studio templates plugin
$tpl = Join-Path $sk 'roblox-templates'
if (Test-Path (Join-Path $tpl 'DegenTemplates.rbxmx')) {
  $plugins = Join-Path $env:LOCALAPPDATA 'Roblox\Plugins'; New-Item -ItemType Directory -Force -Path $plugins | Out-Null
  Copy-Item (Join-Path $tpl 'DegenTemplates.rbxmx') $plugins -Force
}

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
