# White-background cutout: flood fill from the borders over near-white pixels -> transparent; soft 1px edge; trim + pad to square 512.
param([string]$In, [string]$Out, [int]$Size = 512, [int]$Thresh = 232)
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @"
using System; using System.Collections.Generic;
public static class Cut {
  public static byte[] Mask(byte[] px, int w, int h, int thr) {
    var m = new byte[w*h]; var q = new Queue<int>();
    Func<int,bool> white = i => px[i*4] >= thr && px[i*4+1] >= thr && px[i*4+2] >= thr;
    for (int x=0;x<w;x++){ foreach (int y in new[]{0,h-1}) { int i=y*w+x; if (m[i]==0 && white(i)) { m[i]=1; q.Enqueue(i);} } }
    for (int y=0;y<h;y++){ foreach (int x in new[]{0,w-1}) { int i=y*w+x; if (m[i]==0 && white(i)) { m[i]=1; q.Enqueue(i);} } }
    while (q.Count>0) { int i=q.Dequeue(); int x=i%w, y=i/w;
      int[] nb = { x>0?i-1:-1, x<w-1?i+1:-1, y>0?i-w:-1, y<h-1?i+w:-1 };
      foreach (int n in nb) if (n>=0 && m[n]==0 && white(n)) { m[n]=1; q.Enqueue(n);} }
    return m;
  }
}
"@
$src = [System.Drawing.Bitmap]::FromFile($In)
$w = $src.Width; $h = $src.Height
$bmp = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp); $g.DrawImage($src, 0, 0, $w, $h); $g.Dispose(); $src.Dispose()
$rect = New-Object System.Drawing.Rectangle 0, 0, $w, $h
$data = $bmp.LockBits($rect, 'ReadWrite', ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb))
$bytes = New-Object byte[] ($w*$h*4)
[Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)
$m = [Cut]::Mask($bytes, $w, $h, $Thresh)
$minX=$w;$minY=$h;$maxX=0;$maxY=0
for ($i=0; $i -lt $w*$h; $i++) {
  if ($m[$i] -eq 1) { $bytes[$i*4+3] = 0 }
  else {
    $x = $i % $w; $y = [math]::Floor($i / $w)
    if ($x -lt $minX){$minX=$x}; if ($x -gt $maxX){$maxX=$x}; if ($y -lt $minY){$minY=$y}; if ($y -gt $maxY){$maxY=$y}
    # soften pixels touching the background
    $edge = ($x -gt 0 -and $m[$i-1] -eq 1) -or ($x -lt $w-1 -and $m[$i+1] -eq 1) -or ($y -gt 0 -and $m[$i-$w] -eq 1) -or ($y -lt $h-1 -and $m[$i+$w] -eq 1)
    if ($edge) { $bytes[$i*4+3] = 150 }
  }
}
[Runtime.InteropServices.Marshal]::Copy($bytes, 0, $data.Scan0, $bytes.Length); $bmp.UnlockBits($data)
$cw = $maxX-$minX+1; $ch = $maxY-$minY+1; $side = [math]::Max($cw,$ch); $pad = [int]($side*0.04)
$outBmp = New-Object System.Drawing.Bitmap $Size, $Size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g2 = [System.Drawing.Graphics]::FromImage($outBmp); $g2.Clear([System.Drawing.Color]::Transparent)
$g2.InterpolationMode = 'HighQualityBicubic'; $g2.SmoothingMode = 'HighQuality'; $g2.PixelOffsetMode = 'HighQuality'
$scale = ($Size - 2*$pad*$Size/$side) / $side
$dw = $cw*$scale; $dh = $ch*$scale
$g2.DrawImage($bmp, (New-Object System.Drawing.RectangleF ((($Size-$dw)/2), (($Size-$dh)/2), $dw, $dh)), (New-Object System.Drawing.RectangleF $minX, $minY, $cw, $ch), 'Pixel')
$g2.Dispose(); $outBmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png); $outBmp.Dispose(); $bmp.Dispose()
$Out
