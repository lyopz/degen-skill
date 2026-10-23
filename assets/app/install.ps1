# Run once: puts a "Degen Skills" shortcut on the Desktop and in the Start menu.
$app = $PSScriptRoot
$target = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
$argsLine = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$app\launch.ps1`""
$sh = New-Object -ComObject WScript.Shell
$places = @([Environment]::GetFolderPath('Desktop'), (Join-Path ([Environment]::GetFolderPath('StartMenu')) 'Programs'))
foreach ($p in $places) {
  $lnk = $sh.CreateShortcut((Join-Path $p 'Degen Skills.lnk'))
  $lnk.TargetPath = $target
  $lnk.Arguments = $argsLine
  $lnk.WorkingDirectory = $app
  $lnk.IconLocation = "$app\icon.ico"
  $lnk.WindowStyle = 7
  $lnk.Description = 'Degen Skills - your Claude Code skill library'
  $lnk.Save()
}
Write-Host 'Done. Open "Degen Skills" from your Desktop or Start menu.'
