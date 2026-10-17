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
echo   Skills Backup
echo   Commit: %BACKUP_MSG%
echo ============================================================
echo.
echo [1/6] Pull remote updates
echo ------------------------------------------------------------
git pull
if errorlevel 1 goto :failed

echo.
echo [2/6] Show working tree status
echo ------------------------------------------------------------
git status
if errorlevel 1 goto :failed

echo.
echo [3/6] Stage local changes
echo ------------------------------------------------------------
git add --all -- .
if errorlevel 1 goto :failed

echo.
echo [4/6] Check for staged changes
echo ------------------------------------------------------------
git diff --cached --quiet
if errorlevel 2 goto :failed
if not errorlevel 1 (
    echo.
    echo [NO CHANGES] Nothing to commit. Finished.
    goto :done
)

echo.
echo [5/6] Create local commit
echo ------------------------------------------------------------
git commit -m "%BACKUP_MSG%"
if errorlevel 1 goto :failed
echo.
echo [COMMITTED] %BACKUP_MSG%

echo.
echo [6/6] Push to remote
echo ------------------------------------------------------------
git push

echo.
echo ============================================================
echo   Finished. Check the push result above.
echo ============================================================
:done
echo.
echo Press any key to exit . . .
pause >nul
exit /b 0

:failed
echo.
echo ============================================================
echo   [STOPPED] Backup incomplete. Check the error above.
echo ============================================================
echo.
echo Press any key to exit . . .
pause >nul
exit /b 1
