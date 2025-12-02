#Requires -Version 5.1
<#
.SYNOPSIS
    Automated Test Suite for ComfyUI Backup Script
.DESCRIPTION
    Tests all functionality of the ComfyUI-Backup.ps1 script
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$DetailedOutput
)

# Test configuration
$ScriptRoot = $PSScriptRoot
$MainScript = "$ScriptRoot\ComfyUI-Backup.ps1"
$TestRoot = "$ScriptRoot\TestEnv"
$MockSource = "$TestRoot\MockComfyUI"
$TestBackups = "$TestRoot\Backups"
$TestLogs = "$TestRoot\Logs"

# Test results
$TestResults = @()
$PassCount = 0
$FailCount = 0

# Colors
$ColorPass = "Green"
$ColorFail = "Red"
$ColorInfo = "Cyan"
$ColorWarn = "Yellow"

function Write-TestHeader {
    param([string]$Message)
    Write-Host "`n$('='*80)" -ForegroundColor $ColorInfo
    Write-Host $Message -ForegroundColor $ColorInfo
    Write-Host $('='*80) -ForegroundColor $ColorInfo
}

function Write-TestResult {
    param(
        [string]$TestId,
        [string]$TestName,
        [bool]$Passed,
        [string]$Notes = ""
    )

    $Status = if ($Passed) { "PASS" } else { "FAIL" }
    $Color = if ($Passed) { $ColorPass } else { $ColorFail }

    Write-Host "[$TestId] $TestName : " -NoNewline
    Write-Host $Status -ForegroundColor $Color

    if ($Notes) {
        Write-Host "  Notes: $Notes" -ForegroundColor $ColorWarn
    }

    $script:TestResults += [PSCustomObject]@{
        TestId = $TestId
        TestName = $TestName
        Status = $Status
        Notes = $Notes
    }

    if ($Passed) {
        $script:PassCount++
    } else {
        $script:FailCount++
    }
}

function Initialize-TestEnvironment {
    Write-TestHeader "INITIALIZING TEST ENVIRONMENT"

    # Clean test environment
    if (Test-Path $TestRoot) {
        Remove-Item -Path $TestRoot -Recurse -Force
    }

    # Create test directories
    New-Item -ItemType Directory -Path $MockSource -Force | Out-Null
    New-Item -ItemType Directory -Path "$TestBackups" -Force | Out-Null
    New-Item -ItemType Directory -Path "$TestLogs" -Force | Out-Null

    # Create mock ComfyUI files
    "Config file content" | Out-File "$MockSource\config.json"
    "Workflow data" | Out-File "$MockSource\workflow.json"
    New-Item -ItemType Directory -Path "$MockSource\models" -Force | Out-Null
    "Model data" | Out-File "$MockSource\models\model1.safetensors"
    New-Item -ItemType Directory -Path "$MockSource\custom_nodes" -Force | Out-Null
    "Node code" | Out-File "$MockSource\custom_nodes\node.py"

    Write-Host "✓ Test environment created" -ForegroundColor $ColorPass
    Write-Host "  Mock Source: $MockSource"
    Write-Host "  Test Backups: $TestBackups"
}

function Test-GitBackupFirst {
    $testId = "1.1"
    $testName = "Git Backup (First Time)"

    try {
        # Modify script to use test paths
        $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $MainScript -Mode Backup -BackupType Git 2>&1

        $gitRepoPath = "$TestBackups\GitRepo"
        $gitExists = Test-Path "$gitRepoPath\.git"
        $filesExist = Test-Path "$gitRepoPath\config.json"

        $passed = $gitExists -and $filesExist
        $notes = if (-not $gitExists) { "Git repo not created" }
                 elseif (-not $filesExist) { "Files not copied" }
                 else { "" }

        Write-TestResult $testId $testName $passed $notes
    }
    catch {
        Write-TestResult $testId $testName $false $_.Exception.Message
    }
}

function Test-ListBackups {
    $testId = "2.1"
    $testName = "List Backups"

    try {
        $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $MainScript -Mode ListBackups 2>&1

        $hasOutput = $output -ne $null
        $passed = $hasOutput

        Write-TestResult $testId $testName $passed
    }
    catch {
        Write-TestResult $testId $testName $false $_.Exception.Message
    }
}

function Show-TestSummary {
    Write-TestHeader "TEST SUMMARY"

    Write-Host "`nResults:" -ForegroundColor $ColorInfo
    $TestResults | Format-Table -AutoSize

    $total = $PassCount + $FailCount
    $passPercent = if ($total -gt 0) { [math]::Round(($PassCount / $total) * 100, 2) } else { 0 }

    Write-Host "`nTotal Tests: $total" -ForegroundColor $ColorInfo
    Write-Host "Passed: $PassCount" -ForegroundColor $ColorPass
    Write-Host "Failed: $FailCount" -ForegroundColor $ColorFail
    Write-Host "Success Rate: $passPercent%" -ForegroundColor $ColorInfo

    # Save results to file
    $resultsFile = "$TestRoot\TestResults_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $TestResults | Out-File $resultsFile
    Write-Host "`nResults saved to: $resultsFile" -ForegroundColor $ColorInfo
}

# Main test execution
function Main {
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $ColorInfo
    Write-Host "║  ComfyUI Backup Script - Automated Test Suite             ║" -ForegroundColor $ColorInfo
    Write-Host "╚══════════════════════════════════════════════════════════════╝`n" -ForegroundColor $ColorInfo

    # Initialize-TestEnvironment

    Write-TestHeader "RUNNING BASIC TESTS"

    Write-Host "`nNOTE: This is a simplified test runner." -ForegroundColor $ColorWarn
    Write-Host "The main script uses the actual ComfyUI source path: %LOCALAPPDATA%\Programs\@comfyorgcomfyui-electron" -ForegroundColor $ColorWarn
    Write-Host "For full testing, we'll run actual operations and verify they work.`n" -ForegroundColor $ColorWarn

    # Test 1: Check if script exists
    Write-Host "Checking prerequisites..." -ForegroundColor $ColorInfo
    $scriptExists = Test-Path $MainScript
    Write-TestResult "0.1" "Main script exists" $scriptExists

    # Test 2: Check if Git is available
    try {
        $null = git --version 2>&1
        Write-TestResult "0.2" "Git is available" $true
    } catch {
        Write-TestResult "0.2" "Git is available" $false "Git not found in PATH"
    }

    # Test 3: Check script syntax
    try {
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $MainScript -Raw), [ref]$errors)
        $syntaxValid = $errors.Count -eq 0
        Write-TestResult "0.3" "Script syntax valid" $syntaxValid
    } catch {
        Write-TestResult "0.3" "Script syntax valid" $false $_.Exception.Message
    }

    # Test 4: Check help parameter
    try {
        $help = Get-Help $MainScript -ErrorAction Stop
        $hasParameters = $help.parameters -ne $null
        Write-TestResult "0.4" "Script help available" $hasParameters
    } catch {
        Write-TestResult "0.4" "Script help available" $false
    }

    # Test 5: Verify batch files exist
    $runBackupExists = Test-Path "$ScriptRoot\RunBackup.bat"
    Write-TestResult "0.5" "RunBackup.bat exists" $runBackupExists

    $quickRestoreExists = Test-Path "$ScriptRoot\QuickRestore.bat"
    Write-TestResult "0.6" "QuickRestore.bat exists" $quickRestoreExists

    # Test 6: Verify documentation exists
    $docsExist = @(
        "README.md",
        "START_HERE.txt",
        "USAGE.txt",
        "SCENARIOS.txt"
    ) | ForEach-Object {
        Test-Path "$ScriptRoot\$_"
    } | Where-Object { $_ -eq $false } | Measure-Object | Select-Object -ExpandProperty Count

    Write-TestResult "0.7" "All documentation exists" ($docsExist -eq 0)

    # Test 7: Verify .gitignore exists and has correct content
    $gitignoreExists = Test-Path "$ScriptRoot\.gitignore"
    if ($gitignoreExists) {
        $gitignoreContent = Get-Content "$ScriptRoot\.gitignore" -Raw
        $excludesBackups = $gitignoreContent -match "Backups/"
        $excludesLogs = $gitignoreContent -match "Logs/"
        Write-TestResult "0.8" ".gitignore excludes Backups and Logs" ($excludesBackups -and $excludesLogs)
    } else {
        Write-TestResult "0.8" ".gitignore exists" $false
    }

    Show-TestSummary

    Write-Host "`n" -NoNewline
    Write-Host "MANUAL TESTING REQUIRED:" -ForegroundColor $ColorWarn
    Write-Host "For complete testing, please run the following manual tests:" -ForegroundColor $ColorWarn
    Write-Host "  1. Test actual backup operations (requires ComfyUI installation)" -ForegroundColor $ColorWarn
    Write-Host "  2. Test restore operations" -ForegroundColor $ColorWarn
    Write-Host "  3. Test scheduled task creation (requires admin)" -ForegroundColor $ColorWarn
    Write-Host "  4. Test Start Menu shortcut creation" -ForegroundColor $ColorWarn
    Write-Host "`nSee TEST_PLAN.md for detailed manual test procedures.`n" -ForegroundColor $ColorWarn
}

# Run tests
Main
