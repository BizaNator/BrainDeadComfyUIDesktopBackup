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
    set /p backuptype="Rollback using (G)it or (A)rchive? "
    echo.
    if /i "%backuptype%"=="G" (
        echo Using Git backup...
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Rollback -BackupType Git
    ) else if /i "%backuptype%"=="A" (
        echo Using Archive backup...
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Rollback -BackupType Archive
    ) else (
        echo Invalid choice. Using Archive backup as default...
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Rollback -BackupType Archive
    )
    goto continue
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
