@echo off
setlocal DisableDelayedExpansion
chcp 65001 >nul

cd /d "%~dp0" || exit /b 1

set "BACKUP_DATE="
for /f %%D in ('powershell.exe -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set "BACKUP_DATE=%%D"
if not defined BACKUP_DATE exit /b 1

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 exit /b 1

git add --all -- .
if errorlevel 1 exit /b 1

git diff --cached --quiet
if errorlevel 2 exit /b 1
if not errorlevel 1 (
    echo 没有需要提交的变更。
    exit /b 0
)

git commit -m "skill-backup-%BACKUP_DATE%"
exit /b %errorlevel%
