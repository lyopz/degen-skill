# ChatGPT picture handoff: shows a detailed prompt in the Degen Roblox app (Copy + Open ChatGPT), lyopz makes the
# picture in ChatGPT and saves it to Downloads, this script grabs the newest new image, copies it into the project, prints its path.
# Usage (from Claude Code):
#   powershell -NoProfile -File "$env:DEGEN_APP\gpt-image.ps1" -Project mythic-cube-pets -Name kappa-concept -From roblox-art-director -Prompt "<detailed prompt>"
# Prints the saved path, or SKIPPED / NO_IMAGE / APP_CLOSED (APP_CLOSED: print the prompt in the terminal and ask lyopz to save the image to Downloads).
param([string]$Prompt, [string]$Name = 'image', [string]$Project = '', [string]$From = 'Lead', [int]$Minutes = 45)
$RG = Join-Path $env:USERPROFILE 'RobloxGames'; $D = Join-Path $RG '.degen'
$alive = Join-Path $D 'server.alive'
$appOpen = (Test-Path $alive) -and (((Get-Date) - (Get-Item $alive).LastWriteTime).TotalSeconds -lt 20)
$dl = Join-Path $env:USERPROFILE 'Downloads'
$start = Get-Date
$id = 'g' + (Get-Date -Format 'yyyyMMddHHmmssfff')
if ($appOpen) {
  $item = [ordered]@{ id = $id; kind = 'chatgpt'; from = $From; at = (Get-Date -Format 'HH:mm'); name = $Name; prompt = $Prompt; images = @()
    questions = @([ordered]@{ q = "Make this picture in ChatGPT, then save it to Downloads"; h = 'ChatGPT'; multi = $false; options = @() }) }
  [IO.File]::WriteAllText("$D\inbox\$id.json", ($item | ConvertTo-Json -Depth 8 -Compress), (New-Object Text.UTF8Encoding $false))
} else { Write-Output "APP_CLOSED - prompt for lyopz:`n$Prompt" }
$ans = "$D\answers\$id.json"; $until = $start.AddMinutes($Minutes); $found = $null
while ((Get-Date) -lt $until) {
  $found = Get-ChildItem $dl -File | Where-Object { $_.Extension -in '.png', '.jpg', '.jpeg', '.webp' -and $_.LastWriteTime -gt $start -and $_.Length -gt 10kb } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($found) { Start-Sleep -Milliseconds 800; break }   # let the download finish
  if (Test-Path $ans) { $a = [IO.File]::ReadAllText($ans) | ConvertFrom-Json; Remove-Item $ans -Force; if ([string]$a.answer -like 'skip*') { 'SKIPPED'; exit 0 } }
  Start-Sleep -Milliseconds 1000
}
Remove-Item "$D\inbox\$id.json" -Force -ErrorAction SilentlyContinue
if (-not $found) { 'NO_IMAGE'; exit 0 }
$destDir = if ($Project) { Join-Path $RG "$Project\chatgpt" } else { Join-Path $RG 'chatgpt' }
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
$safe = ($Name -replace '[^\w\-]', '_'); $dest = Join-Path $destDir ($safe + '-' + (Get-Date -Format 'HHmmss') + $found.Extension)
Copy-Item $found.FullName $dest -Force
$dest
