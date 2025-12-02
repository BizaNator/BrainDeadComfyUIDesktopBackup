# ComfyUI Backup System - Comprehensive Test Plan

## Test Environment Setup
- **Test Directory**: C:\tools\ComfyDesktopBackup\TestEnv
- **Mock Source**: Test ComfyUI installation with sample files
- **Expected Results**: All operations should complete without errors

## Test Categories

### A. Pre-Test Setup
- [ ] Create mock ComfyUI installation directory
- [ ] Populate with test files (configs, workflows, models)
- [ ] Verify script can read source path
- [ ] Clean any existing Backups/ and Logs/ folders

---

## 1. BACKUP OPERATIONS

### Test 1.1: Git Backup (First Time)
**Menu**: RunBackup.bat → Option 1

**Prerequisites**:
- Git installed and in PATH
- No existing GitRepo folder
- Mock source directory has files

**Steps**:
1. Run backup with Git type
2. Verify GitRepo folder created
3. Verify .git folder exists
4. Verify files copied to GitRepo
5. Verify git commit created
6. Check log file for success message

**Expected Results**:
- GitRepo initialized successfully
- All source files copied
- Git commit with timestamp created
- Log shows "Git backup completed. Commit: [hash]"
- No errors in output

**Pass Criteria**: ✅ / ❌

---

### Test 1.2: Git Backup (Subsequent)
**Menu**: RunBackup.bat → Option 1

**Prerequisites**:
- Test 1.1 passed
- Modify some files in source

**Steps**:
1. Change a file in source directory
2. Run backup again
3. Verify new commit created
4. Verify changes reflected in GitRepo

**Expected Results**:
- New commit with latest changes
- Git history shows multiple commits
- No duplicate files
- Log shows success

**Pass Criteria**: ✅ / ❌

---

### Test 1.3: Git Backup (No Changes)
**Menu**: RunBackup.bat → Option 1

**Prerequisites**:
- Test 1.2 passed
- No changes to source

**Steps**:
1. Run backup without any changes
2. Verify message about no changes

**Expected Results**:
- Log shows "No changes detected since last backup"
- No new commit created
- No errors

**Pass Criteria**: ✅ / ❌

---

### Test 1.4: Archive Backup (First Time)
**Menu**: RunBackup.bat → Option 2

**Prerequisites**:
- No existing Archives folder
- Mock source directory has files

**Steps**:
1. Run backup with Archive type
2. Verify Archives folder created
3. Verify ZIP file created with timestamp name
4. Verify ZIP contains all source files
5. Check log file for success

**Expected Results**:
- Archive folder created
- ZIP file: ComfyUI-Backup_YYYY-MM-DD_HHMMSS.zip
- ZIP contains all files from source
- Log shows size in MB
- No errors

**Pass Criteria**: ✅ / ❌

---

### Test 1.5: Archive Backup (Multiple)
**Menu**: RunBackup.bat → Option 2

**Prerequisites**:
- Test 1.4 passed

**Steps**:
1. Wait 2 seconds (for different timestamp)
2. Run backup again
3. Verify multiple ZIP files exist

**Expected Results**:
- Two distinct ZIP files with different timestamps
- Both contain source files
- No overwriting of previous backup

**Pass Criteria**: ✅ / ❌

---

## 2. LIST BACKUPS OPERATIONS

### Test 2.1: List Git Backups
**Menu**: RunBackup.bat → Option 3

**Prerequisites**:
- Test 1.1 and 1.2 passed (multiple Git commits exist)

**Steps**:
1. Run ListBackups mode
2. Verify Git commits displayed

**Expected Results**:
- Shows "Git Backups:" section
- Lists commits with hash, time ago, message
- Shows last 20 commits max
- No errors

**Pass Criteria**: ✅ / ❌

---

### Test 2.2: List Archive Backups
**Menu**: RunBackup.bat → Option 3

**Prerequisites**:
- Test 1.4 and 1.5 passed (multiple archives exist)

**Steps**:
1. Run ListBackups mode
2. Verify archives displayed

**Expected Results**:
- Shows "Archive Backups:" section
- Lists ZIP files with name, size, date
- Shows last 20 archives max
- No errors

**Pass Criteria**: ✅ / ❌

---

### Test 2.3: List with No Backups
**Menu**: RunBackup.bat → Option 3

**Prerequisites**:
- Clean Backups folder (no backups exist)

**Steps**:
1. Run ListBackups mode

**Expected Results**:
- Gracefully handles empty backup folders
- No crashes or errors
- Clear message or empty lists

**Pass Criteria**: ✅ / ❌

---

## 3. RESTORE OPERATIONS

### Test 3.1: Restore from Git (Specific Commit)
**Menu**: QuickRestore.bat → Option 1

**Prerequisites**:
- Test 1.1 and 1.2 passed (multiple commits)
- Note a specific commit hash

**Steps**:
1. Modify source files
2. Run restore with specific commit hash
3. Confirm restore
4. Verify files restored to that commit state

**Expected Results**:
- Safety backup created in %TEMP%
- Source files replaced with commit version
- Log shows restore success
- Safety backup path displayed
- Git repo returns to master after restore

**Pass Criteria**: ✅ / ❌

---

### Test 3.2: Restore from Archive (Specific File)
**Menu**: QuickRestore.bat → Option 2

**Prerequisites**:
- Test 1.4 passed (archive exists)
- Note archive filename

**Steps**:
1. Modify source files
2. Run restore with archive filename
3. Confirm restore
4. Verify files restored from archive

**Expected Results**:
- Safety backup created in %TEMP%
- Source files replaced with archive contents
- Log shows restore success
- Safety backup path displayed

**Pass Criteria**: ✅ / ❌

---

### Test 3.3: Restore with Invalid Commit Hash
**Menu**: QuickRestore.bat → Option 1

**Prerequisites**:
- Git backups exist

**Steps**:
1. Run restore with fake commit hash "abc123xyz"
2. Verify error handling

**Expected Results**:
- Error message: "Commit hash not found"
- No changes to source files
- No corruption
- Graceful failure

**Pass Criteria**: ✅ / ❌

---

### Test 3.4: Restore with Invalid Archive Name
**Menu**: QuickRestore.bat → Option 2

**Prerequisites**:
- Archive backups exist

**Steps**:
1. Run restore with non-existent filename
2. Verify error handling

**Expected Results**:
- Error message: "Archive not found"
- No changes to source files
- Graceful failure

**Pass Criteria**: ✅ / ❌

---

## 4. ROLLBACK OPERATIONS

### Test 4.1: Rollback Git (to Previous)
**Menu**: RunBackup.bat → Option 4 (or QuickRestore.bat → Option 3)

**Prerequisites**:
- Test 1.1 and 1.2 passed (at least 2 commits)

**Steps**:
1. Run rollback with Git type
2. Confirm rollback
3. Verify source restored to previous commit

**Expected Results**:
- Safety backup created
- Source restored to HEAD~1
- Log shows rollback success
- Previous commit hash displayed

**Pass Criteria**: ✅ / ❌

---

### Test 4.2: Rollback Archive (to Latest)
**Menu**: RunBackup.bat → Option 4

**Prerequisites**:
- Test 1.4 passed (archive exists)

**Steps**:
1. Run rollback with Archive type
2. Confirm rollback
3. Verify source restored to latest archive

**Expected Results**:
- Safety backup created
- Source restored from latest ZIP
- Log shows rollback success
- Archive filename displayed

**Pass Criteria**: ✅ / ❌

---

### Test 4.3: Rollback with No Backups
**Menu**: RunBackup.bat → Option 4

**Prerequisites**:
- Clean Backups folder

**Steps**:
1. Run rollback
2. Verify error handling

**Expected Results**:
- Error message: "No backups found" or similar
- No changes to source
- Graceful failure

**Pass Criteria**: ✅ / ❌

---

## 5. SCHEDULED TASK OPERATIONS

### Test 5.1: Create Scheduled Task (Git)
**Menu**: RunBackup.bat → Option 5 (or CreateSchedule mode)

**Prerequisites**:
- Administrator privileges
- No existing scheduled task

**Steps**:
1. Run CreateSchedule with Git type
2. Set time to 02:00
3. Verify task created in Task Scheduler

**Expected Results**:
- Task "ComfyUI-DailyBackup" created
- Task set to run daily at 02:00
- Task points to correct script
- Task uses correct parameters
- Log shows success

**Pass Criteria**: ✅ / ❌

---

### Test 5.2: Update Existing Scheduled Task
**Menu**: RunBackup.bat → Option 5

**Prerequisites**:
- Test 5.1 passed (task exists)

**Steps**:
1. Run CreateSchedule again with different time
2. Verify old task removed, new task created

**Expected Results**:
- Warning about existing task
- Old task removed
- New task created with new time
- No duplicate tasks

**Pass Criteria**: ✅ / ❌

---

### Test 5.3: Scheduled Task Execution
**Manual Test**

**Prerequisites**:
- Test 5.1 passed

**Steps**:
1. Manually run task from Task Scheduler
2. Wait for completion
3. Check Logs folder for new entry
4. Verify backup was created

**Expected Results**:
- Task runs successfully
- Backup created
- Log file updated
- Task shows "Last Run Result: Success"

**Pass Criteria**: ✅ / ❌

---

## 6. START MENU SHORTCUT

### Test 6.1: Create Start Menu Shortcut
**Menu**: CreateShortcut mode

**Prerequisites**:
- None

**Steps**:
1. Run CreateShortcut with Git type
2. Verify shortcut created in Start Menu

**Expected Results**:
- Shortcut at: %APPDATA%\Microsoft\Windows\Start Menu\Programs\ComfyUI Backup.lnk
- Shortcut points to script
- Shortcut has correct arguments
- Log shows success

**Pass Criteria**: ✅ / ❌

---

### Test 6.2: Start Menu Shortcut Execution
**Manual Test**

**Prerequisites**:
- Test 6.1 passed

**Steps**:
1. Open Start Menu
2. Search for "ComfyUI Backup"
3. Click shortcut
4. Verify backup runs

**Expected Results**:
- Shortcut appears in Start Menu
- Clicking runs backup
- Backup completes successfully

**Pass Criteria**: ✅ / ❌

---

## 7. INSTALLATION WIZARD

### Test 7.1: Install Mode (Git)
**Menu**: RunBackup.bat → Option 5

**Prerequisites**:
- Clean environment
- Git installed

**Steps**:
1. Run Install mode
2. Choose Git backup (option 1)
3. Set time 02:00
4. Complete installation

**Expected Results**:
- Directories created
- Scheduled task created
- Start Menu shortcut created
- Initial backup performed
- Success message displayed

**Pass Criteria**: ✅ / ❌

---

### Test 7.2: Install Mode (Archive)
**Menu**: RunBackup.bat → Option 5

**Prerequisites**:
- Clean environment

**Steps**:
1. Run Install mode
2. Choose Archive backup (option 2)
3. Set time 03:00
4. Complete installation

**Expected Results**:
- Directories created
- Scheduled task created (Archive type)
- Start Menu shortcut created
- Initial backup performed (ZIP file)
- Success message displayed

**Pass Criteria**: ✅ / ❌

---

## 8. ERROR HANDLING

### Test 8.1: Source Path Does Not Exist
**Menu**: RunBackup.bat → Option 1

**Prerequisites**:
- Mock source directory deleted or renamed

**Steps**:
1. Run backup
2. Verify error handling

**Expected Results**:
- Error message: "Source path does not exist"
- No crash
- Log shows error
- Graceful exit

**Pass Criteria**: ✅ / ❌

---

### Test 8.2: Git Not Installed (Git Backup)
**Menu**: RunBackup.bat → Option 1

**Prerequisites**:
- Git not in PATH (temporarily rename git.exe or modify PATH)

**Steps**:
1. Run Git backup
2. Verify error handling

**Expected Results**:
- Error message about Git not found
- Suggestion to install Git or use Archive
- No crash
- Graceful exit

**Pass Criteria**: ✅ / ❌

---

### Test 8.3: Disk Space Issues
**Simulation Required**

**Expected Results**:
- Graceful handling of disk full errors
- Clear error message
- No corruption

**Pass Criteria**: ✅ / ❌

---

### Test 8.4: Permission Denied
**Menu**: Various

**Prerequisites**:
- Make Backups folder read-only

**Steps**:
1. Run backup
2. Verify error handling

**Expected Results**:
- Error message about permissions
- No crash
- Log shows error

**Pass Criteria**: ✅ / ❌

---

## 9. LOGGING

### Test 9.1: Log File Creation
**Menu**: Any operation

**Prerequisites**:
- Clean Logs folder

**Steps**:
1. Run any backup operation
2. Verify log file created

**Expected Results**:
- Log file: Logs\ComfyUI-Backup_YYYY-MM.log
- File contains timestamped entries
- Shows operation type and result

**Pass Criteria**: ✅ / ❌

---

### Test 9.2: Log File Rotation
**Menu**: Various operations across months

**Prerequisites**:
- Operations in different months

**Steps**:
1. Verify separate log files for different months

**Expected Results**:
- One log file per month
- Correct naming: ComfyUI-Backup_YYYY-MM.log
- All operations logged correctly

**Pass Criteria**: ✅ / ❌

---

## 10. CLEANUP OPERATIONS

### Test 10.1: Git Pruning (30+ Commits)
**Menu**: RunBackup.bat → Option 1 (multiple times)

**Prerequisites**:
- Create 35+ Git commits

**Steps**:
1. Create many backups (35+)
2. Verify old commits pruned

**Expected Results**:
- Only last 30 commits kept
- Automatic pruning message in log
- Git history consolidated
- No errors

**Pass Criteria**: ✅ / ❌

---

### Test 10.2: Archive Cleanup (14+ Days Old)
**Menu**: RunBackup.bat → Option 2

**Prerequisites**:
- Create archives with old timestamps (mock)

**Steps**:
1. Create archives older than 14 days
2. Run new backup
3. Verify old archives deleted

**Expected Results**:
- Archives older than 14 days removed
- Log shows cleanup message
- Recent archives preserved

**Pass Criteria**: ✅ / ❌

---

## 11. SAFETY FEATURES

### Test 11.1: Safety Backup Before Restore
**Menu**: QuickRestore.bat

**Prerequisites**:
- Valid backup exists

**Steps**:
1. Run restore operation
2. Check %TEMP% for safety backup

**Expected Results**:
- Safety backup created: %TEMP%\ComfyUI-PreRestore_*
- Contains current files before restore
- Path displayed to user
- Safety backup complete before restore starts

**Pass Criteria**: ✅ / ❌

---

## 12. BATCH FILE LAUNCHERS

### Test 12.1: RunBackup.bat Interactive Menu
**Menu**: RunBackup.bat

**Prerequisites**:
- None

**Steps**:
1. Run RunBackup.bat
2. Test each menu option (1-6)
3. Verify all options work

**Expected Results**:
- Menu displays correctly
- All options functional
- Invalid input handled
- Exit works

**Pass Criteria**: ✅ / ❌

---

### Test 12.2: QuickRestore.bat Interactive Menu
**Menu**: QuickRestore.bat

**Prerequisites**:
- Backups exist

**Steps**:
1. Run QuickRestore.bat
2. Test each menu option (1-4)
3. Verify confirmation prompts work

**Expected Results**:
- Menu displays correctly
- Backups listed first
- Confirmation required
- Cancel works
- All restore types work

**Pass Criteria**: ✅ / ❌

---

## Test Summary Template

| Test ID | Test Name | Status | Notes |
|---------|-----------|--------|-------|
| 1.1 | Git Backup (First) | ⏳ | |
| 1.2 | Git Backup (Subsequent) | ⏳ | |
| 1.3 | Git Backup (No Changes) | ⏳ | |
| 1.4 | Archive Backup (First) | ⏳ | |
| 1.5 | Archive Backup (Multiple) | ⏳ | |
| 2.1 | List Git Backups | ⏳ | |
| 2.2 | List Archive Backups | ⏳ | |
| 2.3 | List No Backups | ⏳ | |
| 3.1 | Restore Git | ⏳ | |
| 3.2 | Restore Archive | ⏳ | |
| 3.3 | Invalid Git Hash | ⏳ | |
| 3.4 | Invalid Archive | ⏳ | |
| 4.1 | Rollback Git | ⏳ | |
| 4.2 | Rollback Archive | ⏳ | |
| 4.3 | Rollback No Backups | ⏳ | |
| 5.1 | Create Scheduled Task | ⏳ | |
| 5.2 | Update Scheduled Task | ⏳ | |
| 5.3 | Task Execution | ⏳ | |
| 6.1 | Create Shortcut | ⏳ | |
| 6.2 | Shortcut Execution | ⏳ | |
| 7.1 | Install Git | ⏳ | |
| 7.2 | Install Archive | ⏳ | |
| 8.1 | Missing Source | ⏳ | |
| 8.2 | No Git | ⏳ | |
| 8.3 | Disk Space | ⏳ | |
| 8.4 | Permissions | ⏳ | |
| 9.1 | Log Creation | ⏳ | |
| 9.2 | Log Rotation | ⏳ | |
| 10.1 | Git Pruning | ⏳ | |
| 10.2 | Archive Cleanup | ⏳ | |
| 11.1 | Safety Backup | ⏳ | |
| 12.1 | RunBackup Menu | ⏳ | |
| 12.2 | QuickRestore Menu | ⏳ | |

## Total Tests: 35
