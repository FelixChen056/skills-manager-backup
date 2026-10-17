@echo off
setlocal DisableDelayedExpansion
chcp 65001 >nul

cd /d "%~dp0" || goto :failed

set "BACKUP_DATE="
for /f %%D in ('powershell.exe -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set "BACKUP_DATE=%%D"
if not defined BACKUP_DATE goto :failed

git rev-parse --is-inside-work-tree >nul
if errorlevel 1 goto :failed

git add --all -- .
if errorlevel 1 goto :failed

git diff --cached --quiet
if errorlevel 2 goto :failed
if not errorlevel 1 (
    echo 没有需要提交的变更。
    goto :done
)

git commit -m "skill-backup-%BACKUP_DATE%"
if errorlevel 1 goto :failed
echo.
echo 提交成功：skill-backup-%BACKUP_DATE%

:done
echo.
echo 按任意键关闭窗口...
pause >nul
exit /b 0

:failed
echo.
echo 提交未完成，请查看上方错误信息。
echo 按任意键关闭窗口...
pause >nul
exit /b 1
