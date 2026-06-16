# Setup New Course Script
# Automates folder structure and lab creation for new courses
# Usage: .\_scripts\SETUP-NEW-COURSE.ps1 -CourseCode "az-900" -CourseName "Azure Fundamentals"

param(
    [Parameter(Mandatory=$true)]
    [string]$CourseCode,

    [Parameter(Mandatory=$true)]
    [string]$CourseName,

    [string]$ModuleName = "Module 01",

    [int]$InitialLabCount = 3,

    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Setting up new course: $CourseCode - $CourseName" -ForegroundColor Green
Write-Host ""

# Validate course code format
if ($CourseCode -notmatch '^[a-z]{2}-\d{3}$') {
    Write-Host "❌ Invalid course code format. Expected: xx-### (e.g., az-900)" -ForegroundColor Red
    exit 1
}

# Define course structure
$coursePath = "courses\$CourseCode"
$moduleNum = "00"
$moduleName = "01-$($ModuleName -replace '\s+', '-' | ToLower())"

# Create directory structure
Write-Host "📁 Creating folder structure..." -ForegroundColor Cyan
$folders = @(
    "$coursePath\$moduleName\concepts",
    "$coursePath\$moduleName\labs",
    "$coursePath\$moduleName\documents"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "  ✓ Created: $folder"
    } else {
        Write-Host "  ✓ Exists: $folder"
    }
}

# Create course README
Write-Host ""
Write-Host "📝 Creating course README..." -ForegroundColor Cyan
$readmePath = "$coursePath\README.md"
$readmeContent = @"
# $CourseName ($CourseCode)

**Level:** Beginner | **Duration:** ~[X] hours | **Labs:** [X]

## Overview

[Brief course description]

## What You'll Learn

- Learning objective 1
- Learning objective 2
- Learning objective 3

## Prerequisites

- [Prerequisite 1]
- [Prerequisite 2]

## Course Structure

### Module 01: $ModuleName

**Concepts:**
- [Concept 1](01-$($ModuleName -replace '\s+', '-' | ToLower())/concepts/01-*.md)
- [Concept 2](01-$($ModuleName -replace '\s+', '-' | ToLower())/concepts/02-*.md)

**Labs:**
- [Lab 01](01-$($ModuleName -replace '\s+', '-' | ToLower())/documents/lab01-*.html)
- [Lab 02](01-$($ModuleName -replace '\s+', '-' | ToLower())/documents/lab02-*.html)

## Getting Started

1. Read the concepts in order
2. Complete each lab hands-on
3. Verify success criteria before moving forward

## Resources

- [Official Documentation](https://docs.microsoft.com)
- [Learning Path](https://learn.microsoft.com)

## Support

For issues or questions, open an issue on GitHub.

---

**Last Updated:** $(Get-Date -Format 'yyyy-MM-dd')
"@

$readmeContent | Out-File -FilePath $readmePath -Encoding UTF8
Write-Host "  ✓ Created: $readmePath"

# Create initial lab files from template
Write-Host ""
Write-Host "📚 Creating initial lab templates..." -ForegroundColor Cyan

$templatePath = "_templates\COURSE-LAB-TEMPLATE.md"
if (-not (Test-Path $templatePath)) {
    Write-Host "  ⚠ Template not found: $templatePath" -ForegroundColor Yellow
} else {
    $templateContent = Get-Content $templatePath -Raw

    for ($i = 1; $i -le $InitialLabCount; $i++) {
        $labNum = $i.ToString("00")
        $labPath = "$coursePath\$moduleName\labs\lab$labNum-your-topic.md"

        # Customize template for this lab
        $customContent = $templateContent `
            -replace '\[##\]', $labNum `
            -replace '\[Lab Title\]', "Lab Title" `
            -replace '\[Company Name\]', "Your Company"

        $customContent | Out-File -FilePath $labPath -Encoding UTF8
        Write-Host "  ✓ Created: $labPath"
    }
}

# Generate HTML from markdown
Write-Host ""
Write-Host "🔄 Generating HTML from markdown..." -ForegroundColor Cyan

$generationScript = "_scripts\GENERATE-LABS-HTML.ps1"
if (Test-Path $generationScript) {
    & $generationScript -CourseFolder "courses\$CourseCode"
    Write-Host "  ✓ Generated HTML files"
} else {
    Write-Host "  ⚠ Generation script not found: $generationScript" -ForegroundColor Yellow
}

# Create git commit
Write-Host ""
Write-Host "✨ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Course structure:" -ForegroundColor Cyan
Write-Host "   Path: $coursePath"
Write-Host "   Modules: 1"
Write-Host "   Initial Labs: $InitialLabCount"
Write-Host ""
Write-Host "🎯 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Edit the markdown files in: $coursePath\$moduleName\labs\"
Write-Host "   2. Add your course description: $readmePath"
Write-Host "   3. Regenerate HTML: .\_scripts\GENERATE-LABS-HTML.ps1 -CourseFolder 'courses\$CourseCode'"
Write-Host "   4. Test locally by opening HTML files in browser"
Write-Host "   5. Commit and push: git add -A && git commit -m 'Add $CourseCode course' && git push"
Write-Host ""
Write-Host "📖 For detailed instructions, see: COURSE-CREATION-GUIDE.md" -ForegroundColor Cyan
