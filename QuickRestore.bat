@echo off
REM Quick Restore Helper
REM Lists backups and helps you restore

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
echo   4. Cancel
echo.

set /p choice="Enter choice (1-4): "

if "%choice%"=="1" (
    echo.
    set /p commit="Enter Git commit hash: "
    echo.
    echo WARNING: This will replace your current installation!
    set /p confirm="Are you sure? (yes/no): "
    if /i "%confirm%"=="yes" (
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Restore -BackupType Git -RestorePoint "%commit%"
    ) else (
        echo Cancelled.
    )
    goto end
)

if "%choice%"=="2" (
    echo.
    set /p archive="Enter archive filename: "
    echo.
    echo WARNING: This will replace your current installation!
    set /p confirm="Are you sure? (yes/no): "
    if /i "%confirm%"=="yes" (
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Restore -BackupType Archive -RestorePoint "%archive%"
    ) else (
        echo Cancelled.
    )
    goto end
)

if "%choice%"=="3" (
    echo.
    set /p backuptype="Rollback using (G)it or (A)rchive? "
    echo.
    echo WARNING: This will replace your current installation!
    set /p confirm="Are you sure? (yes/no): "
    if /i "%confirm%"=="yes" (
        if /i "%backuptype%"=="G" (
            powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Rollback -BackupType Git
        ) else (
            powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ComfyUI-Backup.ps1" -Mode Rollback -BackupType Archive
        )
    ) else (
        echo Cancelled.
    )
    goto end
)

if "%choice%"=="4" (
    echo Cancelled.
    goto end
)

echo Invalid choice!

:end
echo.
echo Press any key to exit...
pause >nul
