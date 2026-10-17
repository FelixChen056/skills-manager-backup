@echo off
setlocal DisableDelayedExpansion
chcp 65001 >nul

cd /d "%~dp0" || goto :failed

git rev-parse --is-inside-work-tree >nul
if errorlevel 1 goto :failed

set "BACKUP_MSG="
for /f %%D in ('powershell.exe -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set "BACKUP_MSG=skill-backup-%%D"
if not defined BACKUP_MSG goto :failed

git pull
if errorlevel 1 goto :failed

git status
if errorlevel 1 goto :failed

git add --all -- .
if errorlevel 1 goto :failed

git diff --cached --quiet
if errorlevel 2 goto :failed
if not errorlevel 1 (
    echo 没有需要提交的变更。
    goto :done
)

git commit -m "%BACKUP_MSG%"
if errorlevel 1 goto :failed
echo.
echo 提交成功：%BACKUP_MSG%

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
