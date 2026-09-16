param(
    [string]$RecipeRoot = (Split-Path -Parent $PSScriptRoot)
)

Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$width = 1080
$height = 1350
$drafts = Join-Path $RecipeRoot 'assets\drafts'
$output = Join-Path $RecipeRoot 'assets\final\instagram-feed-home-party'
New-Item -ItemType Directory -Force -Path $output | Out-Null

$coverPath = Join-Path $drafts 'fruit-burrata-wreath-editorial-cover-v1.png'
$ingredientsPath = Join-Path $drafts 'fruit-burrata-wreath-editorial-ingredients-v1.png'
$processPath = Join-Path $drafts 'fruit-burrata-wreath-editorial-process-v1.png'
$finalPath = Join-Path $drafts 'fruit-burrata-wreath-editorial-final-v1.png'
foreach ($path in @($coverPath, $ingredientsPath, $processPath, $finalPath)) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing source image: $path" }
}

$cover = [System.Drawing.Image]::FromFile($coverPath)
$ingredients = [System.Drawing.Image]::FromFile($ingredientsPath)
$process = [System.Drawing.Image]::FromFile($processPath)
$final = [System.Drawing.Image]::FromFile($finalPath)
$fontFamily = 'Malgun Gothic'
$ink = '#1E2420'
$muted = '#647069'
$accent = '#B33D4B'
$green = '#3E7658'
$paper = '#FFFDFC'

function ColorFromHex([string]$hex, [int]$alpha = 255) {
    $value = $hex.TrimStart('#')
    return [System.Drawing.Color]::FromArgb($alpha,
        [Convert]::ToInt32($value.Substring(0, 2), 16),
        [Convert]::ToInt32($value.Substring(2, 2), 16),
        [Convert]::ToInt32($value.Substring(4, 2), 16))
}

function Brush([string]$hex, [int]$alpha = 255) {
    return [System.Drawing.SolidBrush]::new((ColorFromHex $hex $alpha))
}

function Font([float]$size, [bool]$bold = $false) {
    $style = if ($bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    return [System.Drawing.Font]::new($fontFamily, $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

function NewCanvas() {
    $bitmap = [System.Drawing.Bitmap]::new($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $graphics.Clear((ColorFromHex $paper))
    return @($bitmap, $graphics)
}

function DrawCrop($graphics, $image, [int]$x, [int]$y, [int]$w, [int]$h) {
    $sourceRatio = $image.Width / [double]$image.Height
    $targetRatio = $w / [double]$h
    if ($sourceRatio -gt $targetRatio) {
        $sourceHeight = $image.Height
        $sourceWidth = [int]($sourceHeight * $targetRatio)
        $sourceX = [int](($image.Width - $sourceWidth) / 2)
        $sourceY = 0
    } else {
        $sourceWidth = $image.Width
        $sourceHeight = [int]($sourceWidth / $targetRatio)
        $sourceX = 0
        $sourceY = [int](($image.Height - $sourceHeight) / 2)
    }
    $sourceRect = [System.Drawing.Rectangle]::new($sourceX, $sourceY, $sourceWidth, $sourceHeight)
    $targetRect = [System.Drawing.Rectangle]::new($x, $y, $w, $h)
    $graphics.DrawImage($image, $targetRect, $sourceRect, [System.Drawing.GraphicsUnit]::Pixel)
}

function DrawText($graphics, [string]$text, [int]$x, [int]$y, [float]$size, [string]$color = $ink, [bool]$bold = $false) {
    $font = Font $size $bold
    $brush = Brush $color
    $graphics.DrawString($text, $font, $brush, $x, $y)
    $font.Dispose(); $brush.Dispose()
}

function DrawCenteredText($graphics, [string]$text, [int]$x, [int]$y, [int]$w, [float]$size, [string]$color = $ink, [bool]$bold = $false) {
    $font = Font $size $bold
    $brush = Brush $color
    $format = [System.Drawing.StringFormat]::new()
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $graphics.DrawString($text, $font, $brush, [System.Drawing.RectangleF]::new($x, $y, $w, $size + 28), $format)
    $format.Dispose(); $font.Dispose(); $brush.Dispose()
}

function DrawPanel($graphics, [int]$y, [int]$h, [int]$alpha = 235) {
    $panel = Brush '#FFFFFF' $alpha
    $graphics.FillRectangle($panel, 0, $y, $width, $h)
    $panel.Dispose()
}

function DrawDot($graphics, [int]$x, [int]$y) {
    $dot = Brush $accent
    $graphics.FillEllipse($dot, $x, $y, 14, 14)
    $dot.Dispose()
}

function DrawRule($graphics, [int]$x, [int]$y, [int]$w, [string]$color = '#D8DDD8') {
    $pen = [System.Drawing.Pen]::new((ColorFromHex $color), 1)
    $graphics.DrawLine($pen, $x, $y, $x + $w, $y)
    $pen.Dispose()
}

function SaveCanvas($bitmap, $graphics, [string]$path) {
    $graphics.Dispose()
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
}

# 01 - cover: the dish and the occasion first
$canvas = NewCanvas; $bmp = $canvas[0]; $g = $canvas[1]
DrawCrop $g $cover 0 0 $width $height
DrawPanel $g 790 560 240
DrawDot $g 72 845
DrawText $g 'HOME PARTY APPETIZER' 101 837 20 $muted $false
DrawText $g '홈파티 과일 부라타' 72 895 48 $ink $true
DrawText $g '리스 샐러드' 72 955 66 $accent $true
DrawText $g '달콤한 과일·부드러운 치즈·허브를' 72 1050 24 $ink $false
DrawText $g '한 접시에 원형으로 담는 노오븐 애피타이저' 72 1088 24 $ink $false
DrawRule $g 72 1146 936
DrawText $g '4인분  ·  준비 15분  ·  불 없이 완성' 72 1174 24 $green $true
DrawCenteredText $g '01' 0 1285 $width 18 $muted $false
SaveCanvas $bmp $g (Join-Path $output '01-cover-fruit-burrata-wreath.png')

# 02 - ingredients, with every amount visible
$canvas = NewCanvas; $bmp = $canvas[0]; $g = $canvas[1]
DrawCrop $g $ingredients 0 0 $width $height
DrawPanel $g 750 600 242
DrawDot $g 72 805
DrawText $g 'INGREDIENTS' 101 797 20 $muted $false
DrawText $g '재료' 72 846 42 $ink $true
DrawText $g '4인분 · 총 13가지' 72 897 23 $green $true
DrawRule $g 72 938 936
DrawText $g '부라타 치즈 1개(150–200g) · 딸기 8개' 72 963 20 $ink $false
DrawText $g '레드용과 1/2개 · 백용과 1/2개 · 블루베리 1/2컵' 72 997 20 $ink $false
DrawText $g '그린 올리브 1/3컵 · 민트·로즈마리 한 줌' 72 1031 20 $ink $false
DrawText $g '레몬 1/2개 · 엑스트라버진 올리브유 2큰술' 72 1065 20 $ink $false
DrawText $g '레몬즙 1큰술 · 꿀 1작은술 · 소금 1/4작은술 · 후추 약간' 72 1099 20 $ink $false
DrawText $g '선택: 바질 페스토 2큰술' 72 1148 20 $green $true
DrawText $g '※ 우유 함유 · 페스토 제품의 견과류·알레르기 성분 확인' 72 1200 18 $muted $false
DrawCenteredText $g '02' 0 1285 $width 18 $muted $false
SaveCanvas $bmp $g (Join-Path $output '02-ingredients-and-dressing.png')

# 03 - complete method, no cooking omitted
$canvas = NewCanvas; $bmp = $canvas[0]; $g = $canvas[1]
DrawCrop $g $process 0 0 $width $height
DrawPanel $g 735 615 244
DrawDot $g 72 790
DrawText $g 'HOW TO MAKE' 101 782 20 $muted $false
DrawText $g '만드는 법' 72 831 42 $ink $true
DrawText $g '준비 15분 · 조리 없음' 72 882 23 $green $true
DrawRule $g 72 923 936
DrawText $g '01  과일은 씻어 물기를 완전히 닦고, 용과는 동그랗게 떠요.' 72 950 19 $ink $false
DrawText $g '     딸기는 반으로 잘라 크기를 맞춰요.' 72 984 19 $muted $false
DrawText $g '02  올리브유 2T + 레몬즙 1T + 꿀 1t + 소금·후추를 섞어요.' 72 1028 19 $ink $false
DrawText $g '03  접시 가장자리에 과일·치즈·올리브를 번갈아 원형으로 놓아요.' 72 1072 19 $ink $false
DrawText $g '     민트와 로즈마리를 사이사이에 꽂아 리스 모양을 잡아요.' 72 1106 19 $muted $false
DrawText $g '04  가운데에 페스토 2T를 담고, 드레싱을 가볍게 둘러요.' 72 1150 19 $ink $false
DrawText $g '     먹기 직전에 완성해 바로 서빙합니다.' 72 1184 19 $green $true
DrawCenteredText $g '03' 0 1285 $width 18 $muted $false
SaveCanvas $bmp $g (Join-Path $output '03-how-to-assemble.png')

# 04 - serving guidance and recipe explanation on the final food shot
$canvas = NewCanvas; $bmp = $canvas[0]; $g = $canvas[1]
DrawCrop $g $final 0 0 $width $height
DrawPanel $g 700 650 244
DrawDot $g 72 800
DrawText $g 'SERVE & SAVE' 101 792 20 $muted $false
DrawText $g '완성 & 서빙' 72 841 42 $ink $true
DrawText $g '색감은 풍성하게, 조리는 가볍게.' 72 892 24 $accent $true
DrawRule $g 72 932 936
DrawText $g '드레싱은 먹기 직전에 둘러야 과일의 식감이 살아나요.' 72 962 20 $ink $false
DrawText $g '가운데 페스토를 두면 빵이나 과일을 찍어 먹기 좋아요.' 72 1000 20 $ink $false
DrawText $g '치즈와 과일은 따로 밀폐해 냉장 보관하고 당일 드세요.' 72 1038 20 $ink $false
DrawText $g '남은 드레싱은 냉장 보관 후 2–3일 안에 사용하세요.' 72 1076 20 $ink $false
DrawText $g '레시피 출처를 바탕으로 과일·치즈 조합과 분량을 재구성한 콘텐츠용 응용안입니다.' 72 1136 17 $muted $false
DrawText $g '※ 우유 함유 · 페스토 제품 라벨의 견과류·알레르기 성분 확인' 72 1178 18 $muted $false
DrawCenteredText $g '04' 0 1285 $width 18 $muted $false
SaveCanvas $bmp $g (Join-Path $output '04-serve-and-save.png')

$cover.Dispose(); $ingredients.Dispose(); $process.Dispose(); $final.Dispose()
Write-Output "Created home-party Instagram feed slides in $output"
