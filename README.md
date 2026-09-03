# Arcade — Attract-Mode 고전게임 실행환경

Attract-Mode 프론트엔드와 에뮬레이터, 게임 목록·아트웍 설정을 한 벌로 묶은
**아케이드 캐비닛 실행환경**입니다. 클론하면 그대로 돌아가는 소스 프로젝트가 아니라,
런타임 디렉터리 자체를 버전관리하는 형태입니다.

| | |
|---|---|
| 프론트엔드 | Attract-Mode v2.7.0 (Windows / SFML 2.5.1) |
| 디스플레이 | 21개 (MAME, Capcom, SNK Neo Geo, SEGA MODEL 2/3, NAOMI, Atomiswave, Taito Type X, TeknoParrot, Zinc, NESiCAxLive, PS1/PS2/PSP, N64, GameCube, Wii, Wii U, Saturn, Dreamcast, MAME Adult) |
| 에뮬레이터 정의 | 35개 |
| 게임 항목 | 활성 1,079개 (비활성 포함 1,624개) |
| UI 언어 | 한국어 |

## 문서

| 문서 | 내용 |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | **작업 지침서.** 구조·데이터 흐름·경로 규칙·작업 레시피·진단 순서 |
| [`docs/ASSETS.md`](docs/ASSETS.md) | 롬·BIOS·아트웍 버전관리 정책과 배치 규칙 |
| [`docs/ISSUES.md`](docs/ISSUES.md) | 알려진 문제와 개선 과제 (심각도순) |

---

## 새 장비에 설치하기

> ⚠️ **클론만으로는 실행되지 않습니다.** 롬·BIOS·에뮬레이터 코어·아트웍은
> 저작권과 용량 때문에 저장소에서 제외되어 있습니다([`docs/ASSETS.md`](docs/ASSETS.md) 참고).
> 아래 2~4단계에서 기존 설치본이나 별도 보관본에서 직접 복사해야 합니다.

### 1. 클론

```powershell
git clone https://github.com/wonhoz/Arcade.git D:\AttractMode
cd D:\AttractMode
git checkout bartop        # 장비에 맞는 브랜치 선택 (아래 표 참고)
```

설치 경로는 `D:\AttractMode`를 권장합니다. 설정 대부분은 상대경로라 다른 경로도 되지만,
`emulators/Mame/mame.ini`에 절대경로가 한 줄 남아 있어 확인이 필요합니다.

| 브랜치 | 대상 |
|---|---|
| `main` | 공통 베이스 (직접 실행용이 아님) |
| `develop` | 공통 작업 브랜치 — 모든 장비에 적용될 변경은 여기서 (직접 실행용이 아님) |
| `bartop` | 바탑 캐비닛 |
| `desktop`, `desktop-ASUS-TUF`, `desktop-MSI-Sword`, `desktop-MSI-Sword-DriveWheel`, `desktop-keyboard` | 데스크톱 각 사양 |
| `Compact` | 50GB 축소판 |

### 2. 에뮬레이터 실행 파일 / 코어

git에서 제외된 것들을 기존 설치본에서 복사합니다.

```
emulators\Mame\mame64.exe          emulators\Mame\EKMAME64.exe
emulators\Mame\hash\               emulators\Mame\artwork\
emulators\RetroArch\cores\         emulators\RetroArch\system\
```

`emulators\RetroArch\cores\fbneo_libretro.dll`은 NESiCAxLive 한글패치 게임에 반드시 필요합니다.

### 3. BIOS

| 에뮬레이터 | 위치 |
|---|---|
| ePSXe (PS1) | `emulators\ePSXe\bios\` — `SCPH1001.BIN`, `scph5500.bin` |
| PCSX2 (PS2) | `emulators\PCSX2\bios\` |
| Mednafen (새턴/PC-FX) | `emulators\Mednafen\firmware\` |
| MAME | `emulators\Mame\roms\Bios\` |

### 4. 롬과 아트웍

`emulators/*.cfg`의 `rompath`가 가리키는 위치에 넣습니다.
경로는 **executable이 있는 디렉터리 기준 상대경로**입니다.

```
emulators\Mame\roms\{Arcade, Arcade Adult, Arcade CHD, Arcade Zinc, Bios, Korean}\
emulators\RetroArch\system\fbneo\patched\      NESiCAxLive 한글패치 롬
emulators\Demul\{Roms, Disc Image}\            NAOMI / Atomiswave / Dreamcast
emulators\M2\Roms\                             SEGA MODEL 2
emulators\SuperModel\ROMs\                     SEGA MODEL 3
emulators\ePSXe\isos\                          PS1
emulators\PCSX2\Game ISO\                      PS2
emulators\PPSSPP\Game ISO\                     PSP
emulators\Project64\Roms\                      N64
emulators\Dolphin\Game ISO\                    GameCube / Wii
emulators\Cemu\Roms\                           Wii U
emulators\Mednafen\ISO\ss\                     SEGA Saturn
emulators\PSXMAME\roms\                        Zinc
emulators\TeknoParrot\Games\                   TeknoParrot
emulators\Taito Type X\<게임별 폴더>\           Taito Type X

menu-art\                                      아트웍 (약 6.5GB, 없어도 실행됨)
```

### 5. 점검

```powershell
powershell -ExecutionPolicy Bypass -File tools\validate.ps1
```

설정과 실제 파일이 어긋난 곳을 잡아줍니다. 결과는 네 단계로 나옵니다.

| 단계 | 뜻 |
|---|---|
| `FAIL` | 저장소가 깨진 상태 — 반드시 고쳐야 합니다 |
| `WARN` | 저장소 차원의 문제 — 모든 장비에서 똑같이 나오며 기대값은 0입니다 |
| `환경` | 롬·아트웍·게임 미설치 — **장비마다 다르며 정상입니다** |
| `참고` | 알고 있고 그대로 두기로 한 것 |

`FAIL`과 `WARN`이 0이면 실행 가능한 상태입니다.
`환경`은 아직 옮기지 않은 롬·아트웍을 알려주므로 설치 중에는 체크리스트로 쓸 수 있습니다.

### 6. 실행

```
attract.bat             실행 (이걸 쓰세요)
```

> ⚠️ **`attract.exe`를 직접 실행하지 마세요.**
> Attract-Mode 2.7.0부터 윈도우 배포본은 `attract-console.exe`를 없애고 `attract.exe` 하나를
> **콘솔 앱으로** 빌드합니다. 그대로 실행하면 ⑴ 검은 콘솔 창이 뜨고 ⑵ **`last_run.log`가 만들어지지 않습니다.**
> `attract.bat`은 `--logfile` 옵션으로 로그를 되살리고, `attract.cfg`의 `hide_console yes`가 콘솔 창을 숨깁니다.
> 캐비닛 자동 시작(바로가기·시작프로그램)도 `attract.bat`을 가리켜야 합니다.
> 자세한 내용은 [`CLAUDE.md`](CLAUDE.md) 4.5절.

문제가 생기면 **`last_run.log`를 먼저 봅니다.** 레이아웃 스크립트 오류, 설정 파싱 경고,
목록 로딩 결과가 전부 여기에 남습니다.

---

## 조작

| 동작 | 키보드 | 조이스틱 |
|---|---|---|
| 선택 | `Enter` | Button 0 |
| 뒤로 | `Esc` | Button 1 |
| 이전/다음 시스템 | `Ctrl+←/→`, `,` `.` | Button 5 / Button 2 |
| 이전/다음 필터 | `Ctrl+↑/↓` | Button 3 / Button 4 |
| 즐겨찾기 | `Ctrl+F` | Button 6 |
| 설정 | `Tab` | Button 7 |
| 시스템 메뉴 | `D` | |
| 종료 | `Shift+Esc` | |
| 게임 중 종료 | `Esc` | Button 6 + Button 7 |

---

## 작업 흐름

1. 공통 변경은 **`develop`(= `main` 기반)에서** → `main`에 병합 → 각 장비 브랜치에서 `git merge main`
   (장비 브랜치에서 직접 작업하면 장비 전용 변경과 뒤섞여 다른 장비로 옮기기 어려워집니다)
2. 장비 전용 변경(레이아웃, 입력맵, 롬 구성)은 해당 브랜치에만
3. 게임을 추가하거나 설정을 고쳤으면 `tools\validate.ps1` 실행
4. 구조·규칙이 바뀌었으면 [`CLAUDE.md`](CLAUDE.md)와 [`docs/ISSUES.md`](docs/ISSUES.md)를 같은 커밋에서 갱신

게임을 실행하면 입력 설정·세이브 같은 런타임 파일이 바뀌어 `git status` 가 지저분해집니다.
`tools\reset-runtime.ps1` 로 한 번에 정리할 수 있습니다(인자 없이 실행하면 목록만 보여줍니다).

자세한 절차는 [`CLAUDE.md`](CLAUDE.md)의 "자주 하는 작업 레시피"에 있습니다.
