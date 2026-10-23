# Picture -> low-poly 3D model in Customuse, by hand (use only when the Customuse MCP tools are NOT loaded).
# Shows a card in the Degen app with the picture and steps, opens Customuse, then picks the exported model up from Downloads.
# Usage (from Claude Code):
#   powershell -NoProfile -File "$env:DEGEN_APP\customuse-3d.ps1" -Project cube-pet-island -Name dragon-pet -Image "C:\...\chatgpt\dragon-pet.png" -From roblox-modeler
# Prints the saved model path (~/RobloxGames/<project>/customuse/<name>-<time>.glb/.fbx/.obj), or SKIPPED / NO_MODEL.
param([string]$Project = '', [string]$Name = 'model', [string]$Image = '', [string]$From = 'Lead', [int]$Minutes = 30, [int]$Tris = 3000)
$RG = Join-Path $env:USERPROFILE 'RobloxGames'; $D = Join-Path $RG '.degen'
New-Item -ItemType Directory -Force -Path "$D\inbox", "$D\answers" | Out-Null
$destDir = if ($Project) { Join-Path $RG "$Project\customuse" } else { Join-Path $RG 'customuse' }
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
$safe = ($Name -replace '[^\w\-]', '_'); $start = Get-Date
if ($Image -and (Test-Path $Image)) { Set-Clipboard -Path (Resolve-Path $Image).Path }
$steps = "Make '$Name' in Customuse: 1) New image-to-3D (Ctrl+V pastes the picture, or drag it in). 2) Low poly, about $Tris triangles, with texture. 3) Export .glb (or .fbx) - it's picked up from Downloads automatically."
$id = 'c' + (Get-Date -Format 'yyyyMMddHHmmssfff')
$imgs = @($Image | Where-Object { $_ -and (Test-Path $_) } | ForEach-Object { (Resolve-Path $_).Path })
$item = [ordered]@{ id = $id; kind = 'approval'; from = $From; at = (Get-Date -Format 'HH:mm'); images = $imgs
  questions = @([ordered]@{ q = $steps; h = 'Customuse 3D'; multi = $false; options = @([ordered]@{ l = 'Skip'; d = '' }) }) }
[IO.File]::WriteAllText("$D\inbox\$id.json", ($item | ConvertTo-Json -Depth 8 -Compress), (New-Object Text.UTF8Encoding $false))
function Done($out) { Remove-Item "$D\inbox\$id.json" -Force -ErrorAction SilentlyContinue; $out; exit 0 }
Start-Process 'https://customuse.com'
$dl = Join-Path $env:USERPROFILE 'Downloads'; $ans = "$D\answers\$id.json"; $until = (Get-Date).AddMinutes($Minutes)
while ((Get-Date) -lt $until) {
  $found = Get-ChildItem $dl -File | Where-Object { $_.Extension -in '.glb', '.fbx', '.obj', '.zip' -and $_.LastWriteTime -gt $start -and $_.Length -gt 1kb } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($found) {
    Start-Sleep -Seconds 2
    if ($found.Extension -eq '.zip') { $out = Join-Path $destDir ($safe + '-' + (Get-Date -Format 'HHmmss')); Expand-Archive $found.FullName $out -Force; Done $out }
    $dest = Join-Path $destDir ($safe + '-' + (Get-Date -Format 'HHmmss') + $found.Extension); Copy-Item $found.FullName $dest -Force; Done $dest
  }
  if (Test-Path $ans) { Remove-Item $ans -Force; Done 'SKIPPED' }
  Start-Sleep -Seconds 1
}
Done 'NO_MODEL'
