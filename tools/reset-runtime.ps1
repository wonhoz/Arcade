<#
.SYNOPSIS
    실행으로 변경된 런타임 파일을 커밋 상태로 되돌리고, 미추적 산출물을 정리한다.

.DESCRIPTION
    이 저장소는 런타임 상태 파일을 일부러 git 으로 추적한다.
    입력 설정이 꼬이거나 에뮬레이터가 이상해졌을 때 "커밋된 정상 상태"로
    한 번에 되돌리기 위해서다. 대신 게임을 한 번 실행하는 것만으로
    git status 가 지저분해지므로, 이 스크립트로 한 번에 정리한다.

    파일을 세 갈래로 나눠 다룬다.

      설정  게임별 입력·딥스위치, UI, 플레이리스트, AM 마지막 선택 상태
            -> 되돌려도 잃는 것이 없다. 평소 정리는 이것만 하면 된다.
      세이브 메모리카드·NVRAM·스테이트·하이스코어
            -> 되돌리면 게임 진행이 커밋 시점으로 돌아간다. 별도 스위치가 필요하다.
      산출물 로그·통계·캐시 (git 이 추적하지 않는 것)
            -> 삭제한다.

.PARAMETER Config   설정 계열을 커밋 상태로 되돌린다.
.PARAMETER Saves    세이브 계열까지 되돌린다. 게임 진행이 사라진다.
.PARAMETER Clean    미추적 산출물(로그·통계·캐시)을 삭제한다.
.PARAMETER All      -Config -Saves -Clean 을 모두 적용한다.
.PARAMETER Force    확인 프롬프트 없이 실행한다.
.PARAMETER Root     저장소 경로 (기본: 스크립트의 상위 폴더)

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\reset-runtime.ps1
    무엇이 바뀌었는지 보여주기만 한다 (기본 동작, 아무것도 건드리지 않음).

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\reset-runtime.ps1 -Config -Clean
    입력·UI 설정을 커밋 상태로 되돌리고 로그·통계를 지운다. 세이브는 그대로 둔다.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\reset-runtime.ps1 -All -Force
    세이브까지 포함해 전부 초기화한다.
#>
[CmdletBinding()]
param(
    [switch]$Config,
    [switch]$Saves,
    [switch]$Clean,
    [switch]$All,
    [switch]$Force,
    [string]$Root
)

$ErrorActionPreference = 'Stop'

if (-not $Root) { $Root = Split-Path -Parent $PSScriptRoot }
if (-not (Test-Path -LiteralPath (Join-Path $Root 'attract.cfg'))) {
    Write-Error "attract.cfg 를 찾을 수 없습니다: $Root"
    exit 1
}
Set-Location -LiteralPath $Root

if ($All) { $Config = $true; $Saves = $true; $Clean = $true }
$ListOnly = -not ($Config -or $Saves -or $Clean)

# ---------------------------------------------------------------------------
# 대상 정의
#
#   추적 중인 파일은 git checkout 으로 되돌린다.
#   경로는 git pathspec 이며, 없는 경로가 섞여 있어도 무해하다.
# ---------------------------------------------------------------------------

# 설정 — 되돌려도 잃는 것이 없다
$ConfigPaths = @(
    'attract.am'                                # AM 마지막 선택 디스플레이/게임
    'emulators/Mame/cfg'                        # MAME 게임별 입력·딥스위치
    'emulators/Mame/ui.ini'                     # MAME UI 상태
    'emulators/RetroArch/retroarch.cfg'         # RetroArch 설정 (종료 시 덮어씀)
    'emulators/RetroArch/content_history.lpl'   # 최근 실행 목록
    'emulators/RetroArch/content_image_history.lpl'
    'emulators/RetroArch/content_music_history.lpl'
    'emulators/RetroArch/content_video_history.lpl'
    'emulators/RetroArch/content_favorites.lpl'
    'emulators/PCSX2/inis'                      # PCSX2 설정·입력
    'emulators/M2/CFG'                          # MODEL2 게임별 입력
    'emulators/Project64/Config'                # Project64 설정·입력
    'emulators/TeknoParrot/UserProfiles'        # TeknoParrot 게임별 입력
    'emulators/Demul/padDemul.ini'
    'emulators/Demul/gpuDX11.ini'
    'emulators/PPSSPP/memstick/PSP/SYSTEM'      # PPSSPP 설정·입력
)

# 세이브 — 되돌리면 게임 진행이 사라진다
$SavePaths = @(
    'emulators/Mame/nvram'
    'emulators/Mame/memcard'
    'emulators/Mame/diff'
    'emulators/Mame/sta'
    'emulators/PCSX2/memcards'
    'emulators/PCSX2/sstates'
    'emulators/ePSXe/memcards'
    'emulators/ePSXe/sstates'
    'emulators/Project64/Save'
    'emulators/SuperModel/NVRAM'
    'emulators/SuperModel/Saves'
    'emulators/Demul/nvram'
    'emulators/RetroArch/saves'
    'emulators/RetroArch/states'
)

# 미추적 산출물 — 삭제 대상
$JunkPaths = @(
    'last_run.log'
    'script.nv'
    'stats'
    'emulators/Mame/hiscore'
    'emulators/Mame/data/history.db'
    'emulators/Mame/cheat/output.json'
    'emulators/Mame/cheat/output.xml'
    'emulators/RetroArch/screenshots'
    'emulators/RetroArch/retroarch.log'
)

# ---------------------------------------------------------------------------
function Get-Changed([string[]]$Paths) {
    # 추적 중이면서 커밋 상태에서 벗어난 파일만 돌려준다
    $existing = @($Paths | Where-Object { Test-Path -LiteralPath $_ })
    if ($existing.Count -eq 0) { return @() }
    $out = & git status --porcelain -- $existing 2>$null
    if (-not $out) { return @() }
    @($out | Where-Object { $_ -notmatch '^\?\?' } | ForEach-Object { $_.Substring(3).Trim('"') })
}

function Get-Junk([string[]]$Paths) {
    # 존재하면서 "git 이 추적하지 않는" 것만 삭제 대상으로 삼는다.
    #
    # 이 확인이 없으면 추적 중인 파일까지 지워버린다.
    # 실제로 emulators/Mame/cheat/output.{json,xml} 이 추적 중인데도 삭제된 적이 있다.
    # 산출물이라고 생각한 경로가 실제로는 커밋돼 있을 수 있으므로 반드시 확인한다.
    $out = @()
    foreach ($p in $Paths) {
        if (-not (Test-Path -LiteralPath $p)) { continue }
        # 경로 하위에 추적 파일이 하나라도 있으면 건드리지 않는다
        $tracked = & git ls-files -- $p 2>$null
        if ($tracked) {
            Write-Host ("  건너뜀(추적 중): {0}" -f $p) -ForegroundColor DarkYellow
            continue
        }
        $out += $p
    }
    @($out)
}

function Show-Group([string]$Title, [string[]]$Items, [string]$Color) {
    Write-Host ""
    if ($Items.Count -eq 0) { Write-Host ("{0}  없음" -f $Title) -ForegroundColor DarkGray; return }
    Write-Host ("{0}  {1}건" -f $Title, $Items.Count) -ForegroundColor $Color
    $show = if ($Items.Count -gt 12) { $Items[0..11] } else { $Items }
    foreach ($i in $show) { Write-Host ("    $i") -ForegroundColor DarkGray }
    if ($Items.Count -gt 12) { Write-Host ("    ... 외 {0}건" -f ($Items.Count - 12)) -ForegroundColor DarkGray }
}

Write-Host ""
Write-Host "런타임 파일 정리  ($Root)" -ForegroundColor Cyan
Write-Host ("=" * 72)

$cfgChanged  = Get-Changed $ConfigPaths
$savChanged  = Get-Changed $SavePaths
$junkFound   = Get-Junk    $JunkPaths

Show-Group "설정   (되돌려도 잃는 것 없음)" $cfgChanged 'Yellow'
Show-Group "세이브 (되돌리면 게임 진행이 사라짐)" $savChanged 'Red'
Show-Group "산출물 (미추적 - 삭제 대상)" $junkFound 'DarkCyan'

Write-Host ""
Write-Host ("=" * 72)

if ($ListOnly) {
    Write-Host ""
    Write-Host "보기만 했습니다. 실제로 정리하려면:" -ForegroundColor Green
    Write-Host "  -Config          설정만 되돌리기 (평소에는 이것만으로 충분)" -ForegroundColor Gray
    Write-Host "  -Clean           산출물 삭제" -ForegroundColor Gray
    Write-Host "  -Saves           세이브까지 되돌리기 (게임 진행이 사라집니다)" -ForegroundColor Gray
    Write-Host "  -All             위 전부" -ForegroundColor Gray
    Write-Host ""
    exit 0
}

# ---------------------------------------------------------------------------
$plan = @()
if ($Config -and $cfgChanged.Count) { $plan += "설정 $($cfgChanged.Count)건을 커밋 상태로 되돌림" }
if ($Saves  -and $savChanged.Count) { $plan += "세이브 $($savChanged.Count)건을 커밋 상태로 되돌림 (게임 진행 삭제)" }
if ($Clean  -and $junkFound.Count)  { $plan += "산출물 $($junkFound.Count)건 삭제" }

if ($plan.Count -eq 0) {
    Write-Host ""
    Write-Host "정리할 것이 없습니다." -ForegroundColor Green
    Write-Host ""
    exit 0
}

Write-Host ""
Write-Host "실행할 작업:" -ForegroundColor Yellow
foreach ($p in $plan) { Write-Host "  - $p" }

if (-not $Force) {
    Write-Host ""
    $ans = Read-Host "진행할까요? (y/N)"
    if ($ans -ne 'y' -and $ans -ne 'Y') { Write-Host "취소했습니다."; exit 0 }
}

if ($Config -and $cfgChanged.Count) {
    & git checkout -- $cfgChanged
    Write-Host ("  설정 {0}건 되돌림" -f $cfgChanged.Count) -ForegroundColor Green
}
if ($Saves -and $savChanged.Count) {
    & git checkout -- $savChanged
    Write-Host ("  세이브 {0}건 되돌림" -f $savChanged.Count) -ForegroundColor Green
}
if ($Clean -and $junkFound.Count) {
    foreach ($j in $junkFound) {
        Remove-Item -LiteralPath $j -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host ("  산출물 {0}건 삭제" -f $junkFound.Count) -ForegroundColor Green
}

Write-Host ""
$left = & git status --porcelain 2>$null | Where-Object { $_ -notmatch '^\?\?' }
if ($left) {
    Write-Host "아직 남은 변경 (런타임 대상이 아님 - 직접 확인하세요):" -ForegroundColor Yellow
    $left | ForEach-Object { Write-Host ("  $_") -ForegroundColor DarkYellow }
} else {
    Write-Host "추적 파일에 남은 변경 없음" -ForegroundColor Green
}
Write-Host ""
exit 0
