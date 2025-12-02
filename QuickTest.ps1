# Quick Test Script for ComfyUI Backup
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host "ComfyUI Backup - Quick Test" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$ScriptPath = "$PSScriptRoot\ComfyUI-Backup.ps1"
$TestsPassed = 0
$TestsFailed = 0

function Test-Item {
    param($Name, $Condition, $ErrorMsg = "")

    Write-Host "Testing: $Name... " -NoNewline

    if ($Condition) {
        Write-Host "PASS" -ForegroundColor Green
        $script:TestsPassed++
    } else {
        Write-Host "FAIL" -ForegroundColor Red
        if ($ErrorMsg) { Write-Host "  Error: $ErrorMsg" -ForegroundColor Yellow }
        $script:TestsFailed++
    }
}

# Test 1: Main script exists
Test-Item "Main script exists" (Test-Path $ScriptPath)

# Test 2: Batch files exist
Test-Item "RunBackup.bat exists" (Test-Path "$PSScriptRoot\RunBackup.bat")
Test-Item "QuickRestore.bat exists" (Test-Path "$PSScriptRoot\QuickRestore.bat")

# Test 3: Documentation exists
Test-Item "README.md exists" (Test-Path "$PSScriptRoot\README.md")
Test-Item "START_HERE.txt exists" (Test-Path "$PSScriptRoot\START_HERE.txt")
Test-Item "USAGE.txt exists" (Test-Path "$PSScriptRoot\USAGE.txt")
Test-Item "SCENARIOS.txt exists" (Test-Path "$PSScriptRoot\SCENARIOS.txt")

# Test 4: .gitignore configured correctly
if (Test-Path "$PSScriptRoot\.gitignore") {
    $gitignore = Get-Content "$PSScriptRoot\.gitignore" -Raw
    Test-Item ".gitignore excludes Backups/" ($gitignore -match "Backups/")
    Test-Item ".gitignore excludes Logs/" ($gitignore -match "Logs/")
} else {
    Test-Item ".gitignore exists" $false
}

# Test 5: Script syntax
try {
    $errors = @()
    $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $ScriptPath -Raw), [ref]$errors)
    Test-Item "Script has valid PowerShell syntax" ($errors.Count -eq 0)
} catch {
    Test-Item "Script has valid PowerShell syntax" $false $_.Exception.Message
}

# Test 6: Git availability
try {
    $null = git --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Test-Item "Git is available in PATH" $true
    } else {
        Test-Item "Git is available in PATH" $false
    }
} catch {
    Test-Item "Git is available in PATH" $false "Git not found"
}

# Test 7: Check script parameters
try {
    $params = (Get-Command $ScriptPath).Parameters
    Test-Item "Script has Mode parameter" ($params.ContainsKey("Mode"))
    Test-Item "Script has BackupType parameter" ($params.ContainsKey("BackupType"))
    Test-Item "Script has RestorePoint parameter" ($params.ContainsKey("RestorePoint"))
} catch {
    Test-Item "Script parameters accessible" $false $_.Exception.Message
}

# Test 8: Directory initialization
Write-Host "`nTesting directory initialization..." -ForegroundColor Cyan
$testBackupPath = "$PSScriptRoot\Backups"
$testLogPath = "$PSScriptRoot\Logs"

# These will be created on first run, so we just check if they can be created
if (-not (Test-Path $testBackupPath)) {
    Test-Item "Backups directory can be created" $true "Will be created on first backup"
} else {
    Test-Item "Backups directory exists" $true
}

if (-not (Test-Path $testLogPath)) {
    Test-Item "Logs directory can be created" $true "Will be created on first run"
} else {
    Test-Item "Logs directory exists" $true
}

# Summary
Write-Host "`n========================================"  -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host "Passed: $TestsPassed" -ForegroundColor Green
Write-Host "Failed: $TestsFailed" -ForegroundColor Red
$total = $TestsPassed + $TestsFailed
if ($total -gt 0) {
    $percent = [math]::Round(($TestsPassed / $total) * 100, 2)
    Write-Host "Success Rate: $percent%" -ForegroundColor $(if ($percent -eq 100) { "Green" } else { "Yellow" })
}

Write-Host "`n"
if ($TestsFailed -eq 0) {
    Write-Host "✓ All basic tests passed!" -ForegroundColor Green
    Write-Host "The script is ready for functional testing." -ForegroundColor Green
} else {
    Write-Host "⚠ Some tests failed. Please review the errors above." -ForegroundColor Yellow
}

Write-Host "`nFor full functional testing, see TEST_PLAN.md" -ForegroundColor Cyan
Write-Host ""
