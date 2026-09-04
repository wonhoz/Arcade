---
name: arcade-audit
description: AttractMode 저장소 주기 재점검. 지정 커밋(또는 마지막 점검 이후 main)에서 한 작업을 파악하고, 설정·로직·문서뿐 아니라 그림·영상·폰트 같은 미디어 자산까지 품질을 스크리닝해 결함/미흡 목록을 만들고, 재점검 아티팩트를 갱신한다. "재점검", "스크리닝", "audit", "커밋 검토해서 리스트업" 요청에 사용.
---

# /arcade-audit — AttractMode 저장소 주기 재점검

인자: 검토할 커밋 해시(들). 없으면 `docs/ISSUES.md` 머리말의 마지막 점검일 이후 `origin/main` 커밋 전부.

## 기본 규칙 (사용자가 정한 것)

- **S1(BIOS·상용 롬 커밋)·S2(.git 용량, 대용량 바이너리)는 별도 지시가 없으면 언급하지 않는다.**
  단, "동일 파일 중복"·"어디서도 참조되지 않는 자산"은 용량이 아니라 **정합성 문제**이므로 다룬다.
- 텍스트 설정·로직만이 아니라 **그림·영상·폰트를 실제로 열어 보고** 품질(규격·투명 배경·크롭·해상도)을 본다.
  개수만 맞춘 "처리 완료"는 완료가 아니다.
- 결과는 아티팩트 **「AttractMode 재점검」(`https://claude.ai/code/artifact/77ac70c7-4034-4802-bd9b-5acde31da921`)** 을
  `url` 로 지정해 **같은 주소에 갱신**한다. 먼저 `action: read` 로 현재 판을 읽는다. 새 아티팩트를 만들지 않는다.
- 오탐(의심했다가 아니었던 것)도 기록한다. 다음 회차가 같은 길을 가지 않게 하는 것이 목적이다.
- 점검 단계에서는 저장소를 손대지 않는다(읽기 전용). 수정은 사용자가 따로 지시할 때 한다.
- **웹 검색·다운로드는 항상 허용이다.** 소재가 부족해 임시본을 만들기 전에 웹에서 더 나은 것을 찾는다 —
  마스코트 컷아웃, 시스템 로고, 배경, 폰트, 그리고 설정·문서에 인용할 근거(AM 소스·에뮬레이터 문서)까지.
  제한 없이 내려받아 적용해도 된다. 적용할 때는 출처 URL 과 규격(크기·알파)을 커밋 메시지나 ISSUES 에 남긴다.
  다운로드는 `curl -L -o` 또는 `Invoke-WebRequest` 로 하고, 받은 이미지는 `Read` 로 열어 눈으로 확인한 뒤 쓴다.
  - 열려 있는 소스: `fightersgeneration.com`(격투 캐릭터 공식 아트, 흰 배경 JPG), `flyers.arcade-museum.com`(전단, 페이지의 `data-src` 가 원본 JPG).
    Cloudflare 로 막힌 곳(curl·WebFetch 모두): Spriters Resource, Fandom 위키, pngwing/pngegg/cleanpng, MobyGames.
  - **마스코트 컷아웃 도구** — `scripts/cutout.ps1 <in> <out> [-Mode white|light] [-Tol 40] [-Erase "x,y,w,h;…"] [-Crop "x,y,w,h"]`.
    가장자리에서 플러드필로 배경을 떼고 480×760 투명 캔버스에 맞춘다. `light` 모드는 연한 그라데이션(분홍·회색)까지 배경으로 본다.
    선화 외곽선이 있는 애니 그림에 잘 맞는다. GDI+ 가 "매개 변수가 잘못되었습니다"로 못 여는 JPEG 는 `scripts/img-to-png.ps1` 로 먼저 변환.
    bash 에서 경로를 넘길 때 `"$SW\web\$in"` 처럼 쓰면 `\$` 가 이스케이프돼 깨진다 — 슬래시(`$SW/web/$in`)로 쓴다.

## 절차

### 1. 무엇을 했는지 파악
```bash
git log --oneline <base>..<head>                      # 머지 커밋이면 --first-parent 아닌 실제 작업 커밋을 본다
git show --stat <commit>; git show <commit> -- <파일>   # 커밋 메시지의 "검증:" 주장을 그대로 믿지 말고 재현한다
```
커밋 메시지가 "같이 고쳤다"고 한 파일은 **그 파일 전체**를 다시 본다 (예: clock.nut 을 고치면서 같은 레이아웃의 `do_nut` 대상 누락은 못 본 사례).

### 2. 기존 검증기
```powershell
powershell -ExecutionPolicy Bypass -File tools\validate.ps1        # FAIL 0 / WARN 0 이어야 정상
```

### 3. 검증기가 못 보는 것 — 이 스킬의 스크립트
```powershell
powershell -ExecutionPolicy Bypass -File .claude\skills\arcade-audit\scripts\audit.ps1
powershell -ExecutionPolicy Bypass -File .claude\skills\arcade-audit\scripts\audit.ps1 -Section mascot   # 한 섹션만
```
출력 태그: `ISSUE`(보고 대상) / `OK`(측정했고 이상 없음 — 보고서의 "이상 없던 것"에 숫자와 함께 적는다) / `INFO`.

| 섹션 | 보는 것 | 왜 validate.ps1 이 못 잡나 |
|---|---|---|
| `layout` | `.nut` 의 리터럴 이미지/영상/셰이더 참조(옵션 자리표시자 `my-own-marquee.jpg` 는 INFO 로 분리) · `do_nut`/`load_module` 대상 존재 · 로드 불가 위치의 layout*.nut · 어디서도 안 부르는 .nut | 레이아웃 내부는 검사 안 함. `do_nut` 대상 부재는 Squirrel 예외 → 그 아래 전부 미실행 |
| `dispimg` | `character/ system/ wheel/[DisplayName]` 21개 디스플레이별 존재 · 디스플레이 이름과 안 맞는 죽은 복사본 | 마스코트 존재만 봄 |
| `mascot` | 480×760 · 알파 컷아웃 여부(투명 비율·가장자리 투명) · **피사체가 직선으로 잘렸는지**(최외곽 불투명 행/열이 피사체 폭의 20% 이상) · 파일 크기 이상치 | 존재만 봄. **불투명 플라이어를 잘라 넣어도 통과** |
| `dupes` | 바이트 동일 미디어(NEVATO↔Console Box 쌍은 정책상 의도된 것이라 INFO, 그 외는 ISSUE) · 두 레이아웃 공용 폴더 드리프트 · 참조 없는 `background/{1280,1920,2xScale}` | — |
| `fonts` | 참조 폰트 해석 가능 여부 · font_path 안의 미사용 폰트 · font_path 밖 폰트 파일 | — |
| `glyph` | 실제 표시 텍스트(overview·romlist Title·kr.msg·NXL HD 한글 리터럴) ↔ 그 텍스트를 그리는 폰트의 글리프 | AM 은 글리프 폴백이 없다(CLAUDE.md 5.4) |
| `cfg` | artwork 경로 후행 공백 · 형제 cfg(CUE/CCD/PBP…) artwork 블록 일치 · 어떤 라벨이 실제 그려지는지 결정하는 layout_config 값 | validate 는 `Trim()` 해서 후행 공백을 영원히 못 본다 |
| `case` | attract.cfg romlist 이름 ↔ 파일명 **대소문자 정확** 일치 · .gitignore 경로 대소문자 · `layouts/<name>/layout.nut` 철자(NXL HD 의 `Layout.nut`) | Windows 가 가려 줌 |
| `branch` | 장비 브랜치 5개 behind main = 0 · 장비 브랜치에만 있는 공통성 커밋 | — |
| `video` | 추적 mp4 해상도/길이/비트레이트(ffprobe 없이 tkhd 파싱) · intro.nut 이 가리키는 영상 존재 | — |
| `junk` | 자체 자산 영역의 `(2)`·`bak/`·`.psd`·`Thumbs.db` · 추적 중인 런타임 산출물 | — |

`layout` 섹션의 `my-own-marquee.jpg` 류는 **설정 옵션 분기**라 오탐이다 — 옵션값(`layout_config`)을 보고 판단한다.
`layout_vewlix_*.nut` 는 `toggle_layout`(L 키)로 도달 가능하고 `attract.am` 에 어느 파일을 쓰는지 기록되므로 **살아 있는 코드**다.

### 4. 미디어는 눈으로 본다
`Read` 도구로 PNG 를 직접 열어 본다 — 최소한 이번 회차에 추가·변경된 이미지 전부와, `mascot` 섹션이 `ISSUE` 로 표시한 것.
기준 이미지(예: `layouts/NEVATO/character/sega naomi.png`)와 나란히 보고 **컷아웃/크롭/로고 잘림**을 판단한다.

### 5. 문서 정합성
- `CLAUDE.md` 의 사실 서술이 현재 상태와 맞는지 (예: 디렉터리 트리의 파일명, 6절 주의사항, 개수).
  구조를 바꾼 커밋이 CLAUDE.md/ISSUES.md 를 같은 커밋에서 안 고쳤으면 그것 자체가 결함이다.
- `docs/ISSUES.md` 의 "처리 완료" 항목을 **하나씩 재검증**한다.

### 6. 스크립트 자체 회귀
`tools/validate.ps1`·`tools/reset-runtime.ps1` 이 바뀌었으면 코드를 읽는다.
reset-runtime 은 "삭제된 추적 파일" 경로(Test-Path 필터), porcelain 파싱(rename·인용), 추적 파일 삭제 여부를 본다.

### 7. 보고
아티팩트 구성(기존 판의 골격을 유지한다):
1. 점검 범위(실측 숫자) 2. 고쳐야 할 것 — 심각도 순, 각 항목에 **근거(명령 결과)·영향·조치** 3. 지난 회차 "완료" 항목 재검증 결과
4. 이상 없던 것(숫자 포함) 5. 오탐 6. 도구 개선 제안(validate.ps1 에 넣을 검사)
마지막에 `.claude/skills/arcade-audit/scripts/audit.ps1` 에 새 검사를 추가할 게 있으면 추가한다 — 이번에 손으로 찾은 것은 다음엔 스크립트가 찾아야 한다.
