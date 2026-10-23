# Run once: "Degen Roblox" shortcuts on the Desktop and Start menu.
$app = $PSScriptRoot
$sh = New-Object -ComObject WScript.Shell
foreach ($p in @([Environment]::GetFolderPath('Desktop'), (Join-Path ([Environment]::GetFolderPath('StartMenu')) 'Programs'))) {
  $l = $sh.CreateShortcut((Join-Path $p 'Degen Roblox.lnk'))
  $l.TargetPath = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
  $l.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$app\launch.ps1`""
  $l.WorkingDirectory = $app; $l.IconLocation = "$app\icon.ico"; $l.WindowStyle = 7
  $l.Description = 'Degen Roblox - Roblox skills, agents and fast Roblox Claude'; $l.Save()
}
Write-Host 'Done. Open "Degen Roblox" from your Desktop or Start menu.'
