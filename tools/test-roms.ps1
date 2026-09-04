<#
.SYNOPSIS
    romlists 전 항목 구동 검증기
.DESCRIPTION
    romlists\*.txt 의 각 항목에 대해 Attract-Mode 가 실제로 만들어 낼 실행 명령을
    그대로 재구성해서 점검한다. 두 단계로 나뉜다.

      1) 정적 점검 (기본, 수 초)   실행파일 . 롬 파일 . 인자 치환까지 조립해 본다.
      2) 구동 점검 (-Launch)       조립한 명령을 실제로 실행해서 살아 있는지 본다.

    tools\validate.ps1 은 "설정이 서로 맞는가"를 보고, 이 스크립트는
    "그 설정으로 실제 실행이 되는가"를 본다. 자세한 구조는 CLAUDE.md 4절 참고.
.PARAMETER Root
    AttractMode 설치 경로. 기본값은 이 스크립트의 상위 디렉터리.
.PARAMETER List
    검사할 romlist 이름. 와일드카드 가능. 생략하면 전부.
.PARAMETER Emulator
    검사할 에뮬레이터 이름. 와일드카드 가능.
.PARAMETER Name
    Name/Title 부분일치 필터.
.PARAMETER Launch
    실제로 에뮬레이터를 실행한다. 화면을 점유하므로 캐비닛에서 직접 볼 때만 쓴다.
.PARAMETER Seconds
    -Launch 시 생존 판정까지 기다리는 초. 기본 12.
.PARAMETER Sample
    에뮬레이터별로 앞에서 N개만 검사한다. 전체 대표 점검용.
.PARAMETER Max
    총 N개까지만 검사한다.
.PARAMETER Shuffle
    순서를 무작위로 섞는다. -Sample/-Max 와 함께 쓰면 무작위 표본이 된다.
.PARAMETER Failed
    직전 보고서(logs\rom-test-*.csv 중 최신)에서 실패한 항목만 다시 검사한다.
.PARAMETER IncludeDisabled
    '#' 로 비활성화된 항목도 포함한다.
.PARAMETER Report
    보고서 경로(확장자 제외). 생략하면 logs\rom-test-<날짜시각>.
    같은 이름으로 .csv 와 .html 두 벌이 나온다.
.PARAMETER NoHtml
    HTML 보고서를 만들지 않는다.
.PARAMETER Open
    끝나고 HTML 보고서를 기본 브라우저로 연다.
.PARAMETER Force
    -Launch 실행 전 확인을 묻지 않는다.
.PARAMETER Quiet
    통과 항목을 출력하지 않고 실패만 보여준다.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\test-roms.ps1
    powershell -ExecutionPolicy Bypass -File tools\test-roms.ps1 -Launch -List MAME -Sample 3
    powershell -ExecutionPolicy Bypass -File tools\test-roms.ps1 -Launch -Failed
.NOTES
    종료 코드: 0 = 실패 없음, 1 = 실패 있음

    -Launch 는 종료할 때 ESC 를 먼저 보낸다. MAME 계열을 강제 종료하면
    cfg\default.cfg 가 0바이트로 잘리기 때문이다(CLAUDE.md 5.5절).
    ESC 로 안 죽는 것만 창 닫기 -> 강제 종료 순으로 올라가고 보고서에 남긴다.
#>
[CmdletBinding()]
param(
    [string]$Root,
    [string[]]$List,
    [string[]]$Emulator,
    [string]$Name,
    [switch]$Launch,
    [int]$Seconds = 12,
    [int]$Sample = 0,
    [int]$Max = 0,
    [switch]$Shuffle,
    [switch]$Failed,
    [switch]$IncludeDisabled,
    [string]$Report,
    [switch]$NoHtml,
    [switch]$Open,
    [switch]$Force,
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

# 상태 코드
#   정적  OK    실행 명령까지 조립 완료. -Launch 대상.
#         NOCHK 롬 존재를 따질 수 없는 정의(고정 실행형, rom 이름만 넘기는 Demul 등).
#               실패가 아니다. 실행은 해 본다.
#         NOEMU / NOEXE / NOROM   실패.
#   구동  PASS  지정 시간 동안 살아 있었다.
#         EXIT0 바로 끝났다(코드 0). 롬을 못 읽고 조용히 닫힌 경우가 대부분이라 실패로 센다.
#         CRASH 0 이 아닌 코드로 끝났다.
#         NOWIN 살아 있으나 창이 없다. 런처가 다른 프로세스를 띄웠을 수 있어 경고에 그친다.
$FailStatus = @('NOEMU', 'NOEXE', 'NOROM', 'EXIT0', 'CRASH', 'LAUNCHERR')
$WarnStatus = @('NOWIN')

# ESC 를 에뮬레이터에 보내기 위한 것. 두 가지가 필요하다.
#   1. 포그라운드 창의 소유 프로세스 확인 — 엉뚱한 창(터미널)에 ESC 를 보내지 않기 위해(ISSUES 45번).
#   2. 스캔코드 SendInput — MAME 는 DirectInput 으로 키보드를 읽어서
#      WScript.Shell 의 SendKeys 를 받지 않는다(PSXMAME 로 실측).
if (-not ('AmInput' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class AmInput {
    [StructLayout(LayoutKind.Sequential)]
    public struct KEYBDINPUT { public ushort wVk; public ushort wScan; public uint dwFlags; public uint time; public IntPtr dwExtraInfo; }
    [StructLayout(LayoutKind.Explicit)]
    public struct INPUT { [FieldOffset(0)] public uint type; [FieldOffset(8)] public KEYBDINPUT ki; }
    [DllImport("user32.dll")] static extern uint SendInput(uint n, INPUT[] p, int cb);
    [DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] static extern int GetWindowThreadProcessId(IntPtr h, out int pid);

    public static int ForegroundPid() {
        int pid = 0;
        GetWindowThreadProcessId(GetForegroundWindow(), out pid);
        return pid;
    }
    // ESC 를 스캔코드(0x01)로 누르고 뗀다. KEYEVENTF_SCANCODE=0x0008, KEYEVENTF_KEYUP=0x0002
    public static void SendEsc() {
        INPUT[] a = new INPUT[2];
        a[0].type = 1; a[0].ki.wScan = 0x01; a[0].ki.dwFlags = 0x0008;
        a[1].type = 1; a[1].ki.wScan = 0x01; a[1].ki.dwFlags = 0x0008 | 0x0002;
        SendInput(2, a, Marshal.SizeOf(typeof(INPUT)));
    }
}
'@
}

function Read-AmConfig([string]$Path) {
    $result = @{}
    foreach ($raw in [System.IO.File]::ReadAllLines($Path)) {
        $line = $raw.TrimStart($BOM)
        if ($line -match '^\s*$' -or $line -match '^\s*#') { continue }
        if ($line -match '^\s') { continue }
        $parts = $line -split '\s+', 2
        $key = $parts[0]
        if ($key -eq 'artwork') { continue }
        $result[$key] = if ($parts.Count -gt 1) { $parts[1].Trim() } else { '' }
    }
    return $result
}

# executable 을 실제 파일로 해석한다. AM 은 확장자를 생략할 수 있게 해 준다.
#   반환: @{ Path = 절대경로; Dir = 작업 디렉터리 }   못 찾으면 $null
#   executable 이 cmd 인 정의(PC Game, Taito Type X)만 경로 기준이 AM 루트다.
function Resolve-Exe([string]$Exe) {
    if (-not $Exe) { return $null }
    if ($Exe -eq 'cmd') {
        return @{ Path = (Join-Path $env:SystemRoot 'system32\cmd.exe'); Dir = $Root }
    }
    foreach ($ext in @('', '.exe', '.bat', '.cmd', '.com', '.lnk')) {
        $p = Join-Path $Root ($Exe + $ext)
        if (Test-Path -LiteralPath $p -PathType Leaf) {
            $full = (Resolve-Path -LiteralPath $p).Path
            return @{ Path = $full; Dir = (Split-Path -Parent $full) }
        }
    }
    return $null
}

# 롬을 찾는다. AM 의 [romfilename] 치환과 같은 순서로 본다.
#   반환: @{ File; Ext; Dir; Checked }   Checked=$false 면 존재를 단정할 수 없는 정의라
#   못 찾아도 실패로 세지 않는다.
function Resolve-Rom($Cfg, [string]$RomName, [string]$ExeDir, $MameRoots) {
    $out = @{ File = $null; Ext = ''; Dir = ''; Checked = $false }

    # rompath 가 비어 있는 정의(TeknoParrot)는 exe 디렉터리가 기준이다.
    # TeknoParrotUi 는 --profile 로 받은 이름을 UserProfiles\ 에서 찾으므로 한 단계 아래까지 본다.
    $rp = $Cfg['rompath']
    $dirs = @()
    if ($rp) {
        $dirs = @(Join-Path $ExeDir $rp)
    } else {
        $dirs = @($ExeDir)
        $dirs += @(Get-ChildItem -LiteralPath $ExeDir -Directory -ErrorAction SilentlyContinue |
                   Select-Object -ExpandProperty FullName)
    }
    $out.Dir = $dirs[0]
    $dirs = @($dirs | Where-Object { Test-Path -LiteralPath $_ })
    if ($dirs.Count -eq 0) { return $out }

    $exts = @()
    if ($Cfg['romext']) { $exts = @(($Cfg['romext'] -split ';') | Where-Object { $_ -and $_ -ne '<DIR>' }) }
    $allowDir = ($Cfg['romext'] -match '<DIR>')
    # romext 가 비어 있는 정의(Demul 의 -rom=)는 확장자를 알 수 없다. 흔한 컨테이너로 훑어보고,
    # 찾으면 그것으로 확정하되 못 찾았을 때는 "없다"고 단정하지 않는다.
    $guess = ($exts.Count -eq 0)
    if ($guess) { $exts = @('.zip', '.7z', '.chd', '.bin') } else { $out.Checked = $true }

    foreach ($dir in $dirs) {
        foreach ($ext in $exts) {
            # romext 에 점 없는 항목이 섞여 있다(SEGA Dreamcast 의 'cdi'). AM 은 그대로 이어 붙인다.
            $e = if ($ext.StartsWith('.')) { $ext } else { ".$ext" }
            $f = Join-Path $dir ($RomName + $e)                          # 평면 배치
            if (Test-Path -LiteralPath $f -PathType Leaf) { $out.File = $f; $out.Ext = $ext; $out.Checked = $true; return $out }
            $f = Join-Path $dir (Join-Path $RomName ($RomName + $e))     # 게임별 하위폴더 배치
            if (Test-Path -LiteralPath $f -PathType Leaf) { $out.File = $f; $out.Ext = $ext; $out.Checked = $true; return $out }
        }
        if ($allowDir) {
            $f = Join-Path $dir $RomName
            if (Test-Path -LiteralPath $f -PathType Container) { $out.File = $f; $out.Checked = $true; return $out }
        }
    }
    # MAME 계열은 실제 탐색을 mame.ini 의 rompath 가 한다. roms\ 하위 전체가 후보다.
    if ($Cfg['executable'] -match 'mame') {
        foreach ($alt in $MameRoots) {
            foreach ($ext in $exts) {
                $e = if ($ext.StartsWith('.')) { $ext } else { ".$ext" }
                $f = Join-Path $alt ($RomName + $e)
                if (Test-Path -LiteralPath $f -PathType Leaf) { $out.File = $f; $out.Ext = $ext; $out.Checked = $true; return $out }
            }
            if ($allowDir) {
                $f = Join-Path $alt $RomName
                if (Test-Path -LiteralPath $f -PathType Container) { $out.File = $f; $out.Checked = $true; return $out }
            }
        }
    }
    return $out
}

# args 의 치환 토큰을 AM 과 같게 채운다.
#   AM 은 [romfilename] 에 cfg 의 rompath 를 그대로 이어 붙인 값(대개 상대경로)을 넣는다.
#   실행 시 작업 디렉터리를 executable 폴더로 두므로 그대로 동작한다. 여기서도 같게 만든다.
function Expand-AmArgs([string]$Template, [string]$RomName, [string]$Title, [string]$EmuName, $Rom, $Cfg) {
    if (-not $Template) { return '' }
    $rompath = [string]$Cfg['rompath']
    if ($rompath -and -not ($rompath.EndsWith('\') -or $rompath.EndsWith('/'))) { $rompath += '\' }
    $ext = $Rom.Ext
    if (-not $ext) {
        $ext = (($Cfg['romext'] -split ';') | Where-Object { $_ -and $_ -ne '<DIR>' } | Select-Object -First 1)
    }
    # 폴더 자체가 롬인 경우(<DIR>)는 확장자가 없다
    if ($Rom.File -and (Test-Path -LiteralPath $Rom.File -PathType Container)) { $ext = '' }

    $s = $Template
    $s = $s.Replace('[romfilename]', ($rompath + $RomName + $ext))
    $s = $s.Replace('[rompath]', $rompath)
    $s = $s.Replace('[romext]', [string]$ext)
    $s = $s.Replace('[name]', $RomName)
    $s = $s.Replace('[title]', $Title)
    $s = $s.Replace('[emulator]', $EmuName)
    return $s
}

# 실행 중인 에뮬레이터를 안전하게 끝낸다. 반환값은 "강제 종료했는가".
#   MAME 계열을 강제 종료하면 cfg\default.cfg 가 0바이트로 잘린다(CLAUDE.md 5.5절).
#   그래서 ESC -> 창 닫기 -> 강제 종료 순으로 올라간다.
function Stop-Emulator($Proc, [string]$ExePath, $Preexisting) {
    $killed = $false
    # 로딩 중인 MAME 는 ESC 를 씹는다. 한 번 보내고 마는 대신 로딩이 끝날 때까지 몇 번 더 보낸다.
    if (-not $Proc.HasExited) {
        $wsh = $null
        try { $wsh = New-Object -ComObject WScript.Shell } catch {}
        for ($try = 0; $try -lt 6; $try++) {
            $Proc.Refresh()
            if ($Proc.HasExited) { break }
            # AppActivate 는 이미 포그라운드인 창에도 False 를 돌려준다(PSXMAME 로 실측).
            # 그래서 반환값이 아니라 포그라운드 PID 로 판단한다.
            try { if ($wsh) { [void]$wsh.AppActivate($Proc.Id) } } catch {}
            Start-Sleep -Milliseconds 350
            $Proc.Refresh()
            if (-not $Proc.HasExited -and [AmInput]::ForegroundPid() -eq $Proc.Id) {
                [AmInput]::SendEsc()
            }
            $w = [Diagnostics.Stopwatch]::StartNew()
            while (-not $Proc.HasExited -and $w.Elapsed.TotalSeconds -lt 2.5) {
                Start-Sleep -Milliseconds 200; $Proc.Refresh()
            }
        }
    }
    if (-not $Proc.HasExited) {
        try { [void]$Proc.CloseMainWindow() } catch {}
        $w = [Diagnostics.Stopwatch]::StartNew()
        while (-not $Proc.HasExited -and $w.Elapsed.TotalSeconds -lt 6) { Start-Sleep -Milliseconds 200; $Proc.Refresh() }
    }
    if (-not $Proc.HasExited) {
        & taskkill.exe /PID $Proc.Id /T /F 2>&1 | Out-Null
        $killed = $true
        Start-Sleep -Milliseconds 500
    }
    # 런처형(cmd /c, TeknoParrotUi)은 자식 프로세스를 남긴다. 이번에 새로 생긴 것만 정리한다.
    $base = [IO.Path]::GetFileNameWithoutExtension($ExePath)
    foreach ($p in @(Get-Process -Name $base -ErrorAction SilentlyContinue)) {
        if ($Preexisting -notcontains $p.Id) {
            try { & taskkill.exe /PID $p.Id /T /F 2>&1 | Out-Null; $killed = $true } catch {}
        }
    }
    return $killed
}

# 결과를 한 장짜리 HTML 로 정리한다. 캐비닛 PC 에는 인터넷이 없을 수 있으므로
# 외부 CDN·폰트를 쓰지 않고 CSS·JS 를 전부 파일 안에 넣는다.
function Write-HtmlReport($Rows, [string]$Path, $Meta) {
    $json = ($Rows | Select-Object List, Name, Title, Emulator, Status, Detail, Exe, Args, ElapsedMs |
             ConvertTo-Json -Depth 3 -Compress)
    if (-not $json.StartsWith('[')) { $json = "[$json]" }   # 1건이면 배열이 아니라 객체로 나온다
    # 롬 이름·인자에 '<' 가 섞이면 </script> 로 읽혀 문서가 끊긴다.
    # JSON 유니코드 이스케이프(역슬래시 u003c)로 바꿔 둔다.
    $lt = [string][char]92 + 'u003c'
    $json = $json.Replace('<', $lt)
    $metaJson = ($Meta | ConvertTo-Json -Depth 3 -Compress).Replace('<', $lt)

    $tpl = @'
<!doctype html>
<html lang="ko"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>롬 구동 검증 보고서</title>
<style>
:root{
  --bg:#f6f7f9; --panel:#fff; --line:#e3e6ea; --fg:#1b1f24; --dim:#6b7280;
  --ok:#1a7f47; --okbg:#e7f5ec; --fail:#c0392b; --failbg:#fdeceb;
  --warn:#a86b00; --warnbg:#fdf3e0; --skip:#5b6470; --skipbg:#eef0f3; --accent:#2f6fd0;
}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){
  --bg:#14171c; --panel:#1c2027; --line:#2c323b; --fg:#e6e9ee; --dim:#98a1ae;
  --ok:#5ed08d; --okbg:#16301f; --fail:#ff8177; --failbg:#3a1d1a; --warn:#f0b849;
  --warnbg:#3a2c12; --skip:#9aa3b0; --skipbg:#242a32; --accent:#79a8f0;
}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--fg);
  font:14px/1.55 "Malgun Gothic","맑은 고딕",system-ui,-apple-system,Segoe UI,sans-serif}
.wrap{max-width:1180px;margin:0 auto;padding:28px 20px 64px}
h1{font-size:20px;margin:0 0 4px}
.sub{color:var(--dim);font-size:13px;margin-bottom:22px}
.sub b{color:var(--fg);font-weight:600}
.cards{display:flex;flex-wrap:wrap;gap:10px;margin-bottom:22px}
.card{flex:0 0 auto;min-width:118px;background:var(--panel);border:1px solid var(--line);border-radius:10px;
  padding:12px 16px 12px 14px;cursor:pointer;transition:border-color .12s,transform .12s}
.card:hover{border-color:var(--accent)}
.card.off{opacity:.42}
.card .n{font-size:24px;font-weight:700;line-height:1.1}
.card .l{font-size:12px;color:var(--dim);margin-top:3px}
.card.s-fail .n{color:var(--fail)} .card.s-ok .n{color:var(--ok)}
.card.s-warn .n{color:var(--warn)} .card.s-skip .n{color:var(--skip)}
.bar{display:flex;flex-wrap:wrap;gap:8px;align-items:center;margin-bottom:14px}
input,select{background:var(--panel);color:var(--fg);border:1px solid var(--line);
  border-radius:8px;padding:7px 10px;font:inherit}
input[type=search]{flex:1 1 240px;min-width:180px}
button.link{background:none;border:none;color:var(--accent);cursor:pointer;font:inherit;padding:0}
.panel{background:var(--panel);border:1px solid var(--line);border-radius:10px;overflow:hidden;margin-bottom:22px}
.panel>h2{font-size:13px;margin:0;padding:11px 14px;border-bottom:1px solid var(--line);
  color:var(--dim);font-weight:600;letter-spacing:.02em}
.scroll{overflow-x:auto}
table{border-collapse:collapse;width:100%;font-size:13px}
th,td{text-align:left;padding:8px 12px;border-bottom:1px solid var(--line);vertical-align:top}
th{font-size:12px;color:var(--dim);font-weight:600;white-space:nowrap;position:sticky;top:0;background:var(--panel)}
tbody tr:last-child td{border-bottom:none}
tbody tr.r{cursor:pointer}
tbody tr.r:hover{background:color-mix(in srgb,var(--accent) 7%,transparent)}
#tbl th:nth-child(1),#tbl td:nth-child(1){width:74px}
#tbl th:nth-child(2),#tbl td:nth-child(2){width:150px}
#tbl th:nth-child(3),#tbl td:nth-child(3){width:170px}
#tbl th:nth-child(5),#tbl td:nth-child(5){width:160px}
#tbl th:nth-child(6),#tbl td:nth-child(6){width:30%}
td.nm{font-family:Consolas,ui-monospace,monospace;white-space:nowrap}
td.ti{min-width:200px}
.badge{display:inline-block;padding:2px 8px;border-radius:999px;font-size:11px;font-weight:700;
  letter-spacing:.03em;white-space:nowrap}
.b-ok{background:var(--okbg);color:var(--ok)}
.b-fail{background:var(--failbg);color:var(--fail)}
.b-warn{background:var(--warnbg);color:var(--warn)}
.b-skip{background:var(--skipbg);color:var(--skip)}
.detail{color:var(--dim);font-size:12px;word-break:break-all}
.cmd{display:none;background:var(--bg);border-top:1px dashed var(--line)}
.cmd td{font-family:Consolas,ui-monospace,monospace;font-size:12px;color:var(--dim);
  white-space:pre-wrap;word-break:break-all;padding:9px 12px 11px}
tr.open+.cmd{display:table-row}
.mini td.n{text-align:right;font-variant-numeric:tabular-nums;white-space:nowrap;width:1%}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(320px,1fr));gap:22px}
.grid .scroll{max-height:326px;overflow:auto}
.empty{padding:26px 14px;text-align:center;color:var(--dim)}
.foot{color:var(--dim);font-size:12px;margin-top:26px;border-top:1px solid var(--line);padding-top:14px}
code{background:var(--skipbg);border-radius:5px;padding:1px 5px;font-size:12px}
</style></head><body><div class="wrap">
<h1>롬 구동 검증 보고서</h1>
<div class="sub" id="sub"></div>
<div class="cards" id="cards"></div>
<div class="bar">
  <input type="search" id="q" placeholder="게임 이름 · 제목 · 사유 검색">
  <select id="fl"></select><select id="fe"></select>
  <button class="link" id="reset">필터 초기화</button>
</div>
<div class="grid">
  <div class="panel"><h2>목록별</h2><div class="scroll"><table class="mini" id="byList"></table></div></div>
  <div class="panel"><h2>에뮬레이터별</h2><div class="scroll"><table class="mini" id="byEmu"></table></div></div>
</div>
<div class="panel"><h2 id="listHead">항목</h2><div class="scroll"><table id="tbl">
<thead><tr><th>상태</th><th>목록</th><th>Name</th><th>Title</th><th>에뮬레이터</th><th>사유</th></tr></thead>
<tbody></tbody></table><div class="empty" id="none" hidden>해당하는 항목이 없습니다.</div></div></div>
<div class="foot">
행을 누르면 실제로 실행되는 명령이 펼쳐진다. 실패만 다시 보려면
<code>test-roms.cmd -Launch -Failed</code>.
</div>
</div><script>
const ROWS = __ROWS__, META = __META__;
const KIND = {OK:'ok',PASS:'ok',NOCHK:'skip',NOWIN:'warn'};
const kind = s => KIND[s] || 'fail';
const ORDER = {fail:0,warn:1,skip:2,ok:3};
const esc = s => String(s==null?'':s).replace(/[&<>"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const state = {status:null,q:'',list:'',emu:''};

const counts = {};
ROWS.forEach(r => counts[r.Status] = (counts[r.Status]||0)+1);
const statuses = Object.keys(counts).sort((a,b)=>ORDER[kind(a)]-ORDER[kind(b)] || counts[b]-counts[a]);
const fails = ROWS.filter(r=>kind(r.Status)==='fail').length;

document.getElementById('sub').innerHTML =
  `<b>${META.Mode}</b> · 대상 <b>${ROWS.length}</b>건 · 실패 <b>${fails}</b>건 · ${esc(META.When)}` +
  (META.Elapsed ? ` · 소요 ${esc(META.Elapsed)}` : '');

document.getElementById('cards').innerHTML = statuses.map(s =>
  `<div class="card s-${kind(s)}" data-s="${s}"><div class="n">${counts[s]}</div><div class="l">${s}</div></div>`).join('');

const fill = (el,vals,label) => {
  el.innerHTML = `<option value="">${label} 전체</option>` +
    [...new Set(vals)].sort().map(v=>`<option>${esc(v)}</option>`).join('');
};
fill(document.getElementById('fl'), ROWS.map(r=>r.List), '목록');
fill(document.getElementById('fe'), ROWS.map(r=>r.Emulator), '에뮬레이터');

function agg(key, el, target){
  const m = new Map();
  ROWS.forEach(r=>{
    const k = r[key]; if(!m.has(k)) m.set(k,{n:0,f:0});
    const o = m.get(k); o.n++; if(kind(r.Status)==='fail') o.f++;
  });
  el.innerHTML = '<tbody>' + [...m.entries()].sort((a,b)=>b[1].f-a[1].f || b[1].n-a[1].n)
    .map(([k,o])=>`<tr class="r" data-k="${esc(k)}"><td>${esc(k)}</td><td class="n">${o.n}</td>` +
      `<td class="n">${o.f?`<span class="badge b-fail">실패 ${o.f}</span>`:''}</td></tr>`).join('') + '</tbody>';
  // 집계 행을 누르면 그 목록/에뮬레이터로 아래 항목 표를 좁힌다
  el.onclick = e => {
    const tr = e.target.closest('tr.r'); if(!tr) return;
    const v = tr.dataset.k;
    state[target] = (state[target] === v) ? '' : v;
    document.getElementById(target === 'list' ? 'fl' : 'fe').value = state[target];
    render();
  };
}
agg('List', document.getElementById('byList'), 'list');
agg('Emulator', document.getElementById('byEmu'), 'emu');

function render(){
  const q = state.q.toLowerCase();
  const rows = ROWS.filter(r =>
    (!state.status || r.Status===state.status) &&
    (!state.list   || r.List===state.list) &&
    (!state.emu    || r.Emulator===state.emu) &&
    (!q || (r.Name+' '+r.Title+' '+(r.Detail||'')).toLowerCase().includes(q))
  ).sort((a,b)=> ORDER[kind(a.Status)]-ORDER[kind(b.Status)] ||
                 a.List.localeCompare(b.List) || a.Name.localeCompare(b.Name));

  document.querySelector('#tbl tbody').innerHTML = rows.map(r=>
    `<tr class="r"><td><span class="badge b-${kind(r.Status)}">${r.Status}</span></td>` +
    `<td>${esc(r.List)}</td><td class="nm">${esc(r.Name)}</td><td class="ti">${esc(r.Title)}</td>` +
    `<td>${esc(r.Emulator)}</td><td class="detail">${esc(r.Detail)}</td></tr>` +
    `<tr class="cmd"><td colspan="6">${esc(r.Exe)} ${esc(r.Args)}</td></tr>`).join('');
  document.getElementById('listHead').textContent = `항목 ${rows.length}건`;
  document.getElementById('none').hidden = rows.length > 0;
  document.querySelectorAll('#tbl tbody tr.r').forEach(tr =>
    tr.onclick = () => tr.classList.toggle('open'));
  document.querySelectorAll('.card').forEach(c =>
    c.classList.toggle('off', !!state.status && c.dataset.s !== state.status));
}
document.getElementById('cards').onclick = e => {
  const c = e.target.closest('.card'); if(!c) return;
  state.status = (state.status === c.dataset.s) ? null : c.dataset.s; render();
};
document.getElementById('q').oninput  = e => { state.q = e.target.value; render(); };
document.getElementById('fl').onchange = e => { state.list = e.target.value; render(); };
document.getElementById('fe').onchange = e => { state.emu = e.target.value; render(); };
document.getElementById('reset').onclick = () => {
  state.status=null; state.q=''; state.list=''; state.emu='';
  document.getElementById('q').value=''; document.getElementById('fl').value='';
  document.getElementById('fe').value=''; render();
};
// 볼 것이 있으면 그것부터 보여 준다(실패 > 경고 > 확인 불가). 전부 정상이면 그대로 전체.
const firstIssue = statuses.find(s => kind(s) !== 'ok');
if (firstIssue) state.status = firstIssue;
render();
</script></body></html>
'@
    $html = $tpl.Replace('__ROWS__', $json).Replace('__META__', $metaJson)
    [System.IO.File]::WriteAllText($Path, $html, (New-Object System.Text.UTF8Encoding $false))
}

# ------------------------------------------------------------------ 준비
$startedAt = Get-Date
Write-Host ""
Write-Host "Attract-Mode 롬 구동 검증  ($Root)" -ForegroundColor Cyan
Write-Host ("=" * 78)

$emulators = @{}
foreach ($f in Get-ChildItem -LiteralPath (Join-Path $Root 'emulators') -Filter '*.cfg') {
    $emulators[$f.BaseName] = Read-AmConfig $f.FullName
}

$mameRoots = @()
$mameRomsDir = Join-Path $Root 'emulators\Mame\roms'
if (Test-Path -LiteralPath $mameRomsDir) {
    $mameRoots = @(Get-ChildItem -LiteralPath $mameRomsDir -Directory -Recurse | Select-Object -ExpandProperty FullName)
}

# 직전 보고서에서 실패 항목 추리기
$retry = $null
if ($Failed) {
    $last = Get-ChildItem -LiteralPath (Join-Path $Root 'logs') -Filter 'rom-test-*.csv' -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $last) {
        Write-Error "logs\rom-test-*.csv 가 없습니다. -Failed 는 이전 실행 결과가 있어야 합니다."
        exit 1
    }
    Write-Host ("직전 보고서: {0}" -f $last.Name) -ForegroundColor DarkGray
    $retry = @{}
    foreach ($r in (Import-Csv -LiteralPath $last.FullName -Encoding UTF8)) {
        if ($FailStatus -contains $r.Status) { $retry[($r.List + "`t" + $r.Name)] = $true }
    }
    if ($retry.Count -eq 0) {
        Write-Host "직전 보고서에 실패 항목이 없습니다." -ForegroundColor Green
        exit 0
    }
}

# ------------------------------------------------------------------ 대상 수집
$items = New-Object System.Collections.ArrayList
foreach ($rf in (Get-ChildItem -LiteralPath (Join-Path $Root 'romlists') -Filter '*.txt' | Sort-Object Name)) {
    $listName = $rf.BaseName
    if ($List -and -not ($List | Where-Object { $listName -like $_ })) { continue }

    $lineNo = 0
    foreach ($raw in [System.IO.File]::ReadAllLines($rf.FullName)) {
        $lineNo++
        if ($lineNo -eq 1) { continue }
        $line = $raw.TrimStart($BOM)
        if ($line -match '^\s*$') { continue }
        $disabled = $line.StartsWith('#')
        if ($disabled) {
            if (-not $IncludeDisabled) { continue }
            $line = $line.Substring(1)
        }
        $c = $line -split ';'
        if ($c.Count -lt 3) { continue }
        $romName = $c[0]; $title = $c[1]; $emuName = $c[2]
        if ($Emulator -and -not ($Emulator | Where-Object { $emuName -like $_ })) { continue }
        if ($Name -and ($romName -notlike "*$Name*") -and ($title -notlike "*$Name*")) { continue }
        if ($retry -and -not $retry.ContainsKey($listName + "`t" + $romName)) { continue }

        [void]$items.Add([pscustomobject]@{
            List = $listName; Line = $lineNo; Name = $romName; Title = $title
            Emulator = $emuName; Disabled = $disabled
        })
    }
}

if ($Shuffle -and $items.Count -gt 1) { $items = @($items | Get-Random -Count $items.Count) }
if ($Sample -gt 0) {
    $picked = New-Object System.Collections.ArrayList
    foreach ($g in ($items | Group-Object Emulator)) {
        foreach ($x in @($g.Group | Select-Object -First $Sample)) { [void]$picked.Add($x) }
    }
    $items = $picked
}
if ($Max -gt 0 -and $items.Count -gt $Max) { $items = @($items | Select-Object -First $Max) }

$mode = if ($Launch) { "구동 점검, 항목당 최대 $Seconds 초" } else { "정적 점검" }
Write-Host ("검사 대상 {0}개  (모드: {1})" -f $items.Count, $mode)
if ($items.Count -eq 0) {
    Write-Host "조건에 맞는 항목이 없습니다." -ForegroundColor Yellow
    exit 0
}

if ($Launch -and -not $Force) {
    $est = [TimeSpan]::FromSeconds($items.Count * ($Seconds + 4))
    Write-Host ""
    Write-Host "[!] 에뮬레이터를 실제로 실행합니다. 실행 중에는 화면을 에뮬레이터가 차지합니다." -ForegroundColor Yellow
    Write-Host ("    예상 소요 약 {0:hh\:mm\:ss}.  중단은 Ctrl+C." -f $est) -ForegroundColor Yellow
    $ans = Read-Host "계속할까요? (y/N)"
    if ($ans -ne 'y' -and $ans -ne 'Y') { Write-Host "취소했습니다."; exit 0 }
}

# MAME 계열 cfg\default.cfg 는 강제 종료 시 0바이트로 잘린다. 실행 전 크기를 기억해 둔다.
$guardFiles = @{}
if ($Launch) {
    foreach ($d in @('emulators\Mame\cfg\default.cfg', 'emulators\PSXMAME\cfg\default.cfg')) {
        $p = Join-Path $Root $d
        if (Test-Path -LiteralPath $p) { $guardFiles[$p] = (Get-Item -LiteralPath $p).Length }
    }
}

# ------------------------------------------------------------------ 검사
$results = New-Object System.Collections.ArrayList
$i = 0
foreach ($it in $items) {
    $i++
    $status = 'OK'; $detail = ''; $exePath = ''; $argStr = ''; $elapsed = 0; $exe = $null

    $cfg = $emulators[$it.Emulator]
    if (-not $cfg) {
        $status = 'NOEMU'; $detail = "emulators\$($it.Emulator).cfg 없음"
    } else {
        $exe = Resolve-Exe $cfg['executable']
        if (-not $exe) {
            $status = 'NOEXE'; $detail = "실행파일 없음 -> $($cfg['executable'])"
        } else {
            $exePath = $exe.Path
            $rom = Resolve-Rom $cfg $it.Name $exe.Dir $mameRoots
            # args 에 롬 토큰이 없으면 AM 이 롬 경로를 아예 넘기지 않는다(고정 실행형 정의).
            $hasToken = ($cfg['args'] -match '\[(romfilename|name|rompath)\]')
            if ($rom.Checked -and $hasToken -and -not $rom.File) {
                $status = 'NOROM'; $detail = "롬 없음 -> $($rom.Dir)"
            } else {
                if (-not $hasToken) { $status = 'NOCHK'; $detail = '고정 실행형 정의(인자에 롬 토큰 없음)' }
                elseif (-not $rom.Checked) { $status = 'NOCHK'; $detail = "romext 가 없어 롬 존재 확인 불가 -> $($rom.Dir)" }
                $argStr = Expand-AmArgs $cfg['args'] $it.Name $it.Title $it.Emulator $rom $cfg
            }
        }
    }

    # --- 구동 점검
    if ($Launch -and ($status -eq 'OK' -or $status -eq 'NOCHK')) {
        $base = [IO.Path]::GetFileNameWithoutExtension($exePath)
        $pre = @(Get-Process -Name $base -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id)
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $proc = $null
        try {
            $sp = @{ FilePath = $exePath; WorkingDirectory = $exe.Dir; PassThru = $true }
            if ($argStr) { $sp['ArgumentList'] = $argStr }
            $proc = Start-Process @sp
        } catch {
            $status = 'LAUNCHERR'; $detail = $_.Exception.Message
        }
        if ($proc) {
            while (-not $proc.HasExited -and $sw.Elapsed.TotalSeconds -lt $Seconds) {
                Start-Sleep -Milliseconds 250; $proc.Refresh()
            }
            $elapsed = [int]$sw.Elapsed.TotalMilliseconds
            $sec = [math]::Round($elapsed / 1000, 1)
            if ($proc.HasExited) {
                $code = $proc.ExitCode
                if ($code -eq 0) { $status = 'EXIT0'; $detail = "$sec 초 만에 스스로 종료(코드 0)" }
                else { $status = 'CRASH'; $detail = "$sec 초 만에 종료, 코드 $code" }
            } else {
                $hasWin = $false
                try { $hasWin = ($proc.MainWindowHandle -ne [IntPtr]::Zero) } catch {}
                if ($hasWin) { $status = 'PASS'; $detail = '' }
                else { $status = 'NOWIN'; $detail = '살아 있으나 창을 찾지 못함(런처가 다른 프로세스를 띄웠을 수 있음)' }
                if (Stop-Emulator $proc $exePath $pre) {
                    $detail = ($detail + ' ESC 로 안 끝나 강제 종료함').Trim()
                }
            }
        }
        Start-Sleep -Milliseconds 700
    }

    [void]$results.Add([pscustomobject]@{
        List = $it.List; Name = $it.Name; Title = $it.Title; Emulator = $it.Emulator
        Disabled = $it.Disabled; Status = $status; Detail = $detail
        Exe = $exePath; Args = $argStr; ElapsedMs = $elapsed
    })

    $isFail = ($FailStatus -contains $status)
    $isWarn = ($WarnStatus -contains $status)
    if ($isFail -or $isWarn -or -not $Quiet) {
        $color = if ($isFail) { 'Red' } elseif ($isWarn) { 'Yellow' } elseif ($status -eq 'NOCHK') { 'DarkGray' } else { 'Green' }
        $prefix = if ($Launch) { "[{0,4}/{1}]" -f $i, $items.Count } else { "" }
        $msg = "{0} {1,-9} {2,-22} {3}" -f $prefix, $status, $it.List, $it.Name
        if ($detail) { $msg += "  -- $detail" }
        Write-Host $msg -ForegroundColor $color
    } elseif ($Launch) {
        Write-Progress -Activity "구동 점검" -Status ("{0} / {1}  {2}" -f $i, $items.Count, $it.Name) -PercentComplete (100 * $i / $items.Count)
    }
}
if ($Launch) { Write-Progress -Activity "구동 점검" -Completed }

# ------------------------------------------------------------------ 보고
if (-not $Report) {
    $logDir = Join-Path $Root 'logs'
    if (-not (Test-Path -LiteralPath $logDir)) { [void](New-Item -ItemType Directory -Path $logDir) }
    $Report = Join-Path $logDir ("rom-test-{0}" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
}
# 확장자를 붙여 줬으면 떼고 .csv / .html 두 벌을 만든다
if ($Report -match '\.(csv|html?)$') { $Report = [IO.Path]::ChangeExtension($Report, $null).TrimEnd('.') }
$csvPath  = "$Report.csv"
$htmlPath = "$Report.html"
$results | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8

if (-not $NoHtml) {
    $span = (Get-Date) - $startedAt
    Write-HtmlReport $results $htmlPath ([pscustomobject]@{
        Mode    = if ($Launch) { "구동 점검 (항목당 최대 $Seconds 초)" } else { '정적 점검' }
        When    = $startedAt.ToString('yyyy-MM-dd HH:mm:ss')
        Elapsed = if ($span.TotalSeconds -ge 1) { "{0:hh\:mm\:ss}" -f $span } else { '' }
        Root    = $Root
    })
}

Write-Host ""
Write-Host ("=" * 78)
foreach ($g in ($results | Group-Object Status | Sort-Object Count -Descending)) {
    $color = if ($FailStatus -contains $g.Name) { 'Red' } elseif ($WarnStatus -contains $g.Name) { 'Yellow' } else { 'Green' }
    Write-Host ("{0,-10} {1,5}건" -f $g.Name, $g.Count) -ForegroundColor $color
}
Write-Host ("보고서: {0}" -f $csvPath) -ForegroundColor DarkGray
if (-not $NoHtml) {
    Write-Host ("        {0}" -f $htmlPath) -ForegroundColor DarkGray
    if ($Open) { Start-Process $htmlPath }
}

foreach ($p in @($guardFiles.Keys)) {
    if ((Test-Path -LiteralPath $p) -and $guardFiles[$p] -gt 0 -and (Get-Item -LiteralPath $p).Length -eq 0) {
        Write-Host ""
        Write-Host "[!] $p 가 0바이트로 잘렸습니다(강제 종료의 영향). 되돌리려면:" -ForegroundColor Yellow
        Write-Host ("    git checkout -- " + '"' + $p.Substring($Root.Length + 1) + '"') -ForegroundColor Yellow
    }
}

$failCount = @($results | Where-Object { $FailStatus -contains $_.Status }).Count
Write-Host ""
if ($failCount -eq 0) {
    Write-Host "실패 없음" -ForegroundColor Green
} else {
    Write-Host ("실패 {0}건 - 그 항목만 다시 보려면 -Failed" -f $failCount) -ForegroundColor Red
}
if ($Launch) {
    Write-Host "실행으로 바뀐 런타임 파일은 tools\reset-runtime.ps1 -Config -Clean 으로 정리한다." -ForegroundColor DarkGray
}
exit $(if ($failCount -gt 0) { 1 } else { 0 })
