# ComfyUI Electron Backup Script

Comprehensive backup solution for ComfyUI Electron installation with Git versioning or ZIP archives, automated scheduling, and easy restore capabilities.

## Features

- **Two Backup Types:**
  - **Git**: Version-controlled backups with unlimited rollback points
  - **Archive**: Simple ZIP file backups (keeps last 14 days)

- **Operations:**
  - Create backups on-demand or scheduled
  - Restore from any backup point
  - Quick rollback to previous backup
  - List all available backups

- **Automation:**
  - Daily scheduled task (Windows Task Scheduler)
  - Start Menu shortcut for quick access
  - Automatic cleanup of old backups

## Quick Start

### Interactive Installation

Run the script in install mode for guided setup:

```powershell
.\ComfyUI-Backup.ps1 -Mode Install
```

This will:
1. Let you choose Git or Archive backup
2. Set backup schedule time
3. Create scheduled task
4. Create Start Menu shortcut
5. Perform initial backup

### Manual Usage

**Create a backup:**
```powershell
# Git backup (recommended)
.\ComfyUI-Backup.ps1 -Mode Backup -BackupType Git

# Archive backup
.\ComfyUI-Backup.ps1 -Mode Backup -BackupType Archive
```

**List available backups:**
```powershell
.\ComfyUI-Backup.ps1 -Mode ListBackups
```

**Restore from specific backup:**
```powershell
# From Git commit
.\ComfyUI-Backup.ps1 -Mode Restore -BackupType Git -RestorePoint abc1234

# From archive
.\ComfyUI-Backup.ps1 -Mode Restore -BackupType Archive -RestorePoint "ComfyUI-Backup_2025-12-02_140530.zip"
```

**Rollback to previous backup:**
```powershell
.\ComfyUI-Backup.ps1 -Mode Rollback -BackupType Git
```

**Create scheduled task:**
```powershell
.\ComfyUI-Backup.ps1 -Mode CreateSchedule -BackupType Git -ScheduleTime "02:00"
```

**Create Start Menu shortcut:**
```powershell
.\ComfyUI-Backup.ps1 -Mode CreateShortcut -BackupType Git
```

## Parameters

| Parameter | Values | Description |
|-----------|--------|-------------|
| `-Mode` | Backup, Restore, Rollback, ListBackups, CreateSchedule, CreateShortcut, Install | Operation to perform |
| `-BackupType` | Git, Archive | Type of backup (default: Git) |
| `-RestorePoint` | commit hash or filename | Specific backup to restore |
| `-ScheduleTime` | HH:mm format | Daily backup time (default: 02:00) |

## File Structure

```
ComfyDesktopBackup/
├── ComfyUI-Backup.ps1          # Main script
├── Backups/
│   ├── GitRepo/                # Git repository (if using Git)
│   └── Archives/               # ZIP files (if using Archive)
└── Logs/
    └── ComfyUI-Backup_YYYY-MM.log  # Monthly log files
```

## Requirements

- Windows 10/11
- PowerShell 5.1 or higher
- Git for Windows (only if using Git backup type)

## Git vs Archive Backup

### Git Backup (Recommended)
✅ Unlimited restore points
✅ Space-efficient (stores only changes)
✅ View full history
✅ Fast rollback
❌ Requires Git installation

### Archive Backup
✅ Simple ZIP files
✅ No dependencies
✅ Easy to understand
❌ More disk space
❌ Limited to recent backups (14 days)

## Safety Features

- Creates safety backup before any restore operation
- Safety backups stored in `%TEMP%\ComfyUI-PreRestore_*`
- Automatic cleanup of old backups
- Git history pruning (keeps last 30 commits)
- Archive rotation (keeps last 14 days)

## Troubleshooting

**"Execution of scripts is disabled on this system"**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**"Access denied" when creating scheduled task**
- Run PowerShell as Administrator

**Git not found**
- Install Git for Windows: https://git-scm.com/download/win
- Or use `-BackupType Archive` instead

**Source path not found**
- Verify ComfyUI Electron is installed at:
  `%LOCALAPPDATA%\Programs\@comfyorgcomfyui-electron`

## Examples

**Daily automated Git backups at 2 AM:**
```powershell
.\ComfyUI-Backup.ps1 -Mode Install
# Choose option 1 (Git), enter 02:00
```

**Manual backup before major changes:**
```powershell
.\ComfyUI-Backup.ps1 -Mode Backup -BackupType Git
```

**Restore after something breaks:**
```powershell
# List backups
.\ComfyUI-Backup.ps1 -Mode ListBackups

# Restore specific commit
.\ComfyUI-Backup.ps1 -Mode Restore -BackupType Git -RestorePoint a1b2c3d

# Or just rollback to previous
.\ComfyUI-Backup.ps1 -Mode Rollback -BackupType Git
```

## Logs

Logs are stored in `Logs\ComfyUI-Backup_YYYY-MM.log` with detailed information about all operations.

## License

Free to use and modify.
