param(
    [string]$RecipeRoot = (Split-Path -Parent $PSScriptRoot)
)

Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$width = 1080
$height = 1350
$drafts = Join-Path $RecipeRoot 'assets\drafts'
$output = Join-Path $RecipeRoot 'assets\final\instagram-feed'
New-Item -ItemType Directory -Force -Path $output | Out-Null

$presenterPath = Join-Path $drafts 'yangbaechu-dakgaseumsal-dubu-kimchi-bokkeumbap-presenter-v1.png'
$foodPath = Join-Path $drafts 'yangbaechu-dakgaseumsal-dubu-kimchi-bokkeumbap-instagram-v1.png'
foreach ($path in @($presenterPath, $foodPath)) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing source image: $path" }
}

$presenter = [System.Drawing.Image]::FromFile($presenterPath)
$food = [System.Drawing.Image]::FromFile($foodPath)
$fontFamily = 'Malgun Gothic'

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

function NewCanvas([string]$background) {
    $bitmap = [System.Drawing.Bitmap]::new($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $graphics.Clear((ColorFromHex $background))
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

function DrawText($graphics, [string]$text, [int]$x, [int]$y, [float]$size, [string]$color = '#2B1E18', [bool]$bold = $false) {
    $font = Font $size $bold
    $brush = Brush $color
    $graphics.DrawString($text, $font, $brush, $x, $y)
    $font.Dispose(); $brush.Dispose()
}

function DrawCenteredText($graphics, [string]$text, [int]$x, [int]$y, [int]$w, [float]$size, [string]$color = '#2B1E18', [bool]$bold = $false) {
    $font = Font $size $bold
    $brush = Brush $color
    $format = [System.Drawing.StringFormat]::new()
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $graphics.DrawString($text, $font, $brush, [System.Drawing.RectangleF]::new($x, $y, $w, $size + 30), $format)
    $format.Dispose(); $font.Dispose(); $brush.Dispose()
}

function DrawRule($graphics, [int]$x, [int]$y, [int]$w, [string]$color = '#D95B35', [int]$thickness = 5) {
    $pen = [System.Drawing.Pen]::new((ColorFromHex $color), $thickness)
    $graphics.DrawLine($pen, $x, $y, $x + $w, $y)
    $pen.Dispose()
}

function DrawCard($graphics, [int]$x, [int]$y, [int]$w, [int]$h, [string]$fill = '#FFFDF8') {
    $brush = Brush $fill
    $graphics.FillRectangle($brush, $x, $y, $w, $h)
    $brush.Dispose()
}

function SaveCanvas($bitmap, $graphics, [string]$path) {
    $graphics.Dispose()
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
}

# 01 - presenter-led cover
$canvas = NewCanvas '#F4E8D8'; $bmp = $canvas[0]; $g = $canvas[1]
DrawCrop $g $presenter 0 0 $width $height
$overlay = Brush '#20160F' 175; $g.FillRectangle($overlay, 0, 890, $width, 460); $overlay.Dispose()
DrawText $g '레시피 카드 01' 72 948 28 '#FFF8EF' $false
DrawText $g '양배추 닭가슴살' 68 1002 60 '#FFF8EF' $true
DrawText $g '두부 김치볶음밥' 68 1070 60 '#FFC56A' $true
DrawText $g '재료 8개  ·  팬 하나  ·  13-15분' 72 1168 30 '#FFF8EF' $false
DrawText $g '저장해두고 오늘 만들어보세요' 72 1240 30 '#FFF8EF' $false
SaveCanvas $bmp $g (Join-Path $output '01-cover-presenter.png')

# 02 - ingredients and prep
$canvas = NewCanvas '#FBF6ED'; $bmp = $canvas[0]; $g = $canvas[1]
DrawText $g '재료와 준비' 70 62 54 '#2B1E18' $true
DrawRule $g 70 145 940
DrawCrop $g $food 730 182 270 210
DrawText $g '1인분' 70 190 28 '#D95B35' $true
DrawText $g '재료 8개' 70 232 42 '#2B1E18' $true
$ingredientLeft = @('익힌 닭가슴살 100g', '양배추 100g', '묵은지 15g', '두부 150g')
$ingredientRight = @('밥 70g', '대파 35g', '식용유 1큰술', '들기름 1/2큰술')
for ($i = 0; $i -lt 4; $i++) {
    DrawText $g ('· ' + $ingredientLeft[$i]) 78 (305 + ($i * 52)) 28 '#2B1E18' $false
    DrawText $g ('· ' + $ingredientRight[$i]) 550 (305 + ($i * 52)) 28 '#2B1E18' $false
}
DrawRule $g 70 555 940 '#E6D6C2' 2
DrawText $g '준비 순서' 70 610 36 '#2B1E18' $true
DrawText $g '01  닭가슴살은 결대로 찢기' 78 680 29 '#2B1E18' $false
DrawText $g '02  양배추 · 대파 · 김치는 잘게 썰기' 78 738 29 '#2B1E18' $false
DrawText $g '03  김치에 간이 있으므로 별도 소금은 생략' 78 796 29 '#2B1E18' $false
$tip = Brush '#F2D7BC'; $g.FillRectangle($tip, 70, 900, 940, 180); $tip.Dispose()
DrawText $g 'TIP' 100 935 28 '#D95B35' $true
DrawText $g '익힌 닭가슴살 기준' 100 985 30 '#2B1E18' $true
DrawText $g '시판 닭가슴살 · 두부 · 김치의 원재료명을 확인하세요.' 100 1034 23 '#2B1E18' $false
DrawText $g '다음 장에서 팬 조리 시간을 확인하세요.' 70 1190 29 '#8E5B43' $false
SaveCanvas $bmp $g (Join-Path $output '02-ingredients-prep.png')

# 03 - method and cooking times
$canvas = NewCanvas '#FBF6ED'; $bmp = $canvas[0]; $g = $canvas[1]
DrawText $g '팬 하나로 만드는 순서' 70 62 50 '#2B1E18' $true
DrawText $g '총 13-15분  ·  1인분' 72 132 28 '#D95B35' $false
DrawRule $g 70 190 940
$cardY = @(245, 480, 715, 950)
$cardFill = @('#F4E3D0', '#F6D1B7', '#E7E6C9', '#F2D7BC')
$num = @('1', '2', '3', '4')
$title = @('손질', '파기름 + 김치', '닭 · 양배추 · 두부', '밥 + 들기름')
$time = @('준비', '1분 + 1분', '1분 + 1분 + 3분', '2-3분')
$body = @(
    '닭가슴살은 찢고, 양배추 · 대파 · 김치는 썰어요.',
    '식용유와 대파를 약불에서 1분 볶고, 김치를 넣어 1분 볶아요.',
    '닭가슴살과 양배추를 각각 1분 볶은 뒤, 두부를 으깨며 3분 볶아요.',
    '밥과 들기름을 넣고 2-3분 볶으면 완성!'
)
for ($i = 0; $i -lt 4; $i++) {
    DrawCard $g 70 $cardY[$i] 940 185 $cardFill[$i]
    $circle = Brush '#D95B35'; $g.FillEllipse($circle, 98, ($cardY[$i] + 36), 78, 78); $circle.Dispose()
    DrawCenteredText $g $num[$i] 98 ($cardY[$i] + 48) 78 34 '#FFF8EF' $true
    DrawText $g $title[$i] 215 ($cardY[$i] + 28) 30 '#2B1E18' $true
    DrawText $g $time[$i] 215 ($cardY[$i] + 76) 24 '#D95B35' $true
    DrawText $g $body[$i] 215 ($cardY[$i] + 118) 22 '#2B1E18' $false
}
$safe = Brush '#2B1E18'; $g.FillRectangle($safe, 70, 1180, 940, 105); $safe.Dispose()
DrawText $g '안전' 100 1200 24 '#FFC56A' $true
DrawText $g '생닭은 별도 도구로 취급하고 중심온도 74°C까지 익혀요.' 190 1198 22 '#FFF8EF' $false
DrawText $g '남은 음식은 2시간 이내 냉장 보관 · 알레르기 성분은 제품 라벨 확인' 190 1235 19 '#FFF8EF' $false
SaveCanvas $bmp $g (Join-Path $output '03-method-times.png')

# 04 - final food + presenter
$canvas = NewCanvas '#2B1E18'; $bmp = $canvas[0]; $g = $canvas[1]
DrawCrop $g $food 0 0 $width 760
$heroOverlay = Brush '#2B1E18' 115; $g.FillRectangle($heroOverlay, 0, 0, $width, 135); $heroOverlay.Dispose()
DrawText $g '완성 컷' 70 42 30 '#FFC56A' $true
DrawText $g '따뜻할 때 한 그릇' 70 82 34 '#FFF8EF' $true
DrawCrop $g $presenter 70 830 470 450
DrawText $g '사람이 소개하는 레시피' 590 850 29 '#FFC56A' $true
DrawText $g '양배추의 식감,' 590 930 36 '#FFF8EF' $true
DrawText $g '포슬포슬한 두부,' 590 985 36 '#FFF8EF' $true
DrawText $g '김치의 감칠맛을' 590 1040 36 '#FFF8EF' $true
DrawText $g '한 팬에 담았어요.' 590 1095 36 '#FFC56A' $true
DrawText $g '저장해두고 오늘 만들어보세요.' 590 1180 24 '#FFF8EF' $false
DrawText $g '응용 레시피 · 제품 라벨과 알레르기 성분 확인' 590 1230 18 '#D8C6B5' $false
SaveCanvas $bmp $g (Join-Path $output '04-final-food-and-presenter.png')

$presenter.Dispose(); $food.Dispose()
Write-Output "Created Instagram feed slides in $output"
