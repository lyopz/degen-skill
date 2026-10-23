# Degen Roblox launcher: pull updates, build roblox-data.js, sync Studio templates, open the app,
# and (unless -AppOnly) open a FAST Roblox Claude Code window (only the Roblox_Studio connection, no claude-flow).
param([switch]$AppOnly)
if (-not $PSBoundParameters.ContainsKey('AppOnly')) { $AppOnly = $true }  # app opens alone; start tasks from the app (or use -AppOnly:$false)
$ErrorActionPreference = 'SilentlyContinue'
$app  = $PSScriptRoot
function Start-Activity($app) {
  $logDir = Join-Path $env:USERPROFILE 'RobloxGames'; New-Item -ItemType Directory -Force -Path $logDir | Out-Null
  $hook = (Join-Path $app 'activity-hook.ps1')
  $cmdline = 'powershell -NoProfile -ExecutionPolicy Bypass -File "' + $hook + '"'
  $h = @{ type = 'command'; command = $cmdline }
  $settings = @{ hooks = @{ PreToolUse = @(@{ matcher = '*'; hooks = @($h) }); SubagentStop = @(@{ hooks = @($h) }); Stop = @(@{ hooks = @($h) }); UserPromptSubmit = @(@{ hooks = @($h) }) } }
  $sf = Join-Path $app 'roblox-hooks.json'
  [IO.File]::WriteAllText($sf, ($settings | ConvertTo-Json -Depth 8), (New-Object Text.UTF8Encoding $false))
  $open = Get-Process powershell -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -eq 'Roblox Activity' }
  if (-not $open) { Start-Process powershell.exe -ArgumentList @('-NoExit','-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $app 'activity.ps1')) }
  return $sf
}

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
$bibles = foreach ($f in Get-ChildItem (Join-Path $sk 'roblox-art-style\projects') -Filter *.md | Where-Object { $_.Name -ne '_template.md' }) { [ordered]@{ n = $f.BaseName; t = (Read-Text $f.FullName) } }
$studies = foreach ($f in Get-ChildItem (Join-Path $sk 'roblox-game-study\studies') -Filter *.md) { [ordered]@{ n = $f.BaseName; t = (Read-Text $f.FullName) } }
$refs = [ordered]@{
  checklist = Read-Text (Join-Path $sk 'roblox-design\references\first-try.md')
  maps = Read-Text (Join-Path $sk 'roblox-design\references\maps.md')
  ui = Read-Text (Join-Path $sk 'roblox-design\references\ui.md')
  feel = Read-Text (Join-Path $sk 'roblox-design\references\game-feel.md')
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

$url = 'file:///' + ((Join-Path $app 'index.html') -replace '\\', '/')
$dataDir = Join-Path $env:LOCALAPPDATA 'DegenRobloxApp'
$argList = @("--app=$url", "--user-data-dir=$dataDir", '--window-size=1300,880', '--no-first-run')
$edge = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe", "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($edge) { Start-Process $edge -ArgumentList $argList } else { Start-Process $url }

if (-not $AppOnly) {
  $games = Join-Path $env:USERPROFILE 'RobloxGames'; New-Item -ItemType Directory -Force -Path $games | Out-Null
  $mcp = Join-Path $app 'roblox-mcp.json'
  # Fast Roblox Claude: only Roblox_Studio MCP, Claude credits (API key hidden for this window only)
  $lead = Join-Path $app 'lead.md'; $sf = Start-Activity $app
  $cmd = "Remove-Item Env:ANTHROPIC_API_KEY -ErrorAction SilentlyContinue; Set-Location '$games'; `$host.UI.RawUI.WindowTitle='Roblox Lead'; claude --strict-mcp-config --mcp-config '$mcp' --settings '$sf' --append-system-prompt (Get-Content -Raw '$lead') '/roblox'"
  Start-Process powershell.exe -ArgumentList @('-NoExit', '-NoProfile', '-Command', $cmd)
}
