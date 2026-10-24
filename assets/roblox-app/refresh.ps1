# Rebuilds roblox-data.js (skills, agents, templates, bibles, refs the app shows) and copies the Studio templates plugin.
# Run by launch.ps1 when the app opens and by update.ps1 after the app pulls an update.
$ErrorActionPreference = 'SilentlyContinue'
$app  = $PSScriptRoot
$repo = Split-Path -Parent (Split-Path -Parent $app)
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
