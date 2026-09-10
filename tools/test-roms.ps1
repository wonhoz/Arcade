<#
.SYNOPSIS
    romlists 전 항목 구동 검증기
.DESCRIPTION
    romlists\*.txt 의 각 항목에 대해 Attract-Mode 가 실제로 만들어 낼 실행 명령을
    그대로 재구성해서 점검한다. 두 단계로 나뉜다.

      1) 정적 점검 (기본, 수 초)   실행파일 . 롬 파일 . 인자 치환까지 조립해 본다.
      2) 구동 점검 (-Launch)       조립한 명령을 실제로 실행해서 게임이 떴는지 본다.
                                   "프로세스가 살아 있다"로는 부족하다 — 오류 대화상자를
                                   띄운 채 서 있어도 살아 있다. 창 클래스까지 본다(DIALOG).

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
.PARAMETER Resume
    중단된 검사를 이어서 한다. 직전 보고서에 이미 결과가 있는 항목을 건너뛰고
    같은 보고서에 계속 써 넣는다. 수 시간짜리 전수 구동 점검용.
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
.PARAMETER Fast
    판정이 서면 곧바로 끝낸다. 12초를 꽉 채우지 않고, 종료 경로도 에뮬레이터별로 학습한다.
    MAME 계열에는 -str 을 붙여 스스로 깨끗이 끝나게 한다. 전수 점검 10시간 -> 2시간.
.PARAMETER Observe
    창이 떠 있어도 최소 이만큼(초)은 지켜본 뒤 PASS 로 본다. 기본 2.5.
    -Fast 의 기준 시간이다. 크게 잡을수록 늦게 죽는 것을 잡을 확률이 오르고 그만큼 느려진다.
.PARAMETER StrSeconds
    -Fast 에서 MAME 계열에 붙이는 seconds_to_run(에뮬레이트 초). 기본 2. 0 이면 안 붙인다.
.PARAMETER Adaptive
    직전 보고서와 비교해 입력(romlist 줄 . 에뮬레이터 cfg . 실행파일 . 롬 파일)이
    그대로인 항목은 건너뛴다. 건너뛰지 않는 항목도 그 보고서의 실측(창이 뜬 시각)에
    맞춰 마감을 조정하므로, 느린 항목이 마감에 걸려 NOWIN 이 되는 일이 줄어든다.
.PARAMETER Baseline
    -Adaptive 가 비교할 보고서. 생략하면 logs\ 의 가장 최근 CSV.
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
    [switch]$Resume,
    [switch]$IncludeDisabled,
    [string]$Report,
    [switch]$NoHtml,
    [switch]$Open,
    [switch]$Force,
    [switch]$Quiet,
    # -Fast : 판정이 서면 곧바로 끝낸다. 12초를 꽉 채우지 않고, 종료 경로도 에뮬레이터별로 학습한다.
    #         MAME 계열에는 -str 을 붙여 스스로 깨끗이 끝나게 한다(ESC 사다리가 통째로 사라진다).
    [switch]$Fast,
    # -Fast 에서 MAME 계열에 붙이는 seconds_to_run 값(에뮬레이트 초). 0 이면 붙이지 않는다.
    [int]$StrSeconds = 2,
    # -Observe : 창이 떠 있어도 최소 이만큼(초)은 지켜본 뒤에 PASS 로 본다. -Fast 의 기준 시간.
    #            크게 잡을수록 늦게 죽는 것을 잡을 확률이 오르고, 그만큼 느려진다.
    [double]$Observe = 2.5,
    # -Adaptive : 직전 정상 보고서와 비교해 입력이 그대로인 항목은 건너뛴다.
    #             건너뛰지 않는 항목도 그 보고서의 실측(창이 뜬 시각)에 맞춰 마감을 조정한다.
    [switch]$Adaptive,
    # -Baseline : 비교 대상 보고서. 없으면 logs\ 의 가장 최근 CSV 를 쓴다.
    [string]$Baseline
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
#         DIALOG 살아 있지만 떠 있는 것이 오류 대화상자다. 게임은 시작되지 않았다.
#               "살아 있으면 PASS" 로만 보면 이것을 정상으로 세게 된다(실제로 그랬다 — ISSUES 46번).
$FailStatus = @('NOEMU', 'NOEXE', 'NOROM', 'EXIT0', 'CRASH', 'LAUNCHERR', 'DIALOG')
$WarnStatus = @('NOWIN')
# 실패도 경고도 아닌 상태. -Adaptive 로 건너뛴 항목은 직전 상태를 그대로 물려받으므로
# 여기에 따로 값을 두지 않는다 — 다시 띄우지 않았다는 사실은 Skipped 열에만 남는다.
$SkipStatus = @('NOCHK')

# ESC 를 에뮬레이터에 보내기 위한 것. 두 가지가 필요하다.
#   1. 포그라운드 창의 소유 프로세스 확인 — 엉뚱한 창(터미널)에 ESC 를 보내지 않기 위해(ISSUES 45번).
#   2. 스캔코드 SendInput — MAME 는 DirectInput 으로 키보드를 읽어서
#      WScript.Shell 의 SendKeys 를 받지 않는다(PSXMAME 로 실측).
# 여기에 창 조사도 같이 둔다. 프로세스가 살아 있다는 것만으로는 기동을 판정할 수 없어서다 —
# 오류 대화상자(창 클래스 #32770)가 떠 있어도 프로세스는 멀쩡히 살아 있다.
if (-not ('AmInput' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;
public class AmInput {
    [StructLayout(LayoutKind.Sequential)]
    public struct KEYBDINPUT { public ushort wVk; public ushort wScan; public uint dwFlags; public uint time; public IntPtr dwExtraInfo; }
    [StructLayout(LayoutKind.Explicit)]
    public struct INPUT { [FieldOffset(0)] public uint type; [FieldOffset(8)] public KEYBDINPUT ki; }
    [DllImport("user32.dll")] static extern uint SendInput(uint n, INPUT[] p, int cb);
    [DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] static extern int GetWindowThreadProcessId(IntPtr h, out int pid);
    [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc cb, IntPtr p);
    [DllImport("user32.dll")] static extern bool EnumChildWindows(IntPtr h, EnumProc cb, IntPtr p);
    [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetWindowTextW(IntPtr h, StringBuilder s, int n);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
    delegate bool EnumProc(IntPtr h, IntPtr p);

    static string ClassOf(IntPtr h) { var s = new StringBuilder(256); GetClassNameW(h, s, 256); return s.ToString(); }
    static string TextOf(IntPtr h)  { var s = new StringBuilder(1024); GetWindowTextW(h, s, 1024); return s.ToString(); }

    // 프로세스가 가진 "보이는 최상위 창"을 클래스 이름과 함께 모은다.
    // Process.MainWindowHandle 로는 창이 하나라는 것밖에 알 수 없고, 그것이
    // 게임 화면인지 오류 대화상자인지 구별하지 못한다.
    static List<IntPtr> TopWindows(int pid) {
        var r = new List<IntPtr>();
        EnumWindows((h, p) => {
            int wp; GetWindowThreadProcessId(h, out wp);
            if (wp == pid && IsWindowVisible(h)) { r.Add(h); }
            return true; }, IntPtr.Zero);
        return r;
    }

    // 오류 대화상자가 떠 있으면 그 안의 Static 텍스트를 돌려준다. 없으면 null.
    // #32770 은 윈도우 표준 대화상자의 클래스 이름이다(MessageBox 포함).
    public static string DialogText(int pid) {
        foreach (IntPtr h in TopWindows(pid)) {
            if (ClassOf(h) != "#32770") { continue; }
            var parts = new List<string>();
            EnumChildWindows(h, (ch, cp) => {
                if (ClassOf(ch) == "Static") {
                    string t = TextOf(ch).Trim();
                    if (t.Length > 0) { parts.Add(t); }
                }
                return true; }, IntPtr.Zero);
            string msg = string.Join(" / ", parts.ToArray());
            return msg.Length > 0 ? msg : TextOf(h);
        }
        return null;
    }

    // 대화상자가 아닌 진짜 창이 하나라도 있는가.
    public static bool HasRealWindow(int pid) {
        foreach (IntPtr h in TopWindows(pid)) {
            if (ClassOf(h) != "#32770") { return true; }
        }
        return false;
    }

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
# 이번 실행으로 새로 생긴, emulators\ 아래 실행파일의 프로세스. 런처형 정의가 띄운 게임이 여기 잡힌다.
#   Root 전체가 아니라 emulators\ 아래로 한정한다 — 점검 중 우연히 뜬 다른 프로그램을 잡지 않기 위해.
# $ExtraRoots : emulators\ 밖에 설치된 게임을 잡기 위한 추가 경로.
#   PC Game / Taito Type X 정의는 cmd /c 로 바로가기를 실행하고, 그 대상은 D:\Games\... 처럼
#   저장소 밖에 있다. emulators\ 만 보면 게임 프로세스를 못 찾아 판정도 정리도 실패한다 —
#   철권 7 이 전수 점검 뒤에도 계속 떠 있었던 이유다(2026-09-10).
function Get-NewEmuProcs($PreIds, [int]$MainId, [string[]]$ExtraRoots) {
    $roots = @((Join-Path $Root 'emulators').TrimEnd('\') + '\')
    foreach ($r in @($ExtraRoots)) { if ($r) { $roots += ($r.TrimEnd('\') + '\') } }
    @(Get-Process | Where-Object { $_.Id -ne $MainId -and $PreIds -notcontains $_.Id } | Where-Object {
        $p = $null; try { $p = $_.Path } catch {}
        if (-not $p) { return $false }
        $hit = $false
        foreach ($r in $roots) { if ($p.StartsWith($r, [StringComparison]::OrdinalIgnoreCase)) { $hit = $true; break } }
        return $hit
    })
}

# 런처형 정의(cmd /c <바로가기>)가 실제로 띄울 프로그램의 폴더를 알아낸다.
#   .lnk 는 WScript.Shell 로 대상을 읽고, .bat 은 안에 적힌 절대경로를 찾는다.
function Resolve-LauncherRoots([string]$ArgLine) {
    $roots = @()
    foreach ($m in [regex]::Matches($ArgLine, '"([^"]+\.(?:lnk|bat|cmd))"')) {
        $t = $m.Groups[1].Value
        if (-not [IO.Path]::IsPathRooted($t)) { $t = Join-Path $Root $t }
        if (-not (Test-Path -LiteralPath $t)) { continue }
        if ($t -match '\.lnk$') {
            try {
                $sh = New-Object -ComObject WScript.Shell
                $tp = $sh.CreateShortcut($t).TargetPath
                if ($tp) { $roots += (Split-Path -Parent $tp) }
            } catch {}
        } else {
            # ps-audit-ok: 저장소 밖의 배치파일이라 ANSI 로 읽는 것이 맞고, 뽑는 것도 ASCII 경로뿐이다.
            foreach ($line in @(Get-Content -LiteralPath $t -ErrorAction SilentlyContinue)) {
                foreach ($mm in [regex]::Matches($line, '([A-Za-z]:\\[^"''<>|]+?\.exe)')) {
                    $roots += (Split-Path -Parent $mm.Groups[1].Value)
                }
            }
        }
    }
    return @($roots | Where-Object { $_ } | Sort-Object -Unique)
}

# 에뮬레이터가 "자기 폴더에서" 읽는 설정 파일. emulators\<Emulator>.cfg 만 봐서는
# 이것이 바뀐 것을 못 잡는데, 여태 실행 불가가 실제로 터진 자리가 대부분 여기다.
#   mame.ini 의 rompath 오타 -> MAME Adult 38개 (ISSUES 48)
#   EKMAME mame.ini 의 BOM 소실 -> EKMAME 전부 (CLAUDE.md 4.7)
#   TeknoParrot 프로필의 <GamePath> 절대경로 -> 32개 (ISSUES 68)
#   Cemu settings.xml 의 gp_download -> Wii U 4개 (ISSUES 66)
# 키는 emulators\ 바로 아래 폴더 이름(= 실행파일이 있는 곳), 값은 그 폴더 기준 상대경로.
# [name] 은 romlist 의 Name 으로 바뀐다(TeknoParrot 처럼 항목마다 프로필이 따로인 경우).
# 내용 해시라서 에뮬레이터가 같은 내용으로 다시 써도 지문이 흔들리지 않는다.
$AuxConfig = @{
    'Mame'        = @('mame.ini')
    'EKMAME'      = @('mame.ini')
    'PSXMAME'     = @('mame.ini')
    'Cemu'        = @('portable\settings.xml')
    'Demul'       = @('padDemul.ini', 'gpuDX11.ini')
    'Dolphin'     = @('portable.txt', 'User\Config\Dolphin.ini')
    'M2'          = @('EMULATOR.INI')
    'PCSX2'       = @('inis\PCSX2_ui.ini', 'inis\LilyPad.ini')
    'Project64'   = @('Config\Project64.cfg')
    'RetroArch'   = @('retroarch.cfg')
    'Mednafen'    = @('mednafen.cfg')
    'PPSSPP'      = @('memstick\PSP\SYSTEM\ppsspp.ini')
    'SuperModel'  = @('Config\Supermodel.ini')
    'TeknoParrot' = @('UserProfiles\[name].xml')
}

$script:AuxCache = @{}
function Get-AuxParts([string]$ExeDir, [string]$ItemName) {
    $parts = @()
    if (-not $ExeDir) { return $parts }
    $emuRoot = (Join-Path $Root 'emulators').TrimEnd('\') + '\'
    # executable 이 cmd 인 런처형은 디렉터리가 AM 루트다. 거기에는 attract.am 처럼
    # 실행할 때마다 바뀌는 파일이 있어 훑으면 안 된다 — emulators\ 아래일 때만 본다.
    if (-not $ExeDir.StartsWith($emuRoot, [StringComparison]::OrdinalIgnoreCase)) { return $parts }
    $key = ($ExeDir.Substring($emuRoot.Length) -split '\\')[0]
    if (-not $key -or -not $AuxConfig.ContainsKey($key)) { return $parts }
    foreach ($rel in $AuxConfig[$key]) {
        $p = Join-Path (Join-Path $emuRoot $key) ($rel -replace '\[name\]', $ItemName)
        if (-not $script:AuxCache.ContainsKey($p)) {
            $h = '-'   # 없는 것도 상태다 — Dolphin 의 portable.txt 가 사라지면 설정 위치가 통째로 바뀐다
            if (Test-Path -LiteralPath $p -PathType Leaf) {
                try { $h = (Get-FileHash -LiteralPath $p -Algorithm MD5).Hash } catch { $h = '?' }
            }
            $script:AuxCache[$p] = $h
        }
        $parts += ($rel + '|' + $script:AuxCache[$p])
    }
    return $parts
}

# 이 항목의 "입력"을 한 줄로 요약한다. 이것이 그대로면 다시 띄워 볼 이유가 없다.
#   romlist 줄 · 에뮬레이터 cfg 내용 · 실행파일 · 롬 파일(크기+수정시각) · 위 보조 설정
# 롬은 폴더일 수도(<DIR>) 아예 못 찾을 수도 있다 — 그럴 때는 있는 재료만으로 만든다.
$script:FpCache = @{}
function Get-Fingerprint([string]$Raw, [string]$EmuName, [string]$ExePath, [string]$RomPath,
                         [string]$ExeDir, [string]$ItemName) {
    $parts = New-Object System.Collections.Generic.List[string]
    [void]$parts.Add($Raw)
    if (-not $script:FpCache.ContainsKey("cfg:$EmuName")) {
        $cf = Join-Path $Root "emulators\$EmuName.cfg"
        $h = ''
        if (Test-Path -LiteralPath $cf) { $h = (Get-FileHash -LiteralPath $cf -Algorithm MD5).Hash }
        $script:FpCache["cfg:$EmuName"] = $h
    }
    [void]$parts.Add($script:FpCache["cfg:$EmuName"])
    foreach ($f in @($ExePath, $RomPath)) {
        if (-not $f) { continue }
        if (-not $script:FpCache.ContainsKey("f:$f")) {
            $v = ''
            try {
                $it = Get-Item -LiteralPath $f -ErrorAction Stop
                if ($it.PSIsContainer) { $v = "D:$($it.LastWriteTimeUtc.Ticks)" }
                else { $v = "$($it.Length):$($it.LastWriteTimeUtc.Ticks)" }
            } catch {}
            $script:FpCache["f:$f"] = $v
        }
        [void]$parts.Add($f + '|' + $script:FpCache["f:$f"])
    }
    foreach ($a in (Get-AuxParts $ExeDir $ItemName)) { [void]$parts.Add($a) }
    $md5 = [Security.Cryptography.MD5]::Create()
    $bytes = [Text.Encoding]::UTF8.GetBytes(($parts -join "`n"))
    return (($md5.ComputeHash($bytes) | ForEach-Object { $_.ToString('x2') }) -join '').Substring(0, 16)
}

# ESC 로 끝난 적이 있는지 에뮬레이터별로 기억한다. -Fast 에서 사다리를 건너뛸지 정하는 근거다.
$script:EscFail = @{}

# taskkill 은 못 죽이는 프로세스를 만나면 stderr 에 쓴다. PowerShell 5.1 은 네이티브 명령의
# stderr 를 ErrorRecord 로 바꾸고, $ErrorActionPreference='Stop' 아래에서는 그것이 종료성 오류가 된다.
# 2026-09-10 전수 점검이 1,052번째 항목에서 이것 하나로 통째로 죽었다 — 몇 시간짜리 실행을
# 종료 실패 한 번으로 잃으면 안 된다. 항상 이 함수로 부른다.
#
# ⚠️ `& exit /b %ERRORLEVEL%` 를 붙이면 안 된다. cmd 는 줄 전체를 한 번에 파싱하면서 %…% 를
#    전개하므로, `&` 로 이어 붙였어도 %ERRORLEVEL% 은 taskkill 이 돌기 *전* 값(0)으로 굳는다.
#    그러면 이 함수가 항상 참을 돌려준다(없는 PID 로 실측: 붙이면 0, 빼면 128).
#    cmd /c 는 마지막 명령의 종료 코드를 그대로 물려주므로 아무것도 붙이지 않는 것이 맞다.
function Kill-Tree([int]$ProcId) {
    if ($ProcId -le 0) { return $false }
    try {
        [void](& cmd.exe /c "taskkill /PID $ProcId /T /F >nul 2>&1")
        return ($LASTEXITCODE -eq 0)
    } catch { return $false }
}

function Stop-Emulator($Proc, [string]$ExePath, $Preexisting, $Kids, [string]$EmuName, [bool]$Protected, [bool]$FastMode) {
    $killed = $false
    $ids = @($Proc.Id) + @($Kids | ForEach-Object { $_.Id })
    $sw = [Diagnostics.Stopwatch]::StartNew()

    # 이 에뮬레이터가 두 번 연속 ESC 로 안 끝났으면 사다리를 건너뛴다.
    #   Protected(=MAME 계열)는 예외다 — 강제 종료하면 cfg\default.cfg 가 0바이트로 잘린다(CLAUDE.md 5.5절).
    $skipEsc = $FastMode -and (-not $Protected) -and ([int]$script:EscFail[$EmuName] -ge 2)
    $tries   = 6
    $escOut  = $false

    if (-not $Proc.HasExited -and -not $skipEsc) {
        $wsh = $null
        try { $wsh = New-Object -ComObject WScript.Shell } catch {}
        for ($try = 0; $try -lt $tries; $try++) {
            $Proc.Refresh()
            if ($Proc.HasExited) { break }
            # AppActivate 는 이미 포그라운드인 창에도 False 를 돌려준다(PSXMAME 로 실측).
            # 그래서 반환값이 아니라 포그라운드 PID 로 판단한다.
            try { if ($wsh) { [void]$wsh.AppActivate($Proc.Id) } } catch {}
            Start-Sleep -Milliseconds 350
            $Proc.Refresh()
            if (-not $Proc.HasExited -and $ids -contains [AmInput]::ForegroundPid()) {
                [AmInput]::SendEsc()
            }
            $w = [Diagnostics.Stopwatch]::StartNew()
            $cap = 2.5
            while (-not $Proc.HasExited -and $w.Elapsed.TotalSeconds -lt $cap) {
                Start-Sleep -Milliseconds 200; $Proc.Refresh()
            }
        }
        $Proc.Refresh()
        $escOut = $Proc.HasExited
    }

    if (-not $Proc.HasExited) {
        try { [void]$Proc.CloseMainWindow() } catch {}
        $w = [Diagnostics.Stopwatch]::StartNew()
        $cap = 6
        if ($FastMode) { $cap = 2 }
        while (-not $Proc.HasExited -and $w.Elapsed.TotalSeconds -lt $cap) { Start-Sleep -Milliseconds 200; $Proc.Refresh() }
    }
    if (-not $Proc.HasExited) {
        [void](Kill-Tree $Proc.Id)
        $killed = $true
        Start-Sleep -Milliseconds 500
    }
    # ESC 성적을 기억한다. MAME 계열은 어차피 건너뛰지 않으므로 세지 않는다.
    if (-not $Protected -and $EmuName) {
        if ($escOut) { $script:EscFail[$EmuName] = 0 }
        elseif (-not $skipEsc) { $script:EscFail[$EmuName] = 1 + [int]$script:EscFail[$EmuName] }
    }
    # 런처형(cmd /c, TeknoParrotUi)은 자식 프로세스를 남긴다. 이번에 새로 생긴 것만 정리한다.
    $base = [IO.Path]::GetFileNameWithoutExtension($ExePath)
    foreach ($p in @(Get-Process -Name $base -ErrorAction SilentlyContinue)) {
        if ($Preexisting -notcontains $p.Id) {
            if (Kill-Tree $p.Id) { $killed = $true }
        }
    }
    # 런처가 띄운 게임 프로세스. 남겨 두면 다음 항목이 "already running" 으로 막힌다(ISSUES 68번).
    foreach ($k in @($Kids)) {
        try { $k.Refresh(); if (-not $k.HasExited) { [void](Kill-Tree $k.Id) } } catch {}
    }
    $script:LastShutdownMs = [int]$sw.Elapsed.TotalMilliseconds
    return $killed
}

# 결과를 한 장짜리 HTML 로 정리한다. 캐비닛 PC 에는 인터넷이 없을 수 있으므로
# 외부 CDN·폰트를 쓰지 않고 CSS·JS 를 전부 파일 안에 넣는다.
function Write-HtmlReport($Rows, [string]$Path, $Meta) {
    $json = ($Rows | Select-Object List, Name, Title, Emulator, Status, Detail, Exe, Args, ElapsedMs, WindowMs, ShutdownMs |
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
const KIND = {OK:'ok',PASS:'ok',NOCHK:'skip',SKIP:'skip',NOWIN:'warn'};
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

# --- 보고서 경로. -Resume 은 새로 만들지 않고 직전 보고서를 이어 쓴다.
$logDir = Join-Path $Root 'logs'
if (-not (Test-Path -LiteralPath $logDir)) { [void](New-Item -ItemType Directory -Path $logDir) }
# 필터가 걸린 실행은 보고서에 romlist 의 "일부"만 담긴다. 그런 보고서가 -Adaptive 의 기준으로
# 잡히면 다음 증분 점검이 나머지를 전부 다시 띄운다(65초 -> 2시간). 그래서 이름부터 갈라 둔다.
# test-roms.cmd 의 [2] 표본 · [5] 목록 지정 · [6] 이름으로 · [7] 실패만이 전부 여기 해당한다.
$partialRun = [bool]($List -or $Emulator -or $Name -or $Failed -or ($Sample -gt 0) -or ($Max -gt 0))

function Get-LastReport([switch]$IncludePartial) {
    Get-ChildItem -LiteralPath (Join-Path $Root 'logs') -Filter 'rom-test-*.csv' -ErrorAction SilentlyContinue |
        Where-Object { $IncludePartial -or $_.Name -notlike 'rom-test-partial-*' } |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
}
if ($Report) {
    # 확장자를 붙여 줬으면 뗀다. .csv / .html 두 벌이 나온다.
    if ($Report -match '\.(csv|html?)$') { $Report = [IO.Path]::ChangeExtension($Report, $null).TrimEnd('.') }
} elseif ($Resume) {
    # 부분 점검을 이어할 때는 부분 보고서를, 전수를 이어할 때는 전수 보고서를 집는다.
    $last = Get-LastReport -IncludePartial:$partialRun
    if (-not $last) { Write-Error "logs\rom-test-*.csv 가 없습니다. -Resume 은 이어 쓸 보고서가 있어야 합니다."; exit 1 }
    $Report = [IO.Path]::Combine($last.DirectoryName, [IO.Path]::GetFileNameWithoutExtension($last.Name))
} else {
    $prefix = if ($partialRun) { 'rom-test-partial' } else { 'rom-test' }
    $Report = Join-Path $logDir ("{0}-{1}" -f $prefix, (Get-Date -Format 'yyyyMMdd-HHmmss'))
}
$csvPath  = "$Report.csv"
$htmlPath = "$Report.html"

# 이번 실행에서 건너뛸 항목(-Resume)과 다시 볼 항목(-Failed)
$results = New-Object System.Collections.ArrayList   # 이어하기면 이전 결과를 담고 시작한다
$done  = @{}
$retry = $null

if ($Resume) {
    if (-not (Test-Path -LiteralPath $csvPath)) {
        Write-Error "이어 쓸 보고서가 없습니다: $csvPath"
        exit 1
    }
    foreach ($r in (Import-Csv -LiteralPath $csvPath -Encoding UTF8)) {
        [void]$results.Add([pscustomobject]@{
            List = $r.List; Name = $r.Name; Title = $r.Title; Emulator = $r.Emulator
            Disabled = ($r.Disabled -eq 'True'); Status = $r.Status; Detail = $r.Detail
            Exe = $r.Exe; Args = $r.Args; ElapsedMs = [int]$r.ElapsedMs
            WindowMs = [int]$r.WindowMs; ShutdownMs = [int]$r.ShutdownMs; StrUsed = ($r.StrUsed -eq 'True')
            Fingerprint = $r.Fingerprint; Skipped = ($r.Skipped -eq 'True')
        })
        $done[($r.List + "`t" + $r.Name)] = $true
    }
    Write-Host ("이어하기: {0} — 이미 끝난 {1}건은 건너뛴다" -f (Split-Path $csvPath -Leaf), $done.Count) -ForegroundColor DarkGray
}

if ($Failed) {
    $last = Get-LastReport -IncludePartial
    if (-not $last) {
        Write-Error "logs\rom-test-*.csv 가 없습니다. -Failed 는 이전 실행 결과가 있어야 합니다."
        exit 1
    }
    Write-Host ("직전 보고서: {0}" -f $last.Name) -ForegroundColor DarkGray
    # -Failed 는 부분 보고서도 본다 — [7] 을 연달아 눌러 "아직 안 고쳐진 것"만 좁혀 가는 쓰임이다.
    $retry = @{}
    foreach ($r in (Import-Csv -LiteralPath $last.FullName -Encoding UTF8)) {
        if ($FailStatus -contains $r.Status) { $retry[($r.List + "`t" + $r.Name)] = $true }
    }
    if ($retry.Count -eq 0) {
        Write-Host "직전 보고서에 실패 항목이 없습니다." -ForegroundColor Green
        exit 0
    }
}

# -Adaptive 의 기준 보고서는 검사 대상이 정해진 뒤에 고른다(아래 "대상 수집" 다음).
$baseMap = @{}

# 보고서 두 벌을 지금 상태로 써 낸다. 전수 구동 점검은 몇 시간짜리라
# 중간에 끊겨도(Ctrl+C, 정전) 여기까지의 결과는 남아 있어야 한다.
function Save-Reports {
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
        if ($done.ContainsKey($listName + "`t" + $romName)) { continue }

        [void]$items.Add([pscustomobject]@{
            List = $listName; Line = $lineNo; Name = $romName; Title = $title
            Emulator = $emuName; Disabled = $disabled; Raw = $line
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

# --- -Adaptive : 직전 보고서를 읽어 (지문, 상태, 실측)을 항목별로 들고 있는다.
#
# 기준을 "가장 최근 rom-test-*.csv" 하나로만 잡으면 그 사이에 돌린 작은 점검 하나가 기준을
# 통째로 갈아 끼운다 — 전수 -> 실패만 -> 증분 순서에서 실제로 그렇게 된다. 두 겹으로 막는다.
#   (1) 필터가 걸린 실행은 이름이 rom-test-partial-* 이라 후보에서 빠진다(위 $partialRun).
#   (2) 그래도 이번 대상을 다 못 덮으면 더 오래된 보고서로 내려가며 빈자리만 메운다.
#       중단된 전수 점검이나 이 규칙이 생기기 전의 부분 보고서까지 자연스럽게 흡수된다.
#
# 무엇을 "통과"로 볼지는 이번 실행이 구동 점검인지에 달렸다.
#   구동 점검(-Launch)이면 직전에도 실제로 떴어야(PASS) 건너뛴다.
#   정적 점검이면 조립이 됐다는 것(OK/NOCHK)으로 충분하다.
#   정적 OK 를 구동 통과로 오인하면 한 번도 안 띄워 본 항목을 건너뛰게 된다.
$OkBase = if ($Launch) { @('PASS') } else { @('PASS', 'OK', 'NOCHK') }
function Test-SkipBase($Row) {
    if (-not $Row) { return $false }
    return [bool]($Row.Fingerprint -and ($OkBase -contains $Row.Status))
}
function Measure-Coverage($Wanted, $Map) {
    $n = 0
    foreach ($k in $Wanted.Keys) { if (Test-SkipBase $Map[$k]) { $n++ } }
    return $n
}

if ($Adaptive -and $items.Count -gt 0) {
    $cands = @()
    if ($Baseline) {
        if ($Baseline -notmatch '\.csv$') { $Baseline = "$Baseline.csv" }
        if (-not [IO.Path]::IsPathRooted($Baseline)) { $Baseline = Join-Path $Root $Baseline }
        if (Test-Path -LiteralPath $Baseline) { $cands = @(Get-Item -LiteralPath $Baseline) }
    } else {
        $cands = @(Get-ChildItem -LiteralPath $logDir -Filter 'rom-test-*.csv' -ErrorAction SilentlyContinue |
                   Where-Object { $_.FullName -ne $csvPath -and $_.Name -notlike 'rom-test-partial-*' } |
                   Sort-Object LastWriteTime -Descending | Select-Object -First 6)
        if (-not $cands) {
            # 전수 보고서가 하나도 없으면 부분 보고서라도 쓴다. 없는 것보다는 낫다.
            $cands = @(Get-ChildItem -LiteralPath $logDir -Filter 'rom-test-*.csv' -ErrorAction SilentlyContinue |
                       Where-Object { $_.FullName -ne $csvPath } |
                       Sort-Object LastWriteTime -Descending | Select-Object -First 6)
        }
    }
    if (-not $cands) {
        Write-Host "-Adaptive : 비교할 보고서가 없습니다. 전부 검사합니다." -ForegroundColor Yellow
    } else {
        $wanted = @{}
        foreach ($q in $items) { $wanted[($q.List + "`t" + $q.Name)] = $true }
        $used = @()
        foreach ($bf in $cands) {
            $added = 0
            foreach ($r in (Import-Csv -LiteralPath $bf.FullName -Encoding UTF8)) {
                $k = $r.List + "`t" + $r.Name
                $old = $baseMap[$k]
                # 최신이 이긴다. 단 하나의 예외 — 최신 행이 "건너뛸 근거가 못 되는" 것이고
                # 더 오래된 행이 근거가 되면 그쪽을 쓴다. 정적 점검(OK)을 한 번 돌렸다고 해서
                # 그 앞의 구동 점검(PASS) 결과까지 버릴 이유는 없다. 지문이 같아야 쓰이므로 안전하다.
                if ($old -and ((Test-SkipBase $old) -or -not (Test-SkipBase $r))) { continue }
                $baseMap[$k] = $r
                if (-not $old) { $added++ }
            }
            if ($added -gt 0) { $used += ("{0}(+{1})" -f $bf.Name, $added) }
            if ((Measure-Coverage $wanted $baseMap) -ge $wanted.Count) { break }
        }
        $covered = Measure-Coverage $wanted $baseMap
        $withFp  = @($baseMap.Values | Where-Object { $_.Fingerprint }).Count
        $pct = if ($wanted.Count -gt 0) { [int](100 * $covered / $wanted.Count) } else { 0 }
        Write-Host ("기준 보고서: {0}" -f ($used -join '  +  ')) -ForegroundColor DarkGray
        Write-Host ("  {0}건 · 지문 있는 것 {1}건 · 이번 대상 {2}건 중 {3}건({4}%) 이 건너뛸 근거를 갖는다" -f `
                    $baseMap.Count, $withFp, $wanted.Count, $covered, $pct) -ForegroundColor DarkGray
        if ($pct -lt 90) {
            Write-Host "  기준이 이번 대상을 다 덮지 못한다 — 나머지는 그냥 다시 검사한다(그만큼 오래 걸린다)." -ForegroundColor Yellow
        }
        if ($withFp -eq 0) {
            Write-Host "  지문이 없는 옛 보고서다. 이번에는 전부 검사하고 지문을 남긴다 — 다음부터 건너뛴다." -ForegroundColor Yellow
        }
    }
}

if ($items.Count -eq 0) {
    if ($Resume -and $results.Count) {
        Write-Host ("이 조건의 {0}건은 이미 전부 끝나 있습니다." -f $results.Count) -ForegroundColor Green
        Save-Reports
        Write-Host ("보고서: {0}" -f $csvPath) -ForegroundColor DarkGray
        if (-not $NoHtml) { Write-Host ("        {0}" -f $htmlPath) -ForegroundColor DarkGray; if ($Open) { Start-Process $htmlPath } }
    } else {
        Write-Host "조건에 맞는 항목이 없습니다." -ForegroundColor Yellow
    }
    exit 0
}

if ($Launch -and -not $Force) {
    # 항목당 = 생존 판정 시간 + 종료 처리. 종료는 ESC 로 바로 끝나면 2~3초,
    # ESC 를 안 받는 에뮬레이터(PSXMAME)는 재전송·창닫기를 거쳐 20초를 넘기기도 한다.
    $lo = [TimeSpan]::FromSeconds($items.Count * ($Seconds + 4))
    $hi = [TimeSpan]::FromSeconds($items.Count * ($Seconds + 24))
    Write-Host ""
    Write-Host "[!] 에뮬레이터를 실제로 실행합니다. 실행 중에는 화면을 에뮬레이터가 차지해" -ForegroundColor Yellow
    Write-Host "    이 PC 로 다른 일을 할 수 없습니다." -ForegroundColor Yellow
    Write-Host ("    예상 소요 {0:hh\:mm\:ss} ~ {1:hh\:mm\:ss}  ({2}건)" -f $lo, $hi, $items.Count) -ForegroundColor Yellow
    if ($items.Count -ge 50) {
        Write-Host "    중단은 Ctrl+C. 5건마다 보고서를 써 두므로 -Resume 으로 이어서 할 수 있습니다." -ForegroundColor Yellow
    } else {
        Write-Host "    중단은 Ctrl+C." -ForegroundColor Yellow
    }
    $ans = Read-Host "계속할까요? (y/N)"
    if ($ans -ne 'y' -and $ans -ne 'Y') { Write-Host "취소했습니다."; exit 0 }
}

# attract.bat 이 걸어 주는 환경변수를 여기서도 같게 맞춘다.
# MEDNAFEN_HOME 이 없으면 Mednafen 이 %USERPROFILE%\.mednafen 을 베이스로 삼아
# 저장소의 mednafen.cfg 와 firmware\ 를 못 찾는다 (CLAUDE.md 4.9절).
$env:MEDNAFEN_HOME = Join-Path $Root 'emulators\Mednafen'

# MAME 계열 cfg\default.cfg 는 강제 종료 시 0바이트로 잘린다. 실행 전 크기를 기억해 둔다.
$guardFiles = @{}
if ($Launch) {
    foreach ($d in @('emulators\Mame\cfg\default.cfg', 'emulators\PSXMAME\cfg\default.cfg')) {
        $p = Join-Path $Root $d
        if (Test-Path -LiteralPath $p) { $guardFiles[$p] = (Get-Item -LiteralPath $p).Length }
    }
}

# ------------------------------------------------------------------ 검사
$i = 0
try {
foreach ($it in $items) {
    $i++
    $status = 'OK'; $detail = ''; $exePath = ''; $argStr = ''; $elapsed = 0; $exe = $null
    $winFirstMs = 0; $strUsed = $false; $script:LastShutdownMs = 0
    $fingerprint = ''; $baseRow = $null; $skipped = $false

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
                # 지문은 항상 남긴다 — 그래야 이번 보고서가 다음 -Adaptive 의 기준이 된다.
                $fingerprint = Get-Fingerprint $it.Raw $it.Emulator $exePath $rom.File $exe.Dir $it.Name
                if ($Adaptive) {
                    $baseRow = $baseMap["$($it.List)`t$($it.Name)"]
                    # 통과의 기준($OkBase)은 기준 보고서를 고를 때와 같은 것을 쓴다(위 Test-SkipBase).
                    if ((Test-SkipBase $baseRow) -and $baseRow.Fingerprint -eq $fingerprint) {
                        # 상태는 직전 것을 그대로 물려받는다. SKIP 으로 적어 버리면
                        # 이 보고서가 다음 실행의 기준이 되지 못한다 — 매일 돌리려면 연쇄돼야 한다.
                        $status  = $baseRow.Status
                        $skipped = $true
                        $detail  = "건너뜀 — 입력이 직전과 같다"
                        $winFirstMs = [int]$baseRow.WindowMs
                        $strUsed = ($baseRow.StrUsed -eq 'True')
                        $script:LastShutdownMs = [int]$baseRow.ShutdownMs
                    }
                }
            }
        }
    }

    # --- 구동 점검
    if ($Launch -and -not $skipped -and ($status -eq 'OK' -or $status -eq 'NOCHK')) {
        # 이 구간에서는 네이티브 명령(taskkill 등)의 stderr 가 치명적이 되지 않게 한다.
        # 스크립트 전역은 Stop 이라 stderr 한 줄에 몇 시간짜리 실행이 통째로 죽는다(2026-09-10 실측).
        # try/finally 로 감싸는 이유: 이 안에서 예외가 나면 맨 아래 복구 줄에 닿지 못하고
        # 남은 실행이 통째로 Continue 로 돌아 버린다. 안쪽은 들여쓰기를 그대로 두었다.
        $eapSaved = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
        $base = [IO.Path]::GetFileNameWithoutExtension($exePath)
        $pre = @(Get-Process -Name $base -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id)
        # 런처형 정의는 게임을 다른 프로세스로 띄운다. 그것을 알아보려면 실행 전 전체 PID 가 필요하다.
        $preAll = @(Get-Process | Select-Object -ExpandProperty Id)

        # MAME 계열은 강제 종료하면 cfg\default.cfg 가 잘린다. 그래서 ESC 사다리를 건너뛰지 않는다.
        # 대신 -Fast 에서는 -str(seconds_to_run) 을 붙여 MAME 이 스스로 깨끗이 끝나게 한다 —
        # 사다리가 통째로 사라져 항목당 20초 넘게 줄어든다.
        $protected = ($exe.Dir -match '\\emulators\\(Mame|EKMAME|PSXMAME)(\\|$)')
        $launchArgs = $argStr
        $strUsed = $false
        if ($Fast -and $protected -and $StrSeconds -gt 0 -and $launchArgs -notmatch '(^|\s)-(str|seconds_to_run)(\s|$)') {
            $launchArgs = ($launchArgs + " -str $StrSeconds").Trim()
            $strUsed = $true
        }

        # cmd /c 로 띄우는 정의는 게임이 다른 프로세스, 그것도 저장소 밖에 있을 수 있다.
        $isLauncher = ([IO.Path]::GetFileNameWithoutExtension($exePath) -eq 'cmd')
        $extraRoots = @()
        if ($isLauncher) { $extraRoots = @(Resolve-LauncherRoots $argStr) }

        $script:LastShutdownMs = 0
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $proc = $null
        try {
            $sp = @{ FilePath = $exePath; WorkingDirectory = $exe.Dir; PassThru = $true }
            if ($launchArgs) { $sp['ArgumentList'] = $launchArgs }
            $proc = Start-Process @sp
        } catch {
            $status = 'LAUNCHERR'; $detail = $_.Exception.Message
        }
        if ($proc) {
            # 판정을 폴링으로 세운다. 두 가지를 얻는다.
            #  (1) 판정이 서면 곧바로 끝내므로 12초를 꽉 채우지 않는다(-Fast).
            #  (2) 대화상자를 매 폴링마다 본다 — 예전에는 마지막에 한 번만 봐서, 점검 중 사람이
            #      상자를 닫아 버리면 실패가 PASS 로 기록되고 흔적이 남지 않았다(ISSUES 78번 srtshot).
            $dlg = $null; $hasWin = $false; $childNote = ''; $kids = @()
            $winFirstMs = 0; $dlgFirstMs = 0; $winStreak = 0; $lastKidMs = -99999; $extended = $false
            $stableNeed = 0   # 0 = 조기 판정 안 함
            if ($Fast) { $stableNeed = 3 }
            # -str 을 붙였으면 MAME 이 스스로 끝나는 것이 정상 경로다. 조기 판정으로 빠져나가면
            # 살아 있는 채로 Stop-Emulator 를 타서 ESC 사다리 비용이 그대로 남는다 — 끝날 때까지 기다린다.
            if ($strUsed) { $stableNeed = 0 }
            $minObserveMs = [int]($Observe * 1000)
            $deadlineMs = $Seconds * 1000
            # 직전 보고서가 "이 항목은 창이 뜨는 데 이만큼 걸린다"고 알려 주면 그만큼 여유를 준다.
            # RaidenIII 처럼 느린 항목이 마감에 걸려 NOWIN 이 되는 것을 막는다.
            if ($Adaptive -and $baseRow -and [int]$baseRow.WindowMs -gt 0) {
                $want = [int]$baseRow.WindowMs * 2 + 4000
                if ($want -gt $deadlineMs) { $deadlineMs = [math]::Min($want, 45000) }
            }
            while (-not $proc.HasExited -and $sw.Elapsed.TotalMilliseconds -lt $deadlineMs) {
                Start-Sleep -Milliseconds 250
                try { $proc.Refresh() } catch { break }
                if ($proc.HasExited) { break }
                $elMs = [int]$sw.Elapsed.TotalMilliseconds
                # 자식 프로세스 열거는 Get-Process 전체를 훑어 비싸다. 1초에 한 번만.
                if (($elMs - $lastKidMs) -ge 1000) { $kids = @(Get-NewEmuProcs $preAll $proc.Id $extraRoots); $lastKidMs = $elMs }
                $d = $null
                try { $d = [AmInput]::DialogText($proc.Id) } catch {}
                if (-not $d) { foreach ($k in $kids) { try { $d = [AmInput]::DialogText($k.Id) } catch {}; if ($d) { break } } }
                if ($d) { if ($dlgFirstMs -eq 0) { $dlgFirstMs = $elMs }; $dlg = $d; break }
                $hw = $false
                # cmd /c 로 띄우는 런처형은 cmd 자신의 콘솔 창을 갖는다. 그것을 게임 창으로 세면
                # 게임이 안 떠도 PASS 가 된다 — 철권 7 이 그랬다(2026-09-10). 런처는 자식 창만 본다.
                if (-not $isLauncher) {
                    try { $hw = [AmInput]::HasRealWindow($proc.Id) } catch {}
                    if (-not $hw) { try { $hw = ($proc.MainWindowHandle -ne [IntPtr]::Zero) } catch {} }
                }
                if (-not $hw) {
                    foreach ($k in $kids) {
                        try { if ([AmInput]::HasRealWindow($k.Id)) { $hw = $true; $childNote = "런처가 띄운 $($k.ProcessName)"; break } } catch {}
                    }
                }
                if ($hw) { if ($winFirstMs -eq 0) { $winFirstMs = $elMs }; $hasWin = $true; $winStreak++ } else { $winStreak = 0 }
                if ($stableNeed -gt 0 -and $winStreak -ge $stableNeed -and $elMs -ge $minObserveMs) { break }
                # 런처형은 게임을 늦게 띄운다. 마감이 다 됐는데 창은 없고 런처가 뭔가를 띄워 놨으면
                # 한 번만 마감을 늘려 준다 — RaidenIII 는 창이 뜨는 데 12초를 넘긴다(2026-09-10 실측).
                if (-not $extended -and -not $hasWin -and $kids.Count -gt 0 -and $elMs -ge ($deadlineMs - 1000)) {
                    # Max 여야 한다. 대입하면 -Adaptive 가 기준 실측으로 늘려 둔 마감보다
                    # 작아질 수 있고, 그러면 "늘려 주려던" 항목의 마감이 오히려 당겨져 NOWIN 이 된다.
                    $deadlineMs = [math]::Max($deadlineMs, [int]($Seconds * 1000 * 2.5)); $extended = $true
                }
            }
            $elapsed = [int]$sw.Elapsed.TotalMilliseconds
            $sec = [math]::Round($elapsed / 1000, 1)
            if ($proc.HasExited) {
                $code = $proc.ExitCode
                # -str 을 붙였으면 스스로 끝나는 것이 정상이다. 창을 봤다면 기동한 것이다.
                if ($strUsed -and $code -eq 0 -and $winFirstMs -gt 0) {
                    $status = 'PASS'; $detail = "-str $StrSeconds 로 $sec 초 만에 정상 종료".Trim()
                }
                elseif ($code -eq 0) { $status = 'EXIT0'; $detail = "$sec 초 만에 스스로 종료(코드 0)" }
                else { $status = 'CRASH'; $detail = "$sec 초 만에 종료, 코드 $code" }
            } else {
                if (-not $kids -or $kids.Count -eq 0) { $kids = @(Get-NewEmuProcs $preAll $proc.Id $extraRoots) }
                if ($dlg) {
                    $status = 'DIALOG'
                    $detail = '오류 대화상자: ' + ($dlg -replace '\s+', ' ')
                }
                elseif ($hasWin) { $status = 'PASS'; $detail = $childNote }
                else { $status = 'NOWIN'; $detail = '살아 있으나 창을 찾지 못함(런처가 다른 프로세스를 띄웠을 수 있음)' }
                if (Stop-Emulator $proc $exePath $pre $kids $it.Emulator $protected ([bool]$Fast)) {
                    $detail = ($detail + ' ESC 로 안 끝나 강제 종료함').Trim()
                }
            }
            # 대화상자를 봤는데 최종 판정이 PASS 면, 그 사이 누군가 상자를 닫았다는 뜻이다.
            if ($dlgFirstMs -gt 0 -and $status -eq 'PASS') {
                $detail = ($detail + ' ※ 점검 중 대화상자가 떴다가 사라짐 — 사람이 닫았을 수 있다').Trim()
            }
        }
        $tailMs = 700
        if ($Fast) { $tailMs = 250 }
        Start-Sleep -Milliseconds $tailMs
        # 앞 항목의 잔재가 남은 채로 다음 항목을 띄우면 런처형이 밀린다 — RaidenIII 가 전수에서만
        # NOWIN 으로 잡혔던 이유다(단독으로는 4초에 창이 뜬다). 비었는지 확인하고 넘어간다.
        $drain = [Diagnostics.Stopwatch]::StartNew()
        while ($drain.Elapsed.TotalSeconds -lt 5) {
            if (@(Get-NewEmuProcs $preAll -1 $extraRoots).Count -eq 0) { break }
            Start-Sleep -Milliseconds 250
        }
        } finally { $ErrorActionPreference = $eapSaved }
    }

    [void]$results.Add([pscustomobject]@{
        List = $it.List; Name = $it.Name; Title = $it.Title; Emulator = $it.Emulator
        Disabled = $it.Disabled; Status = $status; Detail = $detail
        Exe = $exePath; Args = $argStr; ElapsedMs = $elapsed
        WindowMs = $winFirstMs; ShutdownMs = $script:LastShutdownMs; StrUsed = $strUsed
        Fingerprint = $fingerprint; Skipped = $skipped
    })

    $isFail = ($FailStatus -contains $status)
    $isWarn = ($WarnStatus -contains $status)
    if ($isFail -or $isWarn -or -not $Quiet) {
        $color = if ($isFail) { 'Red' } elseif ($isWarn) { 'Yellow' } elseif ($skipped -or ($SkipStatus -contains $status)) { 'DarkGray' } else { 'Green' }
        $prefix = if ($Launch) { "[{0,4}/{1}]" -f $i, $items.Count } else { "" }
        $tag = $status
        if ($skipped) { $tag = "$status~" }   # ~ = 이번에 띄우지 않고 직전 결과를 물려받았다
        $msg = "{0} {1,-9} {2,-22} {3}" -f $prefix, $tag, $it.List, $it.Name
        if ($detail) { $msg += "  -- $detail" }
        Write-Host $msg -ForegroundColor $color
    } elseif ($Launch) {
        Write-Progress -Activity "구동 점검" -Status ("{0} / {1}  {2}" -f $i, $items.Count, $it.Name) -PercentComplete (100 * $i / $items.Count)
    }

    # 긴 구동 점검은 중간에 끊길 수 있다. 몇 건마다 지금까지의 결과를 써 둔다.
    # 쓰는 비용은 0.2초 남짓인데, 항목 하나가 30초 넘게 걸리기도 해서 자주 쓰는 편이 남는다.
    # (강제 종료되면 아래 finally 는 돌지 않는다. 실질적인 보호막은 이 주기 저장이다.)
    if ($Launch -and ($i % 5 -eq 0)) { Save-Reports }
}
} finally {
    # Ctrl+C 로 빠져나가도 여기까지는 남긴다
    if ($Launch) { Write-Progress -Activity "구동 점검" -Completed }
    if ($results.Count) { Save-Reports }
}

# ------------------------------------------------------------------ 보고
Save-Reports

Write-Host ""
Write-Host ("=" * 78)
foreach ($g in ($results | Group-Object Status | Sort-Object Count -Descending)) {
    $color = if ($FailStatus -contains $g.Name) { 'Red' } elseif ($WarnStatus -contains $g.Name) { 'Yellow' } else { 'Green' }
    Write-Host ("{0,-10} {1,5}건" -f $g.Name, $g.Count) -ForegroundColor $color
}
$skipCount = @($results | Where-Object { "$($_.Skipped)" -eq 'True' }).Count
if ($skipCount -gt 0) {
    Write-Host ("  그중 건너뜀 {0,5}건 — 입력이 직전과 같아 다시 띄우지 않았다(-Adaptive)" -f $skipCount) -ForegroundColor DarkGray
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
