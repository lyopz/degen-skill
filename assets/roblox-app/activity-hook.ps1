# Claude Code hook: turns each tool call into one plain-English line in ~/RobloxGames/activity.log
$ErrorActionPreference = 'SilentlyContinue'
$raw = [Console]::In.ReadToEnd(); $e = $raw | ConvertFrom-Json
$log = Join-Path $env:USERPROFILE 'RobloxGames\activity.log'
$ev = $e.hook_event_name; $t = [string]$e.tool_name; $i = $e.tool_input
$msg = $null
switch ($ev) {
  'Stop'          { $msg = 'Done - waiting for you' }
  'SubagentStop'  { $msg = 'An agent finished its part' }
  'UserPromptSubmit' { $msg = 'Got your message' }
  default {
    $n = ($t -split '__')[-1]
    if ($t -like '*Roblox_Studio*') {
      $msg = switch -Wildcard ($n) {
        'execute_luau' { 'Studio: building / running code' } 'screen_capture' { 'Studio: taking a screenshot to check' }
        'insert_asset' { 'Studio: inserting a model' } 'search_asset' { 'Studio: searching free models' }
        'start_stop_play' { 'Studio: playtesting' } 'get_console_output' { 'Studio: checking for errors' }
        'multi_edit' { 'Studio: editing a script' } 'script_*' { 'Studio: reading scripts' }
        'search_game_tree' { 'Studio: looking around the place' } 'inspect_instance' { 'Studio: inspecting a part' }
        'generate_*' { 'Studio: generating ' + ($n -replace 'generate_','') } 'character_navigation' { 'Studio: walking the character' }
        'list_roblox_studios' { 'Studio: connecting' } default { 'Studio: ' + ($n -replace '_',' ') } }
    } elseif ($t -like '*higgsfield*') {
      $msg = switch -Wildcard ($n) {
        'generate_image*' { 'Higgsfield: making a picture' } 'generate_3d*' { 'Higgsfield: making a 3D model' }
        'generate_video*' { 'Higgsfield: making a video' } 'jobs_wait' { $null } 'balance' { 'Higgsfield: checking credits' }
        default { $null } }
      if ($i.params.get_cost) { $msg = 'Higgsfield: checking the price' }
    } elseif ($t -in @('Task','Agent')) {
      $who = if ($i.subagent_type) { $i.subagent_type } else { 'helper' }
      $msg = "Started $who" + $(if ($i.description) { ': ' + $i.description } else { '' })
    } elseif ($t -in @('Write','Edit','MultiEdit')) { $msg = 'Saving ' + (Split-Path -Leaf $i.file_path) }
    elseif ($t -eq 'Bash' -or $t -eq 'PowerShell') {
      $c = [string]$i.command
      if ($c -match 'git .*push') { $msg = 'Saving to GitHub' } elseif ($c -match 'make_rbxmx') { $msg = 'Updating Studio templates' } elseif ($c -match 'blender') { $msg = 'Blender: working' }
    } elseif ($t -like '*Blender*') { $msg = 'Blender: working on the model' }
    elseif ($t -in @('WebSearch','WebFetch')) { $msg = 'Looking something up' }
  }
}
if ($msg) {
  $line = (Get-Date -Format 'HH:mm') + '  ' + $msg
  $last = if (Test-Path $log) { Get-Content $log -Tail 1 } else { '' }
  if ($last -notlike "*  $msg") { Add-Content -Path $log -Value $line -Encoding UTF8 }
  # live copy for the Degen Roblox app (file:// pages can read .js, not .log)
  $lines = @(Get-Content $log -Tail 40 -Encoding UTF8)
  $json = ConvertTo-Json -InputObject $lines -Compress
  [IO.File]::WriteAllText((Join-Path $PSScriptRoot 'activity-data.js'), "window.ACT=$json;", (New-Object Text.UTF8Encoding $false))
}
exit 0
