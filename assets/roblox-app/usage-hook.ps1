# Claude Code hook (PreToolUse, Stop, StopFailure): pauses the Lead when lyopz's Claude plan usage reaches 95%.
#  1. usage-line.ps1 (the Lead's status line) saves the 5-hour / weekly usage % and reset times to .degen\usage\<lead>.json.
#  2. PreToolUse: at 95% or more, the Lead may only Read/Write/Edit. Every other tool is refused with the reason
#     "write the handoff now", so it writes a 'Usage pause' section at the top of the project's HANDOFF.md and ends its turn.
#  3. Stop: pause stage -> 'wait', then this window's Claude is closed. lead-run.ps1 waits until the limit resets
#     and reopens the same chat (claude --resume) with "carry on".
#  4. StopFailure (rate_limit): the limit was hit before 95% was seen. No handoff is possible (no API), so it goes
#     straight to 'wait' and the resumed chat checks how far it got.
# State: .degen\pause\<lead>.json { sid, stage = handoff|wait, until (unix s), why, at, nag }. Local only.
param([string]$Close)
$ErrorActionPreference = 'SilentlyContinue'
$LIMIT = 95
$D = Join-Path $env:USERPROFILE 'RobloxGames\.degen'; $utf8 = New-Object Text.UTF8Encoding $false

# -Close <lead pid>: started hidden by the Stop/StopFailure hook. Closes the Claude running in that Lead window (and its
# MCP servers) so lead-run.ps1 can wait for the reset. The window itself (the PowerShell running lead-run) stays.
if ($Close -match '^\d+$') {
  Start-Sleep -Seconds 3   # let Claude finish saving the turn
  $all = @(Get-CimInstance Win32_Process)
  $kids = @($all | Where-Object { $_.ParentProcessId -eq [int]$Close -and $_.Name -ne 'conhost.exe' -and $_.ProcessId -ne $PID })
  $tree = [Collections.ArrayList]@(); $q = [Collections.Queue]@($kids)
  while ($q.Count) { $p = $q.Dequeue(); [void]$tree.Add($p); $all | Where-Object { $_.ParentProcessId -eq $p.ProcessId -and $_.ProcessId -ne $PID } | ForEach-Object { $q.Enqueue($_) } }
  foreach ($p in $tree) { Stop-Process -Id $p.ProcessId -Force }
  exit 0
}

[Console]::InputEncoding = [Text.Encoding]::UTF8; [Console]::OutputEncoding = [Text.Encoding]::UTF8
$e = [Console]::In.ReadToEnd() | ConvertFrom-Json
$lead = [string]$env:DEGEN_LEAD
if ($lead -notmatch '^\d+$') { exit 0 }   # only Roblox Lead windows (lead-run.ps1 sets DEGEN_LEAD)
$ev = $e.hook_event_name; $sid = [string]$e.session_id
$now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$PD = Join-Path $D 'pause'; New-Item -ItemType Directory -Force -Path $PD | Out-Null
$pf = Join-Path $PD "$lead.json"; $uf = Join-Path $D "usage\$lead.json"
$pz = if (Test-Path $pf) { [IO.File]::ReadAllText($pf) | ConvertFrom-Json } else { $null }
$u = if (Test-Path $uf) { [IO.File]::ReadAllText($uf) | ConvertFrom-Json } else { $null }

function Save($o) { [IO.File]::WriteAllText($pf, ($o | ConvertTo-Json -Compress), $utf8) }
function When([long]$t) {
  $d = [DateTimeOffset]::FromUnixTimeSeconds($t).LocalDateTime
  if ($d.Date -eq (Get-Date).Date) { $d.ToString('HH:mm') } else { $d.ToString('ddd HH:mm') }
}
function Say($m) {   # one line in the app's Activity panel
  $jf = Join-Path $D 'activity.json'
  $st = if (Test-Path $jf) { [IO.File]::ReadAllText($jf) | ConvertFrom-Json } else { $null }
  if (-not $st) { $st = [pscustomobject]@{ status = 'idle'; active = @{}; lines = @() } }
  $st.lines = @(@($st.lines) + [pscustomobject]@{ t = (Get-Date -Format 'HH:mm'); who = 'lead'; msg = $m; k = 'need' }) | Select-Object -Last 80
  [IO.File]::WriteAllText($jf, ($st | ConvertTo-Json -Depth 6 -Compress), $utf8)
  Add-Content -Path (Join-Path $env:USERPROFILE 'RobloxGames\activity.log') -Value ((Get-Date -Format 'HH:mm') + "  [lead] $m") -Encoding UTF8
}
function Hit($min) {   # the limit windows at or over $min %, with the latest reset time
  $r = @{ why = @(); until = 0 }
  if ($u -and $u.sid -eq $sid) {
    if ($null -ne $u.five -and [double]$u.five -ge $min -and [long]$u.fiveAt -gt $now) { $r.why += ('5-hour usage {0:0}%' -f [double]$u.five); $r.until = [math]::Max($r.until, [long]$u.fiveAt) }
    if ($null -ne $u.week -and [double]$u.week -ge $min -and [long]$u.weekAt -gt $now) { $r.why += ('weekly usage {0:0}%' -f [double]$u.week); $r.until = [math]::Max($r.until, [long]$u.weekAt) }
  }
  $r
}
function CloseClaude { Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"' + $PSCommandPath + '"'), '-Close', $lead) }
function HandoffFile {
  $lr = Join-Path $D "leads\$lead.json"
  $p = if (Test-Path $lr) { [string]([IO.File]::ReadAllText($lr) | ConvertFrom-Json).p } else { '' }
  if ($p) { Join-Path $env:USERPROFILE "RobloxGames\$p\HANDOFF.md" } else { Join-Path $D 'last-handoff.md' }
}

switch ($ev) {
  'PreToolUse' {
    if (-not $pz) {
      $h = Hit $LIMIT
      if (-not $h.why.Count) { exit 0 }
      $pz = [pscustomobject]@{ sid = $sid; stage = 'handoff'; until = $h.until; why = ($h.why -join ', '); at = $now; nag = 0 }
      Save $pz
      Say "Claude $($pz.why): Lead is writing its handoff, then pauses until $(When $pz.until) and carries on by itself"
    }
    if ($pz.stage -ne 'handoff') { exit 0 }
    if (-not $e.agent_type -and [string]$e.tool_name -in @('Read', 'Write', 'Edit', 'MultiEdit')) { exit 0 }
    $hf = HandoffFile
    $why = if ($e.agent_type) {
      "PAUSE: lyopz's Claude usage is at $($pz.why). Stop now. Do not use any more tools. Reply with 3 short lines: what you finished, what is half-done (files / where in the place), what is left."
    } else {
      "PAUSE: lyopz's Claude usage is at $($pz.why) (limit resets $(When $pz.until)). Stop the task now and use no tool except Read, Write and Edit. " +
      "Update $hf : keep what is there and put a section at the top called '## Usage pause ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))' with: the task, what is finished, what is half-done (exact files and where in the place), and the exact next steps. " +
      "Then end your turn with one line. Do not ask lyopz anything: the app waits for the reset and reopens this chat by itself to carry on."
    }
    @{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = $why } } | ConvertTo-Json -Compress -Depth 4
    exit 0
  }
  'Stop' {
    if (-not $pz -or $pz.stage -ne 'handoff') { exit 0 }
    $hf = HandoffFile
    $wrote = (Test-Path $hf) -and ([DateTimeOffset](Get-Item $hf).LastWriteTimeUtc).ToUnixTimeSeconds() -ge [long]$pz.at
    if (-not $wrote -and [int]$pz.nag -lt 1) {   # ask once more for the handoff, then pause anyway
      $pz.nag = 1; Save $pz
      @{ decision = 'block'; reason = "Before you stop: write the '## Usage pause' section at the top of $hf (task, done, half-done, next steps). Then end your turn with one line." } | ConvertTo-Json -Compress
      exit 0
    }
    $pz.stage = 'wait'; $pz.sid = $sid; Save $pz
    Say "Lead paused for the usage limit. It carries on by itself at $(When $pz.until)"
    CloseClaude
    exit 0
  }
  'StopFailure' {
    if ([string]$e.error -ne 'rate_limit') { exit 0 }
    if ($pz -and $pz.stage -eq 'wait') { exit 0 }
    $h = Hit 90
    # no plan window near its limit -> probably a short rate limit: try again in 5 minutes
    $until = if ($h.until) { $h.until } else { $now + 300 }
    $why = if ($h.why.Count) { $h.why -join ', ' } else { 'a rate limit' }
    $handed = $pz -and $pz.stage -eq 'handoff'
    Save ([pscustomobject]@{ sid = $sid; stage = 'wait'; until = $until; why = $why; at = $now; nag = 0; hard = $true; handed = [bool]$handed })
    Say "Lead hit the usage limit ($why). It carries on by itself at $(When $until)"
    CloseClaude
    exit 0
  }
}
exit 0
