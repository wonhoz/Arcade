# 자산 버전관리 정책 (롬 · BIOS · 아트웍)

이 저장소는 **설정을 버전관리하고, 대용량·저작권 자산은 저장소 밖에 둔다.**
그 경계가 어디이고 왜 그런지, 그리고 새 장비에 어떻게 복원하는지를 여기서 정한다.

관련 문서: [`../CLAUDE.md`](../CLAUDE.md) (구조·작업 규칙) · [`ISSUES.md`](ISSUES.md) (미해결 과제)

---

## 1. 세 가지 등급

| 등급 | 대상 | git 추적 | 이유 |
|---|---|---|---|
| **A. 추적한다** | `attract.cfg`, `emulators/*.cfg`, `romlists/`, `layouts/`, `modules/`, `plugins/`, `scraper/`, `fonts/`, `sounds/`, `shaders/`, `language/`, `tools/`, `docs/` | ✅ | 손으로 만든 설정. 잃으면 재현 불가. 전부 합쳐 수십 MB. |
| **B. 추적하지 않는다 (용량)** | 롬/ISO/디스크이미지, 에뮬레이터 캐시(`shaderCache`, `scache`), `menu-art/` 동영상·스냅·플라이어, MAME `hash/ artwork/ nvram/ roms/`, RetroArch `cores/ system/` | ❌ | 재취득 가능하고 GB 단위. |
| **C. 추적하면 안 된다 (저작권)** | 게임 롬, 콘솔 BIOS(PS1/PS2/새턴/PC-FX), 에뮬레이터 실행 바이너리 | ❌❌ | 재배포 금지 저작물. **공개 저장소에서는 DMCA 사유.** |

> ⚠️ **현재 C등급 위반이 있다.** PS2 BIOS 94개(153MB), PS1/새턴/PC-FX BIOS, 상용 SNES 롬 3개가
> 추적 중이다. `.gitignore`가 롬 폴더는 막았지만 `bios/`·`firmware/` 폴더는 막지 않아 빠져나갔다.
> 조치 방안은 [`ISSUES.md` S1-1](ISSUES.md) 참고.

## 2. 아트웍 — 현황 실측

`menu-art/` 전체 **6.5GB**. 종류별로 성격이 완전히 다르다.

| 종류 | 전체 | romlist에 실제 등장하는 것만 | 역할 |
|---|---|---|---|
| `video` | **5.3GB** (663) | — | 게임 동영상. 압도적으로 큼 |
| `snap` | 635MB (74) | — | 스크린샷 |
| `flyer` | 300MB (544) | — | 전단지 (배경 아트) |
| `cartridge` | 117MB (449) | 70.6MB (257) | 콘솔 패키지 이미지 |
| `wheel` | 88.5MB (880) | **52.2MB (439)** | ★ 게임 선택 휠의 로고 |
| `marquee` | 29.5MB (291) | 19.7MB (154) | 마키 |
| `character` | 14.6MB (43) | 6.8MB (21) | 캐릭터 이미지 |

MAME 공용 아트웍(`emulators/Mame/`)은 6,349개 전체 세트를 통째로 갖고 있어 낭비가 크다.

| 종류 | 전체 | romlist에 실제 등장하는 것만 |
|---|---|---|
| `emulators/Mame/marquee` | 1,096MB (6,349) | 280MB (919) |
| `emulators/Mame/wheel` | 376MB (6,349) | **66.0MB (919)** |

romlist에 등장하는 Name은 (비활성 포함) **1,624개**뿐이다. 나머지는 전부 쓰이지 않는다.

## 3. 정책

### 3.1 지금 정한 것

- **`menu-art/`와 MAME 아트웍은 계속 추적하지 않는다.** 6.5GB + 1.4GB를 이미 1.3GB인 저장소에
  넣을 수 없다. `.gitignore` 현행 유지.
- 대신 **아트웍 없이도 프론트엔드는 정상 동작한다**는 점을 전제로 한다.
  AM은 아트웍이 없으면 해당 영역을 비워둘 뿐 오류를 내지 않는다.
- 새 장비 배포 시 아트웍은 **git이 아니라 직접 복사**한다 → [`../README.md`](../README.md) 참고.

### 3.2 추적 대상을 늘린다면 (미결정 — 사용자 판단 필요)

저장소 히스토리를 재작성해 크기를 줄인 뒤라면, **"실제로 쓰는 휠(wheel)만" 추적**하는 선택지가 있다.

| 안 | 추가 용량 | 얻는 것 |
|---|---|---|
| **1안 — 휠만** | **약 118MB** (menu-art 52MB + MAME 66MB, 1,358개) | 클론 직후에도 게임 선택 화면이 제 모습으로 보인다 |
| 2안 — 휠 + 마키 + 캐릭터 + 카트리지 | 약 495MB | 정지 아트웍 대부분 복원 |
| 3안 — 현행 유지 | 0 | 아트웍은 항상 수동 복사 |

**1안을 권장한다.** 휠은 게임 선택 화면의 핵심이고 개당 평균 90KB로 작다.
단, 이건 저장소 크기에 직결되는 결정이므로 **실행 전에 확인이 필요하다.**
실행한다면 반드시 [`ISSUES.md` S1-1 / S2-4](ISSUES.md)의 히스토리 정리를 **먼저** 끝낸 뒤에 한다.

### 3.3 미사용 아트웍 정리

`emulators/Mame/{wheel,marquee}`에서 romlist에 없는 5,430개(약 1.1GB)를 지우면
디스크만 회수된다(git 추적 대상이 아니므로 저장소 크기와 무관). 게임을 추가할 때
아트웍을 다시 구해야 하므로 **급하지 않으면 그대로 두는 편이 낫다.**


### 3.4 에뮬레이터 바이너리를 여러 버전 두는 경우

MAME 계열은 롬셋이 버전에 민감해서 **신버전에서 안 되는 롬이 구버전에서 되는 일**이 있다.
그래서 이 저장소에는 구버전 실행파일이 함께 놓여 있다.

| 파일 | 버전 | 용도 |
|---|---|---|
| `emulators/Mame/mame64.exe` | 0.246 (2022-07) | 기본 |
| `emulators/Mame/mame64-0.220.exe` | 0.220 (2020-04) | 폴백 — `raycris` 는 여기서만 검증된다 |
| `emulators/Mame/EKMAME64.exe` | 0.212 (2019-08) | 한글 롬 전용 (`EKMAME.cfg`) |

**규칙**

- 이름에 **버전을 넣는다.** `mame64 - 복사본 (2).exe` 같은 이름은 몇 년 뒤에
  왜 있는지 알 수 없어진다(실제로 그렇게 돼서 이번에 실행해보고서야 정체를 확인했다).
- **MAME 루트에 그대로 둔다.** 하위 폴더로 옮기면 `mame.ini`·`hash`·`roms` 를
  공유하지 못해 별도 설정이 필요해진다.
- `.gitignore` 는 `emulators/Mame/mame64*.exe` / `*.sym` 로 **버전별 파일까지 포괄**한다.
  용량이 커서 추적하지 않지만, `git status` 에 노이즈로 뜨지도 않게 한다.
- 구버전으로만 되는 롬을 목록에 올리려면 전용 cfg(`MAME 0.220.cfg`)를 만들어야 하는데,
  **그 바이너리가 없는 장비에서는 실행이 깨진다.** 장비 전체에 배포할 수 있을 때만 한다.
## 4. 아트웍 배치 규칙

파일명은 **romlist의 `Name`(1번 필드)과 정확히 같아야** 한다. 확장자는 무관
(`.png` `.jpg` `.mp4` 등 AM이 알아서 찾는다).

```
menu-art\<시스템 이름 소문자>\
    flyer\      <Name>.jpg      배경 아트
    marquee\    <Name>.png      마키
    wheel\      <Name>.png      선택 휠 로고
    video\      <Name>.mp4      동영상 스냅
    character\  <Name>.png      캐릭터 (Console Box 레이아웃)
    cartridge\  <Name>.png      패키지 (Console Box 레이아웃)

emulators\Mame\{flyer,marquee,video,wheel}\<Name>.<ext>     MAME 계열 공용
```

- 정확한 검색 경로와 우선순위는 각 `emulators/*.cfg`의 `artwork` 줄에 있다.
  `;`로 구분된 앞쪽 경로부터 찾고, 없으면 다음 경로로 넘어간다
  (예: SEGA NAOMI → `menu-art\demul\...` 없으면 `emulators\mame\...`).
- **artwork 경로는 AM 루트 기준**이다 (rompath와 달리 executable 기준이 아니다).
- 디스플레이 선택 메뉴의 아트웍은 `menu-art\{system,marquee,snap,wheel}\`에 있고,
  파일명은 **디스플레이 이름**을 쓴다.

### 파일명 주의

Windows는 대소문자를 구분하지 않으므로 **대소문자만 다른 `Name`은 아트웍이 서로 덮어쓴다.**
현재 `romlists/NESiCAxLive.txt`의 `tekken`(철권, PSXMAME)과 `Tekken`(철권 태그 토너먼트 2, Wii U)이
이 경우에 해당한다. `tools/validate.ps1`이 이런 충돌을 경고로 잡아준다.

## 5. 점검

```powershell
powershell -ExecutionPolicy Bypass -File tools\validate.ps1
```

아트웍 경로 누락은 `WARN [artwork] ...`로 나온다. 게임을 추가한 뒤 이 스크립트를 돌려
아트웍 파일명이 `Name`과 어긋나지 않았는지 확인한다.
