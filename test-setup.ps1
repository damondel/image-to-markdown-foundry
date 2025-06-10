# Test Image to Markdown Setup
# This script helps validate that your environment is ready for image processing

Write-Host "=== Image to Markdown Foundry - Setup Validation ===" -ForegroundColor Cyan
Write-Host ""

# Test PowerShell version
Write-Host "Checking PowerShell version..." -ForegroundColor Yellow
$version = $PSVersionTable.PSVersion
Write-Host "PowerShell Version: $version"

if ($version.Major -ge 5) {
    Write-Host "[OK] PowerShell version is compatible" -ForegroundColor Green
} else {
    Write-Host "[ERROR] PowerShell version too old. Requires 5.1 or later." -ForegroundColor Red
    exit 1
}

# Test execution policy
Write-Host "
Checking execution policy..." -ForegroundColor Yellow
$policy = Get-ExecutionPolicy
Write-Host "Current policy: $policy"

if ($policy -eq "Restricted") {
    Write-Host "[ERROR] Execution policy is too restrictive" -ForegroundColor Red
    Write-Host "Run this command as Administrator to fix:" -ForegroundColor Yellow
    Write-Host "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
} else {
    Write-Host "[OK] Execution policy allows script execution" -ForegroundColor Green
}

# Test script files
Write-Host "
Checking for script files..." -ForegroundColor Yellow
$scriptPath = Split-Path -Parent $PSCommandPath

$requiredFiles = @(
    "image-to-markdown-foundry.ps1",
    "batch-image-to-markdown-foundry.ps1"
)

$allFilesFound = $true
foreach ($file in $requiredFiles) {
    $filePath = Join-Path $scriptPath $file
    if (Test-Path $filePath) {
        Write-Host "[OK] Found: $file" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Missing: $file" -ForegroundColor Red
        $allFilesFound = $false
    }
}

if (-not $allFilesFound) {
    Write-Host "
Please ensure all required scripts are in the same directory." -ForegroundColor Yellow
    exit 1
}

Write-Host "
=== Setup Validation Complete ===" -ForegroundColor Cyan
Write-Host "Basic validation completed successfully!" -ForegroundColor Green
