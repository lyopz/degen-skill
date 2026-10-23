# Watch me play: while lyopz plays Roblox, saves a screenshot every few seconds (only while Roblox is the active window),
# plus hotkeys F7 = "I like this" and F8 = "I don't like this" (extra screenshot + a note). Voice/typed notes come from the app.
# Everything stays on this PC in ~/RobloxGames/.degen/watch/<session>/ (never the repo). At the end it makes contact sheets
# (9 shots per picture) so the Lead can review a whole session cheaply (roblox-game-study "Learn from a play session").
# Started/stopped by the app's "Watch me play" bubble, or by hand:
#   powershell -ExecutionPolicy Bypass -File "$HOME\.claude\degen-skill\assets\roblox-app\watch-play.ps1" -Game "Pet Simulator 99"
# Stop: the app's Stop button, Ctrl+C in this window, or after -MaxMinutes.
param([string]$Game = 'roblox', [int]$Every = 5, [int]$MaxMinutes = 120)
$ErrorActionPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Drawing, System.Windows.Forms
Add-Type @'
using System; using System.Runtime.InteropServices;
public static class DegenW {
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern short GetAsyncKeyState(int k);
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
}
'@
[DegenW]::SetProcessDPIAware() | Out-Null   # full-resolution screenshots on scaled displays

$D = Join-Path $env:USERPROFILE 'RobloxGames\.degen'
$slug = (($Game.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')); if (-not $slug) { $slug = 'roblox' }
$dir = Join-Path $D ("watch\" + (Get-Date -Format 'yyyy-MM-dd_HHmm') + "-$slug")
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$stop = Join-Path $D 'watch.stop'; Remove-Item $stop -Force
$utf8 = New-Object Text.UTF8Encoding $false
$jpg = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$ep = New-Object Drawing.Imaging.EncoderParameters 1; $ep.Param[0] = New-Object Drawing.Imaging.EncoderParameter([Drawing.Imaging.Encoder]::Quality, [long]75)
$t0 = Get-Date; $shots = 0; $marks = 0; $prev = $null

function Status($running) {
  $s = [ordered]@{ running = $running; game = $Game; dir = $dir; shots = $shots; marks = $marks; started = $t0.ToString('o'); pid = $PID }
  [IO.File]::WriteAllText((Join-Path $D 'watch.json'), ($s | ConvertTo-Json -Compress), $utf8)
}
function Sec { [int]((Get-Date) - $t0).TotalSeconds }
function Note($kind, $text, $shot) {
  $l = [ordered]@{ s = (Sec); at = (Get-Date -Format 'HH:mm:ss'); kind = $kind; text = $text; shot = $shot } | ConvertTo-Json -Compress
  [IO.File]::AppendAllText((Join-Path $dir 'notes.jsonl'), "$l`n", $utf8)
}
function RobloxWindow {
  $h = [DegenW]::GetForegroundWindow(); $p = 0; [DegenW]::GetWindowThreadProcessId($h, [ref]$p) | Out-Null
  $pr = Get-Process -Id $p
  if ($pr.ProcessName -match 'Roblox' -or $pr.MainWindowTitle -eq 'Roblox') { return $h }   # Player or Microsoft Store version
  $null
}
# Grab the screen Roblox is on, shrink to 1280 wide, save as jpg. Skips frames that barely changed (unless forced).
function Shot($h, $prefix, [switch]$Force) {
  $b = [Windows.Forms.Screen]::FromHandle($h).Bounds
  $full = New-Object Drawing.Bitmap $b.Width, $b.Height
  $g = [Drawing.Graphics]::FromImage($full); $g.CopyFromScreen($b.Left, $b.Top, 0, 0, $full.Size); $g.Dispose()
  $tiny = New-Object Drawing.Bitmap 16, 9; $g = [Drawing.Graphics]::FromImage($tiny); $g.DrawImage($full, 0, 0, 16, 9); $g.Dispose()
  $sig = foreach ($y in 0..8) { foreach ($x in 0..15) { $c = $tiny.GetPixel($x, $y); [int](($c.R + $c.G + $c.B) / 3) } }
  $tiny.Dispose()
  if (-not $Force -and $script:prev) { $d = 0; for ($i = 0; $i -lt 144; $i++) { $d += [Math]::Abs($sig[$i] - $script:prev[$i]) }; if ($d / 144 -lt 3) { $full.Dispose(); return $null } }
  $script:prev = $sig
  $w = [Math]::Min(1280, $b.Width); $hh = [int]($b.Height * $w / $b.Width)
  $small = New-Object Drawing.Bitmap $w, $hh; $g = [Drawing.Graphics]::FromImage($small)
  $g.InterpolationMode = 'HighQualityBicubic'; $g.DrawImage($full, 0, 0, $w, $hh); $g.Dispose(); $full.Dispose()
  $name = "$prefix-{0:D5}.jpg" -f (Sec); $small.Save((Join-Path $dir $name), $jpg, $ep); $small.Dispose()
  $script:shots++; $name
}
# 3x3 contact sheets of every shot, labelled with the time (and LIKE / DISLIKE), for a cheap first pass.
function Sheets {
  $files = @(Get-ChildItem $dir -Filter *.jpg | Sort-Object { [int]($_.BaseName -replace '^\D+-', '') }, Name)
  if (-not $files.Count) { return }
  $sd = Join-Path $dir 'sheets'; New-Item -ItemType Directory -Force -Path $sd | Out-Null
  $font = New-Object Drawing.Font 'Segoe UI', 16, ([Drawing.FontStyle]::Bold); $n = 0
  for ($i = 0; $i -lt $files.Count; $i += 9) {
    $sheet = New-Object Drawing.Bitmap 1920, 1080; $g = [Drawing.Graphics]::FromImage($sheet); $g.Clear([Drawing.Color]::Black)
    $g.InterpolationMode = 'HighQualityBicubic'
    for ($k = 0; $k -lt 9 -and ($i + $k) -lt $files.Count; $k++) {
      $f = $files[$i + $k]; $im = [Drawing.Image]::FromFile($f.FullName)
      $x = ($k % 3) * 640; $y = [Math]::Floor($k / 3) * 360; $g.DrawImage($im, $x, $y, 640, 360); $im.Dispose()
      $s = [int]($f.BaseName -replace '^\D+-', ''); $lab = '{0}:{1:D2}' -f [Math]::Floor($s / 60), ($s % 60)
      if ($f.BaseName -like 'like-*') { $lab += '  LIKE' } elseif ($f.BaseName -like 'dislike-*') { $lab += '  DISLIKE' }
      $g.FillRectangle((New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(170, 0, 0, 0))), $x, $y, 190, 30)
      $g.DrawString($lab, $font, [Drawing.Brushes]::White, $x + 6, $y + 2)
    }
    $g.Dispose(); $n++; $sheet.Save((Join-Path $sd ('sheet-{0:D2}.jpg' -f $n)), $jpg, $ep); $sheet.Dispose()
  }
}

[IO.File]::WriteAllText((Join-Path $dir 'session.json'), ([ordered]@{ game = $Game; started = $t0.ToString('o'); every = $Every } | ConvertTo-Json), $utf8)
Status $true
Write-Host "Watching Roblox ($Game). Screenshots every $Every s while Roblox is in front. F7 = like, F8 = don't like. Ctrl+C to stop."
$next = Get-Date; $down = @{ 0x76 = $false; 0x77 = $false }
try {
  while (-not (Test-Path $stop) -and ((Get-Date) - $t0).TotalMinutes -lt $MaxMinutes) {
    foreach ($k in 0x76, 0x77) {   # F7 / F8, edge-triggered
      $now = ([DegenW]::GetAsyncKeyState($k) -band 0x8000) -ne 0
      if ($now -and -not $down[$k]) {
        $h = RobloxWindow; if (-not $h) { $h = [DegenW]::GetForegroundWindow() }
        $kind = if ($k -eq 0x76) { 'like' } else { 'dislike' }
        $n = Shot $h $kind -Force; $script:marks++; Note $kind '' $n
        [Media.SystemSounds]::Asterisk.Play(); Status $true
      }
      $down[$k] = $now
    }
    if ((Get-Date) -ge $next) {
      $next = (Get-Date).AddSeconds($Every)
      $h = RobloxWindow; if ($h) { if (Shot $h 'f') { Status $true } }
    }
    Start-Sleep -Milliseconds 100
  }
} finally {
  Note 'end' '' $null
  Sheets
  $s = Get-Content (Join-Path $dir 'session.json') -Raw | ConvertFrom-Json
  $s | Add-Member -NotePropertyName ended -NotePropertyValue (Get-Date).ToString('o') -Force; $s | Add-Member -NotePropertyName shots -NotePropertyValue $shots -Force; $s | Add-Member -NotePropertyName marks -NotePropertyValue $marks -Force
  [IO.File]::WriteAllText((Join-Path $dir 'session.json'), ($s | ConvertTo-Json), $utf8)
  Status $false; Remove-Item $stop -Force
  Write-Host "Saved $shots screenshots to $dir"
}
