Add-Type -AssemblyName PresentationCore
foreach ($p in $args) {
  $fs = [IO.File]::OpenRead($p)
  $dec = [System.Windows.Media.Imaging.BitmapDecoder]::Create($fs, [System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat, [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
  $f = $dec.Frames[0]
  $conv = New-Object System.Windows.Media.Imaging.FormatConvertedBitmap $f, ([System.Windows.Media.PixelFormats]::Bgra32), $null, 0
  $enc = New-Object System.Windows.Media.Imaging.PngBitmapEncoder
  $enc.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($conv))
  $out = [IO.Path]::ChangeExtension($p, '.src.png')
  $o = [IO.File]::Create($out); $enc.Save($o); $o.Dispose(); $fs.Dispose()
  "$out  $($f.PixelWidth)x$($f.PixelHeight)  $($f.Format)"
}
