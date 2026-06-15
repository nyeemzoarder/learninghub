# Module 01: Identity & Governance — Documentation

Welcome to the Identity & Governance concept documentation in HTML format.

## 📄 Available Documents

All concept articles have been converted to HTML for easy viewing and printing:

1. **01-entra-id-overview.html** — Cloud identity system, tenants, groups, delegation
2. **02-rbac-fundamentals.html** — Role definitions, scopes, permission assignments
3. **03-management-groups-and-azure-policy.html** — Hierarchy, policy enforcement
4. **04-access-control-scenarios.html** — Enterprise patterns and real-world scenarios
5. **05-identity-best-practices.html** — Security hardening, MFA, offboarding

## 🌐 Viewing the Documents

### Option 1: Open in Web Browser (Recommended)
- Simply double-click any `.html` file
- Opens in your default browser (Edge, Chrome, Firefox)
- Best viewing experience with proper formatting

### Option 2: View Source in VS Code
- Right-click → Open with → Code
- Allows editing while keeping formatting

## 📕 Converting to PDF

### Method 1: Browser "Print to PDF" (Easiest)
1. Open the HTML file in your browser
2. Press `Ctrl+P` (or `Cmd+P` on Mac)
3. Select printer: **"Save as PDF"** (or your PDF printer)
4. Click **Print/Save**
5. Choose save location: `./` (same folder)

**Result:** `document_name.pdf` created in the same folder

### Method 2: Microsoft Edge (Built-in)
1. Open HTML file in Edge
2. Click the three-dot menu ⋯
3. Select **Print** (or Ctrl+P)
4. Choose **Save as PDF**
5. Click **Save**

### Method 3: PowerShell Script (Batch Conversion)
Run this script to convert ALL HTML files to PDF at once:

```powershell
# Save this as: convert_to_pdf.ps1

$htmlFolder = Split-Path $MyInvocation.MyCommand.Path
$files = Get-ChildItem -Path $htmlFolder -Filter "*.html"

foreach ($file in $files) {
    $pdfPath = $file.FullName -replace '\.html$', '.pdf'
    
    # Using Edge to print to PDF
    Start-Process -FilePath "msedge.exe" `
        -ArgumentList "--headless", "--disable-gpu", "--print-to-pdf=$pdfPath", $file.FullName `
        -Wait
    
    Write-Host "✅ Created: $(Split-Path $pdfPath -Leaf)"
}
```

**Steps:**
1. Save the script above as `convert_to_pdf.ps1` in this folder
2. Open PowerShell in this directory
3. Run: `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process`
4. Run: `.\convert_to_pdf.ps1`
5. All HTML files will be converted to PDF automatically ✓

### Method 4: Online Converter (If Tools Unavailable)
If browser conversion doesn't work:
1. Visit: https://www.html2pdf.com/ or https://html.online-convert.com/
2. Upload the HTML file
3. Download the PDF result

## 📋 File Sizes and Generation Info

- **HTML Format:** Optimized for screen viewing, smallest file size
- **PDF Format:** Better for printing and archiving
- **Generated:** Each HTML includes generation timestamp at bottom

## 💡 Tips

- **Best for Screen Reading:** Use HTML files directly
- **Best for Printing:** Convert to PDF using browser Print function
- **Best for Sharing:** PDF is more universal and preserves layout
- **Batch Conversion:** Use PowerShell script for all documents at once

## 🔄 Regeneration

If you need to regenerate these HTML files from the markdown source:
1. The `.html` files are auto-generated from `../concepts/*.md`
2. HTML files can be safely deleted and regenerated
3. Use the parent script in `../concepts/` to regenerate

## 📚 Full Documentation

For the original markdown source files, see:
- `../concepts/` — Contains all concept documentation in markdown format

## 🎯 Recommended Reading Order

1. Start with **01-entra-id-overview.html**
2. Continue with **02-rbac-fundamentals.html**
3. Then **03-management-groups-and-azure-policy.html**
4. Read **04-access-control-scenarios.html** (real-world examples)
5. Finish with **05-identity-best-practices.html** (hardening)

---

**Need Help?** Check the parent module README or revisit the concept markdown files for full context and lab links.
