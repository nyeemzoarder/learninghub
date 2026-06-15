# ============================================================
# Azure AZ-104 Learning Hub — Add "Module Pages" links to sidebar
# Inserts a module-wide page list above the existing
# "On This Page" section-anchor list in every content page's
# left sidebar, so readers can jump between pages in a module
# without opening the top-nav dropdown.
# ============================================================

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$titleMap = @{ '00'='Module 00 - Prerequisites'; '01'='Module 01 - Identity &amp; Governance'; '04'='Module 04 - Networking' }

$module00 = @(
    @{file='01-cloud-computing-fundamentals.html';     title='01 - Cloud Computing Fundamentals'},
    @{file='02-networking-basics.html';                title='02 - Networking Basics'},
    @{file='03-identity-and-access-fundamentals.html'; title='03 - Identity &amp; Access Fundamentals'},
    @{file='04-azure-portal-navigation.html';          title='04 - Azure Portal Navigation'}
)
$module01 = @(
    @{file='01-entra-id-overview.html';                       title='01 - Entra ID Overview'},
    @{file='02-rbac-fundamentals.html';                       title='02 - RBAC Fundamentals'},
    @{file='03-management-groups-and-azure-policy.html';     title='03 - Management Groups &amp; Azure Policy'},
    @{file='04-access-control-scenarios.html';                title='04 - Access Control Scenarios'},
    @{file='05-identity-best-practices.html';                 title='05 - Identity Best Practices'}
)
$module04 = @(
    @{file='01-hub-spoke-topology.html';                      title='01 - Hub-Spoke Topology'},
    @{file='01-vnets-and-subnets.html';                       title='01 - VNets &amp; Subnets'},
    @{file='02-network-security-groups.html';                 title='02 - Network Security Groups'},
    @{file='03-routing-fundamentals.html';                    title='03 - Routing Fundamentals'},
    @{file='04-vnet-peering.html';                            title='04 - VNet Peering'},
    @{file='05-vpn-and-expressroute.html';                    title='05 - VPN &amp; ExpressRoute'},
    @{file='07-private-endpoints-service-endpoints.html';     title='07 - Private &amp; Service Endpoints'},
    @{file='08-network-security-advanced.html';               title='08 - Advanced Network Security'}
)

$dirMap  = @{ '00'='00-prerequisites'; '01'='01-identity-governance'; '04'='04-networking' }
$modMap  = @{ '00'=$module00; '01'=$module01; '04'=$module04 }

$dividerCss = @'

.sidebar hr.sidebar-divider{border:none;border-top:1px solid var(--border);margin:14px 0}
.sidebar .toc-title.module-title{margin-top:0}
'@

foreach ($mod in @('00','01','04')) {
    foreach ($p in $modMap[$mod]) {
        $path = Join-Path $root "$($dirMap[$mod])\documents\$($p.file)"
        if (-not (Test-Path $path)) { Write-Host "MISSING: $path" -ForegroundColor Red; continue }

        $content = Get-Content -Path $path -Raw -Encoding UTF8

        if ($content -match 'class="toc-title module-title"') {
            Write-Host "Already has module links: $($dirMap[$mod])/documents/$($p.file)" -ForegroundColor Yellow
            continue
        }

        # Build the module page list (same-folder links; mark current page active)
        $pageLinks = ($modMap[$mod] | ForEach-Object {
            $cls = if ($_.file -eq $p.file) { ' class="active"' } else { '' }
            "    <a href=`"$($_.file)`"$cls>$($_.title)</a>"
        }) -join "`n"

        $moduleBlock = @"
    <div class="toc-title module-title">$($titleMap[$mod])</div>
$pageLinks
    <hr class="sidebar-divider">
    <div class="toc-title">On This Page</div>
"@

        # Insert module page list before the existing "On This Page" title
        $content = $content -replace '(\s*)<div class="toc-title">On This Page</div>', "`n$moduleBlock"

        # Add divider CSS once, right before the .sidebar .toc-title rule
        if ($content -notmatch 'sidebar-divider') {
            $content = $content -replace '(\.sidebar \.toc-title\{[^\}]*\})', ("`$1" + $dividerCss)
        }

        Set-Content -Path $path -Value $content -NoNewline -Encoding UTF8
        Write-Host "Updated: $($dirMap[$mod])/documents/$($p.file)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
