# Ask lyopz for an approval / choice in the Degen Roblox app (with pictures) and wait for the answer.
# Usage (from Claude Code):
#   powershell -NoProfile -File "$env:DEGEN_APP\ask.ps1" -Q "Approve these 3 concept pictures?" -O "Approve|Change something|Redo" -I "C:\...\concept-a.png|C:\...\concept-b.png" -From roblox-art-director
# Prints the answer (e.g. "Approve" or "Change something: make the horns bigger"). Pictures must be inside ~/RobloxGames.
# If the app is closed it prints APP_CLOSED -> ask in the terminal instead.
param([string]$Q, [string]$O = 'Approve|Request changes', [string]$I = '', [string]$From = 'Lead', [int]$Minutes = 55)
$D = Join-Path $env:USERPROFILE 'RobloxGames\.degen'
$alive = Join-Path $D 'server.alive'
if (-not (Test-Path $alive) -or ((Get-Date) - (Get-Item $alive).LastWriteTime).TotalSeconds -gt 20) { 'APP_CLOSED'; exit 0 }
$id = 'a' + (Get-Date -Format 'yyyyMMddHHmmssfff')
$imgs = @($I -split '\|' | Where-Object { $_ -and (Test-Path $_) } | ForEach-Object { (Resolve-Path $_).Path })
$item = [ordered]@{ id = $id; kind = 'approval'; from = $From; at = (Get-Date -Format 'HH:mm'); images = $imgs
  questions = @([ordered]@{ q = $Q; h = 'Approval'; multi = $false; options = @($O -split '\|' | ForEach-Object { [ordered]@{ l = $_.Trim(); d = '' } }) }) }
[IO.File]::WriteAllText("$D\inbox\$id.json", ($item | ConvertTo-Json -Depth 8 -Compress), (New-Object Text.UTF8Encoding $false))
$ans = "$D\answers\$id.json"; $until = (Get-Date).AddMinutes($Minutes)
while (-not (Test-Path $ans) -and (Get-Date) -lt $until) { Start-Sleep -Milliseconds 700 }
if (-not (Test-Path $ans)) { Remove-Item "$D\inbox\$id.json" -Force; 'NO_ANSWER'; exit 0 }
$a = [IO.File]::ReadAllText($ans) | ConvertFrom-Json; Remove-Item $ans -Force
switch ([string]$a.answer) { '__decline__' { 'DECLINED - do not do this, skip it and continue' } '__dismiss__' { 'DISMISSED - decide yourself and continue' } default { [string]$a.answer } }
