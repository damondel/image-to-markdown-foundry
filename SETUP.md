# Image-to-Markdown Foundry - Setup Guide for New Users

## Quick Start Guide

### 1. Download the Scripts
Copy these files to your preferred directory:
- `image-to-markdown-foundry.ps1` - Single image processor
- `batch-image-to-markdown-foundry.ps1` - Batch processor

### 2. Azure AI Setup (Required)

#### Option A: Azure AI Foundry (Recommended)
1. Go to [Azure AI Foundry](https://ai.azure.com/)
2. Create a new project or use existing one
3. Deploy a vision-capable model (GPT-4o recommended)
4. Note your endpoint URL and API key

#### Option B: Azure OpenAI (Alternative)
1. Go to [Azure Portal](https://portal.azure.com)
2. Create an Azure OpenAI resource
3. Deploy GPT-4o or GPT-4 Vision model
4. Get endpoint URL and API key from Keys and Endpoint section

### 3. Create Environment File

Create `ai-foundry.env` file in the same folder as the scripts:

```bash
# For Azure AI Foundry
AZURE_AI_FOUNDRY_ENDPOINT=https://your-project.openai.azure.com
AZURE_AI_FOUNDRY_KEY=your-api-key-here

# OR for Azure OpenAI
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com
AZURE_OPENAI_API_KEY=your-api-key-here

# Optional: Specify API version
AZURE_OPENAI_API_VERSION=2025-01-01-preview
```

### 4. Test Your Setup
```powershell
# Test single image conversion
.\image-to-markdown-foundry.ps1 -ImageFolderPath "path\to\images"

# Test batch processing
.\batch-image-to-markdown-foundry.ps1 -RootDirectory "path\to\image\folders"
```

## Example Usage

### Single Image Processing
```powershell
# Basic conversion
.\image-to-markdown-foundry.ps1 -ImageFolderPath "C:\Screenshots"

# Custom output with YAML front matter
.\image-to-markdown-foundry.ps1 -ImageFolderPath "C:\Screenshots" -OutputFolderPath "C:\Markdown" -IncludeYamlFrontMatter

# Recursive processing
.\image-to-markdown-foundry.ps1 -ImageFolderPath "C:\Projects" -Recursive
```

### Batch Processing
```powershell
# Process all image directories under a root folder
.\batch-image-to-markdown-foundry.ps1 -RootDirectory "C:\Documents"

# Include YAML front matter in all outputs
.\batch-image-to-markdown-foundry.ps1 -RootDirectory "C:\Projects" -IncludeYamlFrontMatter
```

## Supported Image Formats
- PNG
- JPG/JPEG
- BMP
- GIF
- WebP

## Troubleshooting

### Authentication Errors
1. Verify your endpoint URL is correct
2. Check that your API key is valid and not expired
3. Ensure your model deployment name matches (default: "gpt-4o")
4. Test connectivity: `Test-NetConnection your-endpoint.azure.com -Port 443`

### No Images Found
- Check file extensions are supported
- Use `-Recursive` flag for subdirectories
- Verify read permissions on image directories

### Output Issues
- Verify write permissions to output directory
- Check disk space availability
- Ensure output path doesn't exceed Windows path limits (260 chars)

### Model Deployment Issues
```powershell
# Test with specific deployment name
.\image-to-markdown-foundry.ps1 -ImageFolderPath "C:\Images" -DeploymentName "your-model-name"
```

## Cost Optimization Tips

1. **Token Usage**: Each image consumes tokens based on size and complexity
2. **Batch Processing**: More efficient than individual calls
3. **Image Size**: Larger images use more tokens - consider resizing if needed
4. **Custom Prompts**: Adjust `-SystemPrompt` for specific use cases

## Security Best Practices

1. **Environment Files**: Never commit `.env` files to version control
2. **API Keys**: Rotate keys regularly
3. **Network**: Use private endpoints in production environments
4. **Access**: Follow principle of least privilege for Azure resources

## Cross-Platform Support

Works on:
- Windows PowerShell 5.1+
- PowerShell Core 6+ (Windows, Linux, macOS)
- Azure Cloud Shell

## Getting Help

If you encounter issues:
1. Check the error messages in the console output
2. Verify your Azure setup in the Azure portal
3. Test with a single small image first
4. Review the generated markdown files for quality

## Example Environment File Template

Create `ai-foundry.env`:
```bash
# Replace these values with your actual Azure credentials
AZURE_AI_FOUNDRY_ENDPOINT=https://your-project-name.openai.azure.com
AZURE_AI_FOUNDRY_KEY=1234567890abcdef1234567890abcdef
AZURE_OPENAI_API_VERSION=2025-01-01-preview
```
