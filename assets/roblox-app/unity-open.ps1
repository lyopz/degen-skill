# Opens the Unity polish project minimized (lead-run.ps1, every Lead start) so the Unity MCP connects.
# -Show: pop Unity up in front while it designs (roblox-3d-pipeline stage 3). -Hide: minimize it again when done.
#   powershell -ExecutionPolicy Bypass -NoProfile -File "$env:DEGEN_APP\unity-open.ps1" [-Show | -Hide]
# Prints OPEN (already running), STARTED, or why it couldn't.
param([switch]$Show, [switch]$Hide)
Add-Type -Namespace Degen -Name Win -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(System.IntPtr h, int c); [DllImport("user32.dll")] public static extern bool SetForegroundWindow(System.IntPtr h);'
function Win($cmd) {
  $u = Get-Process Unity -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
  if (-not $u) { return }
  if ($cmd -eq 'show') { [Degen.Win]::ShowWindow($u.MainWindowHandle, 9) | Out-Null; [Degen.Win]::SetForegroundWindow($u.MainWindowHandle) | Out-Null }
  if ($cmd -eq 'hide') { [Degen.Win]::ShowWindow($u.MainWindowHandle, 6) | Out-Null }
}
$D = Join-Path $env:USERPROFILE 'RobloxGames\.degen'
$pf = Join-Path $D 'unity-project.txt'
if (-not (Test-Path $pf)) { 'NO_PROJECT (run unity-setup.ps1)'; exit 0 }
$proj = ([IO.File]::ReadAllText($pf)).Trim()
if (-not (Test-Path (Join-Path $proj 'Assets'))) { "NO_PROJECT ($proj)"; exit 0 }

# Keep the project's DegenPolish.cs in step with the repo (app updates change it; Unity recompiles it by itself)
$src = Join-Path $PSScriptRoot '..\..\skills\roblox-3d-pipeline\unity\DegenPolish.cs'
$dst = Join-Path $proj 'Assets\Editor\DegenPolish.cs'
if ((Test-Path $src) -and ((-not (Test-Path $dst)) -or (Get-FileHash $src).Hash -ne (Get-FileHash $dst).Hash)) {
  New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
  Copy-Item $src $dst -Force
}

# Already open? (Unity keeps Temp\UnityLockfile locked while the project is open)
$lock = Join-Path $proj 'Temp\UnityLockfile'
if (Test-Path $lock) {
  try { $s = [IO.File]::Open($lock, 'Open', 'ReadWrite', 'None'); $s.Close() } catch {
    if ($Show) { Win 'show' } elseif ($Hide) { Win 'hide' }
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

if ($Hide) { 'NOT_OPEN'; exit 0 }
$style = if ($Show) { 'Normal' } else { 'Minimized' }
Start-Process -FilePath $exe -ArgumentList @('-projectPath', "`"$proj`"") -WindowStyle $style
'STARTED'
