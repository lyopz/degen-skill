# Claude Code hook: turns each action into one plain-English line, tagged with WHO is doing it.
# Writes ~/RobloxGames/.degen/activity.json (read by the app) and ~/RobloxGames/activity.log.
$ErrorActionPreference = 'SilentlyContinue'
$e = [Console]::In.ReadToEnd() | ConvertFrom-Json
$RG = Join-Path $env:USERPROFILE 'RobloxGames'; $D = Join-Path $RG '.degen'; New-Item -ItemType Directory -Force -Path $D | Out-Null
$log = Join-Path $RG 'activity.log'; $jf = Join-Path $D 'activity.json'
$ev = $e.hook_event_name; $t = [string]$e.tool_name; $i = $e.tool_input
$who = if ($e.agent_type) { ($e.agent_type -replace '^roblox-', '') } else { 'lead' }
$st = if (Test-Path $jf) { [IO.File]::ReadAllText($jf) | ConvertFrom-Json } else { $null }
$lines = [Collections.ArrayList]@(); if ($st.lines) { $st.lines | ForEach-Object { [void]$lines.Add($_) } }
$active = [ordered]@{}; if ($st.active) { $st.active.PSObject.Properties | ForEach-Object { $active[$_.Name] = $_.Value } }
$status = if ($st.status) { $st.status } else { 'idle' }
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
