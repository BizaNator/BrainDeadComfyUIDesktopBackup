@echo off
REM Quick launcher for ComfyUI Backup Script
REM Double-click to run backup with your preferred settings

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
    echo Running Git backup...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Backup -BackupType Git
    goto end
)

if "%choice%"=="2" (
    echo Running Archive backup...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Backup -BackupType Archive
    goto end
)

if "%choice%"=="3" (
    echo Listing backups...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode ListBackups
    goto end
)

if "%choice%"=="4" (
    echo.
    set /p backuptype="Rollback using (G)it or (A)rchive? "
    if /i "%backuptype%"=="G" (
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Rollback -BackupType Git
    ) else (
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Rollback -BackupType Archive
    )
    goto end
)

if "%choice%"=="5" (
    echo Running installation...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Install
    goto end
)

if "%choice%"=="6" (
    exit /b
)

echo Invalid choice!

:end
echo.
echo Press any key to exit...
pause >nul
