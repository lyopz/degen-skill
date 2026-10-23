# Degen Skills desktop app launcher.
# 1) pulls the latest skills from GitHub, 2) rebuilds skills.js from the skill files, 3) opens the app window.
$ErrorActionPreference = 'SilentlyContinue'
$app  = $PSScriptRoot
$repo = Split-Path -Parent (Split-Path -Parent $app)

if (-not $env:DEGEN_NO_PULL) { git -C $repo pull --quiet --ff-only 2>$null | Out-Null }

function Get-Desc($file) {
  $lines = Get-Content $file -Encoding UTF8
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^description:\s*(.*)$') {
      $d = $Matches[1].Trim()
      if ($d -in @('|', '>', '|-', '>-')) {
        $parts = @()
        for ($j = $i + 1; $j -lt $lines.Count -and $lines[$j] -match '^\s+\S'; $j++) { $parts += $lines[$j].Trim() }
        $d = $parts -join ' '
      }
      return $d.Trim('"')
    }
  }
  return ''
}

$skills = foreach ($dir in Get-ChildItem (Join-Path $repo 'skills') -Directory | Sort-Object Name) {
  $f = Join-Path $dir.FullName 'SKILL.md'
  if (Test-Path $f) { [ordered]@{ n = $dir.Name; d = (Get-Desc $f) } }
}
$data = [ordered]@{
  skills   = @($skills)
  agents   = @(Get-ChildItem (Join-Path $repo 'agents') -Recurse -Filter *.md).Count
  commands = @(Get-ChildItem (Join-Path $repo 'commands') -Recurse -Filter *.md).Count
}
$json = $data | ConvertTo-Json -Depth 5 -Compress
[IO.File]::WriteAllText((Join-Path $app 'skills.js'), "window.DEGEN=$json;", (New-Object Text.UTF8Encoding $false))

$glb = Join-Path $app 'src\chicken.glb'; $cj = Join-Path $app 'chicken.js'
if ((Test-Path $glb) -and (-not (Test-Path $cj) -or (Get-Item $glb).LastWriteTime -gt (Get-Item $cj).LastWriteTime)) {
  [IO.File]::WriteAllText($cj, 'window.CHICKEN="' + [Convert]::ToBase64String([IO.File]::ReadAllBytes($glb)) + '";')
}

# Roblox templates -> Studio plugin + a templates folder
$tpl = Join-Path $repo 'skills\roblox-templates'
if (Test-Path (Join-Path $tpl 'DegenTemplates.rbxmx')) {
  $plugins = Join-Path $env:LOCALAPPDATA 'Roblox\Plugins'
  New-Item -ItemType Directory -Force -Path $plugins | Out-Null
  Copy-Item (Join-Path $tpl 'DegenTemplates.rbxmx') $plugins -Force
  $docs = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Roblox Templates'
  New-Item -ItemType Directory -Force -Path $docs | Out-Null
  Copy-Item (Join-Path $tpl 'templates\rbxmx\*.rbxmx') $docs -Force
}

$url = 'file:///' + ((Join-Path $app 'index.html') -replace '\\', '/')
$dataDir = Join-Path $env:LOCALAPPDATA 'DegenSkillsApp'
$argList = @("--app=$url", "--user-data-dir=$dataDir", '--window-size=1280,860', '--no-first-run')
$edge = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe", "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
$chrome = @("$env:ProgramFiles\Google\Chrome\Application\chrome.exe", "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($edge) { Start-Process $edge -ArgumentList $argList }
elseif ($chrome) { Start-Process $chrome -ArgumentList $argList }
else { Start-Process $url }
