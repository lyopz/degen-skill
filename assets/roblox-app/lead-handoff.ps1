# Called by lead-start.ps1 before a new Lead window opens. If an older Lead window for the same project is still open:
#  1. the old window is closed if it is idle (waiting for you); a busy one gets 45 s to finish its step, else it is
#     left alone and lead-start shows lyopz a pop-up naming the window to close,
#  2. a copy of the old Lead's chat (claude --resume --fork-session) writes its task + progress into the project's
#     HANDOFF.md and replies with a short summary,
#  3. that summary goes on top of the new Lead's task file, so the new Lead carries the old task on.
# Open Leads are tracked in ~/RobloxGames/.degen/leads/<pid>.json (lead-run.ps1 + activity-hook.ps1). Local only.
# Prints: lines "CLOSE_ASK|<window title>" for windows lyopz must close, and "NO_RESUME" if -Resume must be dropped.
param([string]$TaskFile, [string]$Resume)
$ErrorActionPreference = 'SilentlyContinue'
$RG = Join-Path $env:USERPROFILE 'RobloxGames'; $D = Join-Path $RG '.degen'; $LD = Join-Path $D 'leads'
if (-not (Test-Path $LD)) { exit 0 }
$utf8 = New-Object Text.UTF8Encoding $false

function Say($m) {   # one line in the app's Activity panel
  $jf = Join-Path $D 'activity.json'
  $st = if (Test-Path $jf) { [IO.File]::ReadAllText($jf) | ConvertFrom-Json } else { $null }
  if (-not $st) { $st = [pscustomobject]@{ status = 'idle'; active = @{}; lines = @() } }
  $st.lines = @(@($st.lines) + [pscustomobject]@{ t = (Get-Date -Format 'HH:mm'); who = 'lead'; msg = $m; k = '' }) | Select-Object -Last 80
  [IO.File]::WriteAllText($jf, ($st | ConvertTo-Json -Depth 6 -Compress), $utf8)
}
function Get-Lead($f) {   # the lead's record, or $null if its window is gone (pid reused counts as gone)
  $l = [IO.File]::ReadAllText($f.FullName) | ConvertFrom-Json
  $p = Get-Process -Id ([int]$l.pid)
  if (-not $p -or [math]::Abs($p.StartTime.Ticks - [long]$l.ticks) -gt 20000000) { Remove-Item $f.FullName -Force; return $null }
  $l | Add-Member -NotePropertyName file -NotePropertyValue $f.FullName -Force; $l
}

$task = if ($TaskFile -and (Test-Path $TaskFile)) { [IO.File]::ReadAllText($TaskFile).Trim() } else { '' }
$proj = ''
foreach ($m in [regex]::Matches($task, 'RobloxGames[\\/]+([\w\-\.]+)')) {
  $n = $m.Groups[1].Value
  if ($n -notlike '.*' -and $n -notlike '_*' -and $n -ne 'imports' -and (Test-Path (Join-Path $RG $n) -PathType Container)) { $proj = (Get-Item (Join-Path $RG $n)).Name; break }
}
# Same project (a project inside a game counts as that game: same Studio place), or a Lead that hasn't touched a project yet. No project named in the new task -> every open Lead
# (they would all be driving the same Studio anyway).
$old = @(Get-ChildItem $LD -Filter '*.json' | ForEach-Object { Get-Lead $_ } | Where-Object { $_ -and (-not $proj -or -not $_.p -or (([string]$_.p -split '/')[0] -eq $proj)) })
if (-not $old.Count) { exit 0 }

$notes = @()
foreach ($l in $old) {
  $title = [string]$l.title; $lp = if ($l.p) { [string]$l.p } else { $proj }
  # Close it only when it is idle (waiting for lyopz). Give a busy one a short moment to finish its step first.
  $until = (Get-Date).AddSeconds(45); $now = $l
  while ($now -and $now.busy -and (Get-Date) -lt $until) { Start-Sleep -Seconds 3; $now = if (Test-Path $l.file) { Get-Lead (Get-Item $l.file) } else { $null } }
  $closed = -not $now
  if ($now -and -not $now.busy) {
    & taskkill.exe /PID ([int]$l.pid) /T /F 2>$null | Out-Null
    Start-Sleep -Milliseconds 800
    if (-not (Get-Process -Id ([int]$l.pid))) { Remove-Item $l.file -Force; $closed = $true; Say "Closed the old Lead window ($title)" }
  }
  if (-not $closed) { "CLOSE_ASK|$title" }
  $same = $Resume -and $Resume -eq $l.sid
  if ($same -and $closed) { continue }      # "Continue last task" reopens that same chat, so it already knows everything
  if ($same) { 'NO_RESUME' }                # never run two windows on one chat: the new Lead starts fresh with the notes

  # A copy of the old chat (the old window is not touched) writes the handoff and a short summary
  $sum = ''
  if ([string]$l.sid -match '^[\w\-]+$') {
    Say "Passing the old Lead's task to the new Lead..."
    $hf = if ($lp) { "~/RobloxGames/$lp/HANDOFF.md" } else { '~/RobloxGames/.degen/last-handoff.md' }
    $ask = "STOP working on the task. A new Lead window is taking over from you right now, so do not continue it and do not use any tool except Read, Write and Edit. " +
      "1) Update $hf : keep what is there, and put a section at the top called '## Handoff from previous Lead ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))' with: the task you were doing, what is finished, what is half-done (exact files and where in the place), and the exact next steps. " +
      "2) Then reply with only 3 to 8 short lines: the task, what is done, and the next steps."
    $emptyMcp = Join-Path $D 'empty-mcp.json'; [IO.File]::WriteAllText($emptyMcp, '{"mcpServers":{}}', $utf8)
    $job = Start-Job -ArgumentList $RG, $l.sid, $emptyMcp, $ask -ScriptBlock {
      param($rg, $sid, $mcp, $ask)
      Remove-Item Env:ANTHROPIC_API_KEY -ErrorAction SilentlyContinue; Set-Location $rg
      # prompt goes in on stdin: Windows PowerShell 5.1 mangles native arguments that contain quotes
      $ask | & claude -p --model claude-opus-5-5 --resume $sid --fork-session --strict-mcp-config --mcp-config $mcp --allowedTools 'Read,Write,Edit' --permission-mode acceptEdits --max-turns 8 2>$null
    }
    if (Wait-Job $job -Timeout 240) { $sum = ((Receive-Job $job) -join "`n").Trim() }
    Remove-Job $job -Force
  }
  if ($sum.Length -gt 3000) { $sum = $sum.Substring(0, 3000) + '...' }
  $n = "## Taken over from the previous Lead window ($title)`n"
  if ($l.task) { $n += "It was doing: $($l.task)`n" }
  if ($lp) { $n += "Project: ~/RobloxGames/$lp (its HANDOFF.md has a 'Handoff from previous Lead' section).`n" }
  $n += $(if ($sum) { "Its notes:`n$sum`n" } else { "It could not write notes, so check HANDOFF.md and the place to see how far it got.`n" })
  if (-not $closed) { $n += "That window may still be open: do not work on the same thing at the same time as it.`n" }
  $notes += $n
}
if (-not $notes.Count) { exit 0 }

# New task = takeover notes + what lyopz asked for now (a bare app open just carries the old task on)
$new = ($notes -join "`n")
$new += $(if ($task -and $task -ne '/roblox') { "`nCarry that on first, unless the new task below replaces it.`n`n## New task`n$task" } else { "`nCarry that task on now." })
[IO.File]::WriteAllText($TaskFile, $new, $utf8)
