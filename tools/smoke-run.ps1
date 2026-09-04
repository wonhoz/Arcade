<#
.SYNOPSIS
    Attract-Mode 실행 점검. 지정한 디스플레이(와 레이아웃 파일)로 AM 을 몇 초 띄웠다가 끄고 last_run.log 를 돌려준다.
.DESCRIPTION
    저장소는 건드리지 않는다. %TEMP% 아래에 격리된 설정 디렉터리를 만들고, 저장소의 각 폴더를 정션(junction)으로
    연결한 뒤 attract.cfg / attract.am 사본만 고쳐서 attract.exe --config 로 실행한다.
      - startup_mode 를 default 로 바꿔 디스플레이 메뉴 대신 지정 디스플레이에서 바로 시작
      - attract.am 의 현재 디스플레이 인덱스와 그 디스플레이의 레이아웃 파일(layout_vewlix_white 등)을 지정
      - -Layout 으로 그 디스플레이의 layout 을 임시로 바꿔 어떤 레이아웃이든 로드해 볼 수 있다 (Mega-Display 등)
    로그에 "AN ERROR HAS OCCURED" / "Script Error" 가 있으면 종료 코드 1.
    ※ 화면은 그 시간 동안 AM 이 차지한다. 창 모드는 480x320 이라 NEVATO 가 지원하지 않는 종횡비(1.5)가 되어 쓰지 않는다.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\smoke-run.ps1 -Display "Taito Type X"
    powershell -ExecutionPolicy Bypass -File tools\smoke-run.ps1 -Display MAME -LayoutFile layout_vewlix_white
    powershell -ExecutionPolicy Bypass -File tools\smoke-run.ps1 -Display MAME -Layout Mega-Display
    powershell -ExecutionPolicy Bypass -File tools\smoke-run.ps1 -All          # NEVATO·Console Box·NXL HD·Mega-Display 4종 순서대로
#>
param(
    [string]$Display = 'MAME',
    [string]$LayoutFile = '',      # attract.am 에 기록되는 레이아웃 파일명 (확장자 없이). 비우면 layout.nut
    [string]$Layout = '',          # 그 디스플레이의 layout 을 임시로 이 레이아웃으로 바꿔 실행
    [int]$Seconds = 20,
    [switch]$All,
    [switch]$Quiet
)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Cfg  = Join-Path $env:TEMP 'attractmode-smoke-run'
$enc  = New-Object Text.UTF8Encoding $false

if (-not (Test-Path -LiteralPath $Cfg)) { New-Item -ItemType Directory -Path $Cfg | Out-Null }
foreach ($d in Get-ChildItem -LiteralPath $Root -Directory) {
    if ($d.Name -in '.git', '.claude') { continue }
    $link = Join-Path $Cfg $d.Name
    if (-not (Test-Path -LiteralPath $link)) { New-Item -ItemType Junction -Path $link -Target $d.FullName | Out-Null }
}

# attract.cfg 의 display 순서 = attract.am 의 인덱스
$displays = @()
foreach ($l in [IO.File]::ReadAllLines("$Root\attract.cfg")) { if ($l -match '^display\s+(.+?)\s*$') { $displays += $Matches[1] } }

function Invoke-One([string]$disp, [string]$layoutFile, [string]$swap) {
    $idx = [array]::IndexOf($displays, $disp)
    if ($idx -lt 0) { Write-Host "FAIL  display '$disp' 가 attract.cfg 에 없음" -ForegroundColor Red; return $false }

    $lines = [IO.File]::ReadAllLines("$Root\attract.cfg")
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match '^\s*window_mode\s')  { $lines[$i] = "`twindow_mode          default" }
        if ($lines[$i] -match '^\s*startup_mode\s') { $lines[$i] = "`tstartup_mode         default" }
        if ($swap -and $lines[$i] -match ('^display\s+' + [regex]::Escape($disp) + '\s*$') -and $lines[$i + 1] -match '^\s*layout\s') {
            $lines[$i + 1] = "`tlayout               $swap"
        }
    }
    [IO.File]::WriteAllLines("$Cfg\attract.cfg", $lines, $enc)

    # attract.am: 0행 = 현재 디스플레이 인덱스, (인덱스+1)행 = 그 디스플레이 상태 "...;<레이아웃 파일>;0;"
    $am = [IO.File]::ReadAllLines("$Root\attract.am")
    while ($am.Length -lt $displays.Count + 1) { $am += '0,0,;;0;' }
    $am[0] = "$idx;0,0,0;"; $am[$idx + 1] = "0,0,;$layoutFile;0;"
    [IO.File]::WriteAllLines("$Cfg\attract.am", $am)

    $log = Join-Path $Cfg 'last_run.log'
    if ([IO.File]::Exists($log)) { [IO.File]::Delete($log) }
    $psi = New-Object Diagnostics.ProcessStartInfo
    $psi.FileName = Join-Path $Root 'attract.exe'; $psi.WorkingDirectory = $Root; $psi.UseShellExecute = $true
    $psi.Arguments = "--config `"$Cfg`" --logfile `"$log`""
    $p = [Diagnostics.Process]::Start($psi)
    Start-Sleep -Seconds $Seconds
    if (-not $p.HasExited) { $p.Kill() }
    Start-Sleep -Seconds 2

    $label = "$disp"; if ($layoutFile) { $label += " / $layoutFile" }; if ($swap) { $label += " / layout=$swap" }
    if (-not [IO.File]::Exists($log)) { Write-Host "FAIL  [$label] 로그가 생성되지 않음" -ForegroundColor Red; return $false }
    $lines = [IO.File]::ReadAllLines($log)
    $bad = @($lines | Where-Object { $_ -match 'AN ERROR HAS OCCURED|Script Error|Error opening' })
    $loaded = @($lines | Where-Object { $_ -match 'Loaded layout' } | ForEach-Object { $_ -replace [regex]::Escape($Cfg), '<cfg>' })
    if ($bad.Count) {
        Write-Host "FAIL  [$label]" -ForegroundColor Red
        $lines | Where-Object { $_ -notmatch 'using settings|does not exist|using default value' } | ForEach-Object { "      $_" }
        return $false
    }
    Write-Host "OK    [$label]  $($loaded -join ' | ')" -ForegroundColor Green
    if (-not $Quiet) { $lines | Where-Object { $_ -match 'Initializing display|Loaded|Constructed' } | ForEach-Object { "      $($_ -replace [regex]::Escape($Cfg), '<cfg>')" } }
    return $true
}

$ok = $true
if ($All) {
    # 각 레이아웃을 실제로 쓰는 디스플레이 하나씩 + 메뉴에서만 고를 수 있는 Mega-Display
    $ok = (Invoke-One 'MAME' '' '') -and $ok
    $ok = (Invoke-One 'Sony PlayStation' '' '') -and $ok
    $ok = (Invoke-One 'NESiCAxLive' '' '') -and $ok
    $ok = (Invoke-One 'MAME' '' 'Mega-Display') -and $ok
} else {
    $ok = Invoke-One $Display $LayoutFile $Layout
}
if ($ok) { exit 0 } else { exit 1 }
