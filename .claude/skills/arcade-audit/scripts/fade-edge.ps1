# fade-edge.ps1: soften a straight cut on a mascot cut-out by ramping alpha to 0 over the last
# N px of the subject at that edge. Use when no full-body source exists and the subject ends on
# a flat line (flyer crop, knee-level crop) - a hard edge floats mid-screen in NEVATO.
#   fade-edge.ps1 <in.png> <out.png> [-Bottom 90] [-Top 0] [-Left 0] [-Right 0]
# The band is measured from the outermost pixel with alpha >= 16 inward; alpha is multiplied by a
# smoothstep ramp so the fade has no visible start line. Pixels already transparent are untouched.
param([string]$In, [string]$Out, [int]$Bottom = 0, [int]$Top = 0, [int]$Left = 0, [int]$Right = 0)
Add-Type -AssemblyName System.Drawing
$src = New-Object System.Drawing.Bitmap $In
$bmp = New-Object System.Drawing.Bitmap $src.Width, $src.Height, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp); $g.Clear([System.Drawing.Color]::Transparent); $g.DrawImageUnscaled($src, 0, 0); $g.Dispose(); $src.Dispose()
$w = $bmp.Width; $h = $bmp.Height
$rows = New-Object int[] $h; $cols = New-Object int[] $w
for ($y = 0; $y -lt $h; $y++) { for ($x = 0; $x -lt $w; $x++) { if ($bmp.GetPixel($x, $y).A -ge 16) { $rows[$y]++; $cols[$x]++ } } }
$t = 0; while ($t -lt $h -and $rows[$t] -eq 0) { $t++ }; $b = $h - 1; while ($b -ge 0 -and $rows[$b] -eq 0) { $b-- }
$l = 0; while ($l -lt $w -and $cols[$l] -eq 0) { $l++ }; $r = $w - 1; while ($r -ge 0 -and $cols[$r] -eq 0) { $r-- }
function Ramp([double]$k) { if ($k -le 0) { return 0.0 }; if ($k -ge 1) { return 1.0 }; return $k * $k * (3 - 2 * $k) }
for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $c = $bmp.GetPixel($x, $y); if ($c.A -eq 0) { continue }
        $f = 1.0
        if ($Bottom -gt 0) { $f *= Ramp (($b - $y) / [double]$Bottom) }
        if ($Top    -gt 0) { $f *= Ramp (($y - $t) / [double]$Top) }
        if ($Left   -gt 0) { $f *= Ramp (($x - $l) / [double]$Left) }
        if ($Right  -gt 0) { $f *= Ramp (($r - $x) / [double]$Right) }
        if ($f -lt 1.0) { $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb([int][math]::Round($c.A * $f), $c.R, $c.G, $c.B)) }
    }
}
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
"subject x=$l..$r y=$t..$b  faded bottom=$Bottom top=$Top left=$Left right=$Right -> $Out"
