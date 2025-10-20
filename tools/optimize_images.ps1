# Optimize wallpaper.jpg using System.Drawing (no external deps)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$root = Resolve-Path (Join-Path $scriptDir "..")
$imgDir = Join-Path $root "assets\images"
$wall = Join-Path $imgDir "wallpaper.jpg"
$backup = Join-Path $imgDir "wallpaper.original.jpg"

if (-not (Test-Path $wall)) {
    Write-Error "No wallpaper found at $wall"
    exit 1
}

if (-not (Test-Path $backup)) {
    Copy-Item -Path $wall -Destination $backup -Force
    Write-Output "Backup created: $backup"
    $src = $backup
} else {
    Write-Output "Backup already exists; using backup as source"
    $src = $backup
}

Add-Type -AssemblyName System.Drawing

try {
    $img = [System.Drawing.Image]::FromFile($src)
    $w = $img.Width
    $h = $img.Height
    $maxw = 1920
    if ($w -gt $maxw) {
        $neww = $maxw
        $newh = [int]($h * ($neww / $w))
    } else {
        $neww = $w
        $newh = $h
    }

    $thumb = New-Object System.Drawing.Bitmap $neww, $newh
    $graphics = [System.Drawing.Graphics]::FromImage($thumb)
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.DrawImage($img, 0, 0, $neww, $newh)

    $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $encoder = [System.Drawing.Imaging.Encoder]::Quality
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encoderParam = New-Object System.Drawing.Imaging.EncoderParameter($encoder, 75L)
    $encoderParams.Param[0] = $encoderParam

    $thumb.Save($wall, $jpegCodec, $encoderParams)
    $img.Dispose(); $thumb.Dispose(); $graphics.Dispose()

    $origSize = (Get-Item $src).Length
    $newSize = (Get-Item $wall).Length
    Write-Output "Optimized saved: $wall"
    Write-Output "Size: $origSize -> $newSize bytes"
} catch {
    Write-Error "Erro ao otimizar imagem: $_"
    exit 1
}
