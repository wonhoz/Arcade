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
| 추적 파일 | 23,554개 / `.git` 1.2GB (size-pack 1.17GiB, 2026-09-04 실측 — `docs/ISSUES.md` 2번과 같은 수치) |
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
- 흐름: `develop`에서 작업 → `main`에 병합 → **장비 브랜치 5개 전부**에 `git merge main` → `develop`을 `main`에 동기화.
- **"bartop에 반영해 달라"는 요청은 장비 브랜치 5개 전부에 반영하라는 뜻이다.** (2026-09-04 사용자 지시)
  `bartop`만 병합하고 나머지를 두면 그 순간부터 장비마다 다른 코드를 돌리게 되고,
  2번의 "장비 브랜치에 갇힌 공통 수정" 같은 어긋남이 다시 생긴다. 한 번에 다 한다.

  ```bash
  git push origin develop
  git checkout main && git merge --no-ff develop && git push origin main
  for b in bartop desktop desktop-ASUS-TUF desktop-MSI-Sword desktop-MSI-Sword-DriveWheel; do
    #  아래 한 줄이 없으면 exe 교체 때 unlink 오류로 죽는다 (바로 아래 경고)
    git diff --name-only HEAD origin/$b -- '*.exe' | while read -r f; do rm -f "$f"; done
    git checkout -B $b origin/$b && git merge main -m "Merge branch 'main' into $b" \
      && powershell -ExecutionPolicy Bypass -File tools/validate.ps1 -Quiet && git push origin $b
  done
  git checkout develop && git merge --ff-only main && git push origin develop
  ```

  > ⚠️ **`.exe` 를 바꾸는 병합·체크아웃은 `unable to unlink … : Invalid argument` 로 죽는다.**
  > Windows Defender 실시간 검사가 방금 쓴 실행파일을 붙잡고 있어서다. 재시도해도 잘 안 풀린다.
  > **git 이 지우지 않고 새로 만들게 하면 통과한다** — 바꿀 `.exe` 를 먼저 지워 두는 것이 유일하게 확실했다.
  >
  > ```bash
  > git diff --name-only <현재> <대상> -- '*.exe' | while read -r f; do rm -f "$f"; done
  > ```
  >
  > 2026-09-07 MAME 0.289 전파 때 `emulators/Mame/` 의 보조 도구 11개(`nltool` `nlwav` `chdman` …)가
  > 한꺼번에 바뀌면서 `main` 병합이 세 번 연속 실패했다. 위 한 줄을 넣으니 한 번에 됐다.

  > 🚨🚨 **장비 브랜치·`main` 에서 `git clean` 을 돌리지 말 것. `.gitignore` 가 브랜치마다 다르다.**
  > `.gitignore` 는 추적 파일이라 브랜치를 따라 바뀐다. `develop` 에서 무시되는 경로가
  > `main` 에서는 무시 대상이 아닐 수 있고, 그 상태에서 `git clean -fd` 를 돌리면
  > **롬·에뮬레이터 실행파일처럼 되찾기 어려운 것이 통째로 지워진다.**
  >
  > 2026-09-07 에 실제로 `main` 에서 `git clean -fd` 를 돌려 `emulators/EKMAME/` 가 통째로 날아갔다
  > (`EKMAME64.exe` + `roms/Korean` 38개). `main` 의 `.gitignore` 에는 아직 EKMAME 규칙이 없었기 때문이다.
  > 백업본이 저장소 밖에 있어 복구했지만, `roms/Korean` 은 **어떤 롬셋으로도 다시 못 만드는 유일본**이었다.
  >
  > 병합이 남긴 미추적 잔재를 치워야 하면 `git clean` 대신 **`git checkout -f <브랜치>`** 를 쓴다.
  > 굳이 지워야 하면 `git clean -nd` 로 먼저 보고, 무시 규칙이 다른 브랜치인지 확인한다.
  각 장비 브랜치에서 병합 직후 `validate.ps1`을 돌린다 — 장비 전용 설정과 공통 변경이 충돌하지 않았는지 보는 유일한 자리다.
  `gh`가 없으면 위처럼 로컬에서 `--no-ff`로 병합한다(PR 머지와 같은 모양).

  > ⚠️ **커밋하기 전에 `git branch --show-current`가 `develop`인지 확인한다.**
  > 위 스크립트의 `git checkout -B $b origin/$b`는 로컬 장비 브랜치를 원격 상태로 **되돌린다**.
  > 그래서 실수로 장비 브랜치에 커밋한 뒤 이 스크립트를 돌리면 그 커밋이 고아가 된다
  > (2026-09-04에 실제로 `bartop`에 커밋했다가 `reflog`에서 `cherry-pick`으로 건졌다).
  > 스크립트는 그 자리에서 브랜치를 검사하고 아니면 멈추는 것이 안전하다:
  > `[ "$(git branch --show-current)" = develop ] || { echo "develop 아님"; exit 1; }`
- 장비 전용 변경(레이아웃 해상도, 입력맵, 롬 구성)은 해당 장비 브랜치에만 둔다.

  > ⚠️ **`emulators/PSXMAME/cfg/` 는 장비 전용이다 — 전파할 때 되돌려야 한다.**
  > 버튼 매핑이 조이스틱 종류에 묶여 있다. `bartop` 은 generic USB 아케이드 패널,
  > desktop 계열 4개는 **XInput Xbox 패드**라 같은 게임이라도 `JOYCODE` 번호가 다르다
  > (6버튼 펀치: bartop = 조이 4·5·6 / desktop = 3·4·5).
  >
  > **"충돌 나면 장비 것 우선"으로는 부족하다.** git 은 양쪽이 같은 파일을 고쳤을 때만 충돌을 낸다.
  > 장비 브랜치가 자기 매핑을 가진 파일은 `tektagt.cfg` 하나뿐이라(`desktop-ASUS-TUF` 는 그것도 없다)
  > 나머지는 **충돌 없이 조용히 덮인다**. 그래서 충돌 여부가 아니라 **경로**로 갈라야 한다.
  >
  > ```bash
  > PRE=$(git rev-parse HEAD)                 # 병합 전 장비 상태
  > git merge main -m "Merge branch 'main' into $b"
  > #  cfg/ 안에서 충돌이 나면 --ours(장비 쪽)로 해결한 뒤,
  > #  병합으로 새로 들어온 cfg 파일을 지우고 나머지는 PRE 로 되돌린다
  > comm -13 <(git ls-tree -r --name-only $PRE -- emulators/PSXMAME/cfg | sort) \
  >          <(git ls-tree -r --name-only HEAD -- emulators/PSXMAME/cfg | sort) \
  >   | while read -r f; do git rm -q -f -- "$f"; done
  > git checkout $PRE -- emulators/PSXMAME/cfg
  > git commit -m "emulators | $b 의 PSXMAME 입력 설정 유지 — 공용 변경만 반영"
  > git diff --quiet $PRE HEAD -- emulators/PSXMAME/cfg   # 되돌아갔는지 확인
  > ```
  >
  > 이렇게 하면 `mame.exe` 패치·`MAME Adult.cfg`·문서·즐겨찾기 같은 **장비 무관 변경만** 전파된다.
  > 2026-09-05에 5개 장비 브랜치 전부 이 방식으로 처리했다(`docs/ISSUES.md` 45번).
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
├─ test-roms.cmd                        ★ 롬 구동 검증 런처 — 인자 없이 실행하면 메뉴 (7.5절)
├─ attract.cfg                         ★ 메인 설정: display / sound / input_map / general / layout_config
├─ attract.am                          런타임 상태(마지막 선택/레이아웃). 실행할 때마다 변함
├─ default-{display,emulator,filter}.cfg  AM 기본 템플릿(수정 금지)
├─ emulators\
│   ├─ *.cfg                           ★ 에뮬레이터 정의 35개 (= romlist의 Emulator 필드 값)
│   ├─ Mame\ Demul\ M2\ SuperModel\ PCSX2\ ePSXe\ PPSSPP\ Dolphin\
│   │  Project64\ Project64_v1.7\ Cemu\ Mednafen\ RetroArch\ PSXMAME\
│   │  TeknoParrot\ "Taito Type X"\ "PC Game"\      실제 에뮬레이터 바이너리
│   ├─ Mame\mame.ini                   ★ MAME 계열의 실제 롬 탐색 경로(rompath) — 4.7절
│   ├─ EKMAME\                        ★ EKMAME 0.224 — MAME 과 분리된 별도 폴더 (4.7절)
│   └─ script\                         AM 내장 에뮬레이터 자동탐지 스크립트(벤더 원본, 수정 금지)
├─ romlists\
│   ├─ <Display>.txt                   ★ 게임 목록 (세미콜론 21필드)
│   └─ <Display>.tag                   즐겨찾기(Favourite) 목록 — 한 줄에 romlist의 Name
├─ layouts\                            테마: NEVATO / Console Box / NXL HD / Mega-Display(-Advanced)
├─ modules\                            AM 공용 Squirrel 모듈 (animate, conveyor, objects/scrollingtext …)
├─ plugins\                            플러그인 (**현재 attract.cfg에 활성화된 것 없음**)
├─ screensaver\                        기본 스크린세이버 (`screensaver.nut`) — 600초 후 동작
├─ intro\                              시작 인트로 (`intro.nut` + `intro.mp4`(16:9), `intro_4x3.mp4`)
│                                      ※ 9:16·3:4 영상은 없음 → 세로 모니터에선 인트로가 조용히 생략된다
├─ loader\                             타 프론트엔드 목록 임포터(hyperspin/mala/mamewah/attract_xml)
├─ scraper\@\overview\<display>.txt    ★ 디스플레이 메뉴에 뜨는 시스템 설명문 (한국어)
├─ scraper\@exit\overview\             종료 항목 설명문
├─ menu-art\                           시스템별 아트웍 (**.gitignore — 로컬 전용**)
├─ fonts\                              폰트. font_path = "fonts;fonts/NXL HD"
├─ sounds\ shaders\ language\          효과음/셰이더/UI 번역(kr 사용)
├─ tools\validate.ps1                  ★ 설정 무결성 검증 스크립트 (7.1절)
├─ tools\reset-runtime.ps1             ★ 런타임 파일 초기화 스크립트 (7.3절)
├─ tools\smoke-run.ps1                 ★ 실행 점검 — 지정 디스플레이·레이아웃으로 AM 을 띄워 로그 확인 (7.4절)
├─ tools\test-roms.ps1                 ★ 롬 구동 검증 — romlist 전 항목의 실행 명령 조립·실행 (7.5절)
│                                       PowerShell 도구는 전부 tools\ 에 둔다. 루트에는 런처 cmd 만.
├─ docs\                               ASSETS.md(자산 정책) / ISSUES.md(과제 목록)
├─ logs\                               검증 보고서 CSV (gitignored, test-roms.ps1 이 생성)
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
| MAME | `MAME`, `MAME Vertical`, `MAME Adult`, `EKMAME`, `EKMAME Vertical`, `EKMAME Adult`(팬 한글화 롬), `PSXMAME` |
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

### 4.6 PSXMAME — ⚠️ `mame.exe`에 1바이트 패치가 들어가 있다

`emulators/PSXMAME/mame.exe`(MAME 0.139 계열, 2009년 빌드)는 게임 시작 때
**저작권 고지 화면**과 **롬/에뮬레이션 경고 화면**을 띄운다. 이 버전에는 이를 끄는 옵션이 없다
(`-showusage` 로 확인한 지원 옵션은 `-skip_gameinfo` 뿐 — `-skip_disclaimer`·`-skip_warnings` 는 없다).

그래서 2026-09-04에 `ui_display_startup_screens()`의 분기 한 개를 뒤집었다
(`docs/ISSUES.md` 44번).

| 파일 오프셋 | VA | 원래 | 패치 후 |
|---|---|---|---|
| `0x1039C1` | `0x005045C1` | `74 0E` (`je 0x5045D1`) | `EB 0E` (`jmp 0x5045D1`) |

`0x5045D1`은 `show_disclaimer`·`show_warnings`·`show_gameinfo`를 전부 0으로 두는 블록이다.
PSXMAME 자신이 `use_gpu_plugin` 이 켜져 있을 때 타는 것과 **같은 경로**라 새로 도는 코드가 없다.

> **`mame.exe` 를 교체하면 패치가 사라진다.** 재적용:
> ```powershell
> $exe='D:\AttractMode\emulators\PSXMAME\mame.exe'; $off=0x1039C1
> $b=[IO.File]::ReadAllBytes($exe)
> if ($b[$off] -ne 0x74) { throw '패치 위치 불일치 — 바이너리가 다른 빌드다' }
> $b[$off]=0xEB; [IO.File]::WriteAllBytes($exe,$b)
> ```
> 위치가 안 맞으면 다른 빌드다. `ui.c`의 `if (!first_time || (str > 0 && str < 60*5) || …)` 분기를
> 무조건 성립으로 바꾸는 것이 목적이므로, 상수 `300`(`cmp eax,0x12A`)과 그 앞의 `je` 를 찾아 같은 방식으로 처리한다.
> 되돌리려면 `git checkout -- emulators/PSXMAME/mame.exe`.

`emulators/Mame`의 MAME 0.289는 경고 화면 억제가 UI 옵션 `skip_warnings`(0.226부터)인데,
예전에는 `EKMAME64.exe` 와 `ui.ini` 를 공유해 넣지 못했는데, 2026-09-07 폴더를 나누면서 넣었다(4.7절).

### 4.7 MAME(0.289)와 EKMAME(0.224)은 **폴더가 나뉘어 있다** — 2026-09-07 분리

```
emulators\Mame\      mame64.exe 0.289   roms\{Arcade, Arcade Adult, Bios, Arcade CHD, Arcade Zinc}
emulators\EKMAME\    EKMAME64.exe 0.224 roms\Korean   ← 팬 한글화 롬 전용 (30종)
```

2026-09-07 이전에는 두 벌이 한 폴더에서 `mame.ini`·`plugins`·`cfg`·`roms` 를 공유했고,
그 때문에 45개가 Lua 오류로 멈추고 38개가 rompath 오타로 죽어 있었다(`docs/ISSUES.md` 46·48번).
분리하면서 `-pluginspath plugins-none` 우회와 `emulators/Mame/plugins-none/` 폴더는 없앴다.

**EKMAME 은 자기 `mame.ini` 를 갖는다.** 부모셋·BIOS 는 MAME 쪽 것을 상대경로로 빌려 쓴다.

```
rompath   roms;roms\Korean;..\Mame\roms\Arcade;..\Mame\roms\Bios
artpath   ..\Mame\artwork      samplepath ..\Mame\samples      cheatpath ..\Mame\cheat
```

> ⚠️ **EKMAME 의 ini 는 함정이 셋 있다. 0.212 에서 실측했고 0.224 도 같은 전제로 다룬다.**
>
> 1. **`mame.ini` 에 UTF-8 BOM 이 없으면 파일을 통째로 무시한다.** 오류도 경고도 없이
>    전부 기본값으로 돈다(`rompath` 가 `roms` 로 되돌아가 롬을 못 찾는다).
>    BOM 을 지웠다 되살리며 재현했다. **편집할 때 반드시 BOM 을 유지할 것.**
> 2. **`rompath` 에 따옴표·공백 경로를 못 쓴다.** `"...;..\Mame\roms\Arcade Adult"` 처럼 쓰면
>    역시 조용히 무시된다. 그래서 `pcktgalk` 의 부모 `pcktgal.zip` 은 `EKMAME\roms\Korean\` 에 복사해 뒀다.
> 3. **`writeconfig 0` 이 아니면 종료할 때 3바이트(BOM 만) 짜리 `plugin.ini` 를 써 놓고,
>    다음 실행에서 그걸 읽다 `Error loading plugin.ini` 대화상자를 띄운다.**
>    0.224 는 정상적인 `plugin.ini` 를 자기 폴더 루트에 만들어 둔다 — 그것을 추적한다.
>
> **`EKMAME64 -verifyroms` 는 결과를 stdout 이 아니라 메시지 박스로 낸다.** 자동 점검에 쓸 수 없다.
> 존재 확인은 `-listfull`, 실제 구동은 `test-roms.cmd`(대화상자를 `DIALOG` 로 잡는다)로 본다.

**롬 컬렉션은 MAME 0.289 판이다 (2026-09-07 교체).** 0.212 시절 롬셋이라 0.246 이 거부하던
61개 문제는 본체·롬 동시 갱신으로 해소했다(`docs/ISSUES.md` 47번).
2025-10-01 full split set 에서 **romlists 가 참조하는 것만 추린 1,005개**이고,
추린 기준은 romlist 항목(비활성 `#` 포함) → `mame.exe -listxml` 로 부모(`cloneof`)·BIOS(`romof`)·
디바이스 롬을 더 나오지 않을 때까지 따라간 폐포다. `mame64 -verifyroms` 전수로 확인했다
(good 774 / best available 102 / CHD 미보유 10 / 실제 누락 0).

**한글 롬은 EKMAME 전용이 아니다.** 49개 중 36개는 MAME 본가에 정식 클론으로 등재된
한국 발매판이라 0.289 로 그대로 돈다. 그래서 `EKMAME`→`MAME`, `EKMAME Vertical`→`MAME Vertical` 로 옮겼고
`EKMAME Vertical` 정의는 참조가 0 이 되어 지웠다. EKMAME 이 계속 필요한 것은
**MAME 본가에 없는 팬 한글화("Korean Translator") 14개뿐**이다.

> ⚠️ **`EKMAME\roms\Korean` 은 어떤 롬셋으로도 다시 만들 수 없다.** MAME 에 등재되지 않은 개조 롬이라
> 배포되는 세트에 존재하지 않는다. 지금 있는 파일이 유일본이다 — 갱신·정리할 때 절대 덮지 말 것.

> **셋 이름은 판마다 바뀐다.** 0.289 로 오면서 romlist 의 5개를 고쳤다 —
> `acedrvrw`→`acedrive`, `raveracw`→`raverace`, `getstar`→`grdian`, `kof99nd`→`kof99ka`,
> `pcktgalk`→ 본가에 없어 `EKMAME Adult` 로 이관. 앞의 넷은 0.246 에서도 이미 없던 이름이라
> 여태 실행되지 않고 있었다.

**경고 화면 억제** — 0.289 는 UI 옵션 `skip_warnings`(0.226+)를 지원한다.
폴더를 나눠 `ui.ini` 를 EKMAME 과 공유하지 않게 됐으므로 `emulators/Mame/ui.ini` 에 `skip_warnings 1` 을 넣었다.
불완전 덤프 셋(`is best available`)에서 뜨던 빨간 경고 화면을 넘긴다 — 실제 창으로 띄워 대기 없이 끝나는 것을 확인했다.
`PSXMAME`(0.139)에는 이 옵션이 없어 여전히 1바이트 패치로 처리한다(4.6절).

**`mame.ini` 의 `rompath` 가 실제 롬 탐색을 담당한다 — 폴더명이 한 글자만 달라도 전부 실패**

`roms\Arcade AD` 로 적혀 있어 실제 폴더 `roms\Arcade Adult` 를 못 찾았고, MAME Adult 목록 38개가 통째로 실행되지 않았다.
**cfg 의 `rompath` 는 목록 생성·`[romfilename]` 치환용일 뿐이라 이 오타를 가려 주지 못한다.**
`tools\validate.ps1` 도 cfg 쪽만 보므로 잡지 못한다 — 실제로 띄워 보는 `test-roms.cmd` 만이 잡는다.

### 4.8 에뮬레이터를 갱신하거나 폴더를 나눌 때

현재 들어 있는 것(2026-09-06 실측). **버전 열은 바이너리의 버전 리소스에서 읽은 것만 적었다** —
빈 칸은 리소스가 없어서 파일 날짜밖에 근거가 없다는 뜻이니, 갱신 전에 각자 실행해서 확인한다.

| 폴더 | 버전 | 파일 날짜 | 갱신할 때 걸리는 것 |
|---|---|---|---|
| `Mame` | **0.289** | 2026-07-30 | 2026-09-07 갱신. 롬 세트가 버전에 묶인다(4.7절 (2)). 세트 이름도 판마다 바뀐다 |
| `EKMAME` | EKMAME **0.224** | 2024-04-04 | 2026-09-07 분리 + 갱신. 지원 셋 8,740 -> 16,304 (4.7절) |
| `PSXMAME` | MAME 0.139 계열 | 2026-09-05 | ⚠️ **`mame.exe` 에 1바이트 패치**(4.6절). 교체하면 사라진다 |
| `SuperModel` | (0.3a-WIP · `revision.txt` 는 svn r757 까지) | 2018-11-28 | ⚠️ **개조 빌드다** — `revision.txt` 에 "sr2 music fix" 패치를 넣었다고 적혀 있다 |
| `Demul` | | 2018-04-28 | `-run=<플랫폼> -rom=` 인자 체계 |
| `M2` | | 2018-10-14 | 인자가 `[name]` 하나뿐이라 갱신 여파가 작다 |
| `PCSX2` | | 2020-05-07 | ⚠️ **최신판은 CLI 가 다르다.** 지금 쓰는 `--nogui --portable` 이 그대로 있는지 먼저 확인 |
| `ePSXe` | | 2018-11-14 | `-loadmemc0 "memcards\epsxe000.mcr"` 가 메모리카드를 직접 가리킨다 |
| `Dolphin` | | 2019-01-06 | `-b -e` 인자와 `Sys/`·`User/` 구조 |
| `Project64` | 3.0.1 | 2021-07-30 | `Config/`·`Save/` |
| `Cemu` | | 2022-02-18 | ⚠️ 인자가 `-f -g "<롬>\code\<롬>.rpx"` 라 **롬 폴더 구조에 묶여 있다** |
| `Mednafen` | 1.29.0 | 2022-01-18 | `firmware/` 의 BIOS 파일 이름이 고정이다 |
| `RetroArch` | | 2022-05-03 | `cores/` 는 gitignore. 코어와 본체의 ABI 가 맞아야 한다 |
| `PPSSPP` | 1.13.1 | 2022-07-28 | |
| `TeknoParrot` | 1.0.0.804 | 2022-08-01 | `UserProfiles/` 형식이 판마다 바뀐다 |

> ⚠️ **교체하면 이 저장소의 손질이 사라지는 바이너리가 둘 있다** — `PSXMAME/mame.exe`(4.6절)와
> `SuperModel/Supermodel.exe`. 둘 다 `.gitignore` 대상이 아니라 **git 추적 중**이므로
> `git checkout -- <경로>` 로 되돌릴 수 있다. 새 빌드를 쓰기로 했다면 그 손질을 다시 넣을지 먼저 정한다.
> (`Mame/mame64.exe`·`EKMAME64.exe` 는 반대로 미추적이라 되돌릴 원본이 저장소에 없다.)

**갱신할 때마다 같이 봐야 하는 자리**

1. **`emulators/<이름>.cfg` 의 `args`** — 에뮬레이터 CLI 는 메이저 버전에서 잘 바뀐다.
   MAME 의 `-fallback_artwork` 는 0.215+, `skip_warnings` 는 0.226+ 처럼 **버전 하한이 있는 옵션**이 섞여 있다.
   모르는 옵션을 만나면 MAME 계열은 **오류 대화상자를 띄우고 멈춘다**(7.5절 `DIALOG`).
2. **`rompath` / `romext`** — `executable` 이 있는 디렉터리 기준 상대경로(4.2절). 폴더를 옮기면 같이 고친다.
3. **`artwork` 경로** — 이쪽은 AM 루트 기준이다. 기준이 다르니 헷갈리지 말 것.
4. **`.gitignore`** — 폴더 이름으로 걸러내므로 폴더를 추가·개명하면 롬·코어가 추적되기 시작한다(S1 위험).
5. **`tools/reset-runtime.ps1` 의 `$ConfigPaths`·`$SavePaths`** — 경로가 하드코딩돼 있다.
6. **세이브** — `PCSX2/memcards`, `ePSXe/memcards`, `Project64/Save`, `Mame/nvram`, `SuperModel/NVRAM`,
   `Demul/nvram`, `RetroArch/saves`. 갱신 전에 따로 챙긴다.
7. **`stats/<Emulator>/`** — 에뮬레이터 정의 이름이 바뀌면 플레이 통계가 0으로 돌아간다(6절).
8. 끝나면 `tools\validate.ps1` → `test-roms.cmd` 전수 구동 점검(7.5절) 순으로 확인한다.
   **정적 점검만으로는 부족하다** — 인자가 안 먹는 것은 띄워 봐야 나온다.

**`Mame` 와 `EKMAME` 폴더 분리 — 2026-09-07 완료**

2026-09-07 이전에는 `emulators/Mame` 하나에 `mame64.exe`와 `EKMAME64.exe`가 같이 있고
`mame.ini`·`ui.ini`·`plugins`·`cfg`·`roms`·아트웍 폴더를 전부 공유했다. 아래를 손봐서 나눴다 — 다시 나눌 일이 있으면 같은 자리를 본다.

| 대상 | 지금 | 할 일 |
|---|---|---|
| `emulators/EKMAME.cfg`, `EKMAME Adult.cfg` | `executable emulators\EKMAME\ekmame64` | ✔ `-pluginspath plugins-none` 제거 |
| 두 cfg 의 `rompath` | `roms\Korean\` | ✔ `emulators\EKMAME\roms\Korean` 기준 |
| 두 cfg 의 `artwork` 4줄 | `emulators\mame\{flyer,marquee,video,wheel}` | ✔ 그대로 공유(AM 루트 기준, 용량이 커서 복제하지 않았다) |
| `mame.ini` | 공유 | ✔ EKMAME 전용 `mame.ini` 신설. 부모셋은 `..\Mame\roms\...` 로 빌려 쓴다 |
| `emulators/Mame/cfg/` | 두 MAME 이 게임별 입력 설정을 공유 | ✔ `emulators/EKMAME/cfg` 신설(빈 폴더에서 시작) |
| `.gitignore` | `emulators/Mame/roms` 등 폴더명 기준 | ✔ `emulators/EKMAME/{EKMAME64.exe,roms,nvram,hash,samples}` 추가 |
| `tools/reset-runtime.ps1` | `emulators/Mame/{cfg,ui.ini,nvram,…}` | ✔ `emulators/EKMAME/{cfg,ui.ini,nvram}` 추가 |
| `emulators/Mame/plugins-none/` | EKMAME 용 우회 | ✔ 삭제 |

> 나눈 뒤 **EKMAME 활성 11개를 전부 띄워 확인했다**(`test-roms.cmd -Launch -Emulator EKMAME*` → 11/11 PASS).
> 경로가 하나만 어긋나도 `Unknown system` 대화상자로 끝나는데, 그것은 정적 점검에 안 잡힌다.


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
  **새 마스코트를 만들 때**: 흰/단색 배경의 원화(공식 아트, 전단)를 구해
  `.claude\skills\arcade-audit\scripts\cutout.ps1 <in> <out> [-Mode white|light] [-Erase "x,y,w,h;…"] [-HoleTol 14 -HoleDark 20]` 로
  배경을 떼어내면 480×760 알파 PNG 가 나온다. GDI+ 가 못 여는 JPEG 는 `img-to-png.ps1` 로 먼저 변환.
  **머리카락·팔 사이처럼 피사체에 둘러싸인 흰 영역은 가장자리 플러드필이 못 닿는다** — `-HoleTol` 을 주면 둘레가 먹선인 고립 영역만 추가로
  지운다(둘레 조건 없이 지우면 흰 옷의 하이라이트까지 뚫린다, `docs/ISSUES.md` 42번). 머리카락처럼 둘레가 먹선이 아닌 곳이 남으면
  `-Debug <png>` 로 후보를 초록/빨강으로 확인하고 `-HoleBox "x,y,w,h"`(원본 픽셀)로 그 영역만 조건을 면제한다. 결과는 반드시 배경색을 깔고 확대해서 본다.
  **피사체가 직선으로 끝나는 소재**(전단 크롭, 무릎 컷)밖에 없으면 `fade-edge.ps1 <in> <out> -Bottom 90` 으로
  그 변을 알파 페이드시킨다 — 절단선이 화면 중간에 뜨는 것보다 낫다(`docs/ISSUES.md` 37·38번). `audit.ps1 -Section mascot` 이 직선 컷을 잡는다.
  소재가 열려 있는 곳: fightersgeneration.com(격투 캐릭터 공식 아트), flyers.arcade-museum.com(전단).
  Spriters Resource·Fandom·pngwing 류는 Cloudflare 가 스크립트 접근을 막는다.
- 디스플레이 메뉴 아트웍은 `menu-art/system|marquee|snap|wheel`(로컬 전용).

### 5.4 레이아웃 수정
- Squirrel(`.nut`). 모듈은 `fe.load_module("...")`, 하위 스크립트는 `fe.do_nut("scripts/...")`.
- **`NEVATO`와 `Console Box`는 공용 정적 자산(`background/ listbox/ key/ monitor/`)을
  바이트 단위로 똑같이 유지한다.** 한쪽만 고치면 두 레이아웃이 다르게 보인다(`docs/ISSUES.md` 35번).
  디스플레이별 폴더(`character/ system/ wheel/`)는 예외 — 디스플레이는 레이아웃을 하나만 쓴다.
  둘 중 하나를 바꾸면 반드시 다른 쪽에도 같은 파일을 넣고,
  `.claude\skills\arcade-audit\scripts\audit.ps1 -Section dupes`로 어긋남이 없는지 확인한다.
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
>
> 지금은 안전하지만 한 줄만 바꾸면 깨지는 곳 두 군데(`docs/ISSUES.md` 36번):
> - `romlists/MAME.txt`의 `뱀프½` — `½`(U+00BD)가 `default_font`인 `SUIT-Regular`에 **없다**.
>   NEVATO·Console Box가 `select_font = Font`(`fonts/font.ttf`, ½ 있음)라 지금은 보이지만,
>   `select_font`를 SUIT로 바꾸거나 폰트 폴백이 일어나면 두부가 된다.
> - NEVATO의 LCD 텍스트(`digital-7 (italic)`, 라틴·숫자만)가 `[FilterName]`을 표시한다.
>   `attract.cfg`의 필터 이름(All, Favourites, Fighting …)을 **한글로 바꾸는 순간** 두부가 된다.
>
> 표시 텍스트 ↔ 폰트 글리프 대조는 `.claude\skills\arcade-audit\scripts\audit.ps1 -Section glyph`가 한다.
- 수정 후 반드시 `attract.bat` 실행하고 `last_run.log`에 `AN ERROR HAS OCCURED`가 없는지 확인.
  고친 레이아웃만 골라 띄우려면 `tools\smoke-run.ps1 -Display <디스플레이> [-LayoutFile layout_vewlix_white] [-Layout Mega-Display]`(7.4절).

> ⚠️ **예외 줄을 지울 때는 그 아래 코드가 새로 살아난다.**
> Squirrel 예외는 그 스크립트의 **나머지 전체를 중단**시킨다. 그래서 오랫동안 예외를 던져 온
> 스크립트는 예외 지점 아래가 **한 번도 실행된 적 없는 죽은 코드**일 수 있고,
> 지금 보이는 화면이 그 죽은 코드가 빠진 결과일 수 있다.
> 예외를 고치면 그 코드가 처음으로 실행되면서 화면이 바뀐다 —
> 실제로 `arcade_name.nut`에서 이 방식으로 회귀가 났다(`docs/ISSUES.md` S2-3 참고).
> **예외 줄 아래 문장을 먼저 읽고, 그것이 실행돼도 되는 코드인지 판단한 뒤 지운다.**

### 5.5 MAME 계열 게임의 버튼 배열 바꾸기 (`emulators/<Mame|PSXMAME>/cfg/<게임>.cfg`)

게임별 입력은 MAME 자신이 쓰는 XML 형식이다. `<system name="<셋 이름>">` → `<input>` → `<port>`.

```xml
<port type="P1_BUTTON1" mask="16" defvalue="16">
    <newseq type="standard">
        JOYCODE_1_BUTTON4
    </newseq>
</port>
```

> ⚠️ **`type` 만 맞으면 되는 게 아니다.** `inptport.c` `load_game_config()` 는
> `type` · `player` · **`mask`** · **`defvalue`** 가 전부 맞아야 적용하고,
> 하나라도 틀리면 **오류 없이 조용히 무시**한다.

> ⚠️⚠️ **`mask`/`defvalue` 를 드라이버 소스에서 "읽어서" 정하지 말 것.**
> PSXMAME 은 MAME 0.139 기반이지만 **드라이버가 개조돼 있어 mainline 소스와 값이 다르다.**
> 실제로 namcos11 계열(tekken·tekken2·primglex·souledge)은 mainline 이 `mask=0x10 defvalue=0x10` 인데
> 이 빌드는 **`mask=4096 defvalue=0`** 이다(namcos12·zn6b 는 우연히 일치). 소스를 믿고 넣으면 조용히 무시된다.

**mask 는 바이너리에서 직접 알아낸다** — 후보 mask 를 전부 써 넣고 게임을 띄운 뒤 ESC 로 정상 종료하면,
MAME 가 다시 써 낸 cfg 에 **실제로 매칭된 것만** 남는다.

```
<port type="P1_BUTTON1" mask="1"     defvalue="1">…</port>   ┐ 1,2,4,8,…,32768 을
<port type="P1_BUTTON1" mask="1"     defvalue="0">…</port>   │ defvalue = mask / 0
<port type="P1_BUTTON1" mask="2"     defvalue="2">…</port>   ┘ 두 가지로 전부 나열
…  (P1/P2 × BUTTON1~6)
```

- **버튼 번호는 두 체계가 다르다.** MAME UI 가 보여 주는 `Joy 1 3` 은 **0-base**(DirectInput 이 준 이름),
  cfg 에 쓰는 `JOYCODE_1_BUTTONn` 은 **1-base**다. 즉 UI 의 `Joy 1 3` = `JOYCODE_1_BUTTON4`.
- 4버튼/6버튼 구분도 위 실측으로 정한다(`-listxml` 의 `buttons=` 는 드라이버가 공용 포트셋을 쓰면 실제와 다를 수 있다).
- `tag` 는 생략하면 전 포트를 훑으므로 **빼는 편이 안전하다**. 파일은 **UTF-8 BOM 없이** 저장한다.
- **검증법**: 게임을 띄우고 ESC 로 정상 종료하면 MAME 가 그 cfg 를 다시 쓴다.
  > 🚨 **다시 썼는지를 먼저 확인해야 한다.** MAME 가 써 낸 파일에는 **`tag="…"` 가 붙는다.**
  > `tag=` 가 없으면 그건 그냥 **내 파일이 그대로 남은 것**이지 성공이 아니다 —
  > 이걸 성공으로 오독해서 틀린 mask 를 장비까지 올린 적이 있다(`docs/ISSUES.md` 45번).
  > `tag=` 가 있고 그 안의 `JOYCODE` 가 내 값과 같아야 적용된 것이다.

  (프로세스를 강제 종료하면 `cfg/default.cfg` 가 0바이트로 잘릴 수 있으니 ESC 로 끝낼 것.)

현재 PSXMAME 은 격투게임 20종에 캐비닛 배열(윗줄 = 조이스틱 4·5·6, 아랫줄 = 1·2·3)을 적용해 뒀다
(`docs/ISSUES.md` 45번에 포트군별 mask 표).

### 5.6 손대지 말아야 할 것
- `default-*.cfg`, `emulators/script/`, `loader/`, `modules/`, `plugins/` — AM 벤더 원본.
  `plugins/`는 `attract.cfg`에 `plugin` 섹션이 없어 전부 비활성이지만, AM 설정 메뉴에서
  켤 수 있는 정상 자산이라 지우지 않는다.
- `layouts/Mega-Display` — 어떤 display도 쓰지 않지만 AM 레이아웃 메뉴에서 선택 가능한 예비 테마다.
- `emulators/PSXMAME/mame.exe` — **1바이트 패치가 들어가 있다**(4.6절). 새 빌드로 교체하면 시작 확인 창이 다시 뜬다.
- `emulators/EKMAME/mame.ini` — **UTF-8 BOM 이 없으면 EKMAME 이 통째로 무시한다**(4.7절). 편집할 때 BOM 유지.
  `writeconfig 0` 도 지우지 말 것 — 지우면 깨진 `plugin.ini` 를 스스로 써 놓고 다음 실행에서 멈춘다.

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
>
> **2차 정리(2026-09-04)** — 같은 기준으로 레이아웃 폴더 안쪽을 훑어 아래를 제거하고
> `archive/unused-assets-2026-09-04` 태그에 보존했다(`docs/ISSUES.md` 34번).
>
> | 대상 | 왜 지웠나 |
> |---|---|
> | `layouts/{NEVATO,Console Box}/character/* (2).png · (3).png` 12개, `Console Box/system/nintendo wii u (2).png` | 파일명이 디스플레이 이름과 달라 `[DisplayName]`으로 도달 불가 |
> | `layouts/{NEVATO,Console Box}/background/{1280,1920,2xScale}/` | 어떤 .nut도 참조 안 함. `2xScale`은 원본과 바이트 동일한 복사본 |
> | `fonts/NXL HD/{etc,download}/` | `font_path`는 `fonts;fonts/NXL HD`까지만 — 하위 폴더는 탐색 대상이 아님 |
> | `layouts/NXL HD/carrier.nut`, `layouts/NXL HD/assets/shaders/layout.nut` | 어느 `do_nut`도 안 부름 / 3단계 깊이라 AM 메뉴에 안 뜸(참조 이미지 22개·폰트가 전부 없는 데모 잔재) |
> | `layouts/**/bak/`, `layouts/**/*.psd`, `Thumbs.db` | 작업 원본·백업. AM이 읽는 파일이 아님 |
>
> 레이아웃 폴더의 미연결 자산은 `.claude/skills/arcade-audit/scripts/audit.ps1 -Section dispimg,dupes,fonts,junk`가 뽑아 준다.
- `License.txt`, `Readme.txt`, `Layouts.txt`, `Compile.txt`, `Changelog.txt` — AM 공식 문서.

### 5.7 Attract-Mode 본체 업그레이드

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
- 🚨 **`.gitignore` 는 추적 파일이라 브랜치마다 다르다 — `git clean` 을 함부로 돌리면 안 된다.**
  `develop` 에 새 무시 규칙을 넣은 직후에는 `main`·장비 브랜치가 아직 그 규칙을 모른다.
  그 브랜치에서 `git clean -fd` 를 돌리면 **거기서는 무시 대상이 아닌** 롬·실행파일이 통째로 지워진다.
  2026-09-07에 `main` 에서 실제로 `emulators/EKMAME/` 를 날렸다(2절의 경고 참고).
  잔재 정리는 `git clean` 이 아니라 `git checkout -f <브랜치>` 로 한다.
- `.gitignore`의 경로 대소문자는 2026-09-03에 실제 폴더명(`emulators/Mame` 등)과 맞췄다(불일치 0건).
  다만 **아트웍·레이아웃 자산은 여전히 Windows의 대소문자 무시에 기대고 있다**
  (`assets/buttons/1button.png` ↔ 실제 `1Button.png`, `menu-art/wheel/MAME.png` ↔ `mame.png`).
  Linux/macOS에서 클론하면 버튼 아이콘과 메뉴 아트가 사라진다.
  `layouts/NXL HD/Layout.nut`(대문자 L)은 그보다 심해서 레이아웃 자체가 안 열리는 문제라 2026-09-04에 `layout.nut`으로
  개명했다(`docs/ISSUES.md` 40번). 대소문자만 바꾸는 개명은 `git mv`를 임시 이름 경유로 두 번 한다.
  `audit.ps1 -Section case`가 `layouts/<name>/layout.nut` 철자를 감시한다.
- 줄바꿈은 `.gitattributes`(2026-09-03 신설)가 고정한다 — 저장소 LF, 작업트리 OS 기본, `*.bat`만 CRLF 강제.
  `core.autocrlf` 설정이 다른 PC에서도 전체 줄바꿈 diff가 나지 않는다.
- `attract.am`은 추적 중인데 실행할 때마다 내용이 바뀔 수 있다(런타임 상태 파일).
- `stats/`와 `emulators/Mame/cheat/output.{json,xml}`은 런타임 산출물이라 2026-09-04부터 무시 목록에 있다
  (그 전엔 cheat 산출물이 추적되고 있어 `reset-runtime.ps1`이 매번 "건너뜀"을 찍었다).
  `stats/`는 2.7.0부터 저장 경로가 `stats/<romlist명>/` → `stats/<Emulator명>/` 로 바뀌어서,
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

#### validate.ps1 이 못 보는 것 — 주기 재점검 스킬 `/arcade-audit`

`validate.ps1`은 **설정 파일의 상호 참조**를 본다. 레이아웃 스크립트 내부, 이미지의 규격(알파·크기),
폰트 글리프, 두 레이아웃의 어긋남 같은 것은 보지 않는다. 그쪽은 저장소 안 스킬이 맡는다.

```powershell
powershell -ExecutionPolicy Bypass -File .claude\skills\arcade-audit\scripts\audit.ps1            # 11개 섹션 전부
powershell -ExecutionPolicy Bypass -File .claude\skills\arcade-audit\scripts\audit.ps1 -Section mascot   # 하나만
```

| 섹션 | 보는 것 |
|---|---|
| `layout` | `.nut`의 리터럴 이미지·`do_nut`·`load_module` 대상 존재, 로드 불가 위치의 layout*.nut, 어디서도 안 부르는 .nut |
| `dispimg` | `character/ system/ wheel/[DisplayName]` 디스플레이별 존재, 이름이 안 맞는 죽은 복사본 |
| `mascot` | 480×760·알파 컷아웃 여부(투명 비율), **피사체가 직선으로 잘렸는지**(최외곽 불투명 행/열이 피사체 폭의 20% 이상) |
| `dupes` | NEVATO↔Console Box 공용 폴더 어긋남, 참조 없는 배경 변형, 바이트 동일 중복(두 레이아웃의 의도된 쌍은 INFO) |
| `fonts` · `glyph` | 참조 폰트 해석 가능 여부, **표시 텍스트 ↔ 폰트 글리프** |
| `cfg` · `case` | 값 끝 공백, 형제 cfg 일치, `layout_config` 값, romlist·.gitignore 대소문자, `layout.nut` 철자 |
| `branch` · `video` · `junk` | 장비 브랜치 전파, mp4 해상도·비트레이트, `(2)`·`bak/`·`.psd`·추적된 런타임 산출물 |

출력 태그는 `ISSUE`(보고) / `OK`(측정했고 이상 없음) / `INFO`. 읽기 전용이다.
Claude Code에서 `/arcade-audit <커밋…>`을 부르면 diff 정독 → validate → audit → 이미지 직접 열기 →
ISSUES "완료" 재검증 → 아티팩트 갱신까지 절차 전체를 따른다(`.claude/skills/arcade-audit/SKILL.md`).

### 7.2 진단 순서

1. **`last_run.log`를 먼저 읽는다.** 레이아웃 스크립트 에러, cfg 파싱 경고, 롬 로딩 결과가 전부 여기 남는다.
   로그가 갱신돼 있지 않다면 `attract.exe`를 직접 실행한 것이다 — **`attract.bat`으로 다시 실행한다**(4.5절).
   특정 디스플레이·레이아웃만 골라 띄우고 싶으면 `tools\smoke-run.ps1`(7.4절) — 저장소의 `attract.am`을 건드리지 않는다.
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
| **설정** | `attract.am`, `Mame\cfg`(게임별 입력·딥스위치), `Mame\ui.ini`, `PSXMAME\cfg`, `RetroArch\retroarch.cfg`·`content_*.lpl`, `PCSX2\inis`, `M2\CFG`·`M2\EMULATOR.INI`, `Project64\Config`, `TeknoParrot\UserProfiles`, `Demul\*.ini`, `PPSSPP\...\SYSTEM` | 잃는 것 없음 |
| **세이브** | `Mame\{nvram,memcard,diff,sta}`, `PCSX2\{memcards,sstates}`, `ePSXe\{memcards,sstates}`, `Project64\Save`, `SuperModel\{NVRAM,Saves}`, `Demul\nvram`, `RetroArch\{saves,states}` | **게임 진행이 사라진다** |
| **산출물** | `last_run.log`, `script.nv`, `stats\`, `Mame\hiscore`, `Mame\data\history.db`, `Mame\cheat\output.*`, `RetroArch\screenshots` | 미추적이라 삭제 |

- 인자 없이 실행하면 **아무것도 건드리지 않고 목록만** 보여준다.
- 평소 정리는 `-Config -Clean`이면 충분하다. `-Saves`는 게임 진행이 날아가니 의식적으로 붙인다.
- `-Force`를 빼면 실행 전에 한 번 물어본다.
- 되돌리기는 `git checkout --`이므로 **커밋되지 않은 의도적 수정도 함께 날아간다.**
  런타임 파일을 일부러 고쳤다면 먼저 커밋할 것.
### 7.4 실행 점검 — 레이아웃 수정 뒤 캐비닛 없이 로그 보기

```powershell
powershell -ExecutionPolicy Bypass -File tools\smoke-run.ps1 -Display "Taito Type X"                 # 그 디스플레이로 바로 시작
powershell -ExecutionPolicy Bypass -File tools\smoke-run.ps1 -Display MAME -LayoutFile layout_vewlix_white   # L키 변형 지정
powershell -ExecutionPolicy Bypass -File tools\smoke-run.ps1 -Display MAME -Layout Mega-Display      # 레이아웃을 임시로 바꿔 로드
powershell -ExecutionPolicy Bypass -File tools\smoke-run.ps1 -All                                    # NEVATO·Console Box·NXL HD·Mega-Display 4종
```

**정적 검증(validate·audit)은 Squirrel 런타임 오류를 못 본다.** 3차 재점검의 수정 9건이 하루 동안 실행 확인 없이 남아 있었던 것이
`docs/ISSUES.md` 39번이다. 이 스크립트는 `%TEMP%\attractmode-smoke-run\`에 저장소 폴더들을 **정션으로 연결한 격리 설정 디렉터리**를 만들고
`attract.cfg`·`attract.am` 사본만 고쳐 `attract.exe --config`로 띄운다. 그래서 저장소의 `attract.am`이 바뀌지 않고 `git status`가 더러워지지 않는다.

- `attract.am` 0행이 현재 디스플레이 인덱스(= `attract.cfg`의 `display` 순서), **(인덱스+1)행**이 그 디스플레이의 상태로 `…;<레이아웃 파일>;0;`에
  L키로 고른 `layout_vewlix_*` 이름이 들어간다. `-LayoutFile`이 그 자리를 쓴다.
- 지정한 초(기본 20) 동안 **화면을 AM이 차지한다.** 창 모드는 480×320이라 NEVATO가 지원하지 않는 종횡비(1.5)가 되어 쓰지 않는다.
- 로그에 `AN ERROR HAS OCCURED`·`Script Error`가 있으면 종료 코드 1과 함께 그 부분을 출력한다.
- 이 PC의 모니터 종횡비로만 검증된다(5:4 데스크톱에서는 NEVATO의 `5x4` 분기). 16:9 캐비닛 분기는 캐비닛에서 봐야 한다.

### 7.5 롬 구동 검증 — romlist 전 항목이 실제로 실행되는가

```
test-roms.cmd                                          인자 없이 실행하면 메뉴 (캐비닛에서 더블클릭)
test-roms.cmd -Launch -List MAME -Sample 3             인자를 주면 그대로 tools\test-roms.ps1 에 넘어간다

powershell -ExecutionPolicy Bypass -File tools\test-roms.ps1              # 정적 점검 (전체 1,079개, 수 초)
powershell -ExecutionPolicy Bypass -File tools\test-roms.ps1 -Launch -Sample 1   # 에뮬레이터별 1개씩 실제 실행
powershell -ExecutionPolicy Bypass -File tools\test-roms.ps1 -Launch             # ★ 전수 점검 (1,079개 전부 실행)
powershell -ExecutionPolicy Bypass -File tools\test-roms.ps1 -Launch -Resume     # 중단된 전수 점검 이어서
powershell -ExecutionPolicy Bypass -File tools\test-roms.ps1 -Launch -Name tekken
powershell -ExecutionPolicy Bypass -File tools\test-roms.ps1 -Launch -Failed     # 직전 보고서의 실패 항목만
```

메뉴는 `[1]` 빠른(정적) 점검, `[2]` 표본 · `[3]` 전수 · `[4]` 이어하기 · `[5]` 목록 지정 ·
`[6]` 이름으로 · `[7]` 실패만 다시(구동), `[8]`·`[9]` 보고서 순이다.

`validate.ps1`(7.1절)이 **설정끼리 앞뒤가 맞는지**를 본다면, 이쪽은 **AM 이 실제로 만들어 낼 실행 명령**을
romlist 한 줄 한 줄에 대해 그대로 조립한다. `emulators/<Emulator>.cfg` 의 `executable`·`rompath`·`romext`·`args` 를
읽어 `[romfilename]`·`[rompath]`·`[romext]`·`[name]` 을 AM 과 같은 방식으로 치환하므로,
결과 CSV 의 `Exe`/`Args` 열이 곧 **캐비닛에서 게임을 고를 때 실행될 명령 그 자체**다.

| 상태 | 뜻 |
|---|---|
| `OK` | 실행파일·롬·인자까지 조립 완료 (정적 점검의 통과) |
| `PASS` | `-Launch` 에서 지정 시간(기본 12초) 동안 살아 있었고, **대화상자가 아닌 진짜 창**을 갖고 있었다 |
| `NOCHK` | 롬 존재를 단정할 수 없는 정의. **실패가 아니다** — 고정 실행형(`Taito Type X The BishiBashi`)과 `romext` 가 없는 Demul 정의 |
| `NOEMU`/`NOEXE`/`NOROM` | 에뮬레이터 정의·실행파일·롬 없음 |
| `EXIT0`/`CRASH` | 실행 직후 스스로 종료. 롬을 못 읽고 조용히 닫히는 경우가 대부분 |
| `DIALOG` | 살아 있지만 떠 있는 것이 **오류 대화상자**다. 게임은 시작되지 않았다. 상자 안 문구가 `Detail` 에 들어간다 |
| `NOWIN` | 살아 있으나 창이 없음. 런처가 다른 프로세스를 띄운 경우(경고) |

- **"살아 있으면 통과"로 보면 안 된다.** 오류 대화상자를 띄운 채 서 있는 프로세스도 살아 있다.
  그래서 판정은 프로세스의 **보이는 최상위 창을 전부 훑어** 창 클래스가 `#32770`(윈도우 표준 대화상자)인 것이
  하나라도 있으면 `DIALOG`(실패), 대화상자가 아닌 창이 있으면 `PASS` 로 한다.
  `Process.MainWindowHandle` 만으로는 그 창이 게임 화면인지 오류 상자인지 구별하지 못한다 —
  실제로 EKMAME 45개가 이 때문에 첫 전수 점검에서 `PASS` 로 잡혔다(`docs/ISSUES.md` 46번).
- 결과는 `logs\rom-test-<날짜시각>.{csv,html}` 두 벌. **HTML 쪽이 사람이 볼 보고서**다 —
  상태별 카드로 필터, 목록·에뮬레이터별 집계, 검색, 행을 누르면 실제 실행 명령이 펼쳐진다.
  캐비닛에 인터넷이 없어도 되도록 CSS·JS·데이터를 전부 파일 안에 넣은 단일 파일이고,
  열었을 때 **문제가 있는 항목부터** 보여준다(실패 → 경고 → 확인 불가, 전부 정상이면 전체).
  `-Open` 이면 끝나고 바로 띄운다(`test-roms.cmd` 메뉴는 항상 붙인다). `-NoHtml` 로 끌 수 있다.
- `-Failed` 는 `logs\rom-test-*.csv` 중 최신 파일을 읽어 실패 항목만 다시 돈다.
- **`-Launch` 는 ESC → 창 닫기 → 강제 종료 순으로 끝낸다.** MAME 계열을 강제 종료하면 `cfg\default.cfg` 가
  0바이트로 잘리기 때문이다(5.5절). 강제 종료까지 갔으면 보고서 `Detail` 에 남고, `default.cfg` 가 잘렸으면
  되돌리는 명령을 화면에 띄운다.
  - ESC 는 **스캔코드(`SendInput`)로 보낸다.** MAME 는 DirectInput 으로 키보드를 읽어서
    `WScript.Shell` 의 `SendKeys` 를 **받지 않는다**(PSXMAME 로 실측).
  - 보내기 전에 **포그라운드 창의 PID 가 그 프로세스인지 확인한다.** 그 사이 게임이 죽어 있으면
    ESC 가 터미널로 들어간다(`docs/ISSUES.md` 45번의 교훈). `AppActivate` 의 반환값은 쓰지 않는다 —
    이미 포그라운드인 창에도 `False` 를 돌려준다.
  - 그래도 **`emulators/Mame` 의 MAME 0.289 는 ESC 로 끝나고, PSXMAME(0.139)는 끝나지 않아 강제 종료된다.**
    PSXMAME 를 많이 돌린 뒤에는 `git status` 로 `emulators/PSXMAME/cfg/` 를 한 번 보는 편이 좋다.
- **전수 점검은 몇 시간짜리다.** 그래서 `-Launch` 는 **5건마다 보고서를 써 두고**, 중단하면 `-Resume` 이
  직전 보고서에 이미 있는 항목을 건너뛰고 같은 파일에 이어 쓴다. 강제 종료(`taskkill /F`)로도
  여기까지의 결과가 남는 것을 실측했다.
  - **항목당 소요는 ESC 가 먹느냐에 갈린다.** 포그라운드에서 ESC 로 바로 끝나면 판정 시간 + 2~3초지만,
    창이 최소화돼 있거나 ESC 를 안 받는 에뮬레이터는 재전송·창닫기·강제 종료를 거쳐 **20초를 넘긴다.**
    전수 점검은 그 PC 를 점유하고 **포그라운드에서** 돌리는 편이 훨씬 빠르다.
- 실행하면 런타임 파일(`Mame\cfg\*.cfg`, `M2\EMULATOR.INI`, `hiscore\`, `stats\` …)이 바뀐다.
  끝나면 `reset-runtime.ps1 -Config -Clean`(7.3절). 다만 **처음 실행한 게임의 `Mame\cfg\<게임>.cfg` 는
  미추적 파일로 새로 생기므로** `git checkout` 대상이 아니다 — `git status` 에 남으면 직접 지운다.
- **`Emulator` 필드가 아니라 실제 실행까지 보는 유일한 수단**이지만, 게임이 "정상 플레이되는가"까지는 못 본다.
  프로세스가 살아 있는지만 본다 — 검은 화면으로 떠 있는 것과 구별하지 못한다.

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
- **S2**: `.git`이 1.2GB. 에뮬레이터 바이너리 전량이 추적 중이다.

둘 다 히스토리 재작성이 필요하고 브랜치 7개와 `archive/*` 태그 11개 전부에 영향을 주므로, **손대기 전에 전체 백업**한다.
