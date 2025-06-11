# Image to Markdown Foundry - Demo Walkthrough Script

## Demo Overview
This demonstration shows how to convert images to markdown descriptions using Azure AI Vision services.

## Demo Files Prepared
- `architecture-diagram.png` - System architecture diagram (658KB)
- `workflow-diagram.png` - Process flow diagram (169KB)  
- `interface-screenshot.png` - UI screenshot (635KB)

## Prerequisites for Demo
- Azure AI Foundry or Azure OpenAI endpoint configured
- API key and deployment name set in environment variables
- Internet connectivity for Azure AI calls

## Walkthrough Steps

### 1. Setup Validation (2 minutes)
```powershell
# Show the setup validation script
.\test-setup.ps1
```
**What to highlight:**
- PowerShell compatibility check
- Script file validation
- Azure configuration verification
- Connectivity testing

### 2. Single Image Processing Demo (4 minutes)
```powershell
# Process images to demonstrate core functionality
.\image-to-markdown-foundry.ps1 -ImageFolderPath "demo-files\sample-images" -OutputFolderPath "demo-files\output"
```
**What to highlight:**
- Image detection and validation
- Azure AI Vision API call
- Intelligent description generation
- Clean markdown output with image references

### 3. Batch Processing Demo (4 minutes)
```powershell
# Process all sample images at once
.\batch-image-to-markdown-foundry.ps1 -RootDirectory "demo-files\sample-images" -OutputBaseDirectory "demo-files\batch-output"
```
**What to highlight:**
- Multiple image processing
- Automatic file organization
- Progress tracking and error handling
- Consistent output formatting

### 4. Output Review (3 minutes)
**Show the generated files:**
- Open markdown files to show AI-generated descriptions
- Highlight how different image types are analyzed
- Point out structured markdown formatting
- Demonstrate practical use cases

## Key Features to Emphasize
1. **AI-Powered Analysis** - Uses Azure AI for intelligent image understanding
2. **Flexible Processing** - Single files or batch operations
3. **Professional Output** - Clean, structured markdown format
4. **Error Handling** - Robust processing with clear feedback
5. **Configurable** - Works with Azure AI Foundry or Azure OpenAI

## Sample Talking Points
- "This tool leverages Azure AI to automatically generate detailed descriptions of images"
- "Perfect for documentation, accessibility, content management, or image cataloging"
- "The AI understands context and provides meaningful descriptions, not just object detection"
- "Batch processing makes it easy to handle large image collections"

## Demo Scenarios to Highlight
- **Architecture Documentation** - Convert diagrams to searchable text
- **UI Documentation** - Describe interface screenshots for accessibility
- **Process Documentation** - Extract workflow steps from flowcharts
- **Content Management** - Auto-generate alt text and descriptions

## Demo Tips
- Show the original image alongside the generated markdown
- Emphasize the quality and detail of AI-generated descriptions
- Mention cost considerations and API usage
- Point out the environment setup guide for new users

## Fallback for API Issues
If Azure AI calls fail during demo:
- Show the setup validation results
- Demonstrate the file detection and organization
- Use pre-generated output examples from previous runs
- Explain the process flow and benefits

Total Demo Time: ~13 minutes

## Post-Demo Resources
- GitHub repository with setup instructions
- SETUP.md guide for Azure configuration
- Example environment files
- Documentation on supported image formats
