@echo off
:input

Set /P ShaderLevel= plaese input Shaderlevel (max 4472): 
if %ShaderLevel%.==. goto noinput
SET /A TestVal=%ShaderLevel%*1
If %TestVal%==%ShaderLevel% goto setlevel
cls
ECHO Hmmm?..."%ShaderLevel%" not a number!
goto input   
:setlevel
:: maximum 4472 is practical passible, 4473 will crash the OGL2-Plugin (don't know why...) 
if %ShaderLevel% GTR 4472 cls &echo Max Shaderlevel is 4472 & goto input
REG ADD "HKCU\Software\Vision Thing\PSEmu Pro\GPU\PeteOpenGL2" /f /v "FSShaderLevel" /t REG_DWORD /d %ShaderLevel% >nul
cls
echo the next...
goto input