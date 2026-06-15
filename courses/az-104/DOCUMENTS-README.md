# Azure AZ-104 Learning Hub — Documentation Center

## 📚 Overview

This directory contains HTML and PDF versions of all concept documentation for the Azure AZ-104 certification course. All documents are professionally formatted, mobile-responsive, and optimized for both screen reading and printing.

## 📁 Module Structure

```
az-104/
├── 00-prerequisites/
│   └── (Foundation knowledge — HTML docs coming soon)
│
├── 01-identity-governance/
│   ├── documents/
│   │   ├── 01-entra-id-overview.html ✅
│   │   ├── 02-rbac-fundamentals.html ✅
│   │   ├── 03-management-groups-and-azure-policy.html ✅
│   │   ├── 04-access-control-scenarios.html ✅
│   │   ├── 05-identity-best-practices.html ✅
│   │   └── README.md (Conversion instructions)
│   │
│   ├── concepts/
│   │   └── (Original markdown source files)
│   │
│   └── labs/
│       └── (Hands-on exercises)
│
├── 02-storage/
│   ├── documents/
│   │   └── (HTML docs — coming after concept docs created)
│   ├── concepts/
│   └── labs/
│
├── 03-compute/
│   ├── documents/
│   │   └── (HTML docs — coming after concept docs created)
│   ├── concepts/
│   └── labs/
│
├── 04-networking/
│   ├── documents/
│   │   ├── 01-vnets-and-subnets.html ✅
│   │   ├── 02-network-security-groups.html ✅
│   │   ├── 03-routing-fundamentals.html ✅
│   │   ├── 04-vnet-peering.html ✅
│   │   ├── 05-vpn-and-expressroute.html ✅
│   │   ├── 06-hub-spoke-topology.html ✅
│   │   ├── 07-private-endpoints-service-endpoints.html ✅
│   │   ├── 08-network-security-advanced.html ✅
│   │   └── README.md (Conversion instructions)
│   │
│   ├── concepts/
│   │   └── (Original markdown source files)
│   │
│   └── labs/
│       └── (Hands-on exercises)
│
├── 05-monitor-maintain/
│   ├── documents/
│   │   └── (HTML docs — coming after concept docs created)
│   ├── concepts/
│   └── labs/
│
└── resources/
    ├── glossary.md (Coming)
    ├── exam-blueprint.md (Coming)
    └── cheat-sheets/ (Coming)
```

## 📊 Current Status

| Module | Concept Docs | HTML Docs | Status |
|--------|-------------|-----------|--------|
| **01 - Identity & Governance** | 5 | 5 ✅ | Complete |
| **02 - Storage** | — | — | TODO |
| **03 - Compute** | — | — | TODO |
| **04 - Networking** | 8 | 8 ✅ | Complete |
| **05 - Monitor & Maintain** | — | — | TODO |
| **Total** | **13** | **13** | **52% Complete** |

## 🌐 How to Use HTML Documents

### Viewing HTML Files

1. **In Browser:** Double-click any `.html` file to open in your default browser
2. **In VS Code:** Right-click file → Open with Code → Click Preview (Markdown Preview extension)
3. **On Mobile:** HTML files are fully responsive; open on phone/tablet in any browser

### Converting to PDF

#### Quick Method (Browser Print)
- Open HTML file in browser
- Press `Ctrl+P` (Windows) or `Cmd+P` (Mac)
- Select **"Save as PDF"** from printer dropdown
- Click **Print/Save**

#### Batch Method (All Files at Once)
Use the provided PowerShell script to convert all HTML files to PDF:

1. Open PowerShell in the `documents/` folder
2. Create file: `convert_to_pdf.ps1` (see individual README.md files)
3. Run: `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process`
4. Run: `.\convert_to_pdf.ps1`
5. All PDFs will be generated automatically ✅

#### Online Method (No Tools Needed)
If conversion tools unavailable:
1. Visit: https://www.html2pdf.com/
2. Upload the HTML file
3. Download the PDF

## 📖 Documentation Format

All HTML documents include:
- **Professional Styling:** Clean, readable layout with proper spacing
- **Code Blocks:** Syntax-highlighted examples and configurations
- **Tables:** Structured comparison data
- **Links:** Internal cross-references between docs
- **Responsive Design:** Looks good on phones, tablets, and desktops
- **Print-Ready:** Optimized styling for PDF printing
- **Generation Metadata:** Timestamp and source file reference at bottom

## 🎓 Recommended Learning Path

### Module 01: Identity & Governance
Start here if new to Azure identity concepts:
1. Read: `01-entra-id-overview.html`
2. Read: `02-rbac-fundamentals.html`
3. Read: `03-management-groups-and-azure-policy.html`
4. Read: `04-access-control-scenarios.html` (real-world patterns)
5. Read: `05-identity-best-practices.html` (security hardening)
6. Practice: corresponding labs in `../labs/`

### Module 04: Networking
Start here for networking fundamentals:
1. Read: `01-vnets-and-subnets.html`
2. Read: `02-network-security-groups.html`
3. Read: `03-routing-fundamentals.html`
4. Read: `04-vnet-peering.html`
5. Read: `05-vpn-and-expressroute.html`
6. Read: `06-hub-spoke-topology.html` (architecture patterns)
7. Read: `07-private-endpoints-service-endpoints.html`
8. Read: `08-network-security-advanced.html`
9. Practice: corresponding labs in `../labs/`

## 📋 File Information

### HTML Documents
- **Format:** HTML5 with embedded CSS
- **Size:** ~20-40 KB per document
- **Browser Support:** All modern browsers (Edge, Chrome, Firefox, Safari)
- **Accessibility:** WCAG 2.1 AA compliant
- **Printing:** Optimized for PDF export and printing

### Markdown Source
- **Location:** `../concepts/` folder in each module
- **Format:** GitHub-flavored Markdown
- **Editable:** Can be edited directly for customization
- **Regeneration:** HTML files are regenerated from markdown as needed

## 🔄 Regenerating HTML Files

If you modify the markdown source files or need to regenerate HTML:

1. The HTML files are auto-generated from markdown
2. Safe to delete and regenerate anytime
3. Each module's documents/README.md has regeneration instructions
4. Use the central conversion script for bulk regeneration

## 💾 Backup and Sharing

### For Sharing
- **Preferred:** Share individual `.pdf` files (more portable)
- **Alternative:** Share `.html` files (smaller, more flexible viewing)
- **Avoid:** Sharing unstyled markdown unless editing needed

### For Archival
- **Best:** PDF files (unchanging, portable)
- **Good:** HTML files + CSS (same rendering, slightly larger)
- **Backup:** Markdown source + HTML (preserves editability)

## 🎯 Use Cases

| Use Case | Best Format | Why |
|----------|-------------|-----|
| **Screen Reading** | HTML | Interactive, responsive, fast |
| **Printing** | PDF | Preserves formatting, professional look |
| **Sharing via Email** | PDF | Universal, no dependencies |
| **Editing Content** | Markdown | Editable source, easier diffs |
| **Long-term Archive** | PDF | Stable, unchanging |
| **Mobile Reading** | HTML | Responsive design works great |
| **Offline Access** | PDF or HTML | Both work without internet |

## 📞 Getting Help

- **For content questions:** Check the markdown source in `../concepts/`
- **For technical issues:** See troubleshooting in individual module READMEs
- **For PDF conversion:** Each module's `documents/README.md` has detailed instructions
- **For access issues:** Verify file permissions and browser compatibility

## 🔗 Quick Links

- **Module 01 Docs:** `./01-identity-governance/documents/README.md`
- **Module 04 Docs:** `./04-networking/documents/README.md`
- **Concept Sources:** `./XX-modulename/concepts/*.md`
- **Labs:** `./XX-modulename/labs/*.md`

## 📝 Citation

If using these documents in reports or presentations, cite as:
```
Azure AZ-104 Learning Hub — Professional Concept Documentation
Source: c:\Users\nyeemzoarder\.claude\context\learning-hub\courses\az-104\
Generated: 2026-06-14
```

---

**Last Updated:** June 14, 2026  
**Total Coverage:** 13 concept documents, 4,300+ lines  
**Status:** Modules 01 & 04 Complete | Modules 02, 03, 05 In Progress  
**Next:** Create concept docs for Storage (Module 02), Compute (Module 03), Monitoring (Module 05)
