#Requires -Version 5.1
<#
.SYNOPSIS
    ComfyUI Electron Backup Script
.DESCRIPTION
    Creates backups of ComfyUI Electron installation using either Git versioning or ZIP archives.
    Supports scheduled tasks, on-demand execution, and rollback/restore operations.
.PARAMETER Mode
    Operation mode: Backup, Restore, Rollback, CreateSchedule, CreateShortcut, or Install
.PARAMETER BackupType
    Type of backup: Git or Archive (default: Git)
.PARAMETER RestorePoint
    For Restore mode: Git commit hash or archive filename to restore from
.PARAMETER ScheduleTime
    Time for daily scheduled task (default: 02:00)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('Backup','Restore','Rollback','CreateSchedule','CreateShortcut','Install','ListBackups')]
    [string]$Mode = 'Backup',

    [Parameter(Mandatory=$false)]
    [ValidateSet('Git','Archive')]
    [string]$BackupType = 'Git',

    [Parameter(Mandatory=$false)]
    [string]$RestorePoint,

    [Parameter(Mandatory=$false)]
    [string]$ScheduleTime = '02:00'
)

# Configuration
$SourcePath = "$env:LOCALAPPDATA\Programs\@comfyorgcomfyui-electron"
$BackupBasePath = "$PSScriptRoot\Backups"
$GitBackupPath = "$BackupBasePath\GitRepo"
$ArchiveBackupPath = "$BackupBasePath\Archives"
$LogPath = "$PSScriptRoot\Logs"
$LogFile = "$LogPath\ComfyUI-Backup_$(Get-Date -Format 'yyyy-MM').log"

# Ensure directories exist
function Initialize-Directories {
    @($BackupBasePath, $GitBackupPath, $ArchiveBackupPath, $LogPath) | ForEach-Object {
        if (-not (Test-Path $_)) {
            New-Item -ItemType Directory -Path $_ -Force | Out-Null
        }
    }
}

# Logging function
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info','Warning','Error','Success')]
        [string]$Level = 'Info'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"

    # Color coding for console
    $color = switch($Level) {
        'Info'    { 'White' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
        'Success' { 'Green' }
    }

    Write-Host $logMessage -ForegroundColor $color
    Add-Content -Path $LogFile -Value $logMessage
}

# Check if git is available
function Test-GitAvailable {
    try {
        $null = git --version 2>$null
        return $true
    } catch {
        return $false
    }
}

# Initialize Git repository
function Initialize-GitBackup {
    Write-Log "Initializing Git backup repository..." -Level Info

    if (-not (Test-GitAvailable)) {
        Write-Log "Git is not installed or not in PATH. Please install Git for Windows." -Level Error
        return $false
    }

    if (-not (Test-Path "$GitBackupPath\.git")) {
        Push-Location $GitBackupPath
        git init | Out-Null
        git config user.name "ComfyUI Backup Script"
        git config user.email "backup@local"
        Pop-Location
        Write-Log "Git repository initialized at $GitBackupPath" -Level Success
    }

    return $true
}

# Perform Git backup
function Backup-WithGit {
    Write-Log "Starting Git-based backup..." -Level Info

    if (-not (Test-Path $SourcePath)) {
        Write-Log "Source path does not exist: $SourcePath" -Level Error
        return $false
    }

    if (-not (Initialize-GitBackup)) {
        return $false
    }

    try {
        # Copy files to git repo (excluding certain patterns)
        Write-Log "Copying files to Git repository..." -Level Info

        $excludePatterns = @('*.log', '*.tmp', 'node_modules', '.git')

        # Robocopy with exclusions
        $robocopyArgs = @(
            $SourcePath,
            $GitBackupPath,
            '/MIR',
            '/R:3',
            '/W:5',
            '/NFL', # No file list
            '/NDL', # No directory list
            '/NP',   # No progress
            '/XD',   # Exclude directories
            '.git'   # Don't delete the .git folder
        )

        foreach ($pattern in $excludePatterns) {
            $robocopyArgs += "/XF"
            $robocopyArgs += $pattern
        }

        $result = & robocopy @robocopyArgs 2>&1

        # Robocopy exit codes: 0-7 are success, 8+ are errors
        if ($LASTEXITCODE -ge 8) {
            Write-Log "Robocopy encountered errors. Check log for details." -Level Warning
        }

        # Commit changes
        Push-Location $GitBackupPath

        git add -A
        $status = git status --porcelain

        if ($status) {
            $commitMessage = "Backup $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            git commit -m $commitMessage | Out-Null

            $commitHash = git rev-parse HEAD
            Write-Log "Git backup completed. Commit: $commitHash" -Level Success

            # Keep only last 30 commits to save space
            $commitCount = (git rev-list --count HEAD)
            if ($commitCount -gt 30) {
                Write-Log "Pruning old commits (keeping last 30)..." -Level Info
                $keepCommit = git rev-parse HEAD~30
                git checkout --orphan temp $keepCommit
                git commit -m "Consolidated backup history"
                git rebase --onto temp $keepCommit master
                git branch -D temp
                git gc --aggressive --prune=now | Out-Null
            }
        } else {
            Write-Log "No changes detected since last backup." -Level Info
        }

        Pop-Location
        return $true

    } catch {
        Write-Log "Error during Git backup: $_" -Level Error
        Pop-Location
        return $false
    }
}

# Perform Archive backup
function Backup-WithArchive {
    Write-Log "Starting Archive-based backup..." -Level Info

    if (-not (Test-Path $SourcePath)) {
        Write-Log "Source path does not exist: $SourcePath" -Level Error
        return $false
    }

    try {
        $timestamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
        $archiveName = "ComfyUI-Backup_$timestamp.zip"
        $archivePath = Join-Path $ArchiveBackupPath $archiveName

        Write-Log "Creating archive: $archiveName" -Level Info

        # Compress with progress
        Compress-Archive -Path $SourcePath -DestinationPath $archivePath -CompressionLevel Optimal -Force

        $archiveSize = (Get-Item $archivePath).Length / 1MB
        Write-Log "Archive backup completed: $archiveName (${archiveSize:N2} MB)" -Level Success

        # Clean up old archives (keep last 14 days)
        $oldArchives = Get-ChildItem $ArchiveBackupPath -Filter "ComfyUI-Backup_*.zip" |
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-14) }

        if ($oldArchives) {
            Write-Log "Removing $($oldArchives.Count) old archive(s)..." -Level Info
            $oldArchives | Remove-Item -Force
        }

        return $true

    } catch {
        Write-Log "Error during Archive backup: $_" -Level Error
        return $false
    }
}

# List available backups
function Get-AvailableBackups {
    Write-Log "Available backups:" -Level Info

    # Git backups
    if (Test-Path "$GitBackupPath\.git") {
        Write-Log "`nGit Backups:" -Level Info
        Push-Location $GitBackupPath
        $gitLog = git log --oneline -20 --format="%h - %ar - %s" 2>&1
        if ($gitLog) {
            $gitLog | ForEach-Object {
                Write-Log "  $_" -Level Info
            }
        }
        Pop-Location
    }

    # Archive backups
    $archives = Get-ChildItem $ArchiveBackupPath -Filter "ComfyUI-Backup_*.zip" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 20

    if ($archives) {
        Write-Log "`nArchive Backups:" -Level Info
        $archives | ForEach-Object {
            $size = ($_.Length / 1MB).ToString("N2")
            Write-Log "  $($_.Name) - $size MB - $($_.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))" -Level Info
        }
    }
}

# Restore from Git commit
function Restore-FromGit {
    param([string]$CommitHash)

    if (-not $CommitHash) {
        Write-Log "Please specify a commit hash to restore from." -Level Error
        Get-AvailableBackups
        return $false
    }

    Write-Log "Restoring from Git commit: $CommitHash" -Level Info

    try {
        # Backup current state first
        if (Test-Path $SourcePath) {
            $tempBackup = "$env:TEMP\ComfyUI-PreRestore_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Write-Log "Creating safety backup at: $tempBackup" -Level Info
            Copy-Item -Path $SourcePath -Destination $tempBackup -Recurse -Force
        }

        Push-Location $GitBackupPath

        # Verify commit exists
        $commitExists = git cat-file -e "$CommitHash^{commit}" 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Commit hash not found: $CommitHash" -Level Error
            Pop-Location
            return $false
        }

        # Checkout the commit
        git checkout $CommitHash . | Out-Null
        Pop-Location

        # Restore to original location
        Write-Log "Copying restored files to original location..." -Level Info

        if (Test-Path $SourcePath) {
            Remove-Item -Path $SourcePath -Recurse -Force
        }

        Copy-Item -Path $GitBackupPath -Destination $SourcePath -Recurse -Force -Exclude ".git"

        Write-Log "Restore completed successfully!" -Level Success
        Write-Log "Safety backup available at: $tempBackup" -Level Info

        # Return to latest commit
        Push-Location $GitBackupPath
        git checkout master 2>$null
        Pop-Location

        return $true

    } catch {
        Write-Log "Error during restore: $_" -Level Error
        Pop-Location
        return $false
    }
}

# Restore from Archive
function Restore-FromArchive {
    param([string]$ArchiveName)

    if (-not $ArchiveName) {
        Write-Log "Please specify an archive filename to restore from." -Level Error
        Get-AvailableBackups
        return $false
    }

    $archivePath = Join-Path $ArchiveBackupPath $ArchiveName

    if (-not (Test-Path $archivePath)) {
        Write-Log "Archive not found: $ArchiveName" -Level Error
        return $false
    }

    Write-Log "Restoring from archive: $ArchiveName" -Level Info

    try {
        # Backup current state first
        if (Test-Path $SourcePath) {
            $tempBackup = "$env:TEMP\ComfyUI-PreRestore_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Write-Log "Creating safety backup at: $tempBackup" -Level Info
            Copy-Item -Path $SourcePath -Destination $tempBackup -Recurse -Force
        }

        # Extract archive to temp location
        $tempExtract = "$env:TEMP\ComfyUI-Extract_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Expand-Archive -Path $archivePath -DestinationPath $tempExtract -Force

        # Find the actual content folder
        $extractedContent = Get-ChildItem $tempExtract | Select-Object -First 1

        # Remove current installation
        if (Test-Path $SourcePath) {
            Remove-Item -Path $SourcePath -Recurse -Force
        }

        # Move restored content
        Move-Item -Path $extractedContent.FullName -Destination $SourcePath -Force

        # Cleanup
        Remove-Item -Path $tempExtract -Recurse -Force -ErrorAction SilentlyContinue

        Write-Log "Restore completed successfully!" -Level Success
        Write-Log "Safety backup available at: $tempBackup" -Level Info

        return $true

    } catch {
        Write-Log "Error during restore: $_" -Level Error
        return $false
    }
}

# Rollback to previous backup
function Invoke-Rollback {
    Write-Log "Rolling back to previous backup..." -Level Info

    if ($BackupType -eq 'Git') {
        if (-not (Test-Path "$GitBackupPath\.git")) {
            Write-Log "No Git repository found." -Level Error
            return $false
        }

        Push-Location $GitBackupPath
        $previousCommit = git rev-parse HEAD~1 2>$null
        Pop-Location

        if ($previousCommit) {
            return Restore-FromGit -CommitHash $previousCommit
        } else {
            Write-Log "No previous commit found." -Level Error
            return $false
        }
    } else {
        $latestArchive = Get-ChildItem $ArchiveBackupPath -Filter "ComfyUI-Backup_*.zip" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

        if ($latestArchive) {
            return Restore-FromArchive -ArchiveName $latestArchive.Name
        } else {
            Write-Log "No archives found." -Level Error
            return $false
        }
    }
}

# Create scheduled task
function New-BackupSchedule {
    Write-Log "Creating scheduled task..." -Level Info

    try {
        $taskName = "ComfyUI-DailyBackup"
        $scriptPath = $PSCommandPath

        # Check if task already exists
        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Write-Log "Scheduled task already exists. Removing old task..." -Level Warning
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        }

        # Create action
        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
            -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`" -Mode Backup -BackupType $BackupType"

        # Create trigger (daily at specified time)
        $trigger = New-ScheduledTaskTrigger -Daily -At $ScheduleTime

        # Create settings
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -StartWhenAvailable -RunOnlyIfNetworkAvailable:$false

        # Create principal (run as current user)
        $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest

        # Register task
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
            -Settings $settings -Principal $principal -Description "Daily backup of ComfyUI Electron installation"

        Write-Log "Scheduled task created successfully! Backup will run daily at $ScheduleTime" -Level Success
        Write-Log "Task name: $taskName" -Level Info

        return $true

    } catch {
        Write-Log "Error creating scheduled task: $_" -Level Error
        Write-Log "You may need to run this script as Administrator to create scheduled tasks." -Level Warning
        return $false
    }
}

# Create Start Menu shortcut
function New-StartMenuShortcut {
    Write-Log "Creating Start Menu shortcut..." -Level Info

    try {
        $startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
        $shortcutPath = "$startMenuPath\ComfyUI Backup.lnk"

        $WScriptShell = New-Object -ComObject WScript.Shell
        $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = "PowerShell.exe"
        $shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Mode Backup -BackupType $BackupType"
        $shortcut.WorkingDirectory = $PSScriptRoot
        $shortcut.Description = "Backup ComfyUI Electron"
        $shortcut.Save()

        Write-Log "Start Menu shortcut created: $shortcutPath" -Level Success

        return $true

    } catch {
        Write-Log "Error creating shortcut: $_" -Level Error
        return $false
    }
}

# Interactive installation
function Install-BackupSystem {
    Write-Host "`n=== ComfyUI Backup System Installation ===" -ForegroundColor Cyan
    Write-Host ""

    # Choose backup type
    Write-Host "Select backup type:"
    Write-Host "  1. Git (version control, rollback to any point)"
    Write-Host "  2. Archive (ZIP files, simpler)"
    $backupChoice = Read-Host "Enter choice (1 or 2)"

    $selectedBackupType = if ($backupChoice -eq "2") { "Archive" } else { "Git" }

    Write-Host "`nSelected: $selectedBackupType backup" -ForegroundColor Green

    # Choose schedule time
    Write-Host "`nEnter daily backup time (24-hour format, e.g., 02:00):"
    $scheduleTime = Read-Host "Time"
    if (-not $scheduleTime) { $scheduleTime = "02:00" }

    # Create directories
    Initialize-Directories

    # Create scheduled task
    Write-Host "`nCreating scheduled task..."
    $script:BackupType = $selectedBackupType
    New-BackupSchedule

    # Create shortcut
    Write-Host "`nCreating Start Menu shortcut..."
    New-StartMenuShortcut

    # Perform initial backup
    Write-Host "`nPerforming initial backup..."
    if ($selectedBackupType -eq "Git") {
        Backup-WithGit
    } else {
        Backup-WithArchive
    }

    Write-Host "`n=== Installation Complete! ===" -ForegroundColor Green
    Write-Host "Scheduled task: Daily at $scheduleTime"
    Write-Host "Start Menu: ComfyUI Backup"
    Write-Host "Backup location: $BackupBasePath"
    Write-Host ""
}

# Main execution
function Main {
    Write-Host "`n=== ComfyUI Electron Backup Script ===" -ForegroundColor Cyan
    Write-Host "Mode: $Mode | Backup Type: $BackupType`n" -ForegroundColor Yellow

    Initialize-Directories

    switch ($Mode) {
        'Backup' {
            if ($BackupType -eq 'Git') {
                Backup-WithGit
            } else {
                Backup-WithArchive
            }
        }

        'Restore' {
            if (-not $RestorePoint) {
                Write-Log "RestorePoint parameter required for Restore mode." -Level Error
                Get-AvailableBackups
            } else {
                if ($BackupType -eq 'Git') {
                    Restore-FromGit -CommitHash $RestorePoint
                } else {
                    Restore-FromArchive -ArchiveName $RestorePoint
                }
            }
        }

        'Rollback' {
            Invoke-Rollback
        }

        'ListBackups' {
            Get-AvailableBackups
        }

        'CreateSchedule' {
            New-BackupSchedule
        }

        'CreateShortcut' {
            New-StartMenuShortcut
        }

        'Install' {
            Install-BackupSystem
        }
    }

    Write-Host ""
}

# Run main function
Main
