@echo off
rem ---------------------------------------------------------------
rem Attract-Mode 2.7.0 launcher
rem
rem 2.7.0 windows attract.exe is a CONSOLE subsystem build (upstream
rem merged attract-console.exe into it), so it no longer writes
rem last_run.log by default. --logfile restores that behaviour.
rem The console window is hidden by "hide_console yes" in attract.cfg.
rem ---------------------------------------------------------------
cd /d "%~dp0."
"%~dp0attract.exe" --logfile "%~dp0last_run.log" %*
