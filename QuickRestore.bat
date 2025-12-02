@echo off
REM Quick Restore Helper
REM Lists backups and helps you restore

:menu
cls
echo.
echo ====================================
echo   ComfyUI Quick Restore
echo ====================================
echo.

REM First show available backups
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode ListBackups

echo.
echo ====================================
echo.
echo Choose restore type:
echo   1. Restore from Git commit
echo   2. Restore from Archive file
echo   3. Quick Rollback (previous backup)
echo   4. Return to Main Menu / Exit
echo.

set /p choice="Enter choice (1-4): "

if "%choice%"=="1" (
    echo.
    set /p commit="Enter Git commit hash: "
    echo.
    echo WARNING: This will replace your current installation!
    set /p confirm="Are you sure? (yes/no): "
    if /i "%confirm%"=="yes" (
        echo.
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Restore -BackupType Git -RestorePoint "%commit%"
        goto continue
    ) else (
        echo Cancelled.
        timeout /t 2 >nul
        goto menu
    )
)

if "%choice%"=="2" (
    echo.
    set /p archive="Enter archive filename: "
    echo.
    echo WARNING: This will replace your current installation!
    set /p confirm="Are you sure? (yes/no): "
    if /i "%confirm%"=="yes" (
        echo.
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Restore -BackupType Archive -RestorePoint "%archive%"
        goto continue
    ) else (
        echo Cancelled.
        timeout /t 2 >nul
        goto menu
    )
)

if "%choice%"=="3" goto rollback

if "%choice%"=="4" (
    echo.
    echo Exiting...
    exit /b
)

echo.
echo Invalid choice! Please try again.
timeout /t 2 >nul
goto menu

:continue
echo.
echo.
echo ====================================
echo.
set /p return="Press ENTER to return to menu..."
goto menu

:rollback
cls
echo.
echo ====================================
echo   ComfyUI Rollback
echo ====================================
echo.
echo Choose backup type to rollback:
echo   1. Git
echo   2. Archive
echo   3. Cancel
echo.
set /p backuptype="Enter choice (1-3): "

if "%backuptype%"=="1" (
    echo.
    echo WARNING: This will replace your current installation!
    set /p confirm="Are you sure? (yes/no): "
    if /i "%confirm%"=="yes" (
        echo.
        echo Rollback using Git...
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Rollback -BackupType Git
        goto continue
    )
    echo.
    echo Cancelled.
    timeout /t 2 >nul
    goto menu
)

if "%backuptype%"=="2" (
    echo.
    echo WARNING: This will replace your current installation!
    set /p confirm="Are you sure? (yes/no): "
    if /i "%confirm%"=="yes" (
        echo.
        echo Rollback using Archive...
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Rollback -BackupType Archive
        goto continue
    )
    echo.
    echo Cancelled.
    timeout /t 2 >nul
    goto menu
)

if "%backuptype%"=="3" (
    echo.
    echo Cancelled.
    timeout /t 2 >nul
    goto menu
)

echo.
echo Invalid choice! Please try again.
timeout /t 2 >nul
goto rollback
