# PreToolUse hook for AskUserQuestion: when the Degen Roblox app is open, the question pops up in the app
# (Approvals bubble + sound). lyopz picks there; the answer goes back to Claude. App closed -> normal terminal question.
$ErrorActionPreference = 'SilentlyContinue'
$e = [Console]::In.ReadToEnd() | ConvertFrom-Json
$D = Join-Path $env:USERPROFILE 'RobloxGames\.degen'
$alive = Join-Path $D 'server.alive'
if (-not (Test-Path $alive) -or ((Get-Date) - (Get-Item $alive).LastWriteTime).TotalSeconds -gt 20) { exit 0 }
$cwd = if ($e.cwd) { $e.cwd } else { Join-Path $env:USERPROFILE 'RobloxGames' }
$qs = @($e.tool_input.questions)
$imgs = @()
foreach ($q in $qs) {
  $txt = ($q.question + ' ' + (($q.options | ForEach-Object { $_.label + ' ' + $_.description }) -join ' '))
  foreach ($m in [regex]::Matches($txt, '[\w:\\/\.\-~ ]+?\.(png|jpe?g|webp)', 'IgnoreCase')) {
    $p = $m.Value.Trim().Replace('~', $env:USERPROFILE); if (-not [IO.Path]::IsPathRooted($p)) { $p = Join-Path $cwd $p }
    if (Test-Path $p) { $imgs += (Resolve-Path $p).Path }
  }
}
$id = 'q' + (Get-Date -Format 'yyyyMMddHHmmssfff')
$who = if ($e.agent_type) { $e.agent_type } else { 'Lead' }
$item = [ordered]@{ id = $id; kind = 'question'; from = $who; at = (Get-Date -Format 'HH:mm'); images = @($imgs | Select-Object -Unique)
  questions = @($qs | ForEach-Object { [ordered]@{ q = $_.question; h = $_.header; multi = [bool]$_.multiSelect; options = @($_.options | ForEach-Object { [ordered]@{ l = $_.label; d = $_.description } }) } }) }
[IO.File]::WriteAllText("$D\inbox\$id.json", ($item | ConvertTo-Json -Depth 8 -Compress), (New-Object Text.UTF8Encoding $false))
$ans = "$D\answers\$id.json"; $until = (Get-Date).AddMinutes(55)
while (-not (Test-Path $ans) -and (Get-Date) -lt $until) { Start-Sleep -Milliseconds 700 }
if (-not (Test-Path $ans)) { Remove-Item "$D\inbox\$id.json" -Force; exit 0 }
$a = [IO.File]::ReadAllText($ans) | ConvertFrom-Json; Remove-Item $ans -Force
if ([string]$a.answer -eq '__terminal__') { exit 0 }
$out = @{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'
  permissionDecisionReason = "lyopz already answered this in the Degen Roblox app (do not ask again, continue with it): $($a.answer)" } }
$out | ConvertTo-Json -Depth 5 -Compress
exit 0
