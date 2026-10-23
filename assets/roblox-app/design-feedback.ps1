# Rate a design in the Degen Roblox app and log lyopz's like/dislike, so future designs follow his taste (customuse-design skill).
# Usage (from Claude Code):
#   powershell -NoProfile -File "$env:DEGEN_APP\design-feedback.ps1" -Project my-game -Name dragon-pet-v1 -Image "C:\...\dragon-pet-v1.png" -Tool customuse -Prompt "<prompt used>" -From roblox-art-director
# Prints the answer (e.g. "Love it" or "Change something: eyes bigger"). APP_CLOSED -> ask in the terminal, then run again with -Answer "<his words>" to only log it.
param([string]$Project = '', [string]$Name = 'design', [string]$Image = '', [string]$Tool = 'customuse', [string]$Prompt = '', [string]$From = 'Lead', [string]$Answer = '')
$RG = Join-Path $env:USERPROFILE 'RobloxGames'; $D = Join-Path $RG '.degen'
New-Item -ItemType Directory -Force -Path $D | Out-Null
if (-not $Answer) {
  $Answer = & powershell -NoProfile -File (Join-Path $PSScriptRoot 'ask.ps1') -Q "What do you think of '$Name'? Say why (it teaches the next designs)." -O "Love it|Like it|Change something|Don't like it" -I $Image -From $From
  $Answer = ($Answer | Out-String).Trim()
}
if ($Answer -in @('APP_CLOSED', 'NO_ANSWER')) { $Answer; exit 0 }
$rating = switch -Regex ($Answer) { '^Love' { 'love' } '^Like' { 'like' } '^Change' { 'change' } "^Don'?t|^DECLINED" { 'dislike' } default { 'note' } }
$line = [ordered]@{ at = (Get-Date -Format 'yyyy-MM-dd HH:mm'); project = $Project; name = $Name; tool = $Tool; rating = $rating; answer = $Answer; image = $Image; prompt = $Prompt } | ConvertTo-Json -Compress
$utf8 = New-Object Text.UTF8Encoding $false
if ($Project) { $pd = Join-Path $RG "$Project\designs"; New-Item -ItemType Directory -Force -Path $pd | Out-Null; [IO.File]::AppendAllText("$pd\feedback.jsonl", "$line`n", $utf8) }
[IO.File]::AppendAllText("$D\taste-log.jsonl", "$line`n", $utf8)
$Answer
