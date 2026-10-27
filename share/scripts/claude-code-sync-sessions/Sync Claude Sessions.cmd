@echo off
rem Double-click to run. Keep this file next to Sync-ClaudeSessions.ps1.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Sync-ClaudeSessions.ps1" %*
