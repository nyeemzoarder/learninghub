# Module 04: Networking — Documentation

Welcome to the Networking concept documentation in HTML format.

## 📄 Available Documents

All concept articles have been converted to HTML for easy viewing and printing:

1. **01-vnets-and-subnets.html** — Virtual networks, subnets, CIDR notation, address planning
2. **02-network-security-groups.html** — NSG firewall rules, priorities, security tiers
3. **03-routing-fundamentals.html** — System routes, custom routes, UDRs, GPS analogy
4. **04-vnet-peering.html** — Direct VNet connections, regional vs. global, gateway transit
5. **05-vpn-and-expressroute.html** — Hybrid connectivity, VPN vs. dedicated circuits, failover
6. **06-hub-spoke-topology.html** — Enterprise architecture, hub-and-spoke pattern at scale
7. **07-private-endpoints-service-endpoints.html** — Secure PaaS access, private DNS
8. **08-network-security-advanced.html** — DDoS, Azure Firewall, WAF, Network Watcher

## 🌐 Viewing the Documents

### Option 1: Open in Web Browser (Recommended)
- Simply double-click any `.html` file
- Opens in your default browser (Edge, Chrome, Firefox)
- Best viewing experience with proper formatting
- Responsive design works on tablets and phones

### Option 2: View in VS Code
- Right-click → Open with → Code
- Full markdown-like rendering in VS Code's preview
- Allows side-by-side editing

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

## 📋 Document Statistics

| Document | Size | Topics |
|----------|------|--------|
| 01-vnets-and-subnets | ~30KB | Private networks, CIDR, address planning |
| 02-network-security-groups | ~32KB | Firewall rules, defaults, priorities |
| 03-routing-fundamentals | ~35KB | System routes, UDRs, routing tables |
| 04-vnet-peering | ~25KB | Peering, gateway transit, hub-and-spoke intro |
| 05-vpn-and-expressroute | ~37KB | Hybrid connectivity, failover, redundancy |
| 06-hub-spoke-topology | ~43KB | Enterprise architecture, Dallas case study |
| 07-private-endpoints-service-endpoints | ~42KB | Secure PaaS, private DNS, endpoints |
| 08-network-security-advanced | ~38KB | DDoS, Firewall, WAF, diagnostics |

**Total:** ~282 KB of networking documentation

## 💡 Tips

- **Best for Screen Reading:** Use HTML files directly in browser
- **Best for Printing:** Convert to PDF using browser Print function
- **Best for Sharing:** PDF is more universal and preserves layout
- **Batch Conversion:** Use PowerShell script for all documents at once
- **Mobile Viewing:** HTML files are responsive and work on phones

## 🔄 Regeneration

If you need to regenerate these HTML files from the markdown source:
1. The `.html` files are auto-generated from `../concepts/*.md`
2. HTML files can be safely deleted and regenerated
3. Use the parent script in the course to regenerate

## 📚 Full Documentation

For the original markdown source files, see:
- `../concepts/` — Contains all concept documentation in markdown format
- `../labs/` — Contains hands-on lab exercises

## 🎯 Recommended Reading Order

**Foundation First:**
1. **01-vnets-and-subnets.html** — Start here (VNets, subnets, IP addressing)
2. **02-network-security-groups.html** — NSGs (firewall rules)
3. **03-routing-fundamentals.html** — Routing (how traffic flows)

**Intermediate:**
4. **04-vnet-peering.html** — Connecting VNets (regional/global)
5. **05-vpn-and-expressroute.html** — Hybrid (on-premises connections)

**Advanced:**
6. **06-hub-spoke-topology.html** — Enterprise architecture at scale
7. **07-private-endpoints-service-endpoints.html** — Secure PaaS access
8. **08-network-security-advanced.html** — Advanced security patterns

## 🧪 Hands-On Learning

After reading each concept document, practice with the corresponding lab:
- After 01-vnets: See `../labs/lab12-vnet-subnets.md`
- After 02-nsg: See `../labs/lab13-nsg-rules.md`
- After 03-routing: See `../labs/lab14-routing.md`
- After 04-peering: See `../labs/lab15-vnet-peering.md`
- After 05-vpn: See `../labs/lab16-vpn-gateway.md`

---

**Need Help?** Check the parent module README or revisit the concept markdown files for full context.
