# Image-to-Markdown Foundry

A streamlined PowerShell toolkit for converting images to markdown using Azure AI Foundry's vision models. This tool performs OCR (Optical Character Recognition) on images and generates properly formatted markdown files with optional YAML front matter.

## 🚀 Features

- **Azure AI Foundry Integration**: Leverages Azure AI Foundry's GPT-4o vision models for accurate text extraction
- **Batch Processing**: Process entire directories of images automatically
- **Flexible Output**: Optional YAML front matter for static site generators
- **Multiple Image Formats**: Supports PNG, JPG, JPEG, BMP, GIF, and WebP
- **Recursive Processing**: Handle nested directory structures
- **Environment Auto-Detection**: Automatically loads configuration from multiple locations
- **Error Handling**: Robust error handling with detailed logging

## 📋 Prerequisites

- PowerShell 5.1 or later
- Azure AI Foundry or Azure OpenAI service with vision-enabled model deployment
- Valid Azure credentials

## 🔧 Setup

### 1. Configure Environment Variables

Create an `ai-foundry.env` file in one of these locations:
- `./ai-foundry.env` (same directory as scripts)
- `../ai-foundry.env` (parent directory)
- `../../config/ai-foundry.env` (config directory)

```bash
# Required: Azure AI Foundry/OpenAI Configuration
AZURE_AI_FOUNDRY_ENDPOINT=https://your-foundry-endpoint.openai.azure.com
AZURE_AI_FOUNDRY_KEY=your-api-key

# Alternative: Azure OpenAI Configuration (fallback)
AZURE_OPENAI_ENDPOINT=https://your-openai-endpoint.openai.azure.com
AZURE_OPENAI_API_KEY=your-api-key

# Optional: API Version (defaults to 2025-01-01-preview)
AZURE_OPENAI_API_VERSION=2025-01-01-preview
```

### 2. Verify Model Deployment

Ensure you have a vision-capable model deployed in Azure AI Foundry:
- GPT-4o (recommended, default)
- GPT-4 Vision
- GPT-4 Turbo with Vision

## 🚀 Getting Started

1. **Clone Repository**: Download the PowerShell scripts to your local machine
2. **Configure Environment**: Set up your Azure AI Foundry credentials
3. **Verify Model Access**: Ensure you have a vision-capable model deployed
4. **Prepare Images**: Organize your image files in dedicated directories
5. **Choose Processing Mode**: Single directory or batch processing
6. **Execute Scripts**: Run conversion with your desired parameters

## 📖 Usage

### Single Directory Processing

```powershell
# Basic usage - process images in a folder
.\image-to-markdown-foundry.ps1 -ImageFolderPath "C:\path\to\images"

# Custom output directory
.\image-to-markdown-foundry.ps1 -ImageFolderPath "C:\path\to\images" -OutputFolderPath "C:\output\folder"

# Include YAML front matter
.\image-to-markdown-foundry.ps1 -ImageFolderPath "C:\path\to\images" -IncludeYamlFrontMatter

# Process subdirectories recursively
.\image-to-markdown-foundry.ps1 -ImageFolderPath "C:\path\to\images" -Recursive

# Use specific deployment and custom prompt
.\image-to-markdown-foundry.ps1 -ImageFolderPath "C:\path\to\images" -DeploymentName "gpt-4-vision" -SystemPrompt "Extract text with emphasis on preserving table structures"
```

### Batch Processing Multiple Directories

```powershell
# Process all image directories under a root path
.\batch-image-to-markdown-foundry.ps1 -RootDirectory "C:\screenshots" -OutputBaseDirectory "C:\markdown-output"

# Include YAML front matter for all processed files
.\batch-image-to-markdown-foundry.ps1 -RootDirectory "C:\screenshots" -IncludeYamlFrontMatter
```

## 🛠️ Parameters

### image-to-markdown-foundry.ps1

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `ImageFolderPath` | String | Yes | - | Path to folder containing images |
| `OutputFolderPath` | String | No | `{ImageFolderPath}\markdown-output` | Output directory for markdown files |
| `DeploymentName` | String | No | `gpt-4o` | Azure AI model deployment name |
| `MaxTokens` | Int | No | `4000` | Maximum tokens for vision analysis |
| `SystemPrompt` | String | No | Default OCR prompt | Custom system prompt for text extraction |
| `IncludeYamlFrontMatter` | Switch | No | `false` | Include YAML front matter in output |
| `Recursive` | Switch | No | `false` | Process subdirectories recursively |

### batch-image-to-markdown-foundry.ps1

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `RootDirectory` | String | No | `../../data/screenshots` | Root directory to search for images |
| `OutputBaseDirectory` | String | No | `../../data/markdown-output` | Output base directory |
| `IncludeYamlFrontMatter` | Switch | No | `false` | Include YAML front matter in all outputs |
| `DeploymentName` | String | No | `gpt-4o` | Azure AI model deployment name |

## 📁 Output Format

### Standard Markdown Output

```markdown
# Image Title

> Extracted from image: screenshot.png

[Extracted text content here]
```

### With YAML Front Matter

```markdown
---
title: "Image Title"
date: "2025-06-05"
type: "image_extraction"
source_image: "screenshot.png"
extraction_method: "azure_ai_foundry"
---

# Image Title

> Extracted from image: screenshot.png

[Extracted text content here]
```

## 🔍 Supported Image Formats

- PNG (.png)
- JPEG (.jpg, .jpeg)
- Bitmap (.bmp)
- GIF (.gif)
- WebP (.webp)

## 🚨 Error Handling

The scripts include comprehensive error handling for:
- Missing environment configuration
- Invalid image paths
- Azure API errors
- File system permissions
- Network connectivity issues

## 📊 Performance Considerations

- **Token Usage**: Each image consumes tokens based on size and complexity
- **Rate Limits**: Azure AI services have rate limits; large batches may need throttling
- **Image Size**: Larger images may require higher `MaxTokens` values
- **Cost**: Monitor usage in Azure portal to track costs

## 🔧 Troubleshooting

### Common Issues

1. **"Azure AI Foundry credentials not found"**
   - Verify `ai-foundry.env` file exists and is properly formatted
   - Check environment variable names match exactly

2. **"No text extracted from image"**
   - Verify image contains readable text
   - Try increasing `MaxTokens` parameter
   - Check image quality and resolution

3. **API Rate Limit Errors**
   - Reduce batch size
   - Add delays between API calls
   - Verify your Azure service tier and limits

4. **PowerShell Execution Policy**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

## 📝 Best Practices

1. **Image Quality**: Use high-resolution, clear images for best OCR results
2. **Batch Size**: Process images in smaller batches to avoid rate limits
3. **Cost Management**: Monitor token usage and set up Azure budgets
4. **Security**: Store API keys securely and never commit them to version control
5. **Backup**: Keep original images as backup before processing

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 Related Projects

- [VTT to Markdown Converter](https://github.com/damondel/vtt-to-markdown-converter) - Convert VTT transcript files to markdown