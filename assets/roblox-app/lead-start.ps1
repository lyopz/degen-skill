# Opens a Roblox Lead window (Claude Code) with a task file. Used by the app server, the degenroblox:// link and launch.ps1.
param([string]$TaskFile, [string]$Resume)   # -Resume <session id>: reopen that Lead conversation ("Continue last task")
$app = $PSScriptRoot
# Get the newest skills first, so a skill added a minute ago is in this Lead (lyopz never has to reopen the app)
$repo = Split-Path -Parent (Split-Path -Parent $app)
if (-not $env:DEGEN_NO_PULL) {
  $env:GIT_TERMINAL_PROMPT = '0'
  git -C $repo pull --quiet --ff-only 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0) { git -C $repo pull --quiet --no-edit 2>$null | Out-Null; if ($LASTEXITCODE -ne 0) { git -C $repo merge --abort 2>$null | Out-Null } }
}
$games = Join-Path $env:USERPROFILE 'RobloxGames'; New-Item -ItemType Directory -Force -Path (Join-Path $games '.degen') | Out-Null
$ps = 'powershell -NoProfile -ExecutionPolicy Bypass -File '
$act = @{ type = 'command'; command = $ps + '"' + (Join-Path $app 'activity-hook.ps1') + '"' }
$ask = @{ type = 'command'; command = $ps + '"' + (Join-Path $app 'ask-hook.ps1') + '"'; timeout = 3600 }
$settings = @{ hooks = @{
  PreToolUse       = @(@{ matcher = '*'; hooks = @($act) }, @{ matcher = 'AskUserQuestion'; hooks = @($ask) })
  SubagentStop     = @(@{ hooks = @($act) }); Stop = @(@{ hooks = @($act) })
  UserPromptSubmit = @(@{ hooks = @($act) }); Notification = @(@{ hooks = @($act) }) } }
$sf = Join-Path $app 'roblox-hooks.json'
[IO.File]::WriteAllText($sf, ($settings | ConvertTo-Json -Depth 8), (New-Object Text.UTF8Encoding $false))
if (-not $TaskFile -or -not (Test-Path $TaskFile)) {
  $TaskFile = Join-Path $env:TEMP 'degen-roblox-task-open.md'; [IO.File]::WriteAllText($TaskFile, '/roblox', (New-Object Text.UTF8Encoding $false))
}
# An older Lead still open for this project? Hand its task to this one and close it (or ask lyopz to)
$ho = @(& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $app 'lead-handoff.ps1') -TaskFile $TaskFile -Resume $Resume)
if ($ho -contains 'NO_RESUME') { $Resume = '' }
$args2 = @('-NoExit', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"' + (Join-Path $app 'lead-run.ps1') + '"'), ('"' + $TaskFile + '"'), ('"' + $sf + '"'))
if ($Resume -match '^[\w\-]+$') { $args2 += @('-Resume', $Resume) }
Start-Process powershell.exe -ArgumentList $args2
$open = @($ho | Where-Object { $_ -like 'CLOSE_ASK|*' } | ForEach-Object { $_.Substring(10) })
if ($open.Count) {
  Add-Type -AssemblyName System.Windows.Forms
  $w = ($open | ForEach-Object { "  - $_" }) -join "`n"
  [System.Windows.Forms.MessageBox]::Show("The new Lead has taken over the old Lead's task, but this old window was still busy, so I left it open:`n`n$w`n`nPlease close it yourself (the X on that window) so the two don't work on the same game at once.", 'Degen Roblox', 'OK', 'Information', 'Button1', 'DefaultDesktopOnly') | Out-Null
}
