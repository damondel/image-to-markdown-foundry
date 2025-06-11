# Demo Script with Temporary Credentials
# This script sets credentials temporarily without saving them to files

# Set your real credentials here (this file is gitignored)
$env:AZURE_AI_FOUNDRY_ENDPOINT = "https://your-real-endpoint.openai.azure.com"
$env:AZURE_AI_FOUNDRY_KEY = "your-real-api-key"

Write-Host "=== Demo with Live Credentials ===" -ForegroundColor Green
Write-Host "Credentials set temporarily for this session only" -ForegroundColor Yellow

# Run the demo steps
Write-Host "`n1. Setup Validation..." -ForegroundColor Cyan
.\test-setup.ps1

Write-Host "`n2. Single Image Processing..." -ForegroundColor Cyan
.\image-to-markdown-foundry.ps1 -ImageFolderPath "demo-files\sample-images" -OutputFolderPath "demo-files\output"

Write-Host "`n3. Batch Processing..." -ForegroundColor Cyan
.\batch-image-to-markdown-foundry.ps1 -RootDirectory "demo-files\sample-images" -OutputBaseDirectory "demo-files\batch-output"

Write-Host "`nDemo complete! Credentials were not saved to any files." -ForegroundColor Green
