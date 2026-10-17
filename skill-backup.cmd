@echo off
setlocal DisableDelayedExpansion
chcp 65001 >nul

cd /d "%~dp0" || goto :failed

git rev-parse --is-inside-work-tree >nul
if errorlevel 1 goto :failed

set "BACKUP_MSG="
for /f %%D in ('powershell.exe -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set "BACKUP_MSG=skill-backup-%%D"
if not defined BACKUP_MSG goto :failed
echo.
echo ============================================================
echo   Skills 一键备份
echo   本次提交：%BACKUP_MSG%
echo ============================================================
echo.
echo [1/6] 拉取远程更新
echo ------------------------------------------------------------
git pull
if errorlevel 1 goto :failed

echo.
echo [2/6] 查看工作区状态
echo ------------------------------------------------------------
git status
if errorlevel 1 goto :failed

echo.
echo [3/6] 暂存本地变更
echo ------------------------------------------------------------
git add --all -- .
if errorlevel 1 goto :failed

echo.
echo [4/6] 检查是否需要提交
echo ------------------------------------------------------------
git diff --cached --quiet
if errorlevel 2 goto :failed
if not errorlevel 1 (
    echo.
    echo [无需提交] 没有文件变更，本次流程结束。
    goto :done
)

echo.
echo [5/6] 创建本地提交
echo ------------------------------------------------------------
git commit -m "%BACKUP_MSG%"
if errorlevel 1 goto :failed
echo.
echo [本地提交成功] %BACKUP_MSG%

echo.
echo [6/6] 推送到远程仓库
echo ------------------------------------------------------------
git push

echo.
echo ============================================================
echo   备份流程已结束，推送结果请查看上方输出。
echo ============================================================
:done
echo.
echo 按任意键退出脚本 . . .
pause >nul
exit /b 0

:failed
echo.
echo ============================================================
echo   [执行中止] 备份未完成，请查看上方错误信息。
echo ============================================================
echo.
echo 按任意键退出脚本 . . .
pause >nul
exit /b 1
