# Batch Azure AI Foundry Image to Markdown Processor
# Batch processor for Azure AI Foundry image-to-markdown conversion
# documentId: script-batch-image-to-markdown-foundry-content-processing

param(
    [Parameter(Mandatory=$false, HelpMessage="Root directory to search for images")]
    [string]$RootDirectory,
    
    [Parameter(Mandatory=$false, HelpMessage="Output base directory")]
    [string]$OutputBaseDirectory,
    
    [Parameter(Mandatory=$false, HelpMessage="Include YAML front matter in all outputs")]
    [switch]$IncludeYamlFrontMatter,
    
    [Parameter(Mandatory=$false, HelpMessage="Azure AI Foundry deployment name")]
    [string]$DeploymentName = "gpt-4o"
)

# Set defaults
if (-not $RootDirectory) {
    $scriptRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $RootDirectory = Join-Path $scriptRoot "data\screenshots"
}

if (-not $OutputBaseDirectory) {
    $scriptRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $OutputBaseDirectory = Join-Path $scriptRoot "data\markdown-output"
}

Write-Host "=== Batch Azure AI Foundry Image Processing ===" -ForegroundColor Cyan
Write-Host "Root Directory: $RootDirectory"
Write-Host "Output Directory: $OutputBaseDirectory"
Write-Host "Deployment: $DeploymentName"
Write-Host "YAML Front Matter: $IncludeYamlFrontMatter"
Write-Host "============================================`n" -ForegroundColor Cyan

# Find all directories with images
$imageDirectories = Get-ChildItem -Path $RootDirectory -Directory -Recurse | Where-Object {
    $imageFiles = Get-ChildItem -Path $_.FullName -File | Where-Object { $_.Extension -match '\.(png|jpg|jpeg|bmp|gif|webp)$' }
    $imageFiles.Count -gt 0
}

# Also check the root directory
$rootImages = Get-ChildItem -Path $RootDirectory -File | Where-Object { $_.Extension -match '\.(png|jpg|jpeg|bmp|gif|webp)$' }

if ($rootImages.Count -gt 0) {
    $imageDirectories = @($([PSCustomObject]@{ FullName = $RootDirectory; Name = "Root" })) + $imageDirectories
}

if ($imageDirectories.Count -eq 0) {
    Write-Warning "No directories with images found in: $RootDirectory"
    exit 0
}

Write-Host "Found $($imageDirectories.Count) director(ies) with images:`n"

$converterScript = Join-Path $PSScriptRoot "image-to-markdown-foundry.ps1"
$totalProcessed = 0
$totalErrors = 0

foreach ($directory in $imageDirectories) {
    $relativePath = $directory.FullName.Substring($RootDirectory.Length).TrimStart('\', '/')
    $outputDir = if ($relativePath) { 
        Join-Path $OutputBaseDirectory $relativePath 
    } else { 
        $OutputBaseDirectory 
    }
    
    Write-Host "Processing: $($directory.FullName)" -ForegroundColor Yellow
    
    try {
        # Build parameters
        $params = @{
            ImageFolderPath = $directory.FullName
            OutputFolderPath = $outputDir
            DeploymentName = $DeploymentName
        }
        
        if ($IncludeYamlFrontMatter) {
            $params.IncludeYamlFrontMatter = $true
        }        # Run the converter and capture all output
        $result = ""
        try {
            $result = & $converterScript @params *>&1 | Out-String
        } catch {
            $result = $_.Exception.Message
        }
        
        # Check for success based on output content
        $hasProcessingComplete = $result -like "*Processing Complete*"
        $hasSuccessful = $result -like "*Successful:*"
        $hasNoErrors = $result -like "*Errors: 0*"
        
        if ($hasProcessingComplete -and $hasSuccessful -and $hasNoErrors) {
            Write-Host "  SUCCESS: Successfully processed" -ForegroundColor Green
            $totalProcessed++
        } else {
            Write-Host "  FAILED: Processing failed" -ForegroundColor Red
            $totalErrors++
        }
        
    } catch {
        Write-Host "  ERROR: Exception: $($_.Exception.Message)" -ForegroundColor Red
        $totalErrors++
    }
    
    Write-Host ""
}

# Final summary
Write-Host "=== Batch Processing Summary ===" -ForegroundColor Cyan
Write-Host "Directories processed: $totalProcessed" -ForegroundColor Green
Write-Host "Directories with errors: $totalErrors" -ForegroundColor $(if ($totalErrors -gt 0) { "Red" } else { "Green" })
Write-Host "Output location: $OutputBaseDirectory" -ForegroundColor White
Write-Host "===============================" -ForegroundColor Cyan
