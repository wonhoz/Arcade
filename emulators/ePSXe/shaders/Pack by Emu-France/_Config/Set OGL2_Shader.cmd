@echo off
if %*.==. echo ...will use the last Shader... &goto input
if not exist %*\gpuPeteOGL2.slf goto noShader
if not exist %*\gpuPeteOGL2.slv goto noShader
REG ADD "HKCU\Software\epsxe\config" /f /v VideoPlugin /t REG_SZ /d  "gpuPeteOpenGL2.dll">nul
REG ADD "HKCU\Software\Vision Thing\PSEmu Pro\GPU\PeteOpenGL2" /f /v "FullscreenShader" /t REG_DWORD /d  "5">nul
REG ADD "HKCU\Software\Vision Thing\PSEmu Pro\GPU\PeteOpenGL2" /f /v "FilterType" /t REG_DWORD /d  "0">nul
REG ADD "HKCU\Software\Vision Thing\PSEmu Pro\GPU\PeteOpenGL2" /f /v "FullscreenBlur" /t REG_DWORD /d  "0">nul
REG ADD "HKCU\Software\Vision Thing\PSEmu Pro\GPU\PeteOpenGL2" /f /v "ShaderDir" /t REG_SZ /d  %*\>nul
:input
Set /P ShaderLevel= Please input ShaderLevel (0 to 4): 
if %ShaderLevel%.==. goto noinput
SET /A TestVal=%ShaderLevel%*1
If %TestVal%==%ShaderLevel% goto setlevel
cls
ECHO ..."%ShaderLevel%" is not a number!
goto input   
:setlevel
if %ShaderLevel% GTR 4 cls &echo Maximum Shaderlevel is 4 & goto input
REG ADD "HKCU\Software\Vision Thing\PSEmu Pro\GPU\PeteOpenGL2" /f /v "FSShaderLevel" /t REG_DWORD /d %ShaderLevel% >nul
goto end
:noShader
echo %*
echo is not GLSlang-Shaderfolder for Petes OGL2-Plugin!
goto end
:noinput
echo New Shaderlevel not set.
goto end

:end
::wait 3 seconds to closing the Window
@ping -n 3 localhost> nul