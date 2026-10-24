# In-app updates (the app's Update button + its check every few minutes), so lyopz never has to run git pull himself.
#   update.ps1 -Check   fetch from GitHub, write how many new updates there are
#   update.ps1          pull them, rebuild roblox-data.js + Studio plugin (refresh.ps1), restart server.ps1 if it changed
# Started hidden by server.ps1 (/api/update). Writes its state to ~/RobloxGames/.degen/update.json for the app to read.
param([switch]$Check)
$ErrorActionPreference = 'SilentlyContinue'
$app  = $PSScriptRoot
$repo = Split-Path -Parent (Split-Path -Parent $app)
$D    = Join-Path $env:USERPROFILE 'RobloxGames\.degen'; New-Item -ItemType Directory -Force -Path $D | Out-Null
$uf   = Join-Path $D 'update.json'
$utf8 = New-Object Text.UTF8Encoding $false
function Save($o) { $o.at = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'); [IO.File]::WriteAllText($uf, ($o | ConvertTo-Json -Compress), $utf8) }
function Head { (git -C $repo rev-parse --short HEAD 2>$null | Out-String).Trim() }
$env:GIT_TERMINAL_PROMPT = '0'

if ($Check) {
  Save ([ordered]@{ state = 'checking'; behind = 0; head = (Head); msg = '' })
  git -C $repo fetch --quiet 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0) { Save ([ordered]@{ state = 'error'; behind = 0; head = (Head); msg = 'Could not reach GitHub' }); exit 0 }
  $n = [int]((git -C $repo rev-list --count 'HEAD..@{u}' 2>$null | Out-String).Trim())
  $what = @(git -C $repo log --format=%s 'HEAD..@{u}' 2>$null | Select-Object -First 5)
  Save ([ordered]@{ state = 'checked'; behind = $n; head = (Head); msg = ($what -join "`n") })
  exit 0
}

Save ([ordered]@{ state = 'updating'; behind = 0; head = (Head); msg = '' })
$before = Head
$srv = Join-Path $app 'server.ps1'; $srvBefore = (Get-FileHash $srv).Hash
git -C $repo pull --quiet --ff-only --autostash 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
  git -C $repo pull --quiet --no-edit --autostash 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0) {
    git -C $repo merge --abort 2>$null | Out-Null
    Save ([ordered]@{ state = 'error'; behind = 0; head = (Head); msg = 'Update failed (no internet, or a file changed on this PC clashes with the update)' }); exit 0
  }
}
$after = Head
$changed = @(if ($before -ne $after) { git -C $repo diff --name-only $before $after 2>$null })
& (Join-Path $app 'refresh.ps1')

# server.ps1 itself changed? start the new one (the app reconnects by itself)
$restart = (Get-FileHash $srv).Hash -ne $srvBefore
if ($restart) {
  Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -like '*roblox-app*server.ps1*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
  Remove-Item (Join-Path $D 'server.alive') -Force; Start-Sleep -Milliseconds 800
  Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', ('"' + $srv + '"'))
}
Save ([ordered]@{ state = 'done'; behind = 0; head = $after; from = $before; files = $changed.Count; restarted = $restart
                  msg = $(if ($before -eq $after) { 'Already up to date' } else { "Updated ($($changed.Count) files)" }) })
