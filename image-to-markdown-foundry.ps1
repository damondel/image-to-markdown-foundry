# Azure AI Foundry Image to Markdown Converter
# Streamlined Image to Markdown Converter optimized for Azure AI Foundry
# documentId: script-image-to-markdown-foundry-content-processing
# This script is optimized for Azure AI Foundry usage with simplified environment handling

param(
    [Parameter(Mandatory=$true, HelpMessage="Path to folder containing images to process")]
    [string]$ImageFolderPath,
    
    [Parameter(Mandatory=$false, HelpMessage="Output directory for markdown files")]
    [string]$OutputFolderPath,
    
    [Parameter(Mandatory=$false, HelpMessage="Azure AI Foundry deployment name (defaults to gpt-4o)")]
    [string]$DeploymentName = "gpt-4o",
    
    [Parameter(Mandatory=$false, HelpMessage="Maximum tokens for vision analysis")]
    [int]$MaxTokens = 4000,
    
    [Parameter(Mandatory=$false, HelpMessage="Custom system prompt for OCR")]
    [string]$SystemPrompt = "You are an assistant that extracts text from images accurately. Return ONLY the text content you see in the image without any additional commentary or descriptions. Preserve formatting such as headings, bullets, and paragraphs where possible.",
    
    [Parameter(Mandatory=$false, HelpMessage="Include YAML front matter in output")]
    [switch]$IncludeYamlFrontMatter,
    
    [Parameter(Mandatory=$false, HelpMessage="Process subdirectories recursively")]
    [switch]$Recursive
)

# Auto-load environment variables from standard locations
function Initialize-Environment {
    $envPaths = @(
        (Join-Path $PSScriptRoot "..\..\config\ai-foundry.env"),
        (Join-Path $PSScriptRoot "ai-foundry.env"),
        (Join-Path $PSScriptRoot "..\ai-foundry.env")
    )
    
    foreach ($envPath in $envPaths) {
        if (Test-Path $envPath) {
            Write-Host "Loading environment from: $envPath" -ForegroundColor Green
            Get-Content $envPath | ForEach-Object {
                if (-not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#")) {
                    $key, $value = $_ -split '=', 2
                    $value = $value.Trim('"')
                    if (-not [string]::IsNullOrWhiteSpace($key)) {
                        [Environment]::SetEnvironmentVariable($key, $value, [EnvironmentVariableTarget]::Process)
                    }
                }
            }
            return $true
        }
    }
    return $false
}

# Environment validation function
function Test-AzureEnvironment {
    param(
        [string]$endpoint,
        [string]$key
    )
    
    if (-not $endpoint -or -not $key) {
        Write-Host "`nEnvironment Configuration Help:" -ForegroundColor Yellow
        Write-Host "================================" -ForegroundColor Yellow
        Write-Host "This script requires Azure AI Foundry or Azure OpenAI credentials."
        Write-Host "Please create an 'ai-foundry.env' file with your credentials:"
        Write-Host ""
        Write-Host "AZURE_AI_FOUNDRY_ENDPOINT=https://your-project.openai.azure.com"
        Write-Host "AZURE_AI_FOUNDRY_KEY=your-api-key"
        Write-Host ""
        Write-Host "OR for Azure OpenAI:"
        Write-Host "AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com"
        Write-Host "AZURE_OPENAI_API_KEY=your-api-key"
        Write-Host ""
        Write-Host "See SETUP.md for detailed configuration instructions."
        return $false
    }
    return $true
}

# Function to test Azure connectivity
function Test-AzureConnectivity {
    param([string]$endpoint)
    
    try {
        $uri = [System.Uri]$endpoint
        $testResult = Test-NetConnection -ComputerName $uri.Host -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue
        return $testResult
    } catch {
        return $false
    }
}

# Function to extract text using Azure AI Foundry Vision
function Get-TextFromImage-Foundry {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ImagePath,
        [Parameter(Mandatory=$true)]
        [string]$DeploymentName,
        [Parameter(Mandatory=$false)]
        [string]$SystemPrompt,
        [Parameter(Mandatory=$false)]
        [int]$MaxTokens = 4000
    )
      # Get environment variables with fallbacks
    $endpoint = if ($env:AZURE_AI_FOUNDRY_ENDPOINT) { $env:AZURE_AI_FOUNDRY_ENDPOINT } else { $env:AZURE_OPENAI_ENDPOINT }
    $key = if ($env:AZURE_AI_FOUNDRY_KEY) { $env:AZURE_AI_FOUNDRY_KEY } else { $env:AZURE_OPENAI_API_KEY }
    $apiVersion = if ($env:AZURE_OPENAI_API_VERSION) { $env:AZURE_OPENAI_API_VERSION } else { "2025-01-01-preview" }
    
    if (-not $endpoint -or -not $key) {
        throw "Azure AI Foundry credentials not found. Please ensure ai-foundry.env is properly configured."
    }
    
    # Prepare request
    $headers = @{
        'api-key' = $key
        'Content-Type' = 'application/json'
    }
    
    # Convert image to base64
    try {
        $imageBytes = [System.IO.File]::ReadAllBytes($ImagePath)
        $base64Image = [System.Convert]::ToBase64String($imageBytes)
    }
    catch {
        throw "Failed to read image file: $ImagePath. Error: $_"
    }
    
    # Build request body
    $requestBody = @{
        messages = @(
            @{
                role = "system"
                content = $SystemPrompt
            },
            @{
                role = "user"
                content = @(
                    @{
                        type = "text"
                        text = "Extract all text from this image, preserving its formatting and structure."
                    },
                    @{
                        type = "image_url"
                        image_url = @{
                            url = "data:image/jpeg;base64,$base64Image"
                        }
                    }
                )
            }
        )
        max_tokens = $MaxTokens
        temperature = 0.1  # Low temperature for consistent OCR results
    }
      $jsonBody = $requestBody | ConvertTo-Json -Depth 10
    $uri = "$endpoint/openai/deployments/$DeploymentName/chat/completions?api-version=$apiVersion"
    
    try {
        Write-Host "  -> Calling Azure AI Foundry ($DeploymentName)..." -ForegroundColor Cyan
        
        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $jsonBody
        
        $extractedText = $response.choices[0].message.content
        $usage = $response.usage
        
        Write-Host "  SUCCESS: Text extracted successfully (Tokens: $($usage.total_tokens))" -ForegroundColor Green
        return $extractedText
    }
    catch {
        $errorDetails = if ($_.Exception.Response) {
            "Status: $($_.Exception.Response.StatusCode), $($_.Exception.Message)"
        } else {
            $_.Exception.Message
        }
        throw "Azure AI Foundry API error: $errorDetails"
    }
}

# Function to generate enhanced markdown with optional YAML front matter
function Convert-ToEnhancedMarkdown {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Text,
        [Parameter(Mandatory=$true)]
        [string]$ImageFileName,
        [Parameter(Mandatory=$false)]
        [bool]$IncludeYaml = $false
    )
    
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($ImageFileName)
    $title = $baseName -replace "_", " " -replace "-", " "
    $title = (Get-Culture).TextInfo.ToTitleCase($title.ToLower())
    
    $markdown = ""
    
    # Add YAML front matter if requested
    if ($IncludeYaml) {
        $currentDate = Get-Date -Format "yyyy-MM-dd"
        $markdown += "---`n"
        $markdown += "title: `"$title`"`n"
        $markdown += "date: `"$currentDate`"`n"
        $markdown += "type: `"image_extraction`"`n"
        $markdown += "source_image: `"$ImageFileName`"`n"
        $markdown += "extraction_method: `"azure_ai_foundry`"`n"
        $markdown += "---`n`n"
    }
    
    $markdown += "# $title`n`n"
    $markdown += "> Extracted from image: `$ImageFileName``n`n"
    $markdown += $Text
    
    return $markdown
}

# Main execution
Write-Host "=== Azure AI Foundry Image-to-Markdown Converter ===" -ForegroundColor Cyan
Write-Host "Optimized workflow for Azure AI Foundry vision models`n" -ForegroundColor Cyan

# Initialize environment
if (-not (Initialize-Environment)) {
    Write-Warning "No environment file found. Please ensure ai-foundry.env is configured."
}

# Validate input directory
if (-not (Test-Path $ImageFolderPath)) {
    Write-Error "Image folder not found: $ImageFolderPath"
    exit 1
}

# Set output directory
if (-not $OutputFolderPath) {
    $OutputFolderPath = Join-Path $ImageFolderPath "markdown-output"
}

# Create output directory
if (-not (Test-Path $OutputFolderPath)) {
    New-Item -ItemType Directory -Path $OutputFolderPath -Force | Out-Null
    Write-Host "Created output directory: $OutputFolderPath" -ForegroundColor Green
}

# Find image files
if ($Recursive) {
    $imageFiles = Get-ChildItem -Path $ImageFolderPath -Recurse -File | Where-Object { $_.Extension -match '\.(png|jpg|jpeg|bmp|gif|webp)$' }
} else {
    $imageFiles = Get-ChildItem -Path $ImageFolderPath -File | Where-Object { $_.Extension -match '\.(png|jpg|jpeg|bmp|gif|webp)$' }
}

if ($imageFiles.Count -eq 0) {
    Write-Warning "No image files found in: $ImageFolderPath"
    exit 0
}

Write-Host "Found $($imageFiles.Count) image file(s) to process`n" -ForegroundColor White

# Process each image
$successCount = 0
$errorCount = 0
$totalTokens = 0
$startTime = Get-Date

foreach ($imageFile in $imageFiles) {
    Write-Host "Processing: $($imageFile.Name)" -ForegroundColor Yellow
    
    try {
        # Extract text using Azure AI Foundry
        $extractedText = Get-TextFromImage-Foundry -ImagePath $imageFile.FullName -DeploymentName $DeploymentName -SystemPrompt $SystemPrompt -MaxTokens $MaxTokens
          if ([string]::IsNullOrWhiteSpace($extractedText)) {
            Write-Warning "  WARNING: No text extracted from $($imageFile.Name)"
            continue
        }
        
        # Generate markdown
        $markdown = Convert-ToEnhancedMarkdown -Text $extractedText -ImageFileName $imageFile.Name -IncludeYaml $IncludeYamlFrontMatter
        
        # Save markdown file
        $markdownFileName = [System.IO.Path]::GetFileNameWithoutExtension($imageFile.Name) + ".md"
        $markdownFilePath = Join-Path $OutputFolderPath $markdownFileName
        
        Set-Content -Path $markdownFilePath -Value $markdown -Encoding UTF8
        
        Write-Host "  SUCCESS: Created $markdownFileName" -ForegroundColor Green
        $successCount++
        
    }
    catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
        $errorCount++
    }
    
    Write-Host ""
}

# Summary
$endTime = Get-Date
$duration = New-TimeSpan -Start $startTime -End $endTime

Write-Host "=== Processing Complete ===" -ForegroundColor Cyan
Write-Host "Processed: $($imageFiles.Count) files" -ForegroundColor White
Write-Host "Successful: $successCount" -ForegroundColor Green
Write-Host "Errors: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })
Write-Host "Duration: $($duration.TotalSeconds.ToString('F1')) seconds" -ForegroundColor White
Write-Host "Output: $OutputFolderPath" -ForegroundColor White
Write-Host "=========================" -ForegroundColor Cyan
