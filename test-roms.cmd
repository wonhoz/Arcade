@echo off
chcp 65001 > nul
rem ---------------------------------------------------------------
rem romlists 구동 검증 런처
rem
rem 실제 검사는 tools\test-roms.ps1 이 한다. PowerShell 스크립트는
rem 전부 tools\ 에 모아 두고, 캐비닛에서 바로 더블클릭할 수 있게
rem 이 파일만 루트에 둔다.
rem
rem   test-roms.cmd                       메뉴를 띄운다
rem   test-roms.cmd -Launch -List MAME    인자를 주면 그대로 넘긴다
rem ---------------------------------------------------------------
setlocal
cd /d "%~dp0."
set "PS=powershell -NoProfile -ExecutionPolicy Bypass -File tools\test-roms.ps1"

if not "%~1"=="" (
    %PS% %*
    goto :end
)

:menu
cls
echo.
echo   ================================================================
echo    Attract-Mode 롬 구동 검증                      (D:\AttractMode)
echo   ================================================================
echo.
echo    [1] 빠른 점검      전체 목록의 실행파일·롬·인자를 조립 검사  (수 초)
echo.
echo    --- 실제로 실행해 보는 구동 점검 (화면을 에뮬레이터가 차지한다) ---
echo.
echo    [2] 표본 점검      에뮬레이터별 1개씩                        (약 10분)
echo    [3] 전수 점검      모든 목록의 모든 롬                       (수 시간)
echo    [4] 이어하기       중단된 전수 점검을 이어서
echo    [5] 목록 지정      목록 하나를 골라 전부
echo    [6] 이름으로 찾기
echo    [7] 직전 실패 항목만 다시
echo.
echo    검사가 끝나면 HTML 보고서가 열린다.
echo    [8] 마지막 보고서 다시 열기      [9] 보고서 폴더 (logs\)
echo    [0] 종료
echo.
set "sel="
set /p "sel=  선택: "

if "%sel%"=="1" goto :static
if "%sel%"=="2" goto :sample
if "%sel%"=="3" goto :full
if "%sel%"=="4" goto :resume
if "%sel%"=="5" goto :bylist
if "%sel%"=="6" goto :byname
if "%sel%"=="7" goto :failed
if "%sel%"=="8" goto :last
if "%sel%"=="9" goto :logs
if "%sel%"=="0" goto :end
goto :menu

:static
%PS% -Open
goto :pause

:sample
%PS% -Launch -Sample 1 -Open
goto :pause

:full
rem 전수 점검. 10건마다 보고서를 써 두므로 중단해도 [4] 로 이어서 할 수 있다.
%PS% -Launch -Open
goto :pause

:resume
%PS% -Launch -Resume -Open
goto :pause

:bylist
echo.
echo   목록 이름 (romlists\ 의 파일명, 예: MAME / Sony PlayStation / Zinc)
set "arg="
set /p "arg=  목록: "
if "%arg%"=="" goto :menu
%PS% -Launch -List "%arg%" -Open
goto :pause

:byname
echo.
echo   게임 이름 일부 (Name 또는 Title, 예: tekken / 철권)
set "arg="
set /p "arg=  이름: "
if "%arg%"=="" goto :menu
%PS% -Launch -Name "%arg%" -Open
goto :pause

:failed
%PS% -Launch -Failed -Open
goto :pause

:last
rem logs\ 에서 가장 최근 HTML 보고서를 연다
set "html="
for /f "delims=" %%f in ('dir /b /o-d "logs\*.html" 2^>nul') do if not defined html set "html=%%f"
if not defined html (
    echo.
    echo   아직 보고서가 없습니다. 먼저 검사를 한 번 실행하세요.
    goto :pause
)
start "" "%~dp0logs\%html%"
goto :menu

:logs
if not exist "logs" mkdir "logs"
start "" explorer "%~dp0logs"
goto :menu

:pause
echo.
pause
goto :menu

:end
endlocal
