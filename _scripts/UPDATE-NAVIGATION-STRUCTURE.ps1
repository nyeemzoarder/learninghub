# Script to update navigation and sidebar structure for Module 00, 01, and 04 HTML files

# Define paths
$baseDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$modules = @{
    "00-prerequisites" = @{
        concepts = @("01-cloud-computing-fundamentals", "02-networking-basics", "03-identity-and-access-fundamentals", "04-azure-portal-navigation")
        labs = @("lab00-azure-portal-navigation")
        displayName = "Module 00 - Prerequisites"
        moduleName = "Prerequisites"
    }
    "01-identity-governance" = @{
        concepts = @("01-entra-id-overview", "02-rbac-fundamentals", "03-management-groups-and-azure-policy", "04-access-control-scenarios", "05-identity-best-practices")
        labs = @("lab01-entra-users-groups", "lab02-rbac-azure-policy", "lab03-management-groups-subscriptions")
        displayName = "Module 01 - Identity & Governance"
        moduleName = "Identity & Governance"
    }
    "04-networking" = @{
        concepts = @("01-vnets-and-subnets", "02-network-security-groups", "03-routing-fundamentals", "04-vnet-peering", "05-vpn-and-expressroute", "06-hub-spoke-topology", "07-private-endpoints-service-endpoints", "08-network-security-advanced")
        labs = @("lab12-vnet-subnets", "lab13-nsg-asg", "lab14-vnet-peering-vpn", "lab15-load-balancer-app-gateway", "lab16-dns-name-resolution")
        displayName = "Module 04 - Networking"
        moduleName = "Networking"
    }
}

# Define simplified navigation structure
$navStructure = @{
    "00-prerequisites" = @{
        homeLink = "module-home.html"
        label = "Module 00 Home"
    }
    "01-identity-governance" = @{
        homeLink = "module-home.html"
        label = "Module 01 Home"
    }
    "04-networking" = @{
        homeLink = "module-home.html"
        label = "Module 04 Home"
    }
}

function Update-NavigationBar {
    param(
        [string]$htmlContent,
        [string]$currentModule,
        [boolean]$isActive
    )

    # Build new navigation
    $newNav = @"
<nav class="site-nav">
  <a class="nav-brand" href="../../index.html">AZ-104 Learning Hub</a>
  <details class="nav-group">
    <summary>Module 00 - Prerequisites</summary>
    <div class="nav-menu">
      <a href="../../00-prerequisites/documents/$($navStructure['00-prerequisites'].homeLink)"$(if($currentModule -eq '00-prerequisites' -and $isActive) { ' class="active"' })>$($navStructure['00-prerequisites'].label)</a>
    </div>
  </details>
  <details class="nav-group">
    <summary>Module 01 - Identity &amp; Governance</summary>
    <div class="nav-menu">
      <a href="../../01-identity-governance/documents/$($navStructure['01-identity-governance'].homeLink)"$(if($currentModule -eq '01-identity-governance' -and $isActive) { ' class="active"' })>$($navStructure['01-identity-governance'].label)</a>
    </div>
  </details>
  <details class="nav-group">
    <summary>Module 04 - Networking</summary>
    <div class="nav-menu">
      <a href="../../04-networking/documents/$($navStructure['04-networking'].homeLink)"$(if($currentModule -eq '04-networking' -and $isActive) { ' class="active"' })>$($navStructure['04-networking'].label)</a>
    </div>
  </details>
</nav>
"@

    # Replace old nav with new nav
    $pattern = '<nav class="site-nav">.*?</nav>'
    $htmlContent = [regex]::Replace($htmlContent, $pattern, $newNav, [System.Text.RegularExpressions.RegexOptions]::Singleline)

    return $htmlContent
}

function Update-SidebarCollapsible {
    param(
        [string]$htmlContent,
        [string]$currentModule,
        [string[]]$concepts,
        [string[]]$labs,
        [string[]]$pageAnchors
    )

    # Build sidebar HTML with collapsible sections
    $moduleDisplayName = $modules[$currentModule].displayName

    # Build concepts links
    $conceptsLinks = ""
    foreach($concept in $concepts) {
        $conceptsLinks += "        <a href=""$concept.html"">$((Get-Content "$baseDir/courses/az-104/$currentModule/documents/$concept.html" | Select-String '<title>(.*?)</title>' | % { $_.Matches[0].Groups[1].Value }) -replace ' - .*', '')</a>`n"
    }

    # Build labs links
    $labsLinks = ""
    if($labs.Count -gt 0) {
        foreach($lab in $labs) {
            $labsLinks += "        <a href=""$lab.html"">$((Get-Content "$baseDir/courses/az-104/$currentModule/documents/$lab.html" | Select-String '<title>(.*?)</title>' | % { $_.Matches[0].Groups[1].Value }) -replace ' - .*', '')</a>`n"
        }
    }

    # Build page anchors links
    $pageAnchorsLinks = ""
    foreach($anchor in $pageAnchors) {
        $pageAnchorsLinks += "        <a href=""#$anchor"">$($anchor -replace '-', ' ' -replace '(?:^|_)(.)', { $_.Groups[1].Value.ToUpper() })</a>`n"
    }

    # Build sidebar HTML
    $newSidebar = @"
  <aside class="sidebar">
    <details open>
      <summary>▶ $moduleDisplayName</summary>
      <div>
$conceptsLinks      </div>
    </details>
$(if($labsLinks) { @"
    <details>
      <summary>▶ Labs</summary>
      <div>
$labsLinks      </div>
    </details>
"@ })
    <details>
      <summary>▶ On This Page</summary>
      <div>
$pageAnchorsLinks      </div>
    </details>
  </aside>
"@

    # Replace old sidebar with new sidebar
    $pattern = '<aside class="sidebar">.*?</aside>'
    $htmlContent = [regex]::Replace($htmlContent, $pattern, $newSidebar, [System.Text.RegularExpressions.RegexOptions]::Singleline)

    return $htmlContent
}

function Update-SidebarCss {
    param(
        [string]$htmlContent
    )

    # Check if CSS already has the collapsible styles
    if ($htmlContent -match '\.sidebar details\{') {
        return $htmlContent
    }

    # Add collapsible sidebar CSS
    $newCss = @"
.sidebar details{margin-bottom:0}
.sidebar summary{
  cursor:pointer;list-style:none;padding:10px 12px;border-radius:8px;
  font-weight:600;font-size:.92rem;color:var(--primary);
  user-select:none;transition:background 0.2s;
}
.sidebar summary::-webkit-details-marker,.sidebar summary::marker{display:none;content:''}
.sidebar details[open]>summary{background:#eef2ff}
.sidebar summary:hover{background:#f0f4ff}
.sidebar a{display:block;padding:8px 12px;margin:2px 0;border-radius:8px;font-size:.88rem;font-weight:500;
  color:var(--text);border-bottom:none;border-left:3px solid transparent;line-height:1.4;transition:all 0.15s}
.sidebar a:hover{background:#eef2ff;color:#1e2a78}
.sidebar a.active{background:#eef2ff;color:#1735ad;font-weight:700;border-left-color:var(--primary)}
.sidebar details > div{padding:0 0 8px 12px}
.sidebar hr.sidebar-divider{border:none;border-top:1px solid var(--border);margin:12px 0}
"@

    # Replace old sidebar CSS
    $oldPattern = '\.sidebar .toc-title\{font-size:\.72rem;.*?\.sidebar a\.active\{.*?border-left-color:var\(--primary\)\}'
    $htmlContent = [regex]::Replace($htmlContent, $oldPattern, $newCss, [System.Text.RegularExpressions.RegexOptions]::Singleline)

    return $htmlContent
}

# Process each module
foreach($moduleName in @("00-prerequisites", "01-identity-governance", "04-networking")) {
    $module = $modules[$moduleName]
    $docsPath = "$baseDir/courses/az-104/$moduleName/documents"

    Write-Host "Processing Module: $moduleName"

    # Process concept files
    foreach($concept in $module.concepts) {
        $filePath = "$docsPath/$concept.html"

        if (Test-Path $filePath) {
            Write-Host "  Updating: $concept.html"

            $content = Get-Content $filePath -Raw -Encoding UTF8

            # Update navigation
            $content = Update-NavigationBar -htmlContent $content -currentModule $moduleName -isActive $false

            # Update sidebar CSS if needed
            $content = Update-SidebarCss -htmlContent $content

            # TODO: Extract page anchors from content and update sidebar
            # For now, this needs manual work or more sophisticated parsing

            Set-Content $filePath -Value $content -Encoding UTF8
        }
    }

    # Process lab files
    foreach($lab in $module.labs) {
        $filePath = "$docsPath/$lab.html"

        if (Test-Path $filePath) {
            Write-Host "  Updating: $lab.html"

            $content = Get-Content $filePath -Raw -Encoding UTF8

            # Update navigation
            $content = Update-NavigationBar -htmlContent $content -currentModule $moduleName -isActive $false

            # Update sidebar CSS if needed
            $content = Update-SidebarCss -htmlContent $content

            Set-Content $filePath -Value $content -Encoding UTF8
        }
    }
}

Write-Host "`nNavigation update complete!"
