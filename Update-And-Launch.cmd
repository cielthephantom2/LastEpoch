@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Update-And-Launch.ps1" %*
if errorlevel 1 (
  echo Update failed. The game was not started.
  pause
  exit /b 1
)
