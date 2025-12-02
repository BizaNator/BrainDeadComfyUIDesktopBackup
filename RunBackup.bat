@echo off
REM Quick launcher for ComfyUI Backup Script
REM Double-click to run backup with your preferred settings

:menu
cls
echo.
echo ====================================
echo   ComfyUI Backup Quick Launcher
echo ====================================
echo.
echo Choose an option:
echo   1. Run Backup (Git)
echo   2. Run Backup (Archive)
echo   3. List Available Backups
echo   4. Rollback to Previous
echo   5. Install/Setup
echo   6. Exit
echo.

set /p choice="Enter choice (1-6): "

if "%choice%"=="1" (
    echo.
    echo Running Git backup...
    echo.
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Backup -BackupType Git
    goto continue
)

if "%choice%"=="2" (
    echo.
    echo Running Archive backup...
    echo.
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Backup -BackupType Archive
    goto continue
)

if "%choice%"=="3" (
    echo.
    echo Listing backups...
    echo.
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode ListBackups
    goto continue
)

if "%choice%"=="4" (
    echo.
    echo Choose backup type to rollback:
    echo   1. Git
    echo   2. Archive
    echo   3. Cancel
    echo.
    set /p backuptype="Enter choice (1-3): "
    echo.
    if "%backuptype%"=="1" (
        echo Rollback using Git...
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Rollback -BackupType Git
        goto continue
    ) else if "%backuptype%"=="2" (
        echo Rollback using Archive...
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Rollback -BackupType Archive
        goto continue
    ) else if "%backuptype%"=="3" (
        echo Cancelled.
        timeout /t 2 >nul
        goto menu
    ) else (
        echo Invalid choice! Please try again.
        timeout /t 2 >nul
        goto menu
    )
)

if "%choice%"=="5" (
    echo.
    echo Running installation...
    echo.
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Install
    goto continue
)

if "%choice%"=="6" (
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
