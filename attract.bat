@echo off
rem ---------------------------------------------------------------
rem Attract-Mode 2.7.0 launcher
rem
rem 2.7.0 windows attract.exe is a CONSOLE subsystem build (upstream
rem merged attract-console.exe into it), so it no longer writes
rem last_run.log by default. --logfile restores that behaviour.
rem The console window is hidden by "hide_console yes" in attract.cfg.
rem
rem MEDNAFEN_HOME makes Mednafen use this repository as its base
rem directory instead of %USERPROFILE%\.mednafen, so it reads our
rem mednafen.cfg and finds firmware\ (Saturn BIOS). Child processes
rem launched by attract.exe inherit it. See CLAUDE.md 4.9.
rem ---------------------------------------------------------------
cd /d "%~dp0."
set "MEDNAFEN_HOME=%~dp0emulators\Mednafen"
"%~dp0attract.exe" --logfile "%~dp0last_run.log" %*
