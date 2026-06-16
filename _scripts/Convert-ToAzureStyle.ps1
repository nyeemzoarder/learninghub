# Azure Style PDF Conversion Script
# Converts all markdown concept files to professional Azure-styled HTML and PDF

function Convert-MarkdownToAzureHTML {
    param(
        [string]$MarkdownPath,
        [string]$OutputPath
    )

    # Read markdown file
    $content = Get-Content -Path $MarkdownPath -Raw -Encoding UTF8

    # Convert markdown to HTML
    $html = $content `
        -replace '(?m)^# (.*?)$', '<h1>$1</h1>' `
        -replace '(?m)^## (.*?)$', '<h2>$1</h2>' `
        -replace '(?m)^### (.*?)$', '<h3>$1</h3>' `
        -replace '(?m)^#### (.*?)$', '<h4>$1</h4>' `
        -replace '(?m)^##### (.*?)$', '<h5>$1</h5>' `
        -replace '(?m)^###### (.*?)$', '<h6>$1</h6>' `
        -replace '\*\*([^*]+)\*\*', '<strong>$1</strong>' `
        -replace '__([^_]+)__', '<strong>$1</strong>' `
        -replace '\*([^*]+)\*', '<em>$1</em>' `
        -replace '_([^_]+)_', '<em>$1</em>' `
        -replace '\[([^\]]+)\]\(([^)]+)\)', '<a href="$2">$1</a>'

    # Handle inline code
    $html = $html -replace '`([^`]+)`', '<code>$1</code>'

    # Handle code blocks
    $codeBlockPattern = '```(.*?)```'
    $codeMatches = [regex]::Matches($html, $codeBlockPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

    foreach ($match in $codeMatches) {
        $codeContent = $match.Groups[1].Value.Trim()
        $escapedCode = [System.Web.HttpUtility]::HtmlEncode($codeContent)
        $html = $html -replace [regex]::Escape($match.Value), "<pre><code>$escapedCode</code></pre>"
    }

    # Convert remaining lines to paragraphs
    $lines = @()
    foreach ($line in $html -split "`n") {
        if ($line -match '^<h|^<pre|^<table|^<ul|^<ol|^---' -or $line.Trim() -eq '') {
            $lines += $line
        } else {
            $lines += "<p>$line</p>"
        }
    }
    $html = $lines -join "`n"

    # Get file information
    $fileName = Split-Path $MarkdownPath -Leaf
    $generationDate = Get-Date -Format "MMMM dd, yyyy HH:mm:ss"

    # Create complete HTML document with Azure styling
    $htmlDocument = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Azure AZ-104</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --azure-dark: #003DA5;
            --azure-blue: #0078D4;
            --azure-accent: #ff8c00;
            --text-dark: #1f1f1f;
            --text-gray: #424242;
            --bg-light: #f5f5f5;
            --card-white: #ffffff;
            --border-gray: #e0e0e0;
            --code-bg: #1e1e1e;
            --code-text: #d4d4d4;
        }

        body {
            font-family: 'Segoe UI', 'Calibri', 'Arial', sans-serif;
            line-height: 1.7;
            color: var(--text-dark);
            background: linear-gradient(135deg, var(--bg-light) 0%, #e8e8e8 100%);
            padding: 40px 20px;
            min-height: 100vh;
        }

        .container {
            max-width: 900px;
            margin: 0 auto;
            background: var(--card-white);
            padding: 60px 50px;
            border-radius: 8px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
            border-top: 5px solid var(--azure-blue);
        }

        h1 {
            font-size: 40px;
            color: var(--azure-dark);
            margin: 40px 0 20px 0;
            padding-bottom: 15px;
            border-bottom: 3px solid var(--azure-dark);
            font-weight: 700;
            letter-spacing: -0.5px;
        }

        h2 {
            font-size: 28px;
            color: var(--azure-dark);
            margin: 40px 0 15px 0;
            padding-left: 15px;
            border-left: 4px solid var(--azure-blue);
            font-weight: 600;
        }

        h3 {
            font-size: 22px;
            color: var(--text-dark);
            margin: 30px 0 12px 0;
            font-weight: 600;
        }

        h4 {
            font-size: 18px;
            color: var(--text-dark);
            margin: 20px 0 10px 0;
            font-weight: 600;
        }

        h5, h6 {
            font-size: 16px;
            color: var(--text-gray);
            margin: 15px 0 8px 0;
            font-weight: 600;
        }

        p {
            margin-bottom: 15px;
            color: var(--text-gray);
            font-size: 16px;
            line-height: 1.8;
        }

        a {
            color: var(--azure-blue);
            text-decoration: none;
            font-weight: 500;
            border-bottom: 1px solid transparent;
            transition: all 0.3s ease;
        }

        a:hover {
            border-bottom-color: var(--azure-blue);
            color: var(--azure-dark);
        }

        code {
            background: #f0f0f0;
            padding: 4px 8px;
            border-radius: 4px;
            font-family: 'Courier New', 'Consolas', monospace;
            font-size: 14px;
            color: var(--azure-accent);
            font-weight: 500;
        }

        pre {
            background: var(--code-bg);
            color: var(--code-text);
            padding: 20px;
            border-radius: 6px;
            overflow-x: auto;
            margin: 20px 0;
            font-family: 'Courier New', 'Consolas', monospace;
            font-size: 13px;
            line-height: 1.6;
            border-left: 4px solid var(--azure-accent);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }

        pre code {
            background: none;
            padding: 0;
            color: inherit;
            font-size: inherit;
        }

        ul, ol {
            margin: 15px 0 15px 30px;
            color: var(--text-gray);
        }

        li {
            margin-bottom: 10px;
            line-height: 1.8;
        }

        ul > li:before {
            content: "▹ ";
            color: var(--azure-blue);
            font-weight: bold;
            margin-right: 8px;
        }

        table {
            border-collapse: collapse;
            width: 100%;
            margin: 25px 0;
            border-radius: 6px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        th {
            background: linear-gradient(135deg, var(--azure-blue) 0%, var(--azure-dark) 100%);
            color: white;
            padding: 16px 12px;
            text-align: left;
            font-weight: 600;
            font-size: 15px;
            letter-spacing: 0.3px;
        }

        td {
            padding: 14px 12px;
            border-bottom: 1px solid var(--border-gray);
            font-size: 15px;
            color: var(--text-gray);
        }

        tr:last-child td {
            border-bottom: none;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        tr:hover {
            background-color: #f0f7ff;
        }

        blockquote {
            border-left: 5px solid var(--azure-blue);
            padding: 15px 20px;
            margin: 20px 0;
            background: #f0f7ff;
            border-radius: 0 6px 6px 0;
            color: var(--text-gray);
            font-style: italic;
            font-size: 15px;
        }

        hr {
            border: none;
            height: 2px;
            background: linear-gradient(to right, var(--border-gray), var(--azure-blue), var(--border-gray));
            margin: 40px 0;
        }

        strong {
            font-weight: 700;
            color: var(--text-dark);
        }

        em {
            font-style: italic;
            color: var(--text-gray);
        }

        .footer {
            margin-top: 50px;
            padding-top: 30px;
            border-top: 2px solid var(--border-gray);
            font-size: 13px;
            color: var(--text-gray);
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }

        .footer-item {
            padding: 10px 0;
        }

        .footer-item strong {
            display: block;
            color: var(--azure-blue);
            margin-bottom: 5px;
            font-size: 14px;
        }

        @media print {
            body {
                background: white;
                padding: 0;
            }

            .container {
                box-shadow: none;
                border: none;
                padding: 40px;
                max-width: 100%;
            }

            a {
                text-decoration: underline;
            }

            pre {
                page-break-inside: avoid;
            }

            h1, h2, h3 {
                page-break-after: avoid;
            }
        }

        @media (max-width: 768px) {
            .container {
                padding: 30px 20px;
            }

            h1 {
                font-size: 32px;
            }

            h2 {
                font-size: 24px;
            }

            table {
                font-size: 14px;
            }

            th, td {
                padding: 10px 8px;
            }

            pre {
                padding: 15px;
                font-size: 12px;
            }

            .footer {
                grid-template-columns: 1fr;
                gap: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        $html

        <div class="footer">
            <div class="footer-item">
                <strong>📄 Azure AZ-104</strong>
                <p>Professional Concept Documentation</p>
            </div>
            <div class="footer-item">
                <strong>📅 Generated</strong>
                <p>$generationDate</p>
            </div>
        </div>
    </div>
</body>
</html>
"@

    $htmlDocument | Set-Content -Path $OutputPath -Encoding UTF8
}

# Main conversion process
Write-Host "🔄 Converting all markdown files to Azure-styled HTML..." -ForegroundColor Cyan
Write-Host ""

$basePath = "c:\Users\nyeemzoarder\.claude\context\learning-hub\courses\az-104"
$modules = @("01-identity-governance", "04-networking")
$convertedCount = 0

foreach ($module in $modules) {
    $conceptsDir = Join-Path $basePath $module "concepts"
    $docsDir = Join-Path $basePath $module "documents"

    if (-not (Test-Path $conceptsDir)) {
        continue
    }

    $mdFiles = Get-ChildItem -Path $conceptsDir -Filter "*.md" -File

    foreach ($mdFile in $mdFiles) {
        $htmlName = $mdFile.BaseName + ".html"
        $htmlPath = Join-Path $docsDir $htmlName

        Write-Host "⏳ $module/$htmlName..." -NoNewline

        try {
            Convert-MarkdownToAzureHTML -MarkdownPath $mdFile.FullName -OutputPath $htmlPath
            Write-Host " ✅" -ForegroundColor Green
            $convertedCount++
        } catch {
            Write-Host " ❌" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✨ HTML Conversion Complete" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "📊 Converted: $convertedCount HTML files" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next: Converting HTML to PDF with wkhtmltopdf..." -ForegroundColor Cyan
