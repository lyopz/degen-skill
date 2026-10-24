# Claude Code hook: turns each action into one plain-English line, tagged with WHO is doing it.
# Writes ~/RobloxGames/.degen/activity.json (read by the app) and ~/RobloxGames/activity.log.
$ErrorActionPreference = 'SilentlyContinue'
[Console]::InputEncoding = [Text.Encoding]::UTF8; [Console]::OutputEncoding = [Text.Encoding]::UTF8
$e = [Console]::In.ReadToEnd() | ConvertFrom-Json
$RG = Join-Path $env:USERPROFILE 'RobloxGames'; $D = Join-Path $RG '.degen'; New-Item -ItemType Directory -Force -Path $D | Out-Null
$log = Join-Path $RG 'activity.log'; $jf = Join-Path $D 'activity.json'
$ev = $e.hook_event_name; $t = [string]$e.tool_name; $i = $e.tool_input
$who = if ($e.agent_type) { ($e.agent_type -replace '^roblox-', '') } else { 'lead' }
$st = if (Test-Path $jf) { [IO.File]::ReadAllText($jf) | ConvertFrom-Json } else { $null }
$lines = [Collections.ArrayList]@(); if ($st.lines) { $st.lines | ForEach-Object { [void]$lines.Add($_) } }
$active = [ordered]@{}; if ($st.active) { $st.active.PSObject.Properties | ForEach-Object { $active[$_.Name] = $_.Value } }
$status = if ($st.status) { $st.status } else { 'idle' }
# "Continue last task": remember which Claude Code session last worked on which project (local only, .degen/sessions.json)
$sid = [string]$e.session_id
if ($sid -match '^[\w\-]+$') {
  $sf = Join-Path $D 'sessions.json'
  $ss = if (Test-Path $sf) { [IO.File]::ReadAllText($sf) | ConvertFrom-Json } else { $null }
  $byS = [ordered]@{}; if ($ss.s) { $ss.s.PSObject.Properties | ForEach-Object { $byS[$_.Name] = $_.Value } }
  $byP = [ordered]@{}; if ($ss.p) { $ss.p.PSObject.Properties | ForEach-Object { $byP[$_.Name] = $_.Value } }
  $txt = if ($ev -eq 'UserPromptSubmit') { [string]$e.prompt } elseif ($i) { [string]$i.file_path + ' ' + [string]$i.path + ' ' + [string]$i.command } else { '' }
  $proj = $null
  # a game folder, or a project inside one (<game>/projects/<name>) -> key 'game/projects/name'
  foreach ($m in [regex]::Matches($txt, 'RobloxGames[\\/]+([\w\-\.]+)(?:[\\/]+projects[\\/]+([\w\-\.]+))?')) {
    $n = $m.Groups[1].Value
    if ($n -notlike '.*' -and $n -notlike '_*' -and $n -ne 'imports' -and (Test-Path (Join-Path $RG $n) -PathType Container)) {
      $proj = (Get-Item (Join-Path $RG $n)).Name; $sn = $m.Groups[2].Value
      if ($sn -and $sn -notlike '.*' -and (Test-Path (Join-Path $RG "$n\projects\$sn") -PathType Container)) { $proj += '/projects/' + (Get-Item (Join-Path $RG "$n\projects\$sn")).Name }
      break
    }
  }
  $cur = $byS[$sid]; $changed = $false
  if (-not $cur) { $cur = [pscustomobject]@{ p = ''; task = '' }; $byS[$sid] = $cur; $changed = $true }
  if ($ev -eq 'UserPromptSubmit' -and $e.prompt) {
    $tk = [string]$e.prompt -replace '(?s)^Do this task now \(full brief below[^\n]*\n+', ''
    $tk = $(if ($tk -match '(?m)^Task:\s*(.+)$') { $Matches[1] } else { ($tk.Trim() -split "`n")[0] }).Trim()
    if ($tk.Length -gt 140) { $tk = $tk.Substring(0, 140) + '...' }
    $cur.task = $tk; $changed = $true
  }
  # reading the game's own HANDOFF/art-style while working on a project inside it keeps the inside project
  if ($proj -and $cur.p -ne $proj -and -not ([string]$cur.p).StartsWith("$proj/projects/")) { $cur.p = $proj; $changed = $true }
  if ($cur.p -and ($changed -or $ev -eq 'Stop')) { $byP[$cur.p] = [ordered]@{ id = $sid; at = (Get-Date -Format 'yyyy-MM-dd HH:mm'); task = $cur.task }; $changed = $true }
  if ($changed) {
    while ($byS.Count -gt 40) { $byS.RemoveAt(0) }
    [IO.File]::WriteAllText($sf, ([ordered]@{ s = $byS; p = $byP } | ConvertTo-Json -Depth 5 -Compress), (New-Object Text.UTF8Encoding $false))
  }
}
# This Lead window's record (lead-run.ps1 makes it): chat id, project, task, busy/idle - a newer Lead uses it to take over
if ($env:DEGEN_LEAD -match '^\d+$' -and $sid -match '^[\w\-]+$') {
  $lf = Join-Path $D "leads\$($env:DEGEN_LEAD).json"
  $lr = if (Test-Path $lf) { [IO.File]::ReadAllText($lf) | ConvertFrom-Json } else { $null }
  if ($lr) {
    $busy = switch ($ev) { 'Stop' { $false } 'SubagentStop' { [bool]$lr.busy }
      'Notification' { -not ([string]$e.message -match 'waiting for your input') } default { $true } }
    $c = $byS[$sid]
    $np = if ($c.p) { [string]$c.p } else { [string]$lr.p }; $nt = if ($c.task) { [string]$c.task } else { [string]$lr.task }
    if ($lr.busy -ne $busy -or $lr.sid -ne $sid -or $lr.p -ne $np -or $lr.task -ne $nt) {
      $lr.busy = $busy; $lr.sid = $sid; $lr.p = $np; $lr.task = $nt
      [IO.File]::WriteAllText($lf, ($lr | ConvertTo-Json -Compress), (New-Object Text.UTF8Encoding $false))
    }
  }
}
$msg = $null; $kind = ''
switch ($ev) {
  'Stop'             { $msg = 'Done - waiting for you'; $kind = 'done'; $active = [ordered]@{}; $status = 'idle'; $who = 'lead' }
  'SubagentStop'     { $k = if ($e.agent_type) { $e.agent_type -replace '^roblox-', '' } else { @($active.Keys)[0] }
                       if ($k) { $msg = "Finished: " + $active[$k]; $who = $k; $active.Remove($k) } else { $msg = 'An agent finished its part' }; $kind = 'agent' }
  'UserPromptSubmit' { $msg = 'Got your message'; $status = 'working'; $who = 'you' }
  'Notification'     { $msg = 'Needs you: ' + ([string]$e.message); $kind = 'need' }
  default {
    $status = 'working'
    $n = ($t -split '__')[-1]
    if ($t -like '*Roblox_Studio*') {
      $msg = switch -Wildcard ($n) {
        'execute_luau' { 'Studio: building / running code' } 'screen_capture' { 'Studio: screenshot to check' }
        'insert_asset' { 'Studio: inserting a model' } 'search_asset' { 'Studio: searching free models' }
        'start_stop_play' { 'Studio: playtesting' } 'get_console_output' { 'Studio: checking for errors' }
        'multi_edit' { 'Studio: editing a script' } 'script_*' { 'Studio: reading scripts' }
        'search_game_tree' { 'Studio: looking around the place' } 'inspect_instance' { 'Studio: inspecting a part' }
        'generate_*' { 'Studio: generating ' + ($n -replace 'generate_', '') } 'character_navigation' { 'Studio: walking the character' }
        'list_roblox_studios' { 'Studio: connecting' } default { 'Studio: ' + ($n -replace '_', ' ') } }
    } elseif ($t -like '*higgsfield*') {
      $kind = 'hf'
      $msg = switch -Wildcard ($n) { 'generate_image*' { 'Higgsfield: making a picture' } 'generate_3d*' { 'Higgsfield: making a 3D model' }
        'generate_video*' { 'Higgsfield: making a video' } 'balance' { 'Higgsfield: checking credits' } default { $null } }
      if ($i.params.get_cost) { $msg = 'Higgsfield: checking the price' }
    } elseif ($t -in @('Task', 'Agent')) {
      $a = if ($i.subagent_type) { $i.subagent_type -replace '^roblox-', '' } else { 'helper' }
      $job = if ($i.description) { [string]$i.description } else { 'working' }
      $active[$a] = $job; $msg = "Started $a" + ': ' + $job; $kind = 'agent'
    } elseif ($t -eq 'AskUserQuestion') { $msg = 'Asking you a question (see Approvals)'; $kind = 'need' }
    elseif ($t -in @('Write', 'Edit', 'MultiEdit')) { $msg = 'Saving ' + (Split-Path -Leaf $i.file_path) }
    elseif ($t -in @('Read')) { $msg = 'Reading ' + (Split-Path -Leaf $i.file_path) }
    elseif ($t -eq 'Bash' -or $t -eq 'PowerShell') {
      $c = [string]$i.command
      if ($c -match 'ask\.ps1') { $msg = 'Waiting for your approval (see Approvals)'; $kind = 'need' }
      elseif ($c -match 'git .*push') { $msg = 'Saving to GitHub' } elseif ($c -match 'make_rbxmx') { $msg = 'Updating Studio templates' }
      elseif ($c -match 'blender') { $msg = 'Blender: working' } else { $msg = 'Running a command' }
    } elseif ($t -like '*Blender*') { $msg = 'Blender: working on the model' }
    elseif ($t -in @('WebSearch', 'WebFetch')) { $msg = 'Looking something up' }
    elseif ($t -like '*Skill*') { $msg = 'Reading skill ' + [string]$i.skill }
  }
}
if ($msg) {
  $last = if ($lines.Count) { $lines[$lines.Count - 1] } else { $null }
  if (-not ($last -and $last.msg -eq $msg -and $last.who -eq $who)) {
    [void]$lines.Add([ordered]@{ t = (Get-Date -Format 'HH:mm'); who = $who; msg = $msg; k = $kind })
    Add-Content -Path $log -Value ((Get-Date -Format 'HH:mm') + "  [$who] $msg") -Encoding UTF8
  }
}
while ($lines.Count -gt 80) { $lines.RemoveAt(0) }
$obj = [ordered]@{ status = $status; active = $active; lines = @($lines) }
[IO.File]::WriteAllText($jf, ($obj | ConvertTo-Json -Depth 6 -Compress), (New-Object Text.UTF8Encoding $false))
exit 0
