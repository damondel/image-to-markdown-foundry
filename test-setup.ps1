# Test Image-to-Markdown Setup
# This script helps validate that your Azure AI environment is ready for image processing

Write-Host "=== Image-to-Markdown Foundry - Setup Validation ===" -ForegroundColor Cyan
Write-Host ""

# Test PowerShell version
Write-Host "Checking PowerShell version..." -ForegroundColor Yellow
$version = $PSVersionTable.PSVersion
Write-Host "PowerShell Version: $version"

if ($version.Major -ge 5) {
    Write-Host "✓ PowerShell version is compatible" -ForegroundColor Green
} else {
    Write-Host "✗ PowerShell version too old. Requires 5.1 or later." -ForegroundColor Red
    exit 1
}

# Test execution policy
Write-Host "`nChecking execution policy..." -ForegroundColor Yellow
$policy = Get-ExecutionPolicy
Write-Host "Current policy: $policy"

if ($policy -eq "Restricted") {
    Write-Host "✗ Execution policy is too restrictive" -ForegroundColor Red
    Write-Host "Run this command as Administrator to fix:" -ForegroundColor Yellow
    Write-Host "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
} else {
    Write-Host "✓ Execution policy allows script execution" -ForegroundColor Green
}

# Test script files
Write-Host "`nChecking for script files..." -ForegroundColor Yellow
$scriptPath = Split-Path -Parent $PSCommandPath

$requiredFiles = @(
    "image-to-markdown-foundry.ps1",
    "batch-image-to-markdown-foundry.ps1"
)

$allFilesFound = $true
foreach ($file in $requiredFiles) {
    $filePath = Join-Path $scriptPath $file
    if (Test-Path $filePath) {
        Write-Host "✓ Found: $file" -ForegroundColor Green
    } else {
        Write-Host "✗ Missing: $file" -ForegroundColor Red
        $allFilesFound = $false
    }
}

if (-not $allFilesFound) {
    Write-Host "`nPlease ensure all required scripts are in the same directory." -ForegroundColor Yellow
    exit 1
}

# Test environment file
Write-Host "`nChecking for environment configuration..." -ForegroundColor Yellow

$envPaths = @(
    (Join-Path $scriptPath "ai-foundry.env"),
    (Join-Path $scriptPath "..\ai-foundry.env"),
    (Join-Path $scriptPath "..\..\config\ai-foundry.env")
)

$envFound = $false
foreach ($envPath in $envPaths) {
    if (Test-Path $envPath) {
        Write-Host "✓ Found environment file: $envPath" -ForegroundColor Green
        $envFound = $true
        
        # Load and validate environment variables
        Get-Content $envPath | ForEach-Object {
            if (-not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#")) {
                $key, $value = $_ -split '=', 2
                if (-not [string]::IsNullOrWhiteSpace($key)) {
                    [Environment]::SetEnvironmentVariable($key, $value.Trim('"'), [EnvironmentVariableTarget]::Process)
                }
            }
        }
        break
    }
}

if (-not $envFound) {
    Write-Host "✗ No environment file found" -ForegroundColor Red
    Write-Host "Please create 'ai-foundry.env' with your Azure credentials." -ForegroundColor Yellow
    Write-Host "See SETUP.md for instructions." -ForegroundColor Yellow
    exit 1
}

# Test Azure configuration
Write-Host "`nValidating Azure configuration..." -ForegroundColor Yellow

$endpoint = if ($env:AZURE_AI_FOUNDRY_ENDPOINT) { $env:AZURE_AI_FOUNDRY_ENDPOINT } else { $env:AZURE_OPENAI_ENDPOINT }
$key = if ($env:AZURE_AI_FOUNDRY_KEY) { $env:AZURE_AI_FOUNDRY_KEY } else { $env:AZURE_OPENAI_API_KEY }

if (-not $endpoint) {
    Write-Host "✗ No Azure endpoint configured" -ForegroundColor Red
    Write-Host "Set AZURE_AI_FOUNDRY_ENDPOINT or AZURE_OPENAI_ENDPOINT" -ForegroundColor Yellow
} else {
    Write-Host "✓ Azure endpoint configured: $($endpoint.Substring(0, [Math]::Min(50, $endpoint.Length)))..." -ForegroundColor Green
}

if (-not $key) {
    Write-Host "✗ No Azure API key configured" -ForegroundColor Red
    Write-Host "Set AZURE_AI_FOUNDRY_KEY or AZURE_OPENAI_API_KEY" -ForegroundColor Yellow
} else {
    Write-Host "✓ Azure API key configured (length: $($key.Length) characters)" -ForegroundColor Green
}

# Test connectivity
if ($endpoint) {
    Write-Host "`nTesting connectivity..." -ForegroundColor Yellow
    try {
        $uri = [System.Uri]$endpoint
        $testResult = Test-NetConnection -ComputerName $uri.Host -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue
        if ($testResult) {
            Write-Host "✓ Successfully connected to Azure endpoint" -ForegroundColor Green
        } else {
            Write-Host "✗ Cannot connect to Azure endpoint" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ Connection test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== Setup Validation Complete ===" -ForegroundColor Cyan

if ($endpoint -and $key) {
    Write-Host "Your environment is ready for image processing!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor White
    Write-Host "1. Place your images in a directory" -ForegroundColor Gray
    Write-Host "2. Run: .\image-to-markdown-foundry.ps1 -ImageFolderPath 'your-image-directory'" -ForegroundColor Gray
    Write-Host "3. Or batch process: .\batch-image-to-markdown-foundry.ps1 -RootDirectory 'your-root-directory'" -ForegroundColor Gray
} else {
    Write-Host "Please fix the configuration issues above before proceeding." -ForegroundColor Yellow
    Write-Host "See SETUP.md for detailed instructions." -ForegroundColor Yellow
}
