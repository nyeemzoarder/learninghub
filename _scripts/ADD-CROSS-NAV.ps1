# ============================================================
# Azure AZ-104 Learning Hub — Cross-Page Navigation Injector
# Adds a sticky top navigation bar (with dropdowns linking to
# every document across both modules) to all HTML pages.
# ============================================================

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$navCss = @'

/* ===== Site-wide Cross Navigation ===== */
.site-nav{
  position:sticky;top:0;z-index:1000;
  background:var(--primary);color:#fff;
  display:flex;align-items:center;gap:14px;flex-wrap:wrap;
  padding:12px 28px;font-size:.92rem;
  box-shadow:0 2px 10px rgba(0,0,76,.18);
  font-family:Inter,-apple-system,'Segoe UI',sans-serif;
}
.site-nav .nav-brand{font-weight:800;font-size:1.05rem;margin-right:auto;color:#fff}
.site-nav details{position:relative}
.site-nav summary{cursor:pointer;list-style:none;padding:7px 16px;border-radius:8px;background:rgba(255,255,255,.12);font-weight:600;color:#fff;user-select:none}
.site-nav summary::-webkit-details-marker,.site-nav summary::marker{display:none;content:''}
.site-nav details[open] summary{background:rgba(255,255,255,.24)}
.site-nav .nav-menu{
  position:absolute;top:calc(100% + 8px);left:0;
  background:#fff;color:var(--text);
  border:1px solid var(--border);border-radius:12px;
  padding:8px;min-width:300px;box-shadow:0 16px 32px rgba(0,0,76,.22);
  display:flex;flex-direction:column;gap:2px;z-index:1001;
}
.site-nav .nav-menu a{
  display:block;padding:9px 14px;border-radius:8px;border-bottom:none;
  color:var(--text);font-weight:500;font-size:.95rem;
}
.site-nav .nav-menu a:hover{background:#eef2ff;color:#1e2a78}
.site-nav .nav-menu a.active{background:#eef2ff;color:#1735ad;font-weight:700}
@media (max-width:768px){
  .site-nav{padding:10px 16px}
  .site-nav .nav-brand{font-size:.95rem}
}
'@

# Pages, in display order, grouped by module
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

function Build-Nav {
    param(
        [string]$currentModule,   # '01' or '04'
        [string]$currentFile
    )

    $m1Prefix = if ($currentModule -eq '01') { '' } else { '../../01-identity-governance/documents/' }
    $m4Prefix = if ($currentModule -eq '04') { '' } else { '../../04-networking/documents/' }

    $m1Links = ($module01 | ForEach-Object {
        $cls = if ($currentModule -eq '01' -and $_.file -eq $currentFile) { ' class="active"' } else { '' }
        "      <a href=`"$m1Prefix$($_.file)`"$cls>$($_.title)</a>"
    }) -join "`n"

    $m4Links = ($module04 | ForEach-Object {
        $cls = if ($currentModule -eq '04' -and $_.file -eq $currentFile) { ' class="active"' } else { '' }
        "      <a href=`"$m4Prefix$($_.file)`"$cls>$($_.title)</a>"
    }) -join "`n"

    return @"
<nav class="site-nav">
  <span class="nav-brand">AZ-104 Learning Hub</span>
  <details class="nav-group">
    <summary>Module 01 - Identity &amp; Governance</summary>
    <div class="nav-menu">
$m1Links
    </div>
  </details>
  <details class="nav-group">
    <summary>Module 04 - Networking</summary>
    <div class="nav-menu">
$m4Links
    </div>
  </details>
</nav>
"@
}

$targets = @()
foreach ($p in $module01) { $targets += @{module='01'; dir='01-identity-governance'; file=$p.file} }
foreach ($p in $module04) { $targets += @{module='04'; dir='04-networking'; file=$p.file} }

foreach ($t in $targets) {
    $path = Join-Path $root "$($t.dir)\documents\$($t.file)"
    if (-not (Test-Path $path)) {
        Write-Host "MISSING: $path" -ForegroundColor Red
        continue
    }

    $content = Get-Content -Path $path -Raw -Encoding UTF8

    # 1) Inject nav CSS before the @media print block
    if ($content -notmatch '\.site-nav\{') {
        $content = $content -replace '(\r?\n@media print\{)', ("$navCss" + '$1')
    }

    # 2) Hide nav when printing
    if ($content -notmatch '\.site-nav\{display:none\}') {
        $content = $content -replace '(\@media print\{\r?\n)', "`$1  .site-nav{display:none}`r`n"
    }

    # 3) Insert nav markup right after <body>
    if ($content -notmatch '<nav class="site-nav">') {
        $navHtml = Build-Nav -currentModule $t.module -currentFile $t.file
        $content = $content -replace '(<body>\r?\n)', ("`$1" + $navHtml + "`r`n")
    }

    Set-Content -Path $path -Value $content -NoNewline -Encoding UTF8
    Write-Host "Updated: $($t.dir)/documents/$($t.file)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done. Cross-navigation added to $($targets.Count) pages." -ForegroundColor Cyan
