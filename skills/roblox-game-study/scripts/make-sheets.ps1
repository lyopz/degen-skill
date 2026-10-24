param([string]$Dir)
Add-Type -AssemblyName System.Drawing
$out = Join-Path $Dir 'sheets'
New-Item -ItemType Directory -Force $out | Out-Null
$files = Get-ChildItem $Dir -Filter *.jpg | Sort-Object { [int](($_.BaseName -split '-')[1]) }
$w = 640; $h = 360; $n = 0
for ($i = 0; $i -lt $files.Count; $i += 9) {
  $n++
  $bmp = New-Object System.Drawing.Bitmap ($w*3), ($h*3)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $font = New-Object System.Drawing.Font 'Arial', 20, ([System.Drawing.FontStyle]::Bold)
  for ($k = 0; $k -lt 9 -and ($i+$k) -lt $files.Count; $k++) {
    $f = $files[$i+$k]
    $img = [System.Drawing.Image]::FromFile($f.FullName)
    $x = ($k % 3) * $w; $y = [math]::Floor($k / 3) * $h
    $g.DrawImage($img, $x, $y, $w, $h)
    $img.Dispose()
    $parts = $f.BaseName -split '-'
    $label = "{0}s {1}" -f [int]$parts[1], ($(if ($parts[0] -eq 'f') { '' } else { $parts[0].ToUpper() }))
    $brush = if ($parts[0] -eq 'like') { [System.Drawing.Brushes]::Lime } elseif ($parts[0] -eq 'dislike') { [System.Drawing.Brushes]::Red } else { [System.Drawing.Brushes]::Yellow }
    $g.FillRectangle([System.Drawing.Brushes]::Black, $x, $y, 220, 34)
    $g.DrawString($label, $font, $brush, $x + 4, $y + 4)
  }
  $g.Dispose()
  $bmp.Save((Join-Path $out ("sheet-{0:D2}.jpg" -f $n)), [System.Drawing.Imaging.ImageFormat]::Jpeg)
  $bmp.Dispose()
}
"$n sheets"
