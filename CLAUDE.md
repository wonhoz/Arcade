# CLAUDE.md — AttractMode 고전게임 실행환경 작업 지침서

이 저장소는 **Attract-Mode v2.7.0 프론트엔드 + 에뮬레이터 + 게임목록/아트웍 설정**을 통째로 담은
"실행 가능한 아케이드 캐비닛 환경" 그 자체다. 소스코드 프로젝트가 아니라 **런타임 디렉터리를 버전관리**하는 형태다.

> **작업 규칙**: 이 문서를 먼저 숙지하고 작업한다. 구조·규칙·목록이 바뀌는 작업을 했다면
> **반드시 이 문서와 `docs/ISSUES.md`를 같은 커밋에서 함께 갱신**한다.

---

## 1. 저장소 개요

| 항목 | 값 |
|---|---|
| 원격 | https://github.com/wonhoz/Arcade (**public**) |
| 프론트엔드 | Attract-Mode v2.7.0 (Windows, SFML 2.5.1) — `attract.exe` (실행은 `attract.bat`, 4.5절) |
| 설치 경로 | `D:\AttractMode` (절대경로 의존 있음 → 4.4절) |
| 추적 파일 | 약 23,700개 / `.git` 약 1.3GB |
| 현재 브랜치 | `develop` (공통 작업 브랜치, `main` 기반) |
| 커밋 메시지 | 한국어. 최근 스타일은 `영역 | 내용` (예: `retroarch | args 에서 -H 제거`) |

## 2. 브랜치 전략 (중요)

`main`은 **공통 베이스**, 나머지는 **하드웨어/캐비닛별 배포 브랜치**다. 브랜치를 지우지 말 것.

```
main ──┬─> develop                 ★ 공통 작업 브랜치 (여기서 작업 → main 병합 → 각 장비로 전파)
       ├─> bartop                  바탑 캐비닛 (실제 구동 장비)
       ├─> desktop
       ├─> desktop-ASUS-TUF
       ├─> desktop-MSI-Sword
       └─> desktop-MSI-Sword-DriveWheel
```

**브랜치는 7개뿐이다.** 2026-09-03에 2022년에 멈춰 있던 15개를 정리했다(20번 참고).
지워진 것은 전부 `archive/*` 태그로 남아 있으므로 언제든 되살릴 수 있다.

```bash
git tag -l 'archive/*'                       # 아카이브 목록
git tag -n20 archive/Compact                 # 그 브랜치가 뭐였는지
git branch Compact archive/Compact           # 되살리기
```

- **모든 장비에 적용될 변경은 `develop`(= `main` 기반)에서 한다.**
  장비 브랜치에서 작업하면 그 브랜치의 장비 전용 변경과 뒤섞여 다른 장비로 옮기기 어려워진다.
  실제로 이 저장소는 `bartop`에서 작업한 20커밋을 `develop`으로 체리픽해 옮긴 이력이 있다.
- 흐름: `develop`에서 작업 → `main`에 병합 → 각 장비 브랜치에서 `git merge main`.
- 장비 전용 변경(레이아웃 해상도, 입력맵, 롬 구성)은 해당 장비 브랜치에만 둔다.
- `main`↔`bartop` 실제 차이(113개 파일): `layouts/NEVATO/*`(캐비닛 아트/vewlix 레이아웃),
  `layouts/Console Box/*`, `layouts/Mega-Display Advanced/{layout.nut, scripts/*}`,
  `scraper/@/overview/*`, 각 에뮬레이터의 입력·화면 설정(`emulators/*/`), `intro/*`.

> ⚠️ **장비 브랜치에서만 고친 공통 수정은 `main`에서 누락되기 쉽다.**
> 실제로 `bartop`의 `retroarch | args 에서 -H 제거`(`a089eb42`)가 `main`에 2년간 미반영이었다
> (`develop`에 반영 완료 — `docs/ISSUES.md` 19번). 주기적으로 이렇게 확인한다.
>
> ```bash
> for b in bartop Compact desktop desktop-ASUS-TUF desktop-MSI-Sword; do
>   echo "== $b"; git log --oneline main..$b -- 'emulators/*.cfg' attract.cfg romlists/ tools/ docs/
> done
> ```
>
> 장비별 해상도·입력맵이 아니라 **에뮬레이터 인자·롬 목록·문서**를 건드린 커밋이 나오면
> 공통 수정일 가능성이 높으니 `develop`으로 옮긴다.

## 3. 디렉터리 구조

```
D:\AttractMode\
├─ .+필독.txt                           ★ 각 장비에서 반드시 해야 할 것 (git 으로 안 따라오는 작업)
├─ attract.exe                          프론트엔드 본체 (38MB, 추적됨) — 2.7.0부터 콘솔 서브시스템
├─ attract.bat                          ★ 실행 런처 (--logfile 로 last_run.log 복원, 4.5절)
├─ attract.cfg                         ★ 메인 설정: display / sound / input_map / general / layout_config
├─ attract.am                          런타임 상태(마지막 선택/레이아웃). 실행할 때마다 변함
├─ default-{display,emulator,filter}.cfg  AM 기본 템플릿(수정 금지)
├─ emulators\
│   ├─ *.cfg                           ★ 에뮬레이터 정의 35개 (= romlist의 Emulator 필드 값)
│   ├─ Mame\ Demul\ M2\ SuperModel\ PCSX2\ ePSXe\ PPSSPP\ Dolphin\
│   │  Project64\ Project64_v1.7\ Cemu\ Mednafen\ RetroArch\ PSXMAME\
│   │  TeknoParrot\ "Taito Type X"\ "PC Game"\      실제 에뮬레이터 바이너리
│   └─ script\                         AM 내장 에뮬레이터 자동탐지 스크립트(벤더 원본, 수정 금지)
├─ romlists\
│   ├─ <Display>.txt                   ★ 게임 목록 (세미콜론 21필드)
│   └─ <Display>.tag                   즐겨찾기(Favourite) 목록 — 한 줄에 romlist의 Name
├─ layouts\                            테마: NEVATO / Console Box / NXL HD / Mega-Display(-Advanced)
├─ modules\                            AM 공용 Squirrel 모듈 (animate, conveyor, objects/scrollingtext …)
├─ plugins\                            플러그인 (**현재 attract.cfg에 활성화된 것 없음**)
├─ screensaver\                        기본 스크린세이버 (`screensaver.nut`) — 600초 후 동작
├─ intro\                              시작 인트로 (`intro.nut` + `intro.mp4`, `intro_16x9.mp4`)
├─ loader\                             타 프론트엔드 목록 임포터(hyperspin/mala/mamewah/attract_xml)
├─ scraper\@\overview\<display>.txt    ★ 디스플레이 메뉴에 뜨는 시스템 설명문 (한국어)
├─ scraper\@exit\overview\             종료 항목 설명문
├─ menu-art\                           시스템별 아트웍 (**.gitignore — 로컬 전용**)
├─ fonts\                              폰트. font_path = "fonts;fonts/NXL HD"
├─ sounds\ shaders\ language\          효과음/셰이더/UI 번역(kr 사용)
├─ tools\validate.ps1                  ★ 설정 무결성 검증 스크립트 (7.1절)
├─ tools\reset-runtime.ps1             ★ 런타임 파일 초기화 스크립트 (7.3절)
├─ docs\                               ASSETS.md(자산 정책) / ISSUES.md(과제 목록)
├─ stats\<Emulator>\                   플레이 통계 (track_usage yes, 로컬 생성물)
│                                      ★ 2.7.0에서 romlist명 → Emulator명 기준으로 바뀜
└─ last_run.log                        ★ 마지막 실행 로그 — 문제 진단의 1순위 (gitignored)
                                       ※ 2.7.0은 attract.bat 으로 실행해야 생성됨 (4.5절)
```

## 4. 핵심 데이터 흐름

```
attract.cfg [display X]
   ├─ layout   → layouts\<레이아웃>\layout.nut
   ├─ romlist  → romlists\<목록>.txt  ─┐
   └─ filter   → romlist 필드에 대한 규칙
                                       │  각 줄의 3번째 필드(Emulator)
                                       ▼
                       emulators\<Emulator>.cfg
                       ├─ executable  실행할 에뮬레이터
                       ├─ args        인자 (토큰 치환)
                       ├─ rompath/romext  롬 위치·확장자
                       └─ artwork     flyer/marquee/snap/wheel/character/cartridge 검색 경로
```

### 4.1 romlist 형식 (`romlists/*.txt`)

1행은 헤더 주석. 이후 각 줄은 **세미콜론 구분 정확히 21필드**:

```
 1 Name          롬 파일명(확장자 제외) 또는 MAME 셋 이름
 2 Title         화면에 보이는 이름 (한국어 번역명)
 3 Emulator      ★ emulators\<이름>.cfg 의 파일명과 정확히 일치해야 함
 4 CloneOf   5 Year   6 Manufacturer   7 Category   8 Players
 9 Rotation      MAME계열: 0/90/180/270 ┃ NESiCAxLive.txt: **언어(한국어/영어/일본어)로 전용됨**
10 Control  11 Status  12 DisplayCount  13 DisplayType
14 AltRomname    Capcom.txt/NESiCAxLive.txt에서 **플랫폼 태그(cps1/cps2/cps3/neogeo)로 전용됨**
15 AltTitle      원제(영문) 보관용으로 자주 쓰임
16 Extra         PS2 목록에서 **언어(한국어) 표기로 전용됨**
17 Buttons  18 Series  19 Language  20 Region  21 Rating   (19~21은 사실상 미사용)
```

**규칙**
- 줄 맨 앞의 `#` = **비활성(주석) 항목**. 삭제하지 않고 숨길 때 쓰는 이 저장소의 관례.
  (전체 1,700여 항목 중 활성은 약 1,050개)
- 필드 수가 21이 아니면 안 됨. Name 중복 금지. 파일 인코딩 **UTF-8 (BOM 없음)**.
- `.tag` 파일은 즐겨찾기. romlist의 Name과 정확히 일치해야 하고, CRLF 줄바꿈이다.

**전용(re-purposed) 필드에 주의**: 9/14/15/16번은 목록마다 의미가 다르다.
레이아웃(`NXL HD`)이 `[Rotation]`을 정보 라벨로 표시하기 때문에 NESiCAxLive에서는 언어를 넣는다.
새 항목을 추가할 땐 **같은 파일의 기존 줄을 복사해서 맞출 것.**

### 4.2 emulator 정의 (`emulators/*.cfg`)

```
executable   emulators\mame\mame64          실행 파일 (확장자 생략 가능)
args         -skip_gameinfo "[romfilename]" 인자
rompath      roms\arcade\                   ★ executable 디렉터리 기준 상대경로
romext       .7z;.zip;<DIR>
system       MAME
exit_hotkey  Escape;Joy0 Button6+Joy0 Button7;Joy1 Button6+Joy1 Button7
artwork <라벨> <경로1>;<경로2>              앞에서부터 탐색, 없으면 다음 경로로 폴백
```

- **경로 기준**: `rompath`/`args`의 상대경로는 **executable이 있는 디렉터리 기준**.
  예) `MAME.cfg`의 `roms\arcade\` → `emulators\Mame\roms\Arcade\`.
  `executable`이 `cmd`인 경우(PC Game, Taito Type X)만 AM 루트 기준.
- **artwork 경로는 AM 루트 기준**이며 `menu-art\...`, `emulators\mame\...`를 가리킨다.
- 치환 토큰: `[name]`(Name 필드), `[romfilename]`(rompath+name+romext 전체 경로),
  `[rompath]`, `[romext]`, `[emulator]`, `[title]`.
- **MAME 계열은 `mame.ini`의 `rompath`가 실제 롬 탐색을 담당**하므로, cfg의 `rompath`는
  주로 목록 생성/`[romfilename]` 치환용이다. (`emulators/Mame/mame.ini:11` 참고)

**에뮬레이터 정의 목록 (35개)**

| 계열 | cfg |
|---|---|
| MAME | `MAME`, `MAME Vertical`, `MAME Adult`, `EKMAME`(한글롬), `EKMAME Vertical`, `PSXMAME` |
| RetroArch | `RetroArch FinalBurn Neo` (한글패치 롬: `emulators/RetroArch/system/fbneo/patched`) |
| Demul | `SEGA NAOMI`, `Sammy Atomiswave`, `SEGA Hikaru`, `CAVE`, `SEGA Dreamcast` |
| SEGA | `SEGA MODEL 2`(M2 emulator_multicpu), `SEGA MODEL 3`(SuperModel) |
| Sony | `Sony PlayStation {CUE,CCD,PBP}`(ePSXe), `Sony PlayStation 2 {ISO,GZ}`(PCSX2), `Sony PlayStation Portable`(PPSSPP) |
| Nintendo | `Nintendo 64`(Project64), `Nintendo GameCube {ISO,GCZ}` / `Nintendo Wii {WBFS,GCZ}`(Dolphin), `Nintendo Wii U`(Cemu) |
| 기타 | `SEGA Saturn {CUE,CCD,TOC}` / `NEC PC-Engine CD {GECD,SCDSYS}`(Mednafen·MAME), `Taito Type X` 4종, `TeknoParrot`, `PC Game` |

> 같은 시스템이라도 **롬 컨테이너 형식별로 cfg를 나눠 두는 것이 이 저장소의 방식**이다
> (`Sony PlayStation CUE` / `CCD` / `PBP` …). romext 우선순위만 다르다.

### 4.3 attract.cfg 구성

- `display` 21개: NESiCAxLive, MAME, Capcom, SNK Neo Geo, SEGA MODEL 2/3, SEGA NAOMI,
  Sammy Atomiswave, Taito Type X, TeknoParrot, Zinc, Sony PlayStation/2/Portable,
  Nintendo 64/GameCube/Wii/Wii U, SEGA Saturn, SEGA Dreamcast, MAME Adult.
- 레이아웃 배정: 아케이드 → `NEVATO`, 콘솔 → `Console Box`, NESiCAxLive → `NXL HD`,
  디스플레이 선택 메뉴 → `Mega-Display Advanced` (`menu_layout`).
- `general`: `language kr`, `default_font SUIT-Regular`, `font_path fonts;fonts/NXL HD`,
  `startup_mode displays_menu`, `screen_saver_timeout 600`, `track_usage yes`,
  `hide_console yes`(2.7.0에서 필수 — 4.5절).
- 입력맵은 키보드 + Joy0/Joy1 2인용 조이스틱 병행. 종료는 `Escape+LShift`,
  게임 중 종료는 각 emulator cfg의 `exit_hotkey`(Escape 또는 Button6+Button7).
- **`plugin` 섹션 없음** → `plugins/` 디렉터리는 현재 전부 비활성 상태.
- 2.7.0에서 `general`에 `group_clones` 키가 추가됐다(클론을 한 항목으로 묶음). 미설정 = `no`.
  이 저장소는 `CloneOf` 필드를 거의 안 쓰므로 켤 이유가 없다. **제거된 설정 키는 없다.**

### 4.4 절대경로 의존

- `attract.cfg`의 `Config:` 경로는 실행 시 결정되므로 무관하지만,
  `emulators/Mame/mame.ini:11`의 `rompath`에 **`f:\attractmode\emulators\PSXmame\roms`** 라는
  타 드라이브 절대경로가 남아 있다(현재 무효).
- `attract-NESiCAxLive.cfg`(`Y:\Frontend\...` 참조)는 2026-09-03에 제거했다.
  `archive/unused-assets-2026-09-03` 태그에 보존돼 있다.

### 4.5 실행 방법 — ⚠️ 2.7.0에서 바뀐 부분

**`attract.exe`를 직접 실행하지 말고 `attract.bat`으로 실행한다.**

2.7.0부터 윈도우 배포본은 `attract-console.exe`를 없애고 `attract.exe` 하나를
**콘솔 서브시스템(WINDOWS_CUI)** 으로 빌드한다(2.6.2는 GUI 서브시스템 + 별도 콘솔판 2벌).
그 결과 소스의 아래 분기가 죽어서 **기본 로그 파일이 만들어지지 않는다**.

```cpp
// main.cpp
#if defined(SFML_SYSTEM_WINDOWS) && !defined(WINDOWS_CONSOLE)
    log_file = feSettings.get_config_dir() + "last_run.log";   // ← 2.7.0에선 컴파일 제외
#endif
```

| | 2.6.2 | 2.7.0 (그대로 두면) | 2.7.0 (`attract.bat`) |
|---|---|---|---|
| `last_run.log` | 자동 생성 | **안 생김**(stdout으로 감) | 생성됨 |
| 콘솔 창 | 안 뜸 | **검은 창이 뜸** | 안 뜸 |

대응은 두 가지를 같이 쓴다.

1. `attract.bat` — `attract.exe --logfile "%~dp0last_run.log"` 로 로그를 되살린다.
2. `attract.cfg`의 `hide_console yes` — 콘솔 창을 숨긴다.
   이 설정은 소스에서 `#ifdef WINDOWS_CONSOLE` 안에 있어 **2.6.2에선 무시되던 값**이고,
   2.7.0에서 비로소 동작한다.

> 배치파일 함정: `cd /d "%~dp0"` 는 `%~dp0`가 `\`로 끝나므로 닫는 따옴표가 이스케이프되어 깨진다.
> `attract.bat`은 `cd /d "%~dp0."` 로 쓴다.

캐비닛 자동 시작(바로가기·시작프로그램)도 `attract.exe`가 아니라 `attract.bat`을 가리켜야 한다.


## 5. 자주 하는 작업 레시피

### 5.1 게임 추가
1. 롬을 해당 `rompath`에 배치 (예: `emulators/Mame/roms/Arcade/`).
2. `romlists/<Display>.txt`에 **기존 줄을 복사해 21필드 맞춰서** 추가.
   Emulator 필드는 반드시 `emulators/*.cfg` 파일명과 일치.
3. 아트웍을 `menu-art/<system>/{flyer,marquee,video,wheel}/<Name>.<ext>`에 배치
   (MAME 계열은 `emulators/Mame/{flyer,marquee,video,wheel}`). **아트웍은 git 추적 안 됨.**
4. `attract.bat` 실행 → `last_run.log` 확인. (`attract.exe`를 직접 실행하면 로그가 안 남는다 → 4.5절)
5. 커밋: `romlists | <목록>에 <게임> 추가` 형태.

### 5.2 에뮬레이터 추가/수정
1. `emulators/<이름>.cfg`를 기존 파일 복사해서 작성. **UTF-8, BOM 없이 저장.**
2. `executable` 기준 상대경로로 `rompath` 지정. `romext`에 확장자 나열(폴더면 `<DIR>`).
3. romlist의 Emulator 필드를 새 이름으로 맞춘다.
4. 필요하면 `attract.cfg`에 `display` 블록과 `scraper/@/overview/<display 소문자>.txt` 추가.

### 5.3 새 디스플레이 추가
- `attract.cfg`에 `display` 블록 (`layout`, `romlist`, `in_cycle`, `in_menu`, `filter All`, `filter Favourites`).
- `romlists/<이름>.txt` 생성(헤더 포함), `scraper/@/overview/<이름 소문자>.txt`에 한국어 설명 작성.
- **마스코트(캐릭터) 이미지**: `NEVATO` · `Console Box` 는 `select_character = "By Display"` 라서
  화면 우측 캐릭터를 **`layouts/<레이아웃>/character/<디스플레이 이름>.png`** 에서 찾는다.
  emulator cfg 의 `artwork character` 와는 **무관하다**(그쪽은 `By Game` 일 때만 쓰인다).
  없으면 오류 없이 그 자리만 비어 보인다.
  **규격은 480×760, 투명 배경 위 컷아웃**이다 — 불투명 플라이어를 잘라 넣으면 리스트 박스 위에
  포스터 블록이 얹힌다(`docs/ISSUES.md` 28번). `tools/validate.ps1` 이 누락과 규격(크기·알파 비율)을 경고한다.
  Taito Type X · MAME Adult 는 캐릭터 소재가 없어 **게임 로고를 얹은 임시본**이다.
- 디스플레이 메뉴 아트웍은 `menu-art/system|marquee|snap|wheel`(로컬 전용).

### 5.4 레이아웃 수정
- Squirrel(`.nut`). 모듈은 `fe.load_module("...")`, 하위 스크립트는 `fe.do_nut("scripts/...")`.
- **레이아웃이 쓰는 폰트는 그 레이아웃 폴더 안이나 `font_path`(= `fonts` / `fonts/NXL HD`)에 있어야 한다.**
  폰트를 새로 넣으면서 폴더를 추가했다면 `attract.cfg`의 `font_path`도 같이 늘려야 한다.

> ⚠️ **폰트를 찾을 수 있게 만들면 한글이 깨질 수 있다.**
> Attract-Mode에는 **글리프 단위 폴백이 없다.**(2.7.0 확인) 폰트를 못 찾으면 `default_font`
> (`SUIT-Regular`)로 통째로 폴백하지만, 찾으면 그 폰트만 쓴다.
> 그래서 라틴 전용 폰트가 `font_path`에 들어오는 순간 한글이 두부로 바뀐다.
> 실제로 `font_path` 확장 직후 NXL HD에서 이 일이 났다(`docs/ISSUES.md` S3-6 참고).
>
> **규칙: 텍스트 객체가 실제로 무엇을 표시하는지 보고 폰트를 정한다.**
> `[Title]`·`[!genre]`·`[Rotation]`·`[!rss]`·메뉴 리스트박스처럼 한글이 들어가는 곳은
> 한글 글꼴, `[Year]`·`[Players]`·`[ListEntry]`·`[AltTitle]`·고정 영문처럼 라틴/숫자뿐인 곳만
> 테마의 표시 글꼴을 쓴다. `[!token]` 은 레이아웃 안의 함수가 만드는 값이라
> **함수 본문을 열어 반환값이 한글인지 반드시 확인**한다
> (NXL HD의 `genre()`·`rss()`는 한국어를 반환한다).
>
> 폰트의 한글 지원 여부는 이렇게 확인한다.
> ```powershell
> Add-Type -AssemblyName PresentationCore
> $gt = New-Object System.Windows.Media.GlyphTypeface (New-Object Uri "D:\AttractMode\fonts\NXL HD\futureforces.ttf")
> $gt.CharacterToGlyphMap.ContainsKey(0xAC00)   # '가' -> False 면 한글 미지원
> ```
>
> 현재 `fonts/NXL HD`의 `futureforces` · `Squares Bold Free` · `MSMINCHO`는 **전부 한글 미지원**이다.
> NXL HD의 한글 표시 글꼴은 `SUIT-Regular`(기하학적 산세리프)를 쓴다.
>
> **글꼴을 바꿀 때는 한글 지원 여부만이 아니라 실제 표시될 문자 집합 전체를 검사한다.**
> `SUIT` 계열에는 `：`(U+FF1A 전각 콜론)가 없어서, `rss()`의 URL에 섞여 있던 전각 콜론을
> 반각으로 고치고 나서야 쓸 수 있었다. 문장부호 하나 때문에 깨진다.
- 수정 후 반드시 `attract.bat` 실행하고 `last_run.log`에 `AN ERROR HAS OCCURED`가 없는지 확인.

> ⚠️ **예외 줄을 지울 때는 그 아래 코드가 새로 살아난다.**
> Squirrel 예외는 그 스크립트의 **나머지 전체를 중단**시킨다. 그래서 오랫동안 예외를 던져 온
> 스크립트는 예외 지점 아래가 **한 번도 실행된 적 없는 죽은 코드**일 수 있고,
> 지금 보이는 화면이 그 죽은 코드가 빠진 결과일 수 있다.
> 예외를 고치면 그 코드가 처음으로 실행되면서 화면이 바뀐다 —
> 실제로 `arcade_name.nut`에서 이 방식으로 회귀가 났다(`docs/ISSUES.md` S2-3 참고).
> **예외 줄 아래 문장을 먼저 읽고, 그것이 실행돼도 되는 코드인지 판단한 뒤 지운다.**

### 5.5 손대지 말아야 할 것
- `default-*.cfg`, `emulators/script/`, `loader/`, `modules/`, `plugins/` — AM 벤더 원본.
  `plugins/`는 `attract.cfg`에 `plugin` 섹션이 없어 전부 비활성이지만, AM 설정 메뉴에서
  켤 수 있는 정상 자산이라 지우지 않는다.
- `layouts/Mega-Display` — 어떤 display도 쓰지 않지만 AM 레이아웃 메뉴에서 선택 가능한 예비 테마다.

> **미연결 자산을 정리한 이력** — 2026-09-03에 아래를 제거하고
> `archive/unused-assets-2026-09-03` 태그에 보존했다.
> 되살리려면 `git checkout archive/unused-assets-2026-09-03 -- <경로>`.
>
> | 대상 | 왜 지웠나 |
> |---|---|
> | `screensaver-NESiCAxLive/` (31개) | AM은 `screensaver/`만 읽는다. 폴더명을 바꾸지 않는 한 로드 불가 |
> | `plugins-NESiCAxLive/` (2개) | AM 플러그인 UI는 `plugins/`만 스캔한다 |
> | `attract-NESiCAxLive.cfg` | AM은 `attract.cfg`만 읽는다. v2.2.1 시절 `Y:\Frontend` 화석 |
> | `emulators/Taito Type X {Samurai Shodown - Edge of Destiny, Spica Adventure}.cfg` | 게임 미설치 + 어떤 romlist도 미참조 |
>
> **기준**: AM이 스스로 선택할 수 있는 것(레이아웃·플러그인)은 남기고,
> **이름을 바꾸지 않으면 절대 로드될 수 없는 것**만 지웠다.
- `License.txt`, `Readme.txt`, `Layouts.txt`, `Compile.txt`, `Changelog.txt` — AM 공식 문서.

### 5.6 Attract-Mode 본체 업그레이드

배포본은 "AM 벤더 원본"만 덮어쓰고, 이 저장소가 직접 만든 것은 절대 덮지 않는다.
공식 zip(`attract-vX.Y.Z-win64.zip`)을 임시 폴더에 풀고 **해시로 비교**해서 실제로 다른 파일만 반영한다.

```powershell
$ext = "<압축 푼 경로>"; $repo = "D:\AttractMode"
Get-ChildItem -Recurse -File $ext | ForEach-Object {
  $rel = $_.FullName.Substring($ext.Length+1); $r = Join-Path $repo $rel
  if (Test-Path -LiteralPath $r) {
    if ((Get-FileHash $_.FullName -Algorithm MD5).Hash -ne (Get-FileHash $r -Algorithm MD5).Hash) { "다름  $rel" }
  } else { "없음  $rel" }
}
```

**덮어쓸 것** — `attract.exe`, `Changelog.txt`, `Compile.txt`, `Layouts.txt`, `Readme.txt`,
`License.txt`, `default-*.cfg`, `language/*`, `modules/*`, `emulators/script/*`, `loader/*`, `shaders/*`

**덮지 말 것**
- `menu-art/` — 로컬 커스텀 아트웍(gitignore). 배포본의 `menu-art/wheel/exit.png`로 덮으면 아이콘이 바뀐다.
- `plugins/` 중 이 저장소가 손댄 것(`RocketLauncher/plugin.nut`) — 어차피 `plugin` 섹션이 없어 비활성.
- 배포본의 기본 레이아웃(`Basic`/`Cools`/`Grid`/`Orbit`/`Attrac-Man`/`Sample Animate`/`Verticools`)과
  `romlists/mame/*.tag` — 이 저장소는 의도적으로 갖고 있지 않다. 추가하면 쓰지도 않는 항목만 늘어난다.

**업그레이드 전 반드시 확인할 것** (2.6.2→2.7.0 실측 기준, 소스 tarball 2벌을 받아 diff)

| 확인 대상 | 방법 | 2.7.0 결과 |
|---|---|---|
| `general` 설정 키 증감 | `fe_settings.cpp`의 `configSettingStrings[]` diff | `group_clones` 추가만, 제거 없음 |
| emulator/display/filter 설정 키 | `fe_info.cpp` 키 테이블 diff | 변화 없음 |
| Squirrel API 증감 | `fe_vm.cpp`의 `_SC("...")` 목록 diff | **증감 0** (레이아웃 무수정 동작) |
| romlist `#` 주석 규칙 | `fe_util.cpp`의 `tmp_setting[0] != '#'` | 동일 |
| `.tag` 탐색 경로 | `fe_romlist.cpp` | 리팩터링만, 동작 동일 |
| 입력맵/종료 핫키 | `fe_input.cpp` `diff -w` | 공백만 |
| 폰트 탐색 | `fe_settings.cpp` | 변경은 `#ifdef USE_FONTCONFIG`(리눅스 전용) 안. 윈도우 무관 |
| DLL 의존성 | PE import 문자열 비교 | 동일 |
| **PE 서브시스템** | 아래 스니펫 | **GUI(2) → 콘솔(3)로 바뀜 → 4.5절 대응 필요** |

```powershell
$fs=[IO.File]::OpenRead("D:\AttractMode\attract.exe"); $br=New-Object IO.BinaryReader $fs
$fs.Position=0x3C; $pe=$br.ReadInt32(); $fs.Position=$pe+0x5C; $br.ReadUInt16()  # 2=GUI, 3=콘솔
```

마지막으로 `attract.bat` 실행 → `last_run.log`에 오류 없는지 → `tools\validate.ps1` 순으로 확인한다.


## 6. 버전관리 규칙

`.gitignore`가 제외하는 것 (= **다른 PC에 클론해도 따라오지 않는 것**):
- 모든 **롬/ISO/디스크 이미지** (`emulators/*/Roms/`, `Game ISO/`, `isos/`, `Disc Image/` …)
- **MAME 실행파일**(`mame64.exe`, `EKMAME64.exe`, `.sym`)과 `hash/`, `artwork/`, `nvram/`, `roms/`
- **아트웍 전체** (`menu-art/`), MAME 아트(`flyer/ marquee/ snap/ title/ video/ wheel/`)
- RetroArch `cores/`, `system/` · Cemu 캐시/키 · `last_run.log`, `script.nv`

즉 **이 저장소를 클론하는 것만으로는 실행되지 않는다.** 롬·코어·아트웍은 별도로 옮겨야 한다.

주의 사항:
- `core.ignorecase=true`(Windows)에 의존한다. `.gitignore`는 `emulators/MAME/...`로 적혀 있지만
  실제 폴더는 `emulators/Mame`다. Linux/macOS에서 클론하면 무시 규칙이 깨진다.
- `core.autocrlf=true`이고 `.gitattributes`가 없다. 다른 설정의 PC에서 작업하면 전체 줄바꿈 diff가 난다.
- `attract.am`은 추적 중인데 실행할 때마다 내용이 바뀔 수 있다(런타임 상태 파일).
- `stats/`는 무시 목록에 없다. 플레이 통계가 쌓이면 미추적 파일로 나타난다.
  2.7.0부터 저장 경로가 `stats/<romlist명>/` → `stats/<Emulator명>/` 로 바뀌어서,
  기존 `stats/Capcom/`·`stats/Zinc/` 같은 폴더는 더 이상 읽히지 않는다(플레이 횟수만 0으로 초기화됨).

## 7. 검증 및 문제 진단

### 7.1 설정 무결성 검증 (변경 후 필수)

```powershell
powershell -ExecutionPolicy Bypass -File tools\validate.ps1
# 옵션: -Quiet (경고 숨김), -Root <경로>
# 종료 코드 0 = 오류 없음, 1 = 오류 있음
```

romlist 필드 수·중복·BOM, Emulator/layout/romlist 상호 참조, executable·rompath·artwork 경로,
활성 항목의 실제 롬 존재, `.tag` 대조까지 한 번에 점검한다.

결과는 성격에 따라 **네 단계**로 나온다. 이 구분이 핵심이다.

| 단계 | 뜻 | 기대값 |
|---|---|---|
| `FAIL` | 저장소가 깨진 상태. 종료 코드 1 | **0** |
| `WARN` | 저장소 차원의 문제. **모든 장비에서 똑같이 나온다** | **0** |
| `환경` | 롬·아트웍·게임 미설치. `.gitignore` 대상이라 장비마다 다르다 | 0이 아닌 게 정상 |
| `참고` | 알고 있고 그대로 두기로 한 것(비활성 `#` 행이 참조하는 미정의 에뮬레이터 등) | — |

**`WARN`이 0이 아니면 고쳐야 한다.** 예전에는 미설치 자산까지 전부 WARN 이라
59건이 상수처럼 깔려 새 경고가 묻혔다. `-Quiet` 는 `환경`·`참고`를 숨기고
`WARN`/`FAIL`만 보여주므로 커밋 전 점검에 쓰기 좋다.

### 7.2 진단 순서

1. **`last_run.log`를 먼저 읽는다.** 레이아웃 스크립트 에러, cfg 파싱 경고, 롬 로딩 결과가 전부 여기 남는다.
   로그가 갱신돼 있지 않다면 `attract.exe`를 직접 실행한 것이다 — **`attract.bat`으로 다시 실행한다**(4.5절).
2. cfg 파싱 경고(`Unrecognized "emulator" setting of "..."`) → 해당 파일의 **UTF-8 BOM** 의심.
3. 게임이 목록에 안 보임 → romlist에서 `#`으로 비활성화됐는지, 필터 규칙에 걸렸는지 확인.
4. 게임이 실행 안 됨 → `emulators/<Emulator>.cfg`의 `executable`/`rompath`/`romext`와 실제 파일 대조.
5. 아트웍이 안 나옴 → `artwork` 경로(AM 루트 기준)와 파일명(= romlist Name)이 일치하는지 확인.


### 7.3 런타임 파일 초기화

```powershell
powershell -ExecutionPolicy Bypass -File tools\reset-runtime.ps1            # 보기만 (기본)
powershell -ExecutionPolicy Bypass -File tools\reset-runtime.ps1 -Config -Clean
powershell -ExecutionPolicy Bypass -File tools\reset-runtime.ps1 -All -Force
```

**이 저장소는 런타임 상태 파일을 일부러 추적한다.** 입력 설정이 꼬이거나 에뮬레이터가
이상해졌을 때 "커밋된 정상 상태"로 되돌리기 위해서다. 대신 게임을 한 번 실행하는 것만으로
`git status`가 지저분해지므로, 이 스크립트로 한 번에 정리한다.

파일을 세 갈래로 나눠 다룬다. **세이브를 설정과 섞지 않는 것이 핵심이다.**

| 갈래 | 대상 | 되돌리면 |
|---|---|---|
| **설정** | `attract.am`, `Mame\cfg`(게임별 입력·딥스위치), `Mame\ui.ini`, `RetroArch\retroarch.cfg`·`content_*.lpl`, `PCSX2\inis`, `M2\CFG`, `Project64\Config`, `TeknoParrot\UserProfiles`, `Demul\*.ini`, `PPSSPP\...\SYSTEM` | 잃는 것 없음 |
| **세이브** | `Mame\{nvram,memcard,diff,sta}`, `PCSX2\{memcards,sstates}`, `ePSXe\{memcards,sstates}`, `Project64\Save`, `SuperModel\{NVRAM,Saves}`, `Demul\nvram`, `RetroArch\{saves,states}` | **게임 진행이 사라진다** |
| **산출물** | `last_run.log`, `script.nv`, `stats\`, `Mame\hiscore`, `Mame\data\history.db`, `Mame\cheat\output.*`, `RetroArch\screenshots` | 미추적이라 삭제 |

- 인자 없이 실행하면 **아무것도 건드리지 않고 목록만** 보여준다.
- 평소 정리는 `-Config -Clean`이면 충분하다. `-Saves`는 게임 진행이 날아가니 의식적으로 붙인다.
- `-Force`를 빼면 실행 전에 한 번 물어본다.
- 되돌리기는 `git checkout --`이므로 **커밋되지 않은 의도적 수정도 함께 날아간다.**
  런타임 파일을 일부러 고쳤다면 먼저 커밋할 것.
## 8. 관련 문서

| 문서 | 내용 |
|---|---|
| [`README.md`](README.md) | 새 장비 설치·실행 절차, 조작키 |
| [`docs/ASSETS.md`](docs/ASSETS.md) | 롬·BIOS·아트웍 버전관리 정책, 아트웍 배치 규칙 |
| [`docs/ISSUES.md`](docs/ISSUES.md) | 알려진 문제·개선 과제 (심각도순, 체크박스로 관리) |

작업으로 항목이 해소되면 `docs/ISSUES.md`의 체크박스를 갱신하고,
구조·규칙이 바뀌었으면 이 문서도 **같은 커밋에서** 함께 고친다.

### 미해결 중 가장 큰 것

- **S1**: 공개 저장소에 PS2/PS1/새턴 BIOS와 상용 롬이 커밋되어 있다 (저작권 위험).
- **S2**: `.git`이 1.3GB. 에뮬레이터 바이너리 전량이 추적 중이다.

둘 다 히스토리 재작성이 필요하고 25개 브랜치 전부에 영향을 주므로, **손대기 전에 전체 백업**한다.
