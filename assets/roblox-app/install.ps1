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
# degenroblox:// links (Start buttons in the app) -> start-task.ps1
$k = 'HKCU:\Software\Classes\degenroblox'
New-Item -Path $k -Force | Out-Null
Set-ItemProperty -Path $k -Name '(default)' -Value 'URL:Degen Roblox'
New-ItemProperty -Path $k -Name 'URL Protocol' -Value '' -PropertyType String -Force | Out-Null
New-Item -Path "$k\shell\open\command" -Force | Out-Null
Set-ItemProperty -Path "$k\shell\open\command" -Name '(default)' -Value "`"$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe`" -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$app\start-task.ps1`" `"%1`""
Write-Host 'Done. Open "Degen Roblox" from your Desktop or Start menu.'
