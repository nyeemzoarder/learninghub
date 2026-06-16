# ════════════════════════════════════════════════════════════════
# Azure AZ-104 Learning Hub — HTML to PDF Converter
# ════════════════════════════════════════════════════════════════
#
# This script converts all HTML concept documentation to PDF files
# Usage: .\CONVERT-HTML-TO-PDF.ps1
#
# Requirements:
# - Microsoft Edge browser (installed)
# - PowerShell 5.0+
#
# ════════════════════════════════════════════════════════════════

param(
    [switch]$OpenPDFs,
    [switch]$SkipExistingPDFs,
    [string]$BrowserPath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
)

# Detect script location
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "📍 Script location: $scriptPath" -ForegroundColor Gray

# Find all HTML files in documents folders
$htmlFiles = Get-ChildItem -Path "$scriptPath\*\documents\*.html" -Recurse |
             Where-Object { $_.Name -ne "README.html" }

if ($htmlFiles.Count -eq 0) {
    Write-Host "❌ No HTML files found in documents folders" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🔄 HTML to PDF Conversion" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Found $($htmlFiles.Count) HTML files to convert" -ForegroundColor Yellow
Write-Host ""

# Check if Edge is available
if (-not (Test-Path $BrowserPath)) {
    Write-Host "⚠️  Microsoft Edge not found at: $BrowserPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Using browser Print to PDF instead:" -ForegroundColor Yellow
    Write-Host "  1. Open each HTML file in your browser (double-click)" -ForegroundColor Gray
    Write-Host "  2. Press Ctrl+P" -ForegroundColor Gray
    Write-Host "  3. Select 'Save as PDF'" -ForegroundColor Gray
    Write-Host "  4. Click Print" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Convert each HTML file to PDF
$successCount = 0
$failCount = 0
$skippedCount = 0

foreach ($htmlFile in $htmlFiles) {
    $pdfPath = $htmlFile.FullName -replace '\.html$', '.pdf'
    $fileName = Split-Path $htmlFile -Leaf
    $moduleName = Split-Path (Split-Path $htmlFile -Parent) -Parent | Split-Path -Leaf

    # Check if PDF already exists
    if ((Test-Path $pdfPath) -and $SkipExistingPDFs) {
        Write-Host "⏭️  Skipping (PDF exists): $moduleName/$fileName" -ForegroundColor Gray
        $skippedCount++
        continue
    }

    try {
        Write-Host "⏳ Converting: $moduleName/$fileName..." -ForegroundColor Yellow

        # Use Edge to print to PDF (headless mode)
        $process = Start-Process -FilePath $BrowserPath `
            -ArgumentList @(
                "--headless",
                "--disable-gpu",
                "--print-to-pdf=$pdfPath",
                $htmlFile.FullName
            ) `
            -Wait `
            -PassThru

        # Wait a moment for file to be written
        Start-Sleep -Milliseconds 500

        if (Test-Path $pdfPath) {
            $pdfSize = (Get-Item $pdfPath).Length / 1024
            Write-Host "✅ Created: $fileName ($([Math]::Round($pdfSize, 1)) KB)" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "❌ Failed to create PDF: $fileName" -ForegroundColor Red
            $failCount++
        }
    }
    catch {
        Write-Host "❌ Error converting $fileName : $_" -ForegroundColor Red
        $failCount++
    }
}

# Summary
Write-Host ""
Write-Host "════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  📊 Conversion Results" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════" -ForegroundColor Cyan

if ($successCount -gt 0) {
    Write-Host "✅ Successfully converted: $successCount files" -ForegroundColor Green
}
if ($skippedCount -gt 0) {
    Write-Host "⏭️  Skipped (already exist): $skippedCount files" -ForegroundColor Yellow
}
if ($failCount -gt 0) {
    Write-Host "❌ Failed: $failCount files" -ForegroundColor Red
}

Write-Host ""
Write-Host "📂 PDFs saved in:" -ForegroundColor Cyan
Get-ChildItem -Path "$scriptPath\*\documents\*.pdf" -Recurse |
    ForEach-Object { Write-Host "   $(Split-Path $_ -Parent | Split-Path -Leaf)/$($_.Name)" }

# Option to open PDFs
if ($OpenPDFs -and $successCount -gt 0) {
    Write-Host ""
    Write-Host "Opening PDFs..." -ForegroundColor Yellow
    Get-ChildItem -Path "$scriptPath\*\documents\*.pdf" -Recurse |
        ForEach-Object { Start-Process $_.FullName }
}

Write-Host ""
Write-Host "✨ Done!" -ForegroundColor Green
