@echo off
chcp 65001 > nul
title Antigravity 繁體中文語系安裝程式 (Windows)
echo ====================================================
echo   Google Antigravity 繁體中文語系安裝程式 (Windows)
echo ====================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_zh_TW_win.ps1"

pause
