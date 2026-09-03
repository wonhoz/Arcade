# 개선 과제 / 알려진 문제 (심각도순)

최초 점검 2026-09-02 · 전체 재검수 2026-09-03 · 브랜치 `develop` (main 기반) · Attract-Mode v2.7.0
근거: `attract.cfg`, `emulators/*.cfg`, `romlists/*`, `last_run.log`, `mame64 -verifyroms`, git 메타데이터 실측

> 항목이 해소되면 체크박스를 갱신하고, 구조가 바뀌었으면 [`../CLAUDE.md`](../CLAUDE.md)도 같은 커밋에서 함께 고친다.
> 점검은 `powershell -ExecutionPolicy Bypass -File tools\validate.ps1` 로 자동화되어 있다.

**진행 현황** — 처리 12건 / 미해결 11건 · 재분류 1건 · 개선 포인트 8건

---

## S1 — 치명적 (법적 위험)

### - [ ] 1. 공개 저장소에 상용 BIOS·게임 롬이 커밋되어 있음

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
3. `git filter-repo`로 히스토리에서 제거 후 force push. — 25개 브랜치 전부를 재작성하므로
   **작업 전 전체 백업 필수**이며, 부수효과로 2번(저장소 크기) 문제도 크게 완화된다.
4. BIOS/롬은 저장소 밖(외장/NAS)에 두고 배포 절차로 복사 — [`ASSETS.md`](ASSETS.md), [`../README.md`](../README.md) 참고.

---

## S2 — 높음

### - [ ] 2. 저장소가 1.2GB, 에뮬레이터 바이너리 전량이 git에 들어 있음

- `.git` **1.2GB** / 추적 파일 **23,711개 · 1.71GB** (2026-09-03 실측)
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

`layouts/NXL HD/Layout.nut`이 쓰는 `futureforces` / `Squares Bold Free` / `MSMINCHO`가
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

### - [ ] 8. 미추적 대용량 파일 389MB 방치

```
emulators/Mame/mame64 - 복사본 (2).exe   253.9MB
emulators/Mame/mame64 - 복사본 (2).sym   135.5MB
```
`.gitignore`가 `mame64.exe`/`mame64.sym`만 막고 있어 **복사본은 `git status`에 계속 뜬다.**
세션마다 `git status`에 노이즈로 뜨는 것이 확인된다.
→ 삭제하거나 `.gitignore`에 `emulators/[Mm]ame/mame64*` 패턴 추가. (18번과 함께 처리 권장)

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

### - [ ] 12. 대소문자만 다른 `Name` 충돌 — 검증 스크립트가 새로 발견

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

→ 우선순위 낮음. 정리한다면 Wii U 쪽 Name을 `Tekken Tag Tournament 2`로 바꾸고
롬 폴더(`emulators/Cemu/Roms/`)·아트웍 파일명을 함께 맞춘다.

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

**왜 이렇게 됐나**: `layouts/NXL HD/Layout.nut:971`이 정보 상자에 `[Rotation]`을 그대로 뿌린다.
언어를 화면에 띄우려면 레이아웃을 고치는 대신 데이터를 `Rotation`에 넣는 쪽이 빨랐던 것.
`AltRomname`은 `attract.cfg`의 Capcom 필터(`rule AltRomname equals cps1`)가 실제로 의존하고 있어
이제 와서 바꾸면 필터가 깨진다.

**위험**: 새 항목을 추가하는 사람이 필드 의미를 오해하면 목록마다 다른 규칙을 어긴다.
특히 `Rotation`에 언어를 넣은 NESiCAxLive는 나중에 실제 세로 게임이 추가되면 판단이 불가능해진다.

**조치안**
1. (권장) 언어는 `Language`(19)로 통일하고 `NXL HD/Layout.nut`을 `[Language]`로 수정.
   `AltRomname`의 플랫폼 태그는 `attract.cfg` 필터와 함께 `Series`(18) 등으로 이전.
2. (최소) 지금처럼 두되 **[`../CLAUDE.md`](../CLAUDE.md) 4.1절의 표를 반드시 보고
   같은 파일의 기존 줄을 복사해서 추가**한다. ← 현재 채택 중

### - [ ] 14. 비활성(`#`) 항목이 존재하지 않는 에뮬레이터 16종을 참조

`tools/validate.ps1`이 WARN 34건으로 잡아낸다. **전부 `#`으로 꺼져 있어 실행에는 영향이 없다.**
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

### - [ ] 15. 아무 목록도 참조하지 않는 에뮬레이터 cfg 2개

- `Taito Type X Samurai Shodown - Edge of Destiny.cfg` → `emulators\Taito Type X\Samurai Shodown - Edge of Destiny\game.exe`
- `Taito Type X Spica Adventure.cfg` → `emulators\Taito Type X\Spica Adventure\typex_loader.exe`

두 cfg가 가리키는 **실행 파일도 로컬에 없다.** 해당 게임 폴더는 `.gitignore` 대상이라
다른 장비에서 지웠거나 애초에 옮겨오지 않은 것으로 보인다.
한편 `romlists/Taito Type X.txt`에는 두 게임이 **다른 이름**(`Taito Type X_...`)으로 참조되는
비활성 항목이 있다(14번). 즉 **정의와 목록이 서로 다른 이름을 쓰며 둘 다 죽어 있는 상태**다.

→ 게임을 복구하고 이름을 통일하든지, cfg를 정리하든지 결정 필요.
지금은 참조가 없어 실행에 영향이 없으므로 검증 스크립트도 WARN으로만 다룬다.

### - [ ] 16. `emulators/Mame/mame.ini:11`에 무효한 절대경로

```
rompath  "roms;roms\Arcade;…;f:\attractmode\emulators\PSXmame\roms;roms\Console\neocd"
```

`f:\attractmode\...`는 예전 설치 드라이브의 흔적이다. 현재 설치는 `D:\`라 존재하지 않는다.
MAME이 롬을 찾을 때마다 없는 경로를 한 번씩 더 확인하게 되고(성능은 무시할 수준),
**설치 경로를 옮기면 이런 절대경로만 조용히 깨진다**는 점이 문제다.

→ `..\PSXmame\roms` 같은 상대경로로 바꾸거나 제거. 다른 `.ini`에도 절대경로가 없는지 함께 확인.

### - [ ] 17. 연결되지 않은 채 남아 있는 자산들

| 대상 | 상태 | 판단 |
|---|---|---|
| `plugins/` 17종<br>(AudioMode, Confirm Game Selection, Debug Reload, FPSMonitor, History.dat, KeyboardSearch, KonamiCode, LEDBlinky, MultiMon, ResFix, RocketLauncher, RotationControl, SpecificDisplay, UltraStik360, UtilityMenu, eSpeak) | `attract.cfg`에 `plugin` 섹션이 **하나도 없음** → 전부 비활성 | AM 기본 배포물이라 보존해도 무해. 다만 "플러그인이 동작 중"이라고 오해하기 쉬움 |
| `plugins-NESiCAxLive/` (LEDBlinky, MultiMon) | 어디서도 참조 안 됨 | NESiCAxLive 전용 세트의 잔재 |
| `screensaver-NESiCAxLive/` | AM은 `screensaver/`만 읽음 → 미사용 | 폰트 4종(9MB MSMINCHO 포함)을 품고 있음 |
| `attract-NESiCAxLive.cfg` | **AM v2.2.1** 시절 타 환경 설정. `exit_command Y:\Frontend\reload.exe`, `font_path %SYSTEMROOT%/Fonts/;Y:\Frontend\Am\`, `layout blueprint`, `romlist Nesicagui` — 이 저장소에 없는 것만 참조 | 참고용 화석. 현행 `attract.cfg`와 공통점 없음 |
| `intro/intro_16x9.mp4` | `intro_config` 섹션이 없어 기본값(`intro.mp4`)만 재생 | 16:9 전용 인트로를 쓰려면 설정 필요 |
| `loader/` (hyperspin, mala, mamewah, attract_xml) | AM 기본 임포터. 사용 이력 없음 | 벤더 원본, 그대로 둠 |

→ 보존/삭제를 한 번 정하고 [`../CLAUDE.md`](../CLAUDE.md) 5.5절에 반영한다. 현재는 "참고용"으로 기재해 둔 상태.

### - [ ] 18. git 위생

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

→ `content_*.lpl` 4개는 `.gitignore` + `git rm --cached`. `attract.am`도 같이.
`stats/`는 무시 목록에도 없어 미추적 상태로 계속 노출된다.

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

### - [ ] 20. 정지한 원격 브랜치 16개

원격 브랜치 25개 중 **16개가 2022년 이후 갱신이 없다.** 그중 절반은 이미 `main`에 병합돼 있다.

**병합 완료 — 삭제해도 내용 손실 없음 (8개)**
`NESiCAxLive`, `develop`, `develop-layouts`, `develop-replace`, `malio`, `mame`, `retroarch`, `update`

**미병합 — 삭제 전 태그 보존 권장 (8개)**
`Compact`(50GB 축소판), `bartop-NESiCAxLive`, `desktop-keyboard`, `desktop-keyboard-git`,
`develop-prev`, `fbneo`, `mame-failed`, `update-failed`
— 이름에서 보이듯 `*-failed` 둘은 실패한 시도의 기록이다.

**현재 살아 있는 브랜치 (9개)**
`main`, `bartop`, `desktop`, `desktop-ASUS-TUF`, `desktop-MSI-Sword`,
`desktop-MSI-Sword-DriveWheel`, `retroarch-update` 등

→ 병합 완료분은 삭제, 미병합분은 `git tag archive/<이름> <브랜치>` 후 삭제.
브랜치 수가 줄면 S1의 히스토리 재작성도 훨씬 수월해진다.

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

**현재 상태: FAIL 0건 / WARN 59건** (WARN은 미설치 자산·비활성 항목이 대부분)

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
