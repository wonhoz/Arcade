# 개선 과제 / 알려진 문제 (심각도순)

최초 점검 2026-09-02 · 전체 재검수 2026-09-03 · 시각 자산 재스크리닝 2026-09-03 · 3차 재점검 2026-09-04 · 4차 재점검 2026-09-04 · 브랜치 `develop` (main 기반) · Attract-Mode v2.7.0
근거: `attract.cfg`, `emulators/*.cfg`, `romlists/*`, `last_run.log`, `mame64 -verifyroms`, git 메타데이터 실측

> 항목이 해소되면 체크박스를 갱신하고, 구조가 바뀌었으면 [`../CLAUDE.md`](../CLAUDE.md)도 같은 커밋에서 함께 고친다.
> 점검은 `powershell -ExecutionPolicy Bypass -File tools\validate.ps1` 로 자동화되어 있다.

**진행 현황** — 처리 **41건** / 미해결 **1건**(13번) · 보류 2건 · 재분류 3건 · 개선 포인트 8건
(28~36번은 2026-09-04에 항목별로 한 커밋씩 처리. 37~41번은 4차 재점검이 3차 처리분을 재검증해 찾은 것 — 같은 날 항목별 한 커밋씩 처리.
42·43번은 사용자 지적으로 마스코트 2종을 다시 손본 것)

> **보류 (우선순위 낮춤, 별도 지시 전까지 대기)** — S1 공개 저장소의 BIOS·롬, S2 `.git` 1.2GB.
> 둘 다 히스토리 재작성이 필요하고 되돌리기 어렵다.

---

## S1 — 치명적 (법적 위험) · ⏸ 보류

### - [~] 1. 공개 저장소에 상용 BIOS·게임 롬이 커밋되어 있음 — ⏸ **보류**

원격 `https://github.com/wonhoz/Arcade`는 **공개(public)** 저장소인데 다음이 추적되고 있다.

| 대상 | 경로 | 규모 |
|---|---|---|
| PS2 BIOS (Sony 펌웨어) | `emulators/PCSX2/bios/SCPH-*` | **94개 / 152.5MB** |
| PS1 BIOS | `emulators/ePSXe/bios/{SCPH1001.BIN, scph5500.bin, …}` | 6개 / 2.5MB |
| SEGA Saturn / PC-FX BIOS | `emulators/Mednafen/firmware/{sega_101.bin, mpr-17933.bin, pcfx.rom, fx-scsi.rom}` | 6개 / 3.9MB |
| 상용 SNES 롬 | `emulators/Mednafen/Roms/SNES/*.zip` (Clock Tower, The Firemen, taekwonk) | 3개 |
| 에뮬레이터 실행 바이너리 전량 | `emulators/*/*.exe`, `*.dll` | 다수 |

BIOS와 게임 롬은 재배포가 금지된 저작물이다. DMCA 테이크다운 및 계정 제재 대상.
`.gitignore`가 롬 폴더는 막고 있지만 **`bios/`·`firmware/` 폴더는 막지 않아** 빠져나갔다.

2026-09-03 재검수: 네 경로 전부 여전히 `git check-ignore` 에 걸리지 않는다. **합계 109개 / 162MB.**
원격은 여전히 `"private": false`.

**조치 (권장 순서)**
1. 즉시 저장소를 **private로 전환** (임시 차단).
2. `.gitignore`에 `emulators/PCSX2/bios/`, `emulators/ePSXe/bios/`, `emulators/Mednafen/firmware/`, `emulators/Mednafen/Roms/` 추가.
3. `git filter-repo`로 히스토리에서 제거 후 force push. — 브랜치 7개를 재작성하므로(20번에서 22 → 7로 정리)
   **작업 전 전체 백업 필수**이며, 부수효과로 2번(저장소 크기) 문제도 크게 완화된다.
4. BIOS/롬은 저장소 밖(외장/NAS)에 두고 배포 절차로 복사 — [`ASSETS.md`](ASSETS.md), [`../README.md`](../README.md) 참고.

---

## S2 — 높음 · ⏸ 보류 (2번만)

### - [~] 2. 저장소가 1.2GB, 에뮬레이터 바이너리 전량이 git에 들어 있음 — ⏸ **보류**

- `.git` **1.2GB**(size-pack 1.17GiB) / 추적 파일 **23,554개** (2026-09-04 실측. 2026-09-03 에는 23,711개 · 1.71GB 였고 34번 정리로 134개가 줄었다)
- 히스토리 상 가장 큰 blob:

  | 크기 | 파일 |
  |---|---|
  | 43.0MB | `emulators/fbneo/fbneo.exe` |
  | 38.0 / 36.3 / 32.2MB | `attract.exe` **3세대** |
  | 38.0 / 34.4MB | `attract-console.exe` 2세대 |
  | 23.8MB | `emulators/RetroArch/assets/sounds/BGM.wav` |
  | 23.1MB | `emulators/Mame/icons/icons.zip` |
  | 19.0MB | `emulators/Cemu/Cemu.exe` |
  | 18.5MB | `emulators/Mednafen/mednafen.exe` |

  같은 실행파일의 여러 세대가 그대로 쌓여 있는 게 핵심이다.
  2.7.0 업그레이드로 `attract-console.exe`가 작업 트리에서 사라졌지만 **히스토리에는 2세대가 남아 있고**,
  새 `attract.exe` 38MB가 오히려 더 쌓였다.
  → 근본 해결은 아래 "조치"의 히스토리 재작성뿐이라는 점이 이번 업그레이드로 재확인됐다.
- 결과: 클론/브랜치 전환/머지가 매우 느리고, 에뮬레이터 업데이트 때마다 수백 MB가 히스토리에 쌓인다
  (실제로 `MAME 업데이트`, `PPSSPP 업데이트` 같은 커밋이 반복돼 있음).

**조치**: 에뮬레이터 바이너리를 저장소에서 분리(별도 배포 아카이브 또는 Git LFS)하고,
저장소는 **설정·목록·레이아웃·문서**만 담도록 축소. 1번의 히스토리 재작성과 함께 진행하면 한 번에 끝난다.

### - [x] 3. 디스플레이 선택 메뉴 레이아웃이 실행할 때마다 스크립트 에러 2건 — **처리 완료**

`menu_layout = Mega-Display Advanced`(= 시작 화면)에서 `last_run.log`에 매번 남던 오류.

- `scripts/arcade_name.nut` — `ScrollingText.add(...)`를 `fe.add_text(...)`로 바꾼 뒤 남은 잔재.
  `fe.Text`에 없는 `.settings.delay` / `.settings.loop`가 예외를 던졌다.
  → `the index 'settings' does not exist` 해소.
- `scripts/clock.nut` — 중복된 `clock.msg` 대입 삭제. `clock`이 하단 지역변수(이미지)가 아니라
  Squirrel 내장 `clock()` 함수로 해석되어 `trying to set 'function'` 발생.
  실제 시계는 바로 위 `clockb.msg`가 담당한다.

> **⚠️ 이 수정에서 배운 것 — Squirrel 예외는 그 스크립트의 나머지를 통째로 중단시킨다.**
>
> 최초 수정에서 예외 줄만 지웠더니 상단 Overview 텍스트가 왼쪽으로 밀려
> 사이드바 아트 뒤로 숨는 **회귀가 발생했다**.
>
> 원인은 예외 줄 아래의 `uct.align = Align.Left` … `uct.font` 6줄이
> **애초에 한 번도 실행된 적이 없었다**는 데 있다. 예외가 그 지점에서 스크립트를
> 중단시켰기 때문이다. 지금까지 화면에 보이던 가운데 정렬은 `fe.add_text`의 기본값이었고,
> 예외를 없애자 죽어 있던 코드가 되살아나 `Align.Left`가 처음으로 적용된 것이다.
> 텍스트 상자가 `x = flx*0.19`에서 시작하는데 좌측 사이드바 아트가 그 위를 덮는다.
>
> → 잔재 6줄을 전부 주석 처리해 **실행되는 문장을 수정 전과 동일하게** 맞췄다.
> 화면은 그대로이고 `last_run.log`의 예외만 사라진다.
>
> **레이아웃 `.nut`에서 예외 줄을 지울 때는 그 아래 코드가 새로 살아난다는 점을 반드시 확인할 것.**
> 실제 화면 확인은 `attract.exe`를 한 번 실행한 뒤 `last_run.log`에
> `AN ERROR HAS OCCURED`가 없는지, 그리고 화면이 이전과 같은지 함께 본다.

### - [x] 4. 에뮬레이터 cfg 22개에 UTF-8 BOM — **처리 완료**

BOM이 첫 줄(주석)에 붙어 AM 파서가 설정 키로 오인, `Unrecognized "emulator" setting of "﻿#"` 경고가 남았다.
첫 줄이 주석이라 결과는 무해했으나 **첫 줄에 실제 설정이 오면 그 설정이 통째로 무시된다.**
22개 전부 BOM 없는 UTF-8로 재저장. `tools/validate.ps1`이 재발을 잡는다.

---

## S3 — 중간

### - [x] 5. Capcom 디스플레이의 CPS3 필터가 CPS2를 가리킴 — **처리 완료**

`filter CPS3`의 규칙이 `AltRomname equals cps2`였다. CPS3 필터가 CPS2 47개를 보여주고,
cps3 6개(레드 어스, 스파3 3부작, 조조 2종)는 어떤 필터에도 잡히지 않았다. `cps3`으로 수정.

### - [x] 6. NXL HD 레이아웃 폰트 3종 미로드 — **처리 완료**

`layouts/NXL HD/layout.nut`이 쓰는 `futureforces` / `Squares Bold Free` / `MSMINCHO`가
`layouts/NXL HD/` 안에도, `font_path`(=`fonts`) 안에도 없어 기본 폰트로 대체되고 있었다.
실제 파일은 `layouts/NXL HD font/`라는 별도 폴더에 있었다.

- `layouts/NXL HD font/` → **`fonts/NXL HD/`** 로 이동
- `attract.cfg` `font_path` → `fonts;fonts/NXL HD`

동시에 **`layout.nut` 없는 폴더가 `layouts/`에 있어 레이아웃 선택 목록에 깨진 항목으로 노출되던 문제**(구 S4-15)도 해소.

> **⚠️ 이 수정에서 배운 것 — 폰트를 찾을 수 있게 만들면 한글이 깨진다.**
>
> `font_path`를 넓히자 NXL HD 화면의 한글이 전부 두부로 깨지는 **회귀가 발생했다**.
> **Attract-Mode에는 글리프 단위 폴백이 없다.**(2.7.0에서도 동일 — 윈도우 폰트 탐색 코드 무변경) 폰트를 못 찾으면 `default_font`로
> 통째로 폴백하지만, 찾으면 그 폰트만 쓴다. 즉 **"폰트가 로드되지 않아서" 한글이 멀쩡했던 것**이다.
>
> 글리프 실측 결과:
>
> | 폰트 | 한글 | 글리프 수 |
> |---|---|---|
> | `futureforces.ttf` | ❌ | 219 (라틴 전용) |
> | `Squares Bold Free.otf` | ❌ | 221 (라틴 전용) |
> | `MSMINCHO.TTF` | ❌ | 14,965 (일본어 폰트) |
>
> → 되돌리는 대신 **내용에 따라 폰트를 분리**했다. 한글이 들어가는 5개 객체
> (`[Title]`, `[!genre]`, `[Rotation]`, `[!rss]`, 오버레이 메뉴)만 한글 글꼴로 바꾸고,
> 라틴/숫자뿐인 6개 객체(`[FilterName]`, `[ListEntry]/[ListSize]`, `[Players]`, `[Year]`,
> `[AltTitle]`, `"FREE PLAY"`)는 테마 글꼴을 유지해 NESiCAxLive 특유의 외형을 살렸다.
> 유지한 폰트들이 실제 표시할 문자열을 전부 커버하는 것도 확인했다.
>
> 한글 글꼴은 처음에 `NanumBarunGothicBold`로 두었다가
> NESiCAxLive의 각진 느낌에 맞춰 **`SUIT-Regular`**(기하학적 산세리프)로 바꿨다.
> 이때 **SUIT 계열에 `：`(U+FF1A, 전각 콜론) 글리프가 없다**는 것이 걸림돌이었다.
> `rss()`의 URL 8곳이 `http：//`처럼 전각 콜론으로 적혀 있었기 때문이다
> (원본 테마를 일본어 IME로 편집하며 들어간 오타). 반각 `:`로 교정해 표기도 바로잡고 사용을 열었다.
>
> **검증 방법** — SUIT로 렌더링될 모든 문자열(게임 제목 · `genre()` · `rss()` ·
> `language/kr.msg` · 디스플레이/필터명)에서 고유 문자 471자를 추출해 `GlyphTypeface`로 대조했다.
> 글꼴을 바꿀 때는 이 방식으로 **실제 표시될 문자 집합 전체**를 검사하는 것이 확실하다.
>
> **`[!token]` 은 레이아웃 안의 함수가 만드는 값이라 함수 본문을 열어봐야 한다** —
> NXL HD의 `genre()`는 `"액션"/"아케이드"/"격투"`를, `rss()`는 긴 한국어 문장을 반환한다.
> 토큰 이름만 보고 라틴이라고 판단하면 안 된다.

### - [x] 7. 디스플레이 메뉴 설명문 2개 누락 — **처리 완료**

`scraper/@/overview/`에 `taito type x.txt`, `teknoparrot.txt` 추가.
display 21개 전부 설명문을 갖췄다(검증 스크립트가 상시 확인).

### - [x] 8. 미추적 대용량 파일 389MB — **처리 완료 (지우지 않고 정리)**

`mame64 - 복사본 (2).exe/.sym` 389MB 가 `git status` 에 계속 떠 있었다.
지우기 전에 정체부터 확인했더니 **쓰레기가 아니라 의도적인 폴백**이었다.

| 파일 | MAME 버전 | 날짜 |
|---|---|---|
| `mame64.exe` | **0.246** | 2022-07 |
| `mame64 - 복사본 (2).exe` | **0.220** | 2020-04 |

MAME 롬셋은 버전에 민감해서 신버전에서 안 되는 롬이 구버전에서 되는 경우가 있다.
실제로 그런 것이 하나 있었다.

```
                0.246                          0.220
raycris   1 romsets found, 0 were OK.    1 romsets found, 1 were OK.
```

`raycris`(레이크라이시스)는 9번에서 "CHD 만 있고 프로그램 롬 없음"으로 비활성 처리했는데,
**0.220 에서는 정상 검증된다.** 나머지 5개(secretag, simpsons4pa, cleopatr, elandore, ptblank)는
양쪽 다 romset not found 라 진짜 없는 롬이다.

**조치** — 삭제하지 않고 정체가 드러나는 이름으로 바꾸고 무시 규칙을 넓혔다.

```
mame64 - 복사본 (2).exe  ->  mame64-0.220.exe
mame64 - 복사본 (2).sym  ->  mame64-0.220.sym
.gitignore : emulators/Mame/mame64.exe -> emulators/Mame/mame64*.exe (sym 도 동일)
```

MAME 루트에 그대로 두었으므로 기존 `mame.ini`·`hash`·`roms` 를 공유해 바로 실행된다
(rename 후 `-version` 확인 완료). `git status` 노이즈도 사라졌다.

> **raycris 를 되살리려면** `emulators/MAME 0.220.cfg` 를 만들어 executable 을
> `mame64-0.220` 으로 두고 romlist 의 Emulator 를 바꾸면 된다. 다만 이 바이너리는
> `.gitignore` 대상이라 **다른 장비에는 없을 수 있고**, 없는 장비에서는 실행이 깨진다.
> 그래서 지금은 비활성 유지하고 선택지만 남겨둔다.

### - [x] 9. 활성 목록인데 실제 롬이 없는 항목 — **처리 완료**

`mame64 -verifyroms`로 실제 구동 가능 여부를 확인한 뒤 처리했다.

| 대상 | 검증 결과 | 조치 |
|---|---|---|
| `secretag`, `simpsons4pa`, `cleopatr`, `elandore`, `ptblank` | romset not found | `#` 비활성 |
| `raycris` | romset is bad (CHD만 있고 프로그램 롬 없음) | `#` 비활성 |
| `zooo` | best available → **정상 구동** | 활성 유지 |
| `San Francisco Rush 2049 (E)` | 파일명 끝에 공백 | 롬 파일명 정정 |
| `Star Fox 64 (U) (V1.0)` | 파일이 `Star Fox 64 (USA).zip` | 롬 파일명 정정 |
| `SSX 3 (K)` | 파일이 `SSX3 (K).gz` | 롬 파일명 정정 |

뒤 3건은 **romlist Name과 `menu-art` 아트웍 파일명이 이미 목록 쪽 표기를 따르고 있어**
롬 파일 쪽을 맞췄다(롬은 `.gitignore` 대상이라 커밋에는 잡히지 않음).

### - [x] 10. 세로 게임 5건이 가로용 에뮬레이터 설정 사용 — **처리 완료**

| 게임 | 회전 | 변경 |
|---|---|---|
| `misncrft` 미션 크래프트 | 90 | MAME → **MAME Vertical** |
| `scudhamm` 스커드 해머 | 270 | MAME → **MAME Vertical** |
| `fixeightk` / `fixeightkt` / `fixeightbl` 픽스에이트 | 270 | EKMAME → **EKMAME Vertical** |

전환에 앞서 **`EKMAME Vertical.cfg`가 `EKMAME.cfg`와 어긋나 있던 것**을 함께 맞췄다.

```
args     "[name]"        ->  -skip_gameinfo -nowindow "[romfilename]"
rompath  roms\           ->  roms\korean\
```

기존 `EKMAME Vertical` 사용 5건(raidenkb, raidendxk, rfjeta, mikiek, ikari3k)이
모두 `roms\Korean\`에 있음을 확인했다.

### - [~] 11. ~~NEC PC-Engine CD 정의가 죽어 있음~~ — **오진, 재분류**

최초 보고에서 "참조하는 romlist도 display도 없는 死코드"라고 했으나 **사실이 아니다.**

- `romlists/MAME Adult.txt` 59~62행의 **비활성(`#`) 항목 4개**가 이 두 정의를 참조한다
  (CD 마작 미소녀 중심파, CD 빠찡코 미소녀 겜블러 / 구마 네자매, 카드 엔젤스).
- cfg의 `rompath roms\console\pcecd\`는 `emulators/Mame/mame.ini:11`의 rompath 목록에 있는
  `roms\Console\pcecd`와 **정확히 일치**한다. 경로 설정에 오류가 없다.
- 해당 폴더가 없는 이유는 단순히 그 성인용 PCE-CD 롬을 설치하지 않았기 때문이다.

→ **삭제하면 안 되는 예약 정의**다. 검증 스크립트도 이 경우를 FAIL이 아닌
`WARN [emulator] rompath 없음 (롬 미설치이거나 예약 정의)`로 다룬다.

### - [x] 12. 대소문자만 다른 `Name` 충돌 — **처리 완료**

`romlists/NESiCAxLive.txt`

```
21행  tekken ;철권                    ;PSXMAME
35행  Tekken ;철권 태그 토너먼트 2    ;Nintendo Wii U
```

전체 목록을 통틀면 하나 더 있다 — `Contra`(TeknoParrot) vs `contra`(MAME Vertical).

**재검수 결과, 지금 당장 깨지는 것은 없다.** 두 쌍 모두 `artwork` 경로가 시스템별로 갈라져 있고
(`menu-art\nintendo wii u\` vs `menu-art\zinc\`+`emulators\mame\`,
`menu-art\TeknoParrot\` vs `emulators\mame\`), 2.7.0부터 통계도 `stats/<Emulator>/`로 갈린다.
최초 보고의 "같은 아트웍을 공유한다"는 서술은 경로를 확인하지 않은 추정이었다.

남는 위험은 둘이다.
- **Linux/macOS에서 클론하면** 파일시스템이 대소문자를 구분해 아트웍 탐색 결과가 달라진다(18-a와 같은 뿌리).
- 나중에 아트웍을 한 폴더로 합치거나 `artwork` 경로를 공유하게 바꾸면 그때 바로 충돌한다.

**조치 완료** — 같은 목록 안에 있던 `NESiCAxLive.txt` 쪽을 정리했다.

```
romlists/NESiCAxLive.txt   Tekken -> Tekken Tag Tournament 2
romlists/Nintendo Wii U.txt  Tekken -> Tekken Tag Tournament 2
emulators/Cemu/Roms/Tekken -> emulators/Cemu/Roms/Tekken Tag Tournament 2
```

아트웍은 손대지 않았다. `menu-art/nintendo wii u/`에 `Tekken.*`이 아예 없고
`Tekken Tag Tournament 2 - Wii U Edition (USA).*`만 있는 것으로 보아
AM 이 Name 이 아니라 **CloneOf(4번 필드)로 아트웍을 찾고 있었기 때문**이다.
`Sony PlayStation.tag`의 `Tekken`은 PS1 항목이라 무관하다.

> ⚠️ **다른 장비에서도 롬 폴더를 바꿔야 한다.**
> `emulators/Cemu/Roms/`는 `.gitignore` 대상이라 이 rename 이 머지로 따라가지 않는다.
> 안 바꾼 장비에서는 `validate.ps1`이 롬 없음으로 잡아준다.

`Contra`(TeknoParrot) vs `contra`(MAME)는 그대로 뒀다. 서로 다른 romlist 이고
아트웍 경로도 `menu-art/TeknoParrot/` vs `emulators/Mame/`로 완전히 갈려 있어
같은 디렉터리에서 마주칠 일이 없다.

---

## S4 — 낮음 (일관성 · 정리)

> 아래는 지금 당장 무언가를 망가뜨리지 않지만, 방치하면 나중에 원인 파악이 어려워지는 것들이다.

### - [ ] 13. romlist 필드가 목록마다 다른 의미로 전용되어 있음

Attract-Mode의 romlist는 21개 필드가 **고정된 의미**를 갖는 포맷인데, 이 저장소는 일부 필드를
원래 의미와 다르게 쓰고 있다. 문제는 그 규칙이 **파일마다 다르다**는 점이다.

| 필드 | AM의 원래 의미 | 이 저장소의 실제 사용 |
|---|---|---|
| 9 `Rotation` | 화면 회전값 (0/90/180/270) | MAME 계열은 정상 사용 (0:326, 90:12, 180:3, 270:23)<br>**`NESiCAxLive.txt`는 언어를 넣는다** (한국어 16, 영어 15, 일본어 2) |
| 14 `AltRomname` | 대체 롬 이름 | **플랫폼 태그** — `Capcom.txt`는 cps1/cps2/cps3, `NESiCAxLive.txt`는 neogeo/cps2 등 |
| 15 `AltTitle` | 대체 제목 | 영문 원제 보관용 (단, `MAME.txt`에서는 의미 없이 `0`) |
| 16 `Extra` | 자유 필드 | **PS2 목록에서 언어(한국어)** / 다른 목록에서는 `0` |
| 19 `Language` | 언어 | **전 목록에서 비어 있음** |

**왜 이렇게 됐나**: `layouts/NXL HD/layout.nut:971`이 정보 상자에 `[Rotation]`을 그대로 뿌린다.
언어를 화면에 띄우려면 레이아웃을 고치는 대신 데이터를 `Rotation`에 넣는 쪽이 빨랐던 것.
`AltRomname`은 `attract.cfg`의 Capcom 필터(`rule AltRomname equals cps1`)가 실제로 의존하고 있어
이제 와서 바꾸면 필터가 깨진다.

**위험**: 새 항목을 추가하는 사람이 필드 의미를 오해하면 목록마다 다른 규칙을 어긴다.
특히 `Rotation`에 언어를 넣은 NESiCAxLive는 나중에 실제 세로 게임이 추가되면 판단이 불가능해진다.

**조치안**
1. (권장) 언어는 `Language`(19)로 통일하고 `NXL HD/layout.nut`을 `[Language]`로 수정.
   `AltRomname`의 플랫폼 태그는 `attract.cfg` 필터와 함께 `Series`(18) 등으로 이전.
2. (최소) 지금처럼 두되 **[`../CLAUDE.md`](../CLAUDE.md) 4.1절의 표를 반드시 보고
   같은 파일의 기존 줄을 복사해서 추가**한다. ← 현재 채택 중

### - [~] 14. 비활성(`#`) 항목이 존재하지 않는 에뮬레이터 16종을 참조 — **경고에서 참고로 재분류**

**전부 `#`으로 꺼져 있어 실행에는 영향이 없다.** 비활성 행이 없는 에뮬레이터를 가리키는 것은
정의상 무해한데, 한 건씩 경고로 찍으면 34줄이 깔려 진짜 신호를 덮었다.
그래서 `validate.ps1`을 고쳐 **`참고` 한 줄로 집계**하도록 했다. 데이터 자체는 그대로 둔다.
되살리려면 대응하는 `emulators/<이름>.cfg`부터 만들어야 한다는 뜻이다.

| romlist | 참조하는 없는 에뮬레이터 | 건수 |
|---|---|---|
| `MAME Adult.txt` | `3DO` | 13 |
| `Taito Type X.txt` | `Taito Type X_{Battle Fantasia, Beatmania iidx 17 - SIRIUS, BlazBlue Calamity Trigger, Deathsmiles II, Haunted Museum, Haunted Museum II, Mobile Suit Gundam Spirits Of Zeon, Otomedius, Street Fighter IV, Trouble Witches AC, cmd}` | 11 |
| `SEGA SATURN.txt` | `SEGA Saturn`, `SEGA Saturn_mdf` | 8 |
| `Nintendo Wii U.txt` | `Nintendo Wii U Name_Name` | 1 |
| `TeknoParrot.txt` | `Tekno Parrot_VF5B` | 1 |

**표기법이 어긋나 있는 점에 주의**: 실제 cfg 파일명은 `Taito Type X Spica Adventure.cfg`처럼
**공백** 구분인데, 목록은 `Taito Type X_Otomedius`처럼 **밑줄**을 쓴다.
과거 다른 명명 규칙에서 넘어온 흔적으로 보인다. 되살릴 때는 공백 표기로 맞춰야 한다.

`SEGA Saturn`(정의는 `SEGA Saturn CUE/CCD/TOC` 3개로 쪼개져 있음)과
`Nintendo Wii U Name_Name`(치환 토큰이 이름에 섞여 들어간 오타)은 명백한 실수 흔적이다.

### - [x] 15. 아무 목록도 참조하지 않는 에뮬레이터 cfg 2개 — **처리 완료 (17번에서 함께)**

- `Taito Type X Samurai Shodown - Edge of Destiny.cfg` → `emulators\Taito Type X\Samurai Shodown - Edge of Destiny\game.exe`
- `Taito Type X Spica Adventure.cfg` → `emulators\Taito Type X\Spica Adventure\typex_loader.exe`

두 cfg가 가리키는 **실행 파일도 로컬에 없다.** 해당 게임 폴더는 `.gitignore` 대상이라
다른 장비에서 지웠거나 애초에 옮겨오지 않은 것으로 보인다.
한편 `romlists/Taito Type X.txt`에는 두 게임이 **다른 이름**(`Taito Type X_...`)으로 참조되는
비활성 항목이 있다(14번). 즉 **정의와 목록이 서로 다른 이름을 쓰며 둘 다 죽어 있는 상태**다.

→ 게임을 복구하고 이름을 통일하든지, cfg를 정리하든지 결정 필요.
지금은 참조가 없어 실행에 영향이 없으므로 검증 스크립트도 WARN으로만 다룬다.

### - [x] 16. `emulators/Mame/mame.ini`에 무효한 절대경로 — **처리 완료**

```
rompath  "roms;roms\Arcade;…;f:\attractmode\emulators\PSXmame\roms;roms\Console\neocd"
```

`f:\attractmode\...`는 예전 설치 드라이브의 흔적이다. 현재 설치는 `D:\`라 존재하지 않는다.
MAME이 롬을 찾을 때마다 없는 경로를 한 번씩 더 확인하게 되고(성능은 무시할 수준),
**설치 경로를 옮기면 이런 절대경로만 조용히 깨진다**는 점이 문제다.

→ `..\PSXmame\roms` 같은 상대경로로 바꾸거나 제거. 다른 `.ini`에도 절대경로가 없는지 함께 확인.

### - [x] 17. 연결되지 않은 채 남아 있는 자산들

| 대상 | 상태 | 판단 |
|---|---|---|
| `plugins/` 17종<br>(AudioMode, Confirm Game Selection, Debug Reload, FPSMonitor, History.dat, KeyboardSearch, KonamiCode, LEDBlinky, MultiMon, ResFix, RocketLauncher, RotationControl, SpecificDisplay, UltraStik360, UtilityMenu, eSpeak) | `attract.cfg`에 `plugin` 섹션이 **하나도 없음** → 전부 비활성 | AM 기본 배포물이라 보존해도 무해. 다만 "플러그인이 동작 중"이라고 오해하기 쉬움 |
| `plugins-NESiCAxLive/` (LEDBlinky, MultiMon) | 어디서도 참조 안 됨 | NESiCAxLive 전용 세트의 잔재 |
| `screensaver-NESiCAxLive/` | AM은 `screensaver/`만 읽음 → 미사용 | 폰트 4종(9MB MSMINCHO 포함)을 품고 있음 |
| `attract-NESiCAxLive.cfg` | **AM v2.2.1** 시절 타 환경 설정. `exit_command Y:\Frontend\reload.exe`, `font_path %SYSTEMROOT%/Fonts/;Y:\Frontend\Am\`, `layout blueprint`, `romlist Nesicagui` — 이 저장소에 없는 것만 참조 | 참고용 화석. 현행 `attract.cfg`와 공통점 없음 |
| `intro/intro_16x9.mp4` | `intro_config` 섹션이 없어 기본값(`intro.mp4`)만 재생 | 16:9 전용 인트로를 쓰려면 설정 필요 |
| `loader/` (hyperspin, mala, mamewah, attract_xml) | AM 기본 임포터. 사용 이력 없음 | 벤더 원본, 그대로 둠 |

**조치 완료 (2026-09-03)** — 지우기 전에 하나씩 "정말 로드될 수 없는가"를 확인했다.

**기준: AM이 스스로 선택할 수 있으면 남기고, 이름을 바꾸지 않으면 절대 로드될 수 없는 것만 지운다.**

| 대상 | 결정 | 근거 |
|---|---|---|
| `screensaver-NESiCAxLive/` (31개) | **제거** | AM은 `screensaver/` 폴더만 읽는다 |
| `plugins-NESiCAxLive/` (2개) | **제거** | AM 플러그인 UI는 `plugins/`만 스캔. 게다가 `plugins/` 원본과 내용이 달라 동기화도 안 돼 있었다 |
| `attract-NESiCAxLive.cfg` | **제거** | AM은 `attract.cfg`만 읽는다 |
| `emulators/Taito Type X Samurai Shodown - Edge of Destiny.cfg`<br>`emulators/Taito Type X Spica Adventure.cfg` | **제거** | 게임 폴더도 `.7z`도 없고 어떤 romlist도 참조 안 함. `validate.ps1`의 남은 WARN 2건이 이것이었다 |
| `plugins/` (벤더 16 + 저장소 추가 2) | **보존** | AM 설정 메뉴에서 켜면 바로 쓸 수 있는 정상 자산 |
| `layouts/Mega-Display` | **보존** | 미참조지만 AM 레이아웃 메뉴에서 선택 가능한 예비 테마 |
| `intro/intro_16x9.mp4` | **보존** | `intro.nut`의 `video_16x9` 설정으로 쓸 수 있다 |
| `loader/` | **보존** | AM 벤더 원본 |

제거분은 **`archive/unused-assets-2026-09-03` 태그**에 보존했다.
되살리려면 `git checkout archive/unused-assets-2026-09-03 -- <경로>`.

결과: 에뮬레이터 정의 37 → 35, **`validate.ps1` FAIL 0 / WARN 0** (활성 게임 1,079개 변화 없음).

### - [x] 18. git 위생 — **처리 완료**

네 가지를 전부 처리했다. 상세는 각 커밋 메시지 참고.

| | 내용 | 조치 |
|---|---|---|
| (a) | `.gitignore` 가 `core.ignorecase` 에만 의존 | 실제 폴더명(`Mame`)으로 교정. `core.ignorecase=false` 로 17경로 차단 확인 |
| (b) | `.gitattributes` 부재 | 현재 저장 상태를 그대로 못 박아 신설. **재정규화 0건** |
| (c) | 런타임 상태 파일 추적 | 추적은 유지하고 `tools/reset-runtime.ps1` 로 정리 가능하게 함 |
| (d) | 무시 목록에 빠진 산출물 | `mame64*` 패턴으로 확장. `stats/` 등은 reset-runtime 이 삭제 |

아래는 처리 당시의 원래 기록이다.

---


**(a) `.gitignore`가 대소문자 무시 설정에 의존**
규칙은 `emulators/MAME/roms/`처럼 적혀 있는데 실제 폴더는 `emulators/Mame`다.
지금 동작하는 이유는 `core.ignorecase=true`(Windows 기본) 하나뿐이다.
**Linux/macOS에서 클론하면 무시 규칙이 전부 무효가 되어 롬·BIOS·아트웍이 전부 추적 대상이 된다.**
→ 실제 폴더명(`emulators/Mame/...`)에 맞춰 교정.

**(b) `.gitattributes`가 없고 `core.autocrlf=true`**
줄바꿈 정규화 규칙이 저장소가 아니라 각 PC의 git 설정에 달려 있다.
설정이 다른 PC에서 작업하면 **한 줄만 고쳐도 파일 전체가 diff로 뜬다.**
→ `* text=auto`, `*.nut text`, `*.cfg text`, `*.txt text`, 바이너리 확장자 `binary` 지정.

**(c) 런타임 상태 파일이 추적되고 있음**
`attract.am`(마지막 선택 상태)은 프론트엔드를 띄울 때마다 내용이 바뀔 수 있다.
`emulators/Mame/cfg/*.cfg`(게임별 입력 설정)도 게임을 실행할 때마다 갱신된다.

2026-09-03 재검수에서 **RetroArch 쪽도 같은 문제**임을 확인했다. 아래 5개가 추적 중이고,
게임을 한 번 실행하는 것만으로 diff가 생긴다(실제로 이번 검증 중 `content_history.lpl`,
`content_image_history.lpl`이 변경되어 되돌려야 했다).

```
emulators/RetroArch/content_history.lpl        emulators/RetroArch/content_music_history.lpl
emulators/RetroArch/content_image_history.lpl  emulators/RetroArch/content_video_history.lpl
emulators/RetroArch/retroarch.cfg              ← 이건 설정이라 추적이 맞다
```

**조치 — 추적은 유지하고 초기화 스크립트를 만들었다.**

런타임 파일을 추적하는 것은 실수가 아니라 의도다. 입력 설정이 꼬이거나 에뮬레이터가
이상해졌을 때 "커밋된 정상 상태"로 되돌리기 위해서다. 그래서 `.gitignore` 로 빼는 대신
`tools/reset-runtime.ps1` 로 한 번에 정리할 수 있게 했다([`../CLAUDE.md`](../CLAUDE.md) 7.3절).

설정 / 세이브 / 산출물 세 갈래로 나눠 다루는 것이 핵심이다.
세이브(메모리카드·NVRAM·스테이트)를 설정과 같이 되돌리면 게임 진행이 날아가므로
`-Saves` 를 따로 붙여야만 손대도록 했다. 인자 없이 실행하면 목록만 보여준다.

**(d) 무시 목록에 빠진 산출물**
`stats/`(플레이 통계, `track_usage yes`), `emulators/Mame/data/history.db`,
`emulators/Mame/hiscore/`, `emulators/Mame/mame64 - 복사본*`(8번) 등이
쌓이면 `git status`가 지저분해진다.

### - [x] 19. `RetroArch FinalBurn Neo.cfg`의 `%file` · `-H` 인자 — **처리 완료**

```
변경 전(develop) :  args  %file -H -L cores/fbneo_libretro.dll "[romfilename]"
변경 전(bartop)  :  args  %file    -L cores/fbneo_libretro.dll "[romfilename]"
변경 후          :  args           -L cores/fbneo_libretro.dll "[romfilename]"
```

둘 다 **RetroArch 1.10.3 실기 A/B로 원인을 확인**했다(`retroarch --help`, `--verbose --log-file`,
`Get-NetTCPConnection`, RetroArch 내장 스크린샷).

**`-H` = 넷플레이 호스트 모드.** RetroArch의 정식 옵션이다.

```
-H, --host          Host netplay as user 1.
-C, --connect=HOST  Connect to netplay server as user 2.
    --port=PORT     Port used to netplay. Default is 55435.
```

게임을 실행할 때마다 넷플레이 서버가 뜬다. 실측으로 확인한 것:

| | `-H` 있음 | `-H` 없음 |
|---|---|---|
| TCP LISTEN | `:::55435` | 없음 |
| UDP 바인드 | `0.0.0.0:55435` | 없음 |
| 로그 | `[Netplay] 1 플레이어로 입장했습니다`<br>`[Netplay] 넷플레이 포트 매핑 성공: <공인IP>:55435` | 없음 |

**UPnP로 공유기에 포트포워딩까지 걸어 공인 IP에 55435를 연다.** 오락실 캐비닛에는 불필요하고,
`-C`가 "user 2로 접속"인 데서 보듯 2P 슬롯을 원격 클라이언트용으로 잡는 구조라
2인용 로컬 플레이와도 상충한다. `bartop`에서 2년 전 `a089eb42`로 제거한 이유로 보인다.

**`%file` = 첫 번째 위치 인자로 잡혀 콘텐츠 경로가 된다.** RetroArch 사용법은
`retroarch [OPTIONS]... [FILE]`이고 위치 인자 중 **첫 번째**를 콘텐츠로 쓴다.
`%file`이 앞에 있으면 뒤의 실제 롬 경로가 무시된다 — 즉 **게임이 아예 로드되지 않았다.**

| `args` | FBNeo 롬 탐색 로그 | 화면 |
|---|---|---|
| `%file -L core rom` | 없음 (0줄) | `FBNeo Error: Romset is unknown.` |
| `-L core rom` | `Patched romset found at …\patched\dino` 외 45줄 | 정상 구동 |

`%file`은 AM의 치환 토큰도 RetroArch의 옵션도 아니다. 시행착오의 잔재로 보인다.

**검증** — 수정 후 AM에서 NESiCAxLive → `leaguemn`(닌자 베이스볼 배트맨) 실행,
ROM 15개 로드 + 부모 롬셋 `nbbatman` 탐색 성공, GL/XAudio2/입력 초기화 완료, 에러 0건,
RetroArch 내장 스크린샷(F8)으로 한글 패치가 적용된 화면 확인. LISTEN 포트 없음.

> 참고: RetroArch 창은 GL 풀스크린이라 GDI `CopyFromScreen`으로는 검은 화면만 잡힌다.
> 실제 화면 확인은 **RetroArch 내장 스크린샷(F8)** 을 써야 한다.
> 검증 도중 `patched/avsp.zip`이 FBNeo 롬셋 불일치 에러를 냈으나, `avsp`는 `Capcom.txt`에서
> **MAME**로 실행되는 항목이라 FBNeo 경로와 무관하다. 문제 아님.

### - [x] 20. 정지한 원격 브랜치 정리 — **처리 완료**

원격 브랜치 **22개 중 15개가 2022년 이후 갱신이 없었다.** 전부 정리해 **7개**만 남겼다.

```
남은 브랜치   main  develop  bartop  desktop
              desktop-ASUS-TUF  desktop-MSI-Sword  desktop-MSI-Sword-DriveWheel
```

**병합 완료 — 내용이 이미 `main`에 있어 그냥 삭제 (6개)**
`NESiCAxLive`, `develop-layouts`, `malio`, `mame`, `retroarch`, `update`

**미병합 — `archive/<이름>` 태그로 보존 후 삭제 (9개)**

| 브랜치 | 고유 커밋 | 비고 |
|---|---|---|
| `bartop-NESiCAxLive` | 66 | NESiCAxLive 전용 바탑 구성 |
| `desktop-keyboard-git` | 14 | 키보드 조작 데스크톱 |
| `desktop-keyboard` | 11 | 〃 |
| `develop-prev` | 2 | 이전 develop |
| `fbneo` | 2 | |
| `update-failed` | 2 | 실패한 시도의 기록 |
| `Compact` | 1 | 50GB 축소판 (디렉터리 구조가 다름 — E6 참고) |
| `mame-failed` | 1 | 실패한 시도의 기록 |
| `retroarch-update` | 1 | 2024-07, 유일하게 2022년이 아니었다 |

**안전 절차** — 순서가 중요하다.

1. 미병합 9개에 `archive/*` 태그 생성 (고유 커밋 목록을 태그 메시지에 기록)
2. **태그를 먼저 push** — 이걸 안 하면 브랜치 삭제 순간 원격에서 커밋이 도달 불가가 된다
3. 삭제 대상 15개가 *전부* "main 에 포함" 또는 "archive 태그 = 동일 커밋"인지 기계적으로 확인 (15/15)
4. 그다음 브랜치 삭제 → `git fetch --prune`

**되살리기**

```bash
git tag -l 'archive/*'                  # 아카이브 목록
git tag -n20 archive/Compact            # 그 브랜치가 무엇이었는지 (고유 커밋 포함)
git branch Compact archive/Compact      # 되살리기
```

> `Compact` · `desktop-keyboard` · `desktop-keyboard-git` 는 [`../README.md`](../README.md)의
> 장비 목록에 있던 브랜치다. 지웠지만 태그로 온전히 남아 있으니 필요하면 위 명령으로 복구한다.

S1·S2의 히스토리 재작성 대상이 **22개 → 7개**로 줄어 작업량이 크게 준다.
---


## S5 — 시각 자산 재스크리닝 (2026-09-03)

> 텍스트 설정만이 아니라 **화면에 실제로 뜨는 그림·영상**까지 훑어서 나온 항목들이다.
> 대부분 오류를 내지 않고 조용히 빈 자리로만 나타나던 것이라 로그로는 잡히지 않았다.

### - [x] 21. `tools/reset-runtime.ps1`이 git 추적 중인 파일을 지웠다 — **처리 완료**

`-Clean` 이 `emulators/Mame/cheat/output.{json,xml}` 을 산출물로 보고 지웠다. 추적 중인 파일이라
실행하면 그대로 삭제 diff 가 났다. 삭제 후보를 `git ls-files` 로 걸러 추적 중이면 건너뛰게 고쳤다.

### - [x] 22. 디스플레이 마스코트 3종 누락 — **처리 완료 (21/21)**

`NEVATO` · `Console Box` 레이아웃은 `layouts/<레이아웃>/character/<디스플레이>.png` 를 화면 우측에
띄운다. `select_character = "By Display"` 라 emulator cfg 의 `artwork character` 와는 무관하다.
TeknoParrot · Taito Type X · MAME Adult 세 개가 없어 그 자리가 빈 채로 보였다.
저장소 안의 flyer 를 480×760 으로 채움-크롭해 채웠고, **`validate.ps1`에 누락 검사를 추가**했다.

### - [x] 23. PSP 박스 이미지가 17건 전부 안 떴다 — **처리 완료**

`Sony PlayStation Portable.cfg` 의 `artwork cartridge` 가 `menu-art\...\cartridge` 만 봤는데
그 폴더가 비어 있었다. 실제 박스 이미지는 `flyer` 에 17개 전부 있었다.
`cartridge;flyer` 폴백을 추가해 17/17 표시된다.

### - [x] 24. NESiCAxLive 4건이 flyer 를 못 찾았다 — **처리 완료**

`ddtodj` · `knightsj` · `kodj` · `punisherj`. AM 은 `Name → CloneOf → AltRomname → AltTitle`
순으로 아트웍을 찾는데 `CloneOf` 가 비어 있었다. 부모(`ddtod`·`knights`·`kod`·`punisher`)를
채워 부모 flyer 를 물려받게 했다. 12번 항목과 같은 원인이다.

### - [x] 25. 시계 스크립트의 죽은 `am.png` 참조 — **처리 완료**

`Mega-Display(-Advanced)/scripts/clock.nut` 이 존재하지 않는 `am.png` 로 이미지 객체를 만들었다.
좌표도 시계(`flx*0.865~0.915`)와 무관한 화면 좌중앙(`flx*0.513`)이었고, 무엇보다 시계가
**24시간 표기**라 AM/PM 표시 자체가 성립하지 않았다. 지우고 이유를 주석으로 남겼다.
구버전 `Mega-Display` 에는 3번 항목에서 고친 `clock.msg` 예외도 그대로 남아 있어 함께 정리했다.

### - [x] 26. `Taito Type X The BishiBashi.cfg` 의 `rompath` 가 경로를 두 번 겹쳤다 — **처리 완료**

`rompath` 는 **executable 디렉터리 기준**이다. `executable` 이 이미
`emulators\Taito Type X\The BishiBashi\` 안에 있는데 `rompath` 도
`emulators\Taito Type X\` 라서 그 둘이 이어 붙었다. `.` 로 고쳤다.

고치고 나니 이번엔 롬 존재 검사가 FAIL 을 냈다 — 이쪽이 진짜 원인이었다.
이 정의는 `args` 가 비어 있는 **런처형**(executable 이 게임을 고정)이라 AM 이 롬 경로를 넘기지
않는다. `args` 에 치환 토큰이 없으면 롬 존재를 따지지 않도록 `validate.ps1` 을 고쳤다.

### - [~] 27. ~~시작 화면 상단의 marquee 와 `[Overview]` 가 좌표가 같다~~ — **오진, 재분류**

`Mega-Display Advanced` 에서 두 객체가 정확히 같은 자리(`flx*0.19, fly*0.012`)에 있다.
겹침 사고로 봤으나 실측해 보니 **서로 배타적인 레이어**였다.

| | marquee (`snap.nut`) | `[Overview]` (`arcade_name.nut`) |
|---|---|---|
| 디스플레이 21개 | `menu-art\marquee` 에 이미지 **0/21** → 안 그려짐 | `scraper\@\overview\*.txt` **21개** → 이게 보임 |
| 종료(exit) 항목 | `menu-art\marquee\exit.png` → 이게 보임 | `scraper\@exit\overview` 비어 있음 → 빈 문자열 |

`layout.nut` 의 `do_nut` 순서가 `snap`(26행) → `arcade_name`(32행) 이라 텍스트가 항상 위에 온다.
**둘 중 하나를 지우거나 옮기면 안 된다.** 전제가 깨지는 경우(디스플레이용 marquee 를 넣거나
`@exit` 에 overview 를 쓰는 것)만 조심하면 되고, 그 내용을 `snap.nut` 주석에 남겼다.
---

## S6 — 3차 재점검 (2026-09-04) · PR #27~#30 재검토

> 머지 4건(`b03d2e96` `c6a51d0e` `86af84f0` `ed963b32`)의 작업 커밋 20개를 다시 열어 봤다.
> S5 의 "처리 완료" 7건 중 **22번·25번은 완료가 아니었다.** 점검 절차는 `/arcade-audit` 스킬
> (`.claude/skills/arcade-audit/`)로 고정했고, 결과 아티팩트는 「AttractMode 재점검」에 갱신했다.

### - [x] 28. 마스코트 2종이 컷아웃이 아니라 불투명 포스터 — Taito Type X · MAME Adult — **처리 완료**

**1차 조치 (2026-09-04)**: 두 장을 투명 480×760 캔버스에 게임 로고를 얹은 임시본으로 교체했다.

**2차 조치 (2026-09-04, 웹 소재로 교체)**: 웹에서 원화를 받아 배경을 제거한 캐릭터 컷아웃으로 갈아 끼웠다.

| 디스플레이 | 소재 | 출처 | 처리 |
|---|---|---|---|
| Taito Type X | 하오마루 전신 공식 일러스트 (사무라이 스피리츠 섬, 키타 센리) | `fightersgeneration.com/np7/char/sen/haoh-sen.jpg` (775×1000, 흰 배경) | 흰 배경 플러드필 제거 → 464×624 |
| MAME Adult | 갈스 패닉 S2 전단 앞면의 로고+캐릭터 5명 | `flyers.arcade-museum.com/videogame-flyers/1/gals-panic-s2-01468-01.jpg` (850×858) | 연분홍 그라데이션을 "밝고 분홍 계열" 규칙으로 제거, KANEKO 로고·말풍선·문구 사각형 지움 → 464×506 |

투명 픽셀 67.6% / 56.1%, 가장자리 투명 100% (`audit.ps1 -Section mascot` 실측). 도구는 `.claude/skills/arcade-audit/scripts/cutout.ps1`(C# 가속 플러드필 컷아웃)과
`img-to-png.ps1`(GDI+ 가 못 여는 CMYK/프로그레시브 JPEG 를 WIC 로 변환)로 스킬에 동봉했다.
Spriters Resource · Fandom · pngwing 류는 Cloudflare 가 curl/WebFetch 를 막아 못 썼고, fightersgeneration 과 Arcade Flyer Archive 는 열려 있다.
`validate.ps1` 에 `Test-MascotSpec` 을 추가해 크기와 **알파 비율(투명 20% 미만 = 포스터)** 을 검사한다 — 옛 포스터는 WARN 으로 잡히고 새 파일은 통과한다.
이 검사가 `sony playstation portable.png` 가 **380×760** 인 것도 잡아냈다(21종 중 유일한 규격 외 크기). 리샘플링 없이 좌우 50px 씩 투명 패딩해 480×760 으로 맞췄다.

22번에서 "flyer 를 480×760 으로 채움-크롭"해 넣은 3장 중 2장이 규격 위반이다.
기존 19종은 전부 **투명 배경 위 캐릭터 컷아웃**인데, 이 둘은 알파를 4px 간격으로 실측하면 **투명 0.0%**
(나머지 44~80%, 가장자리 투명 83~100%). 열어 보면 사무라이 스피리츠 포스터와 파칭코 전단이 잘려 있고
우측 `TAITO Type X` 로고와 하단 퍼블리셔 띠가 중간에서 끊긴다. 크기도 975KB·756KB 로 2~4배.
`character_alpha 255` 라 리스트 박스 위에 직사각형 포스터가 통째로 얹힌다.
**개수(21/21)로 완료 판정한 것이 원인** — `validate.ps1` 의 마스코트 검사도 존재만 본다.

### - [x] 29. `layouts/Mega-Display/layout.nut:33` 이 없는 `scripts/fade.nut` 을 부른다 — **처리 완료**

**조치 (2026-09-04)**: `do_nut("scripts/fade.nut")` 호출을 지우고 이유를 주석으로 남겼다. `FadeArt` 는 어디서도 안 쓰므로
파일을 복사할 이유가 없다. 이 수정으로 `sidebar.nut`·`wheel2.nut` 이 **처음으로 실행된다** — S2-3 의 교훈대로
두 스크립트를 먼저 읽어 참조 자산(`images/*`)이 이 레이아웃 폴더에 전부 있는지 확인했다(Advanced 와 파일 동일).

```
32  fe.do_nut("scripts/whitebar.nut");
33  fe.do_nut("scripts/fade.nut");      ← Mega-Display/scripts/ 에 없다 (Advanced 에만 있음)
34  fe.do_nut("scripts/sidebar.nut");   ← 예외 이후, 실행 안 됨
35  fe.do_nut("scripts/wheel2.nut");    ← 예외 이후, 실행 안 됨
```

레이아웃 메뉴에서 `Mega-Display` 를 고르면 사이드바·휠이 없는 화면이 나온다. 5.5절이 "예비 테마"로
지키고 있는 레이아웃이 실제로는 깨져 있었다. 25번 커밋(`5edb9d7e`)이 바로 이 레이아웃의 `clock.nut` 을
"메뉴에서 선택 가능하니 같이 고쳤다"며 손댔는데, 같은 폴더 `layout.nut` 의 이 줄은 보지 않았다.
`fade.nut` 이 정의하는 `FadeArt` 클래스는 두 레이아웃 어디에서도 쓰이지 않는다.

### - [x] 30. `layout_vewlix_white.nut:281` 의 배경 `background/white.png` 가 없다 — **처리 완료**

**조치 (2026-09-04)**: `background/gray.png`(2048×1536, 제조사 로고 패턴)를 흰색 쪽으로 55% 블렌드해
`white.png` 를 만들었다. 다른 색 배경과 같은 텍스처를 유지하면서 `cabinet/vewlix_white.png` 에 맞는 밝기다.
NEVATO 에만 넣었다 — Console Box 의 .nut 은 white 를 참조하지 않는다.

vewlix 변형은 죽은 파일이 아니다 — AM 은 `layout*.nut` 을 **L 키(`toggle_layout`)로 순환**하고,
`attract.am` 에 `layout_vewlix_black`(MAME) · `_blue`(Capcom) · `_red`(SNK)가 실제 사용 중으로 기록돼 있다.
white 변형으로 넘기면 배경이 조용히 검게 빈다. `cabinet/vewlix_white.png` 는 있다.

### - [x] 31. CLAUDE.md 가 이미 고친 것을 "아직 안 고쳤다"고 말한다 — **처리 완료**

**조치 (2026-09-04)**: §6 두 항목을 "해결됨 + 아직 남은 대소문자 의존(아트웍·레이아웃 자산)"으로 고쳐 썼고,
§3 트리의 인트로 파일명을 `intro_4x3.mp4` 로 바로잡으면서 9:16·3:4 영상 부재(세로 모니터에서 인트로 생략)를 같이 적었다.

| 서술 | 실제 | 어긋난 커밋 |
|---|---|---|
| §6 "`.gitignore`는 `emulators/MAME/...`로 적혀 있지만 실제 폴더는 `emulators/Mame`" | 전부 `emulators/Mame/` 로 고쳐짐, 대소문자 불일치 0건 | `c6a51d0e` |
| §6 "`.gitattributes`가 없다" | 58줄 존재 | `c6a51d0e` |
| §3 트리 "`intro.mp4`, `intro_16x9.mp4`" | 실제 파일은 `intro.mp4` · `intro_4x3.mp4` | (원래부터) |

"구조·규칙이 바뀌면 같은 커밋에서 이 문서를 갱신"이라는 CLAUDE.md 자신의 규칙을 PR #28 이 어겼다.

### - [x] 32. `reset-runtime.ps1` 은 에뮬레이터가 **지운** 추적 파일을 되돌리지 못한다 — **처리 완료**

**조치 (2026-09-04)**: `Get-Changed` 의 `Test-Path` 필터를 없애고 pathspec 을 그대로 `git status --porcelain --` 에 넘긴다
(없는 경로는 git 이 무해하게 무시한다). 삭제된 추적 파일이 ` D` 로 잡혀 `git checkout --` 으로 복원된다.
`emulators/Mame/cheat/output.{json,xml}` 은 `git rm --cached` 로 추적을 풀고 `.gitignore` 에 넣었다. `stats/` 도 같이 무시 목록에 올렸다.

```powershell
$existing = @($Paths | Where-Object { Test-Path -LiteralPath $_ })   # 작업트리에 없는 경로를 버린다
$out = & git status --porcelain -- $existing
```

추적 중인 파일이 삭제된 상태(porcelain ` D`)는 `Test-Path` 가 실패해 목록에서 빠진다.
"커밋된 정상 상태로 되돌린다"는 목적에서 가장 흔한 사고(에뮬레이터가 설정 파일을 지움)가 제외된다.
함께: `emulators/Mame/cheat/output.{json,xml}` 은 MAME 런타임 산출물인데 **추적 중**이라
21번의 가드가 매번 "건너뜀"을 찍는다. 추적 해제 + `.gitignore` 가 근본 해결이다.

### - [x] 33. emulator cfg 의 artwork 경로 후행 공백 5줄 — `validate.ps1` 은 못 잡는다 — **처리 완료**

**조치 (2026-09-04)**: 35개 cfg 전체에서 값 끝 공백을 지우고(5줄), 끝 개행이 없던 34개 파일에 개행을 넣었다.
`git diff -w` 기준 내용 변화 0. `validate.ps1` 에 Trim 전 원문으로 `artwork|rompath|executable|args|romext` 줄의 후행 공백을 WARN 으로 잡는 검사를 추가했다(시험: 공백을 붙이면 잡히고 지우면 통과).

`Sony PlayStation Portable.cfg:12`(공백 2), `Sony PlayStation 2 GZ.cfg:10,12,13`, `Sony PlayStation 2 ISO.cfg:13`.
`validate.ps1` 은 값을 `.Trim()` 한 뒤 `Test-Path` 하므로 영원히 통과한다. Windows 도 관대해 지금은 동작하지만
23번 커밋(`a57d0e8c`)이 PSP cfg 를 열어 고치면서도 남겨 둔 것이고, 형제 cfg(GZ↔ISO) 사이에서도 다르다.
34개 cfg 의 "끝 개행 없음"도 같은 정리 대상.

### - [x] 34. 레이아웃 폴더의 미연결 자산 — 17번 기준에 걸리는 것이 다섯 부류 남았다 — **처리 완료**

**조치 (2026-09-04)**: 17번과 같은 방식 — 삭제 직전 커밋에 `archive/unused-assets-2026-09-04` 태그를 달고 다섯 부류를 전부 지웠다.
되살리려면 `git checkout archive/unused-assets-2026-09-04 -- <경로>`. `assets/shaders/bloom_shader.frag` 는 NXL HD 가 실제로 쓰므로 남겼다.
삭제 후 `validate.ps1` FAIL 0/WARN 0, `audit.ps1 -Section layout,dispimg,fonts` 에서 새 누락 참조 0. CLAUDE.md 5.5 에 목록을 적었다.

| 부류 | 실체 | 왜 안 쓰이나 |
|---|---|---|
| 마스코트 복사본 | `character/{capcom,mame,snk neo geo,zinc,sony playstation} (2)·(3).png` × 2 레이아웃 = 12개, `Console Box/system/nintendo wii u (2).png` | 파일명이 디스플레이 이름과 안 맞아 `[DisplayName]` 으로 도달 불가 |
| 배경 변형 | `background/{1280,1920,2xScale}/` × 2 레이아웃 (약 60MB) | 어떤 .nut 도 참조하지 않음. **2xScale 은 원본과 바이트 동일**(복사본) |
| 폰트 | `fonts/NXL HD/{etc,download}/` 30여 개 | `font_path = fonts;fonts/NXL HD` — 하위 폴더는 탐색 안 함 |
| 스크립트 | `NXL HD/carrier.nut`, `NXL HD/assets/shaders/layout.nut` | 어느 `do_nut` 도 안 부름 / 3단계 깊이라 AM 메뉴에 안 뜸. 후자는 참조 이미지 22개·폰트 `grobold` 가 전부 없는 데모 잔재 |
| 원본·백업 | `logo/bak`, `Buttons/bak`, `UIelements/bak`, `*.psd` 20개, `Thumbs.db` | 작업 파일. 17번 정리 때 그대로 남음 |

### - [x] 35. NEVATO ↔ Console Box 가 같은 파일 63벌을 따로 들고 있다 — **처리 완료 (드리프트 감시로)**

**조치 (2026-09-04)**: 한쪽이 다른 쪽을 `../NEVATO/...` 로 참조하게 바꾸는 것이 근본 해결이지만 13개 `.nut` 을 고치고
캐비닛에서 실행 확인이 필요해 이번엔 하지 않았다. 대신 **어긋남 자체를 잡는다** — `audit.ps1 -Section dupes` 가
레이아웃 공용 정적 자산 `background/ listbox/ key/ monitor/` 를 이름 기준으로 대조해 해시가 다르거나 한쪽에만 있는 파일을 `ISSUE` 로 낸다.
`character/ system/ wheel/` 은 대조하지 않는다 — 디스플레이는 레이아웃을 하나만 쓰므로(아케이드→NEVATO, 콘솔→Console Box)
디스플레이별 파일은 두 레이아웃에서 같을 필요가 없다(실제로 `wheel/` 7개가 다르지만 각자 자기 디스플레이에서만 쓰인다).
실행해 보니 30번의 `white.png` 가 NEVATO 에만 있었다 — Console Box 에도 넣어 공용 폴더를 다시 동일하게 맞췄다.
CLAUDE.md 5.4 에 "두 레이아웃의 공용 폴더는 항상 같은 내용을 유지한다" 규칙을 적었다.

200KB 이상 추적 미디어를 MD5 로 묶으면 **63그룹 · 125MB** 가 바이트 동일하다(background/*.png 각 4벌,
background/*.mp4, listbox/*.png, character/*.png). 문제는 용량이 아니라 **어긋남** — 이번 마스코트 3장도
양쪽에 따로 넣었고, `system/nintendo wii u (2).png` 는 Console Box 에만 있다.

### - [x] 36. 폰트 함정 두 곳 — 지금은 안전, 한 줄만 바꾸면 두부 — **처리 완료 (문서화 + 감시)**

**조치 (2026-09-04)**: 지금 화면은 정상이라 데이터·폰트는 건드리지 않았다(`뱀프½`는 원제 *Vamp ½* 표기).
CLAUDE.md 5.4 의 폰트 함정 목록에 두 경우를 적었고, `audit.ps1 -Section glyph` 가 overview·romlist Title·kr.msg·
NXL HD 한글 리터럴을 실제 그리는 폰트와 대조해 빠진 글리프를 `ISSUE` 로 낸다.

표시 텍스트 전체 ↔ 그리는 폰트의 글리프를 대조했다. overview 21개 · kr.msg · NXL HD 한글 리터럴 · romlist Title ↔ `font.ttf` 전부 OK.
- `MAME.txt:245` `뱀프½` 의 ½(U+00BD)이 `default_font` **SUIT-Regular 에 없다.** `select_font` 를 SUIT 로 바꾸거나 폰트 폴백이 나면 깨진다.
- NEVATO 의 LCD 텍스트(`digital-7`, 한글 없음)가 `[FilterName]` 을 표시한다 — 필터명을 한글로 바꾸는 순간 두부.

---

## S7 — 4차 재점검 (2026-09-04) · 3차 처리분 15커밋 재검토

> 3차가 등록한 28~36번을 처리한 커밋 11개와 그 뒤의 스킬 보정·문서·마스코트 교체 4개(`c92014b6`‥`857f2f6c`)를 다시 열어 봤다.
> **9건의 "처리 완료"는 전부 저장소 상태로 확인됐다.** 대신 실행 확인이 한 건도 없었고, 새 마스코트에 다른 종류의 규격 위반이 있었다.
> 이번에 손으로 찾은 것은 `audit.ps1` 에 검사로 넣었다(직선 컷 · `layout.nut` 철자 · 옵션 자리표시자 · 정책상 중복 쌍).

### - [x] 37. MAME Adult 마스코트 — 컷아웃이지만 허리 아래가 **직선으로 잘려** 있다 — **처리 완료**

**조치 (2026-09-04)**: 단일 인물 소재를 못 구해(아래) 현재 컷아웃의 하단 90px 를 `fade-edge.ps1 -Bottom 90` 으로 알파 페이드시켰다
(smoothstep 램프, 페이드 시작선이 보이지 않는다). 재측정: 직선 컷 **26% → 6%**, 투명 56.1 → 56.9%, 가장자리 100%. NEVATO·Console Box 양쪽 동일.
`audit.ps1 -Section mascot` 의 컷 지표는 알파 가중치로 재서 페이드된 변은 통과하고 직선 컷만 잡는다.

28번 2차 조치의 갈스 패닉 S2 그룹샷(로고 + 5명)은 피사체가 y=632 에서 수평선으로 끝난다.
20종 전부에서 "최외곽 불투명 행이 피사체 폭의 몇 %를 차지하는지"를 재보면 자연스러운 실루엣(발끝·머리끝)은 0~11% 인데 이것은 **26%** 다.
나머지 19종이 전부 단일 캐릭터 전신 컷아웃이라 이것만 "포스터에서 오려낸 조각"으로 읽히고, NEVATO 가 캔버스를 y = 0.156·화면높이에 그리므로 절단선이 화면 중간에 뜬다.
아케이드 뮤지엄의 갈스 패닉 전단 7장(무인·II 2종·4·S 앞뒤·S2)을 전부 받아 봤지만 단일 인물은 문구·말풍선이 겹치거나 사진 배경이라 깨끗한 컷아웃이 안 나온다.

### - [x] 38. Sammy Atomiswave 마스코트 — 무릎에서 잘려 캔버스 바닥에 닿아 있다 (2022년부터) — **처리 완료**

**조치 (2026-09-04)**: 2D 원화를 유지하고 `fade-edge.ps1 -Bottom 110 -Right 28` 로 무릎 아래 110px 와 오른쪽 변 28px 를 알파 페이드시켰다.
재측정: 직선 컷 **72% → 6%**, 투명 51.5 → 53.2%, 가장자리 83.2 → 99.6%(19종 최저였던 값이 평균 수준으로). NEVATO·Console Box 양쪽 동일.

같은 잣대로 **72%** (y=756, 캔버스 끝 4px 위). 오른팔도 오른쪽 변에서 10% 잘린다. 가장자리 투명율이 19종 중 최저(83.2%)였던 이유다.
`layout.nut:762` 가 캔버스를 `0.15625*flh` 에 480×760 고정 크기로 그리므로 1080p 에서 캔버스 바닥은 화면 바닥보다 151px 위 — 절단선이 보일 수 있다.
fightersgeneration 의 켄시로 원화 10장 중 전신은 저해상도 3D 렌더(274×600) 하나뿐이라 현재의 2D 원화를 유지하는 편이 낫다.

### - [x] 39. 3차 처리분 28·29·30 이 캐비닛에서 실행 확인되지 않았다 — **처리 완료 (이 PC에서 실행, 오류 0)**

**조치 (2026-09-04)**: `tools/smoke-run.ps1` 을 만들어 실행했다 — `%TEMP%` 에 저장소 폴더를 정션으로 연결한 격리 설정 디렉터리를 만들고
`attract.cfg`·`attract.am` 사본만 고쳐 `attract.exe --config` 로 지정 디스플레이·레이아웃을 20초 띄운 뒤 로그를 본다(CLAUDE.md 7.4).

| 실행 | 로드된 레이아웃 | 결과 |
|---|---|---|
| Taito Type X (NEVATO, 28번 마스코트) | `NEVATO/layout.nut` | 오류 0 |
| Taito Type X + `layout_vewlix_white` (30번 배경) | `NEVATO/layout_vewlix_white.nut` | 오류 0 |
| Taito Type X 의 layout 을 Mega-Display 로 (29번) | `Mega-Display/layout.nut` — sidebar·wheel2 처음 실행 | 오류 0 |
| `-All`: MAME · Sony PlayStation · NESiCAxLive · Mega-Display | NEVATO · Console Box · NXL HD · Mega-Display | 4/4 오류 0 |

한계: 이 PC 는 5:4 모니터라 NEVATO 의 `5x4` 분기가 돌았다(`using settings[5x4]…`). 16:9 캐비닛 분기는 bartop 에서 한 번 더 봐야 한다.
처음 시도한 창 모드는 480×320(종횡비 1.5)이 되어 NEVATO 가 `res_x` 예외를 냈다 — 스크립트는 전체화면으로만 돈다.

`last_run.log`(16:34) 에는 NESiCAxLive 와 디스플레이 메뉴만 세 번 로드된 기록뿐이다. NEVATO(마스코트 28 · white 배경 30)도 Mega-Display(29)도 한 번도 열리지 않았다.
29번은 처음 실행되는 코드를 살리는 수정이라(S2-3 전례) 실행해야 안다.

### - [x] 40. `layouts/NXL HD/Layout.nut` 이 대문자 L 로 git 에 추적돼 있다 — **처리 완료 (`layout.nut` 으로 개명)**

**조치 (2026-09-04)**: Windows 는 대소문자만 다른 이름 변경을 한 번에 못 하므로 `git mv` 두 단계(`tmp-layout.nut` 경유)로 `layout.nut` 이 됐다.
`audit.ps1` 의 glyph 섹션이 하드코딩하던 경로도 소문자로 맞췄고, 이 문서의 다른 언급 3곳도 새 이름으로 고쳤다.
`audit.ps1 -Section case` 가 앞으로 `layouts/<name>/layout.nut` 철자를 감시한다.

19개 `layout*.nut` 중 유일. AM 은 `layout.nut` 을 글자 그대로 열므로 Windows 에서는 열리고 로그에도 소문자로 찍혀 눈에 안 띈다.
Linux/macOS 클론에서는 NESiCAxLive 디스플레이가 레이아웃 없이 뜬다(CLAUDE.md 6절의 대소문자 의존 목록에 추가할 것).

### - [x] 41. 문서의 낡은 수치·서술 4곳 — **처리 완료**

**조치 (2026-09-04)**: CLAUDE.md §8 을 "브랜치 7개와 `archive/*` 태그 11개"로, §1·§8 용량을 `1.2GB` 로 통일하고 §1 에 실측치(23,554개 · size-pack 1.17GiB)를 적었다.
ISSUES 2번의 수치를 같은 값으로 갱신하고, 머리말의 "로고 임시본"은 S7 등록 커밋에서 이미 지웠다. 개선제안 A 표는 현재 값(WARN 0 · 환경 17)으로 고쳤다.

| 위치 | 서술 | 실제 |
|---|---|---|
| CLAUDE.md §8 | "히스토리 재작성이 … **25개 브랜치** 전부에 영향" | 브랜치 7개 (§2 가 직접 "7개뿐이다") |
| CLAUDE.md §1 · ISSUES 2번 | "약 23,700개 / .git 약 **1.3GB**" vs "**1.2GB** · 23,711개" | 23,554개 · size-pack 1.17GiB. 두 문서가 서로 다르다 |
| ISSUES.md 머리말 | "28번 마스코트 2종은 **로고 임시본**" | `b8426466` 이 28번 본문만 고치고 머리말은 남겼다 |
| ISSUES.md 개선제안 A 표 | "WARN **2건** · 환경 22건" | 현재 WARN 0 · 환경 17 |

31번을 처리한 바로 그 날 "같은 커밋에서 문서를 갱신" 규칙의 누락이 네 곳에서 다시 생겼다.

### - [x] 42. Taito Type X 마스코트(하오마루)의 머리카락·팔 사이 흰 배경이 남아 있다 — **처리 완료**

사용자 지적(2026-09-04). `cutout.ps1` 은 가장자리에서 플러드필하므로 **피사체에 둘러싸인 흰 영역**(머리카락 가닥 사이, 든 팔과 머리 사이, 칼과 소매 사이)에는 닿지 못한다.
확대해 보면 그 자리가 흰 조각으로 남아 배경색이 다른 캐비닛 화면에서 그대로 보인다.

**조치 (2026-09-04)**: `cutout.ps1` 에 `-HoleTol`/`-HoleMin`/`-HoleDark` 를 추가했다. 배경색과 HoleTol(14) 이내인 고립 영역을 찾아,
부드러운 테두리까지 키운 뒤 **그 바깥 둘레의 HoleDark% 이상이 먹선(휘도<110)일 때만** 배경으로 판정한다.
둘레 조건이 없으면 하오마루의 흰 바지 하이라이트까지 뚫린다(실측: 조건 없이 19곳 5,643px 제거 → 바지에 구멍, 20% 조건에서 8곳 2,202px → 머리·팔 사이만).
원본 `fightersgeneration.com/np7/char/sen/haoh-sen.jpg` 을 `-HoleTol 14 -HoleDark 20` 으로 다시 뽑았다. 464×624, 투명 68%.

**2차 조치 (2026-09-04, 사용자 재지적 "머리카락에 아직 흰색")**: 둘레 조건이 머리카락 안쪽 영역(둘레에 살색·회색 하이라이트가 섞임)도 거부하고 있었다.
`-Debug <png>` 를 추가해 후보 영역을 초록(제거)/빨강(거부)으로 겹쳐 보니 빨강이 머리카락 안쪽 5곳과 옷 하이라이트 2곳으로 갈렸다.
`-HoleBox "x,y,w,h"` 를 추가해 **상자 안(머리카락·칼 영역 40,30,430,530)에서는 둘레 조건을 면제**하고 밖(옷)에는 그대로 적용했다.
11곳 4,412px 제거. 마젠타 배경 2배 확대로 머리카락·칼 주변에 흰 조각이 없고 옷 흰색이 보존된 것을 확인.

### - [x] 43. MAME Adult 마스코트를 단일 전신 캐릭터로 교체 — 갈스 패닉 그룹샷 탈락 — **처리 완료**

사용자 지시(2026-09-04): 마스코트는 **전신이 다 나오는 한 명**이 기준이고, 성인용 디스플레이라는 것이 드러나되 지나치게 야하지 않은
"적당히 섹시한"(바니걸 정도까지) 캐릭터로. 37번의 그룹샷 페이드는 절단선만 없앤 것이라 기준 미달.

**조치 (2026-09-04)**: 시라누이 마이 — KOF XIII 공식 일러스트 `fightersgeneration.com/np5/kof13/mai-kof13.jpg` (748×1054, 흰 배경).
`cutout.ps1 -HoleTol 14 -HoleDark 35` 로 뽑아 311×744 on 480×760, 투명 64.3%, 가장자리 100%, 직선 컷 15%(두 발이 같은 줄에 닿는 자연스러운 값).
후보 13장을 시트로 비교했다 — 모리건(Night Warriors 원화)은 수채 스케치풍이라 다른 마스코트의 셀 화풍과 어긋나고, 펠리시아·포켓걸 전단은 화질 또는 구도가 미달.
SNK Neo Geo 마스코트는 이오리라 같은 시리즈 캐릭터가 겹치지 않는다.

---

## 개선 제안

### - [x] A. 무결성 검증 스크립트 — **완료: `tools/validate.ps1`**

```powershell
powershell -ExecutionPolicy Bypass -File tools\validate.ps1
# -Quiet 경고 숨김 / -Root <경로> / 종료 코드 0 = 오류 없음
```

romlist 필드 수·중복·대소문자 충돌·BOM, Emulator/layout/romlist 상호 참조,
executable·rompath·artwork 경로, 활성 항목의 실제 롬 존재, `.tag` 대조,
`.nut` 없는 레이아웃 폴더, 미참조 에뮬레이터 정의를 한 번에 점검한다.

MAME 계열은 `mame.ini`의 rompath가 실제 탐색을 담당한다는 점, CHD가 폴더 단위로 놓인다는 점,
Dreamcast/Wii U가 게임별 하위폴더 구조라는 점을 모두 반영했다.

**출력은 FAIL / WARN / 환경 / 참고 네 단계로 나눈다.**
처음에는 미설치 자산까지 전부 WARN 이라 59건이 상수처럼 깔려 새 경고가 묻혔다.
장비마다 다른 것(`환경`)과 알고도 둔 것(`참고`)을 분리해 **WARN 의 기대값을 0으로** 만들었다.

| 단계 | 현재 (2026-09-04) | 내용 |
|---|---|---|
| FAIL | 0건 | — |
| WARN | **0건** | 처음 2건(미참조 에뮬레이터 정의)은 17번에서 처리 |
| 환경 | 17건 | 아트웍 15 + 롬 2. 이 장비에 없는 자산 |
| 참고 | 1줄 | 비활성 행 34건이 정의 없는 에뮬레이터 16종 참조 |

### - [x] B. 아트웍 버전관리 정책 — **완료: [`ASSETS.md`](ASSETS.md)**

자산을 A(추적) / B(용량상 제외) / C(저작권상 제외) 3등급으로 정리하고 실측치를 붙였다.
`menu-art/` 6.5GB, MAME 아트웍 1.4GB 중 **romlist에 실제 등장하는 것만 추리면 약 495MB**,
휠(wheel)만 추리면 **약 118MB**.

→ **"실사용 휠만 추적"(약 118MB)을 권장하되, 저장소 크기에 직결되므로 실행 전 확인이 필요하다.**
S1의 히스토리 정리를 먼저 끝낸 뒤 진행할 것.

### - [x] C. 클론 후 실행 절차 문서화 — **완료: [`../README.md`](../README.md)**

클론 → 에뮬레이터 코어 → BIOS → 롬/아트웍 배치 → `validate.ps1` 점검 → 실행의 6단계와
시스템별 `rompath` 실제 위치 표, 장비별 브랜치 표, 조작키 표를 정리했다.

### - [x] D. Attract-Mode 2.6.2 → 2.7.0 업그레이드 — **완료**

공식 `attract-v2.7.0-win64.zip`을 받아 **해시 비교로 실제 다른 파일만** 반영했다
(배포본 217개 중 동일 131 / 다름 17 / 저장소에 없음 69).

**반영** — `attract.exe`(38MB), `Changelog.txt`, `Compile.txt`, `language/*`(10개, `Group Clones` 문자열 추가),
`modules/animate.nut`, `emulators/script/mame_init.nut`
**미반영(의도적)** — `menu-art/wheel/exit.png`(로컬 커스텀), `plugins/RocketLauncher/plugin.nut`(저장소가 수정한 것),
배포본 기본 레이아웃 7종·`romlists/mame/*.tag`(이 저장소는 원래 안 씀)

**사전 호환성 검증** (2.6.2/2.7.0 소스 tarball diff — 절차는 [`../CLAUDE.md`](../CLAUDE.md) 5.6절)

| 항목 | 결과 |
|---|---|
| Squirrel API(`fe_vm.cpp`) 증감 | **0** — 커스텀 레이아웃 4종 무수정 동작 |
| emulator/display/filter 설정 키 | 변화 없음 — cfg 37개·display 21개 그대로 파싱 |
| `general` 설정 키 | `group_clones` 추가만, **제거 없음** |
| romlist `#` 비활성 규칙 | 동일 (비활성 545건 유지) |
| `.tag` 즐겨찾기 경로 | 리팩터링만, 동작 동일 |
| 입력맵·`exit_hotkey` | `diff -w` 결과 공백뿐 |
| 폰트 탐색 | 변경분이 전부 `#ifdef USE_FONTCONFIG`(리눅스) 안 → **한글 폰트 대응 영향 없음** |
| DLL 의존성 | 동일 (새 런타임 요구 없음) |

**실기 검증** — 인트로 영상(FFmpeg) 재생, 디스플레이 21개 순회, `NXL HD`/`NEVATO`/`Mega-Display Advanced`
로드, 한글 제목·장르·언어·RSS 문장 정상 출력, 스냅 비디오/휠 아트웍 정상. `last_run.log` 오류 0건,
`validate.ps1` FAIL 0건.

**부작용 2건과 대응** — 상세는 [`../CLAUDE.md`](../CLAUDE.md) 4.5절

1. **`attract.exe`가 GUI → 콘솔 서브시스템으로 바뀜**(upstream이 `attract-console.exe`를 흡수).
   그 결과 `last_run.log`가 더 이상 자동 생성되지 않고, 실행할 때 검은 콘솔 창이 뜬다.
   → `attract.bat`(`--logfile`) 추가 + `attract.cfg`의 `hide_console`를 `no` → `yes`로.
   → 시작프로그램·바탕화면 바로가기 2개도 `attract.bat`을 가리키도록 변경(최소화 실행).
      *(저장소 밖 파일이라 클론한 다른 장비에서는 각자 다시 잡아줘야 한다.)*
2. **플레이 통계 경로가 `stats/<romlist명>/` → `stats/<Emulator명>/` 로 변경**.
   기존 `stats/Capcom/`·`stats/Zinc/` 등은 더 이상 읽히지 않아 플레이 횟수가 0으로 보인다.
   집계용 데이터라 실행에는 영향 없음. 되살리려면 폴더명을 Emulator 이름으로 바꿔야 한다.

---

## 개선 포인트 (문제는 아니지만 하면 좋은 것)

2026-09-03 전체 재검수에서 함께 정리했다. 위의 S1~S4가 "고쳐야 할 것"이라면, 아래는 "하면 나아지는 것"이다.

### E1. 한글패치 롬 48개가 목록에 없다 — 가장 효과가 큰 항목

`emulators/RetroArch/system/fbneo/patched/`에 롬 **58개**가 있는데
`romlists`가 쓰는 건 **10개**뿐이다(ddsomj, ddtodj, dino, ffight, hook, knightsj, kodj, leaguemn, punisherj, wofj).

나머지 48개 중 리전/클론을 빼면 **목록에 아예 없는 게임이 10여 종** 있다.

```
captcomm(캡틴 코만도)  csclub(캡콤 스포츠 클럽)  daimakai(대마계촌)  ghouls(고스트 앤 고블린)
gunbird(건버드)  megaman(록맨)  samuraia  sngkace(전국 에이스)  strider(스트라이더 비룡)
tengai  uccops(언더커버 캅스)
```

→ `romlists/NESiCAxLive.txt`에 21필드 맞춰 추가하면 한글로 즐길 수 있는 게임이 두 배가 된다.
아트웍(`menu-art`)만 챙기면 되고 롬은 이미 있다. **비용 대비 효과가 가장 좋다.**

### E2. `tools/validate.ps1`을 pre-commit 훅으로

지금은 사람이 기억해서 돌려야 한다. `.git/hooks/pre-commit`에서 호출하면
romlist 21필드 위반·BOM·상호 참조 깨짐을 커밋 시점에 막을 수 있다.
훅은 클론에 따라오지 않으므로 `tools/install-hooks.ps1` 같은 설치 스크립트를 함께 두는 게 좋다.

### E3. 바로가기 교체를 스크립트로

2.7.0 전환 때 각 장비에서 바로가기·시작프로그램을 `attract.exe` → `attract.bat`으로
**수동으로** 바꿔야 했다(저장소 밖 파일이라 머지로 따라가지 않는다).
`tools/setup-shortcuts.ps1`로 만들어 두면 새 장비 설치와 이번 같은 전환이 재현 가능해진다.

### E4. 즐겨찾기(`.tag`)가 주력 목록에 없다

`.tag` 12개가 있지만 **NESiCAxLive, SEGA MODEL 2/3, Taito Type X, TeknoParrot,
Nintendo 64, Nintendo Wii U, SEGA Saturn, MAME Adult**에는 없다.
디스플레이마다 `filter Favourites`는 정의돼 있으므로 빈 필터가 노출된다.
→ 쓰지 않는다면 해당 디스플레이의 `filter Favourites`를 빼고, 쓴다면 즐겨찾기를 채운다.

### E5. 2.7.0의 `group_clones` 검토

활성 1,079건 중 **248건(23%)** 이 `CloneOf`를 갖고 있다. 켜면 목록이 눈에 띄게 짧아진다.
다만 이 저장소는 클론마다 한글 번역명을 따로 붙인 경우가 있어 **대표 1건만 남으면 그 이름이 사라진다.**
→ 켜기 전에 `CloneOf`가 있는 248건의 `Title`이 부모와 같은지 먼저 확인할 것.

### E6. `Compact` 브랜치의 구조 정합화

최상위가 `AttractMode/` 하위로 한 단계 들어가 있어 `main`과 머지하면 **5,834건 충돌**이 난다.
사실상 별개 저장소다. 2022-06에서 멈춰 있고 `main` 대비 251커밋 뒤처져 있다.
→ 구조를 맞춰 재구성하든지, 역할이 끝났으면 태그로 보존하고 브랜치는 정리한다.

### E7. "새 장비 브랜치 추가" 절차가 문서에 없다

[`../README.md`](../README.md)에는 *기존* 장비 설치 절차만 있다.
브랜치 생성 → 장비 전용 설정 조정 → `main` 병합 루프까지의 절차를 적어 두면
장비가 늘어날 때 이번처럼 헤매지 않는다.

### E8. 아트웍 추적 범위 결정 (보류 중)

[`ASSETS.md`](ASSETS.md) 1안 = **실사용 휠만 약 118MB**. 클론 직후에도 게임 선택 화면이 제 모습으로 보인다.
저장소 크기에 직결되므로 **S1·S2의 히스토리 정리를 끝낸 뒤** 판단할 것.
