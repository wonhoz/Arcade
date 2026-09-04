<#
.SYNOPSIS
    Attract-Mode 설정 무결성 검사기
.DESCRIPTION
    attract.cfg / romlists / emulators 상호 참조와 실제 파일 존재를 점검한다.
    게임을 추가하거나 설정을 고친 뒤 이 스크립트를 돌려 회귀를 잡는다.
    자세한 구조 설명은 저장소 루트의 CLAUDE.md 참고.
.PARAMETER Root
    AttractMode 설치 경로. 기본값은 이 스크립트의 상위 디렉터리.
.PARAMETER Quiet
    경고(WARN)를 숨기고 오류(FAIL)만 출력한다.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\validate.ps1
.NOTES
    종료 코드: 0 = 오류 없음, 1 = 오류 있음
#>
[CmdletBinding()]
param(
    [string]$Root,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

if (-not $Root) { $Root = Split-Path -Parent $PSScriptRoot }
if (-not (Test-Path -LiteralPath (Join-Path $Root 'attract.cfg'))) {
    Write-Error "attract.cfg 를 찾을 수 없습니다: $Root"
    exit 1
}
Set-Location -LiteralPath $Root

$BOM = [char]0xFEFF
# FAIL 저장소가 깨진 상태. 반드시 고쳐야 한다.
# WARN 저장소 차원의 문제. 모든 장비에서 똑같이 나온다. 기대값은 0.
# 환경 롬·아트웍·게임 미설치처럼 장비마다 다른 것. 0 이 아닌 게 정상이다.
# 참고 알고 있고 그대로 두기로 한 것(비활성 항목이 참조하는 미정의 에뮬레이터 등).
$script:Fails = New-Object System.Collections.ArrayList
$script:Warns = New-Object System.Collections.ArrayList
$script:Envs  = New-Object System.Collections.ArrayList
$script:Notes = New-Object System.Collections.ArrayList
$script:ParkedEmu = @{}

function Add-Fail([string]$Area, [string]$Message) { [void]$script:Fails.Add([pscustomobject]@{ Area = $Area; Message = $Message }) }
function Add-Warn([string]$Area, [string]$Message) { [void]$script:Warns.Add([pscustomobject]@{ Area = $Area; Message = $Message }) }
function Add-Env( [string]$Area, [string]$Message) { [void]$script:Envs.Add( [pscustomobject]@{ Area = $Area; Message = $Message }) }
function Add-Note([string]$Message)                { [void]$script:Notes.Add($Message) }

function Test-Bom([string]$Path) {
    $fs = [System.IO.File]::OpenRead($Path)
    try {
        $buf = New-Object byte[] 3
        $n = $fs.Read($buf, 0, 3)
        return ($n -eq 3 -and $buf[0] -eq 0xEF -and $buf[1] -eq 0xBB -and $buf[2] -eq 0xBF)
    } finally { $fs.Dispose() }
}

# 마스코트 PNG 규격 검사. 위반 사유 문자열을 돌려주고, 규격에 맞으면 $null.
#   규격: 480x760, 투명 배경 위 컷아웃. 알파를 4px 간격으로 샘플링해
#   투명(alpha<16) 비율이 20% 미만이면 "불투명 포스터"로 본다
#   (실측: 정상 컷아웃 19종은 44~80%, 포스터 2종은 0.0% 였다).
Add-Type -AssemblyName System.Drawing
function Test-MascotSpec([string]$Path) {
    try { $bmp = New-Object System.Drawing.Bitmap $Path } catch { return "PNG 를 열 수 없음" }
    try {
        $w = $bmp.Width; $h = $bmp.Height
        $total = 0; $clear = 0
        for ($y = 0; $y -lt $h; $y += 4) {
            for ($x = 0; $x -lt $w; $x += 4) {
                $total++
                if ($bmp.GetPixel($x, $y).A -lt 16) { $clear++ }
            }
        }
    } finally { $bmp.Dispose() }
    $why = @()
    if ($w -ne 480 -or $h -ne 760) { $why += "크기 ${w}x${h} (480x760 이어야 함)" }
    $pct = [math]::Round(100 * $clear / $total, 1)
    if ($pct -lt 20) { $why += "투명 픽셀 $pct% - 컷아웃이 아니라 불투명 포스터" }
    if ($why.Count) { return ($why -join ', ') }
    return $null
}

# AM 설정 파일(attract.cfg / emulators\*.cfg) 파서.
# 들여쓰기 없는 줄 = 키, 들여쓴 줄 = 직전 키의 하위 항목.
function Read-AmConfig([string]$Path) {
    $result = @{}
    $artwork = New-Object System.Collections.ArrayList
    foreach ($raw in [System.IO.File]::ReadAllLines($Path)) {
        $line = $raw.TrimStart($BOM)
        if ($line -match '^\s*$' -or $line -match '^\s*#') { continue }
        if ($line -match '^\s') { continue }
        $parts = $line -split '\s+', 2
        $key = $parts[0]
        $val = if ($parts.Count -gt 1) { $parts[1].Trim() } else { '' }
        if ($key -eq 'artwork') { [void]$artwork.Add($val) } else { $result[$key] = $val }
    }
    $result['__artwork'] = $artwork
    return $result
}

Write-Host ""
Write-Host "Attract-Mode 설정 검사  ($Root)" -ForegroundColor Cyan
Write-Host ("=" * 72)

# ---------------------------------------------------------------- 1. 에뮬레이터 정의
$emulators = @{}
foreach ($file in Get-ChildItem -LiteralPath (Join-Path $Root 'emulators') -Filter '*.cfg') {
    $emulators[$file.BaseName] = Read-AmConfig $file.FullName
    if (Test-Bom $file.FullName) { Add-Fail 'BOM' "emulators\$($file.Name) 에 UTF-8 BOM 이 있습니다 (AM 파서가 첫 줄을 설정 키로 오인)" }
}
Write-Host ("에뮬레이터 정의 {0}개" -f $emulators.Count)

# 어떤 romlist 에서든 참조되는 에뮬레이터 이름 (비활성 항목 포함).
# 아무도 참조하지 않는 정의는 깨져 있어도 실행에 영향이 없으므로 경고로만 다룬다.
$referenced = @{}
foreach ($rf in (Get-ChildItem -LiteralPath (Join-Path $Root 'romlists') -Filter '*.txt')) {
    foreach ($b in [System.IO.File]::ReadAllLines($rf.FullName) | Select-Object -Skip 1) {
        if ($b -match '^\s*$') { continue }
        if ($b.StartsWith('#')) { $b = $b.Substring(1) }
        $c = $b -split ';'
        if ($c.Count -gt 2) { $referenced[$c[2]] = $true }
    }
}

# ---------------------------------------------------------------- 2. attract.cfg 의 display
$displays = New-Object System.Collections.ArrayList
$currentDisplay = $null
foreach ($raw in [System.IO.File]::ReadAllLines((Join-Path $Root 'attract.cfg'))) {
    $line = $raw.TrimStart($BOM)
    if ($line -match '^display\s+(.+?)\s*$') {
        $currentDisplay = [pscustomobject]@{ Name = $Matches[1]; Layout = $null; Romlist = $null }
        [void]$displays.Add($currentDisplay)
        continue
    }
    if ($line -match '^[^\s]') { $currentDisplay = $null; continue }
    if ($null -eq $currentDisplay) { continue }
    if ($line -match '^\s+layout\s+(.+?)\s*$')  { $currentDisplay.Layout  = $Matches[1] }
    if ($line -match '^\s+romlist\s+(.+?)\s*$') { $currentDisplay.Romlist = $Matches[1] }
}
Write-Host ("디스플레이 {0}개" -f $displays.Count)

foreach ($d in $displays) {
    if ($d.Layout) {
        $layoutDir = Join-Path $Root (Join-Path 'layouts' $d.Layout)
        if (-not (Test-Path -LiteralPath $layoutDir)) {
            Add-Fail 'display' "[$($d.Name)] layout '$($d.Layout)' 폴더 없음"
        } elseif (-not (Get-ChildItem -LiteralPath $layoutDir -Filter '*.nut' -File)) {
            Add-Fail 'display' "[$($d.Name)] layout '$($d.Layout)' 에 .nut 파일 없음"
        }
    }
    if ($d.Romlist) {
        if (-not (Test-Path -LiteralPath (Join-Path $Root "romlists\$($d.Romlist).txt"))) {
            Add-Fail 'display' "[$($d.Name)] romlist '$($d.Romlist).txt' 없음"
        }
    }
    $overview = Join-Path $Root ("scraper\@\overview\{0}.txt" -f $d.Name.ToLower())
    if (-not (Test-Path -LiteralPath $overview)) {
        Add-Warn 'overview' "[$($d.Name)] 디스플레이 메뉴 설명문 없음 -> scraper\@\overview\$($d.Name.ToLower()).txt"
    }

    # 디스플레이 마스코트
    #   NEVATO / Console Box 는 select_character = "By Display" 일 때
    #   character\[DisplayName].png 를 그린다. 없으면 화면 우측이 조용히 빈다
    #   (오류가 안 나서 눈치채기 어렵다). 480x760 알파 PNG 가 규격이다.
    #
    #   존재만 보면 안 된다 — 불투명 플라이어를 480x760 으로 잘라 넣어도 통과하고,
    #   화면에는 리스트 박스 위에 직사각형 포스터가 얹힌다 (ISSUES 28번).
    #   그래서 알파를 실측한다: 투명 픽셀이 20% 미만이면 컷아웃이 아니다.
    if ($d.Layout -eq 'NEVATO' -or $d.Layout -eq 'Console Box') {
        $mascot = Join-Path $Root ("layouts\{0}\character\{1}.png" -f $d.Layout, $d.Name)
        if (-not (Test-Path -LiteralPath $mascot)) {
            Add-Warn 'mascot' "[$($d.Name)] 마스코트 없음 -> layouts\$($d.Layout)\character\$($d.Name).png (화면 우측이 빈 채로 보임)"
        } else {
            $spec = Test-MascotSpec $mascot
            if ($spec) { Add-Warn 'mascot' "[$($d.Name)] 마스코트 규격 위반 -> layouts\$($d.Layout)\character\$($d.Name).png ($spec)" }
        }
    }
}

# layouts\ 안에 .nut 없는 폴더 (레이아웃 선택 목록에 깨진 항목으로 노출됨)
foreach ($dir in Get-ChildItem -LiteralPath (Join-Path $Root 'layouts') -Directory) {
    if (-not (Get-ChildItem -LiteralPath $dir.FullName -Filter '*.nut' -File)) {
        Add-Warn 'layouts' "layouts\$($dir.Name) 에 .nut 이 없습니다 (레이아웃 목록에 깨진 항목으로 노출)"
    }
}

# ---------------------------------------------------------------- 3. 에뮬레이터 cfg 경로
foreach ($name in ($emulators.Keys | Sort-Object)) {
    $cfg = $emulators[$name]
    $exe = $cfg['executable']
    $base = '.'
    if ($exe -and $exe -ne 'cmd') {
        $found = $false
        foreach ($ext in @('', '.exe', '.bat', '.lnk', '.com')) {
            if (Test-Path -LiteralPath ($exe + $ext)) { $found = $true; break }
        }
        if (-not $found) {
            if ($referenced.ContainsKey($name)) { Add-Fail 'emulator' "[$name] executable 없음 -> $exe" }
            else { Add-Env 'emulator' "[$name] executable 없음 -> $exe (참조하는 romlist 가 없어 실행에는 영향 없음)" }
        }
        $base = Split-Path $exe -Parent
    }
    # rompath 의 상대경로는 executable 디렉터리 기준 (executable 이 cmd 면 AM 루트 기준)
    if ($cfg['rompath']) {
        $romDir = Join-Path $base $cfg['rompath']
        if (-not (Test-Path -LiteralPath $romDir)) {
            Add-Env 'emulator' "[$name] rompath 없음 -> $romDir (롬 미설치이거나 예약 정의)"
        }
    }
    # artwork 경로는 AM 루트 기준
    foreach ($entry in $cfg['__artwork']) {
        $split = $entry -split '\s+', 2
        $label = $split[0]
        $paths = if ($split.Count -gt 1) { $split[1] } else { '' }
        foreach ($p in ($paths -split ';')) {
            $p = $p.Trim()
            if (-not $p) { continue }
            if (-not (Test-Path -LiteralPath $p)) {
                # menu-art\ 는 .gitignore 대상이라 장비마다 보유 범위가 다르다
                Add-Env 'artwork' "[$name] $label 아트웍 경로 없음 -> $p"
            }
        }
    }
}

# ---------------------------------------------------------------- 4. romlist
# MAME 계열은 mame.ini 의 rompath 가 실제 탐색을 담당하므로 roms\ 하위 전체를 후보로 둔다
$mameRomRoots = @()
$mameRomsDir = Join-Path $Root 'emulators\Mame\roms'
if (Test-Path -LiteralPath $mameRomsDir) {
    $mameRomRoots = @(Get-ChildItem -LiteralPath $mameRomsDir -Directory -Recurse | Select-Object -ExpandProperty FullName)
}

$totalActive = 0
foreach ($rf in (Get-ChildItem -LiteralPath (Join-Path $Root 'romlists') -Filter '*.txt' | Sort-Object Name)) {
    $listName = $rf.BaseName
    if (Test-Bom $rf.FullName) { Add-Fail 'BOM' "romlists\$($rf.Name) 에 UTF-8 BOM 이 있습니다" }

    $lines = [System.IO.File]::ReadAllLines($rf.FullName)
    # 완전 동일한 Name 은 오류. 대소문자만 다른 Name 은 Windows 에서 아트웍/즐겨찾기 파일이
    # 서로 덮어쓰므로 경고. (Ordinal = 대소문자 구분)
    $seen = New-Object 'System.Collections.Generic.Dictionary[string,int]' ([StringComparer]::Ordinal)
    $seenCI = New-Object 'System.Collections.Generic.Dictionary[string,int]' ([StringComparer]::OrdinalIgnoreCase)
    for ($i = 1; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '^\s*$') { continue }
        $lineNo = $i + 1
        $disabled = $line.StartsWith('#')
        $body = if ($disabled) { $line.Substring(1) } else { $line }
        $cols = $body -split ';'

        if ($cols.Count -ne 21) {
            Add-Fail 'romlist' "$listName : $lineNo 행 필드 수가 $($cols.Count) (21 이어야 함)"
            continue
        }

        $romName = $cols[0]
        $emuName = $cols[2]

        if (-not $disabled) {
            $totalActive++
            if ($seen.ContainsKey($romName)) {
                Add-Fail 'romlist' "$listName : Name 중복 '$romName' ($($seen[$romName]) 행 / $lineNo 행)"
            } elseif ($seenCI.ContainsKey($romName)) {
                Add-Warn 'romlist' "$listName : Name 이 대소문자만 다름 '$romName' ($($seenCI[$romName]) 행 / $lineNo 행) - 아트웍/즐겨찾기 파일이 겹칩니다"
                $seen[$romName] = $lineNo
            } else { $seen[$romName] = $lineNo; $seenCI[$romName] = $lineNo }
        }

        if (-not $emulators.ContainsKey($emuName)) {
            if ($disabled) {
                # 비활성(#) 행이 없는 에뮬레이터를 가리키는 것은 정의상 무해하다.
                # 한 건씩 경고하면 수십 건이 깔려 진짜 신호가 묻히므로 집계만 한다.
                $script:ParkedEmu[$emuName] = 1 + ($script:ParkedEmu[$emuName] -as [int])
            } else {
                Add-Fail 'romlist' "$listName : $lineNo 행 에뮬레이터 '$emuName' 정의 없음"
            }
            continue
        }

        if ($disabled) { continue }

        # --- 롬 파일 존재 확인
        $cfg = $emulators[$emuName]
        $rp = $cfg['rompath']
        $exts = @()
        if ($cfg['romext']) { $exts = @(($cfg['romext'] -split ';') | Where-Object { $_ -and $_ -ne '<DIR>' }) }
        # rompath 나 romext 가 없는 정의(Demul -rom=, TeknoParrot --profile= 등)는 검사 대상 아님
        if (-not $rp -or $exts.Count -eq 0) { continue }

        # args 에 치환 토큰이 없으면 AM 이 롬 경로를 아예 넘기지 않는다.
        #   런처형 정의(Taito Type X The BishiBashi 처럼 executable 이 게임을 고정)에 해당한다.
        #   이런 정의는 rompath/romext 가 목록 생성용 잔재이므로 롬 존재를 따질 대상이 아니다.
        if ($cfg['args'] -notmatch '\[(romfilename|name|rompath)\]') { continue }

        $exe = $cfg['executable']
        $base = if ($exe -and $exe -ne 'cmd') { Split-Path $exe -Parent } else { '.' }
        $dir = Join-Path $base $rp
        if (-not (Test-Path -LiteralPath $dir)) { continue }   # rompath 자체 부재는 위에서 이미 경고함

        $hit = $false
        foreach ($ext in $exts) {
            # 평면 배치: <rompath>\<name><ext>
            if (Test-Path -LiteralPath (Join-Path $dir ($romName + $ext))) { $hit = $true; break }
            # 게임별 하위폴더 배치: <rompath>\<name>\<name><ext>  (SEGA Dreamcast, Nintendo Wii U)
            if (Test-Path -LiteralPath (Join-Path $dir (Join-Path $romName ($romName + $ext)))) { $hit = $true; break }
        }
        if (-not $hit -and $cfg['romext'] -match '<DIR>') {
            if (Test-Path -LiteralPath (Join-Path $dir $romName)) { $hit = $true }
        }
        if (-not $hit -and $exe -match 'mame') {
            $allowDir = ($cfg['romext'] -match '<DIR>')
            foreach ($alt in $mameRomRoots) {
                foreach ($ext in $exts) {
                    if (Test-Path -LiteralPath (Join-Path $alt ($romName + $ext))) { $hit = $true; break }
                }
                # CHD 게임은 <rompath>\<name>\<name>.chd 형태로 폴더 단위로 놓인다
                if (-not $hit -and $allowDir -and (Test-Path -LiteralPath (Join-Path $alt $romName) -PathType Container)) { $hit = $true }
                if ($hit) { break }
            }
        }
        if (-not $hit) {
            Add-Fail 'rom' "$listName : '$romName' ($emuName) 롬 파일 없음 -> $dir"
        }
    }

    # --- .tag (즐겨찾기) 대조
    $tagFile = Join-Path $Root "romlists\$listName.tag"
    if (Test-Path -LiteralPath $tagFile) {
        $names = @{}
        for ($i = 1; $i -lt $lines.Count; $i++) {
            $b = $lines[$i]
            if ($b -match '^\s*$') { continue }
            if ($b.StartsWith('#')) { $b = $b.Substring(1) }
            $names[($b -split ';')[0]] = $true
        }
        foreach ($tag in [System.IO.File]::ReadAllLines($tagFile)) {
            $t = $tag.Trim()
            if (-not $t) { continue }
            if (-not $names.ContainsKey($t)) {
                Add-Fail 'tag' "$listName.tag : '$t' 가 romlist 에 없음"
            }
        }
    }
}

# 어떤 romlist 도 참조하지 않는 에뮬레이터 정의
foreach ($name in ($emulators.Keys | Sort-Object)) {
    if (-not $referenced.ContainsKey($name)) {
        Add-Warn 'emulator' "[$name] 어떤 romlist 도 참조하지 않는 정의"
    }
}

# 비활성 행이 참조하는 미정의 에뮬레이터 집계
if ($script:ParkedEmu.Count -gt 0) {
    $rows  = ($script:ParkedEmu.Values | Measure-Object -Sum).Sum
    $names = ($script:ParkedEmu.Keys | Sort-Object) -join ', '
    Add-Note ("비활성(#) 행 {0}건이 정의 없는 에뮬레이터 {1}종을 참조합니다 (비활성이라 무해)" -f $rows, $script:ParkedEmu.Count)
    Add-Note ("  -> $names")
}

# ---------------------------------------------------------------- 결과
Write-Host ("활성 게임 항목 {0}개" -f $totalActive)
Write-Host ("=" * 72)

# 장비마다 다른 것 — 0 이 아닌 게 정상
if (-not $Quiet -and $script:Envs.Count -gt 0) {
    Write-Host ""
    Write-Host ("환경  {0}건   (롬·아트웍·게임 미설치. 장비마다 다르며 저장소 문제가 아님)" -f $script:Envs.Count) -ForegroundColor DarkGray
    foreach ($e in $script:Envs) { Write-Host ("  [{0}] {1}" -f $e.Area, $e.Message) -ForegroundColor DarkGray }
}

# 알고 있고 그대로 두기로 한 것
if (-not $Quiet -and $script:Notes.Count -gt 0) {
    Write-Host ""
    Write-Host "참고" -ForegroundColor DarkCyan
    foreach ($n in $script:Notes) { Write-Host ("  $n") -ForegroundColor DarkCyan }
}

# 저장소 차원의 문제 — 기대값 0
if ($script:Warns.Count -gt 0) {
    Write-Host ""
    Write-Host ("WARN  {0}건   (저장소 차원. 모든 장비에서 동일하게 나오며 기대값은 0)" -f $script:Warns.Count) -ForegroundColor Yellow
    foreach ($w in $script:Warns) { Write-Host ("  [{0}] {1}" -f $w.Area, $w.Message) -ForegroundColor DarkYellow }
}

if ($script:Fails.Count -gt 0) {
    Write-Host ""
    Write-Host ("FAIL  {0}건" -f $script:Fails.Count) -ForegroundColor Red
    foreach ($f in $script:Fails) { Write-Host ("  [{0}] {1}" -f $f.Area, $f.Message) -ForegroundColor Red }
    Write-Host ""
    exit 1
}

Write-Host ""
if ($script:Warns.Count -eq 0) { Write-Host "오류 없음" -ForegroundColor Green }
else { Write-Host ("오류 없음 (WARN {0}건은 확인 필요)" -f $script:Warns.Count) -ForegroundColor Green }
Write-Host ""
exit 0
