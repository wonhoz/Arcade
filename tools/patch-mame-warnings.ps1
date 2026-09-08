<#
.SYNOPSIS
    MAME 시작 경고 화면 제거 — mame64.exe 1바이트 패치
.DESCRIPTION
    MAME 는 드라이버에 imperfect/preliminary 플래그가 있으면 게임을 띄우기 전에
    "There are known problems with this system … 아무 키를 누르면 진행합니다" 화면을
    띄우고 **키를 누를 때까지 기다린다.** 스스로 닫히지 않는다(40초 실측).
    romlists 의 MAME 계열 항목 중 187개가 이 대상이라 캐비닛에서 매번 걸린다.

    UI 옵션 skip_warnings(0.226+)는 이름과 달리 "이미 확인한 게임을 7일 이내에 다시
    띄울 때"만 건너뛴다. 첫 실행은 못 막는다. 그래서 바이너리를 고친다.

    src/frontend/mame/ui/ui.cpp — mame_ui_manager::display_startup_screens()

        if (!first_time || (str > 0 && str < 60*5) || &system == &___empty
            || debug_flags || video_none)
            show_gameinfo = show_warnings = false;

    이 다섯 조건은 전부 같은 "비활성" 블록으로 분기한다. 첫 분기(!first_time)를
    무조건 점프로 바꾸면 항상 그 블록을 타서 경고 화면이 만들어지지 않는다.
    show_gameinfo 도 같이 꺼지지만 args 에 -skip_gameinfo 가 이미 있어 변화가 없다.
    필수 미디어(파일 매니저) 화면은 별도 조건이라 영향받지 않는다.

        84 DB                     test bl,bl            ; first_time
        74 36                     jz   <비활성>          <-- 이 바이트 74 -> EB
        41 8D 8C 24 D4 FE FF FF   lea  ecx,[r12-0x12c]  ; str - 300
        81 F9 D4 FE FF FF         cmp  ecx,0xfffffed4   ; 부호 없는 범위 비교로 최적화돼
        77 26                     ja   <비활성>          ;  0x12C 가 cmp 즉시값으로 안 나온다

    빌드마다 오프셋이 달라지므로 고정 오프셋이 아니라 **시그니처로 찾는다.**
    정확히 1회 일치하지 않으면 아무것도 쓰지 않는다.

    ⚠️ mame64.exe 는 .gitignore 대상이라 이 패치는 git 으로 따라가지 않는다.
       장비마다 한 번씩 직접 돌려야 한다(.+필독.txt 8절).
.PARAMETER Exe
    대상 실행파일. 기본값은 이 스크립트 기준 ..\emulators\Mame\mame64.exe
.PARAMETER Apply
    패치를 적용한다. 없으면 상태만 보고한다.
.PARAMETER Revert
    패치를 되돌린다.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\patch-mame-warnings.ps1
    powershell -ExecutionPolicy Bypass -File tools\patch-mame-warnings.ps1 -Apply
.NOTES
    종료 코드: 0 = 정상, 1 = 시그니처 불일치 등으로 손대지 않음

    EKMAME(0.224)은 같은 시그니처가 없고, 실제로 띄워 보면 경고 화면 없이
    그대로 진행한다(2026-09-08 실측). 패치 대상이 아니다.
#>
[CmdletBinding()]
param(
    [string]$Exe,
    [switch]$Apply,
    [switch]$Revert
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

if (-not $Exe) { $Exe = Join-Path (Split-Path -Parent $PSScriptRoot) 'emulators\Mame\mame64.exe' }
if (-not (Test-Path -LiteralPath $Exe)) { Write-Error "실행파일이 없습니다: $Exe"; exit 1 }

# 패치 바이트 자리(index 2)와 그 변위(index 3)는 와일드카드다.
# 여기에 74 를 박아 두면 "이미 패치된 파일"을 못 찾아 되돌리기가 불가능해진다.
$sigHex     = '84 DB ?? ?? 41 8D 8C 24 D4 FE FF FF 81 F9 D4 FE FF FF 77'
$patchIndex = 2
$from = 0x74      # jz
$to   = 0xEB      # jmp

Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
public class MameSig {
    public static List<int> Find(byte[] b, int[] sig) {
        var r = new List<int>();
        int n = sig.Length, last = b.Length - n;
        byte s0 = (byte)sig[0];
        for (int i = 0; i < last; i++) {
            if (b[i] != s0) continue;
            bool ok = true;
            for (int k = 1; k < n; k++) { if (sig[k] >= 0 && b[i + k] != sig[k]) { ok = false; break; } }
            if (ok) r.Add(i);
        }
        return r;
    }
}
'@ -Language CSharp

$sig = @()
foreach ($t in ($sigHex -split ' ')) {
    if ($t -eq '??') { $sig += -1 } else { $sig += [Convert]::ToInt32($t, 16) }
}

Write-Host ""
Write-Host "MAME 시작 경고 화면 패치" -ForegroundColor Cyan
Write-Host ("=" * 66)
Write-Host ("대상 : {0}" -f $Exe)
$b = [System.IO.File]::ReadAllBytes($Exe)
Write-Host ("크기 : {0:N0} 바이트   MD5 {1}" -f $b.Length, (Get-FileHash -LiteralPath $Exe -Algorithm MD5).Hash)

$hits = [MameSig]::Find($b, [int[]]$sig)
Write-Host ("시그니처 일치 : {0}건" -f $hits.Count)

foreach ($h in $hits) {
    $o = $h + $patchIndex
    $cur = $b[$o]
    if ($cur -eq $from)   { $state = '패치 안 됨 (74 jz)' ; $color = 'Yellow' }
    elseif ($cur -eq $to) { $state = '패치됨 (EB jmp)'    ; $color = 'Green'  }
    else                  { $state = ('예상 밖 0x{0:X2}' -f $cur) ; $color = 'Red' }
    Write-Host ("  파일 0x{0:X}  패치 바이트 0x{1:X} = 0x{2:X2}  -> {3}" -f $h, $o, $cur, $state) -ForegroundColor $color
}

if ($hits.Count -ne 1) {
    Write-Host ""
    Write-Host "시그니처가 정확히 1회 일치해야 합니다. 파일을 건드리지 않았습니다." -ForegroundColor Red
    Write-Host "다른 빌드일 수 있습니다 — 위 주석의 조건문을 소스에서 찾아 같은 방식으로 처리하세요." -ForegroundColor Red
    exit 1
}
if ($b[$hits[0] + $patchIndex] -ne $from -and $b[$hits[0] + $patchIndex] -ne $to) {
    Write-Host ""
    Write-Host "일치한 자리의 바이트가 74(jz)도 EB(jmp)도 아닙니다. 건드리지 않았습니다." -ForegroundColor Red
    exit 1
}

$off = $hits[0] + $patchIndex
if (-not ($Apply -or $Revert)) {
    Write-Host ""
    Write-Host "상태만 확인했습니다. 적용은 -Apply, 되돌리기는 -Revert." -ForegroundColor DarkGray
    exit 0
}

if ($Revert) { $want = $from; $have = $to } else { $want = $to; $have = $from }
if ($b[$off] -eq $want) { Write-Host ""; Write-Host "이미 그 상태입니다. 할 일이 없습니다." -ForegroundColor Green; exit 0 }
if ($b[$off] -ne $have) {
    Write-Host ""
    Write-Host ("바이트가 0x{0:X2} 입니다. 0x{1:X2} 를 기대했습니다 — 건드리지 않았습니다." -f $b[$off], $have) -ForegroundColor Red
    exit 1
}

$b[$off] = $want
[System.IO.File]::WriteAllBytes($Exe, $b)
Write-Host ""
Write-Host ("파일 0x{0:X} 에 0x{1:X2} 를 썼습니다." -f $off, $want) -ForegroundColor Green
Write-Host ("MD5 : {0}" -f (Get-FileHash -LiteralPath $Exe -Algorithm MD5).Hash)
Write-Host ""
Write-Host "확인 : 아무 게임이나 창 모드로 띄워 경고 화면 없이 바로 시작하는지 봅니다." -ForegroundColor DarkGray
Write-Host "       emulators\Mame\mame64.exe -window -skip_gameinfo asterix" -ForegroundColor DarkGray
exit 0
