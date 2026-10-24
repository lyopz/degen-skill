# Opens the Unity polish project (visible, so lyopz can watch it design) or brings it to the front if it's already open.
# lead-run.ps1 calls it on every Lead start; agents can call it too:
#   powershell -ExecutionPolicy Bypass -NoProfile -File "$env:DEGEN_APP\unity-open.ps1"
# Prints OPEN (already running), STARTED, or why it couldn't.
$D = Join-Path $env:USERPROFILE 'RobloxGames\.degen'
$pf = Join-Path $D 'unity-project.txt'
if (-not (Test-Path $pf)) { 'NO_PROJECT (run unity-setup.ps1)'; exit 0 }
$proj = ([IO.File]::ReadAllText($pf)).Trim()
if (-not (Test-Path (Join-Path $proj 'Assets'))) { "NO_PROJECT ($proj)"; exit 0 }

# Already open? (Unity keeps Temp\UnityLockfile locked while the project is open)
$lock = Join-Path $proj 'Temp\UnityLockfile'
if (Test-Path $lock) {
  try { $s = [IO.File]::Open($lock, 'Open', 'ReadWrite', 'None'); $s.Close() } catch {
    $u = Get-Process Unity -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
    if ($u) { try { (New-Object -ComObject WScript.Shell).AppActivate($u.Id) | Out-Null } catch {} }
    'OPEN'; exit 0
  }
}

# Find the editor version the project uses, then that editor's Unity.exe
$ver = ''
$pv = Join-Path $proj 'ProjectSettings\ProjectVersion.txt'
if (Test-Path $pv) { $m = Select-String -Path $pv -Pattern 'm_EditorVersion:\s*(\S+)' | Select-Object -First 1; if ($m) { $ver = $m.Matches[0].Groups[1].Value } }
$roots = @("$env:ProgramFiles\Unity\Hub\Editor")
$sec = Join-Path $env:APPDATA 'UnityHub\secondaryInstallPath.json'
if (Test-Path $sec) { $p = ([IO.File]::ReadAllText($sec)).Trim().Trim('"'); if ($p) { $roots += $p } }
$exe = $null
foreach ($r in $roots) {
  if ($ver -and (Test-Path "$r\$ver\Editor\Unity.exe")) { $exe = "$r\$ver\Editor\Unity.exe"; break }
}
if (-not $exe) {
  $exe = $roots | ForEach-Object { Get-ChildItem "$_\*\Editor\Unity.exe" -ErrorAction SilentlyContinue } |
    Sort-Object { $_.Directory.Parent.Name } -Descending | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $exe) { 'NO_UNITY (install a Unity editor in Unity Hub)'; exit 0 }

Start-Process -FilePath $exe -ArgumentList @('-projectPath', "`"$proj`"")
'STARTED'
