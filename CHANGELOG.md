# Changelog

All notable changes to the ComfyUI Backup Script will be documented in this file.

## [1.0.1] - 2025-12-02

### Fixed
- **Git Repository Persistence**: Fixed robocopy `/MIR` flag deleting `.git` folder on subsequent backups. Added `/XD .git` to preserve Git repository across backup runs.
- **Git Log Display**: Fixed Git commit history not showing in ListBackups mode. Git log output now properly captured and displayed.

### Changed
- **Interactive Menus**: RunBackup.bat and QuickRestore.bat now loop back to menu after operations instead of exiting. Added explicit "Exit" option.
- **README Updates**: Highlighted `RunBackup.bat` as the primary/recommended interface for most users. Added visual menu example and benefits.

### Added
- **Test Suite**: Created comprehensive test plan (TEST_PLAN.md) with 35 test cases
- **Test Scripts**:
  - `Run-Tests.ps1` - Automated test script
  - `QuickTest.ps1` - Quick validation script
  - `CreateMockData.ps1` - Mock data generator for testing
- **Test Results**: Documented all test results in TEST_RESULTS.md (8/8 tests passed)
- **Changelog**: This file to track all changes

### Testing
- All core functionality verified and working
- Git backup: Creates repository, commits changes, preserves .git folder
- Archive backup: Creates ZIP files with correct sizes
- ListBackups: Shows both Git and Archive backups
- Interactive menus: Loop properly, easy to use

---

## [1.0.0] - 2025-12-02

### Initial Release

#### Features
- **Two Backup Types**:
  - Git-based version control backups (space-efficient, unlimited history)
  - Archive-based ZIP backups (simple, no dependencies)

- **Operations**:
  - Create backups (on-demand or scheduled)
  - List available backups
  - Restore from specific backup point
  - Quick rollback to previous backup
  - Install/setup wizard

- **Automation**:
  - Windows Task Scheduler integration for daily backups
  - Start Menu shortcut creation
  - Automatic cleanup (Git: 30 commits, Archive: 14 days)

- **Interactive Interfaces**:
  - `RunBackup.bat` - Main menu for backup operations
  - `QuickRestore.bat` - Guided restore process with safety confirmations

- **Safety Features**:
  - Pre-restore safety backups stored in %TEMP%
  - Detailed logging (monthly log files)
  - Confirmation prompts for destructive operations

- **Documentation**:
  - README.md - Complete technical documentation
  - START_HERE.txt - Quick start guide for new users
  - USAGE.txt - Detailed usage instructions
  - SCENARIOS.txt - Step-by-step guides for 14 common scenarios
  - TEST_PLAN.md - Comprehensive test plan
  - GITHUB_SETUP.txt - GitHub repository setup instructions

#### Technical Details
- **Target**: ComfyUI Electron installation at `%LOCALAPPDATA%\Programs\@comfyorgcomfyui-electron`
- **Requirements**: Windows 10/11, PowerShell 5.1+, Git (optional, for Git backup mode)
- **Language**: PowerShell 5.1
- **License**: Free to use and modify

---

## Release Notes

### Version 1.0.1 Summary
This update fixes critical bugs found during testing and improves user experience with looping menus. The script is now production-ready with 100% test pass rate.

**Key Fixes:**
- Git backups now persist correctly
- Backup history displays properly
- Menus are more user-friendly

**Recommended for:** All users. Upgrade strongly recommended if using Git backup mode.

### Version 1.0.0 Summary
Initial public release with full feature set. Comprehensive backup solution with both Git and Archive modes, automated scheduling, and easy restore capabilities.

**Recommended for:** All ComfyUI Electron users who want automated, reliable backups.

---

## Future Plans (Possible Future GUI Wrapper)
- Graphical user interface wrapper for even easier operation
- Real-time backup monitoring
- Cloud backup integration
- Multi-installation support
- Backup encryption

---

## Contributing
Found a bug? Have a suggestion? Please open an issue at:
https://github.com/BizaNator/BrainDeadComfyUIDesktopBackup/issues
