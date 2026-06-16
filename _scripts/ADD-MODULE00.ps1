# ============================================================
# Azure AZ-104 Learning Hub — Add Module 00 (Prerequisites)
# 1) Adds the cross-nav + sidebar to the 4 new Module 00 pages
# 2) Rebuilds the cross-nav on all 13 existing pages to include
#    a "Module 00 - Prerequisites" dropdown
# ============================================================

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$dirMap   = @{ '00'='00-prerequisites'; '01'='01-identity-governance'; '04'='04-networking' }
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
$modMap = @{ '00'=$module00; '01'=$module01; '04'=$module04 }

function Build-Nav {
    param([string]$currentModule, [string]$currentFile)

    $groups = foreach ($mod in @('00','01','04')) {
        $prefix = if ($currentModule -eq $mod) { '' } else { "../../$($dirMap[$mod])/documents/" }
        $links = ($modMap[$mod] | ForEach-Object {
            $cls = if ($currentModule -eq $mod -and $_.file -eq $currentFile) { ' class="active"' } else { '' }
            "      <a href=`"$prefix$($_.file)`"$cls>$($_.title)</a>"
        }) -join "`n"

        @"
  <details class="nav-group">
    <summary>$($titleMap[$mod])</summary>
    <div class="nav-menu">
$links
    </div>
  </details>
"@
    }
    $groupsJoined = ($groups -join "`n")

    return @"
<nav class="site-nav">
  <span class="nav-brand">AZ-104 Learning Hub</span>
$groupsJoined
</nav>
"@
}

# ----- 1) Rebuild nav on the 13 existing pages (Module 01 + 04) -----
$existing = @()
foreach ($p in $module01) { $existing += @{module='01'; dir='01-identity-governance'; file=$p.file} }
foreach ($p in $module04) { $existing += @{module='04'; dir='04-networking'; file=$p.file} }

foreach ($t in $existing) {
    $path = Join-Path $root "$($t.dir)\documents\$($t.file)"
    if (-not (Test-Path $path)) { Write-Host "MISSING: $path" -ForegroundColor Red; continue }

    $content = Get-Content -Path $path -Raw -Encoding UTF8
    $newNav = Build-Nav -currentModule $t.module -currentFile $t.file

    $content = [regex]::Replace($content, '<nav class="site-nav">[\s\S]*?</nav>', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $newNav })

    Set-Content -Path $path -Value $content -NoNewline -Encoding UTF8
    Write-Host "Nav updated: $($t.dir)/documents/$($t.file)" -ForegroundColor Green
}

# ----- 2) Add nav + sidebar to the 4 new Module 00 pages -----
$sidebarCss = @'

/* ===== Page Sidebar (On This Page) ===== */
.layout{max-width:1400px;margin:auto;display:flex;align-items:flex-start}
.sidebar{
  flex:0 0 260px;
  position:sticky;top:88px;
  max-height:calc(100vh - 108px);
  overflow-y:auto;
  margin:28px 0 28px 28px;
  padding:20px 18px;
  background:#fff;border:1px solid var(--border);border-radius:14px;
  box-shadow:0 4px 16px rgba(21,29,99,.05);
}
.sidebar .toc-title{font-size:.72rem;font-weight:800;text-transform:uppercase;letter-spacing:.08em;color:var(--muted);margin:0 0 12px;padding:0 12px}
.sidebar a{display:block;padding:8px 12px;margin-bottom:2px;border-radius:8px;font-size:.88rem;font-weight:500;color:var(--text);border-bottom:none;border-left:3px solid transparent;line-height:1.4}
.sidebar a:hover{background:#eef2ff;color:#1e2a78}
.sidebar a.active{background:#eef2ff;color:#1735ad;font-weight:700;border-left-color:var(--primary)}
'@

$scrollspyJs = @'
<script>
(function(){
  var links = Array.prototype.slice.call(document.querySelectorAll('.sidebar a'));
  var sections = [];
  links.forEach(function(a){
    var el = document.getElementById(a.getAttribute('href').slice(1));
    if (el) sections.push({link:a, el:el});
  });
  if (!sections.length || !('IntersectionObserver' in window)) return;
  var observer = new IntersectionObserver(function(entries){
    entries.forEach(function(entry){
      if (!entry.isIntersecting) return;
      var match = sections.find(function(s){ return s.el === entry.target; });
      if (!match) return;
      links.forEach(function(a){ a.classList.remove('active'); });
      match.link.classList.add('active');
    });
  }, { rootMargin: '-100px 0px -70% 0px', threshold: 0 });
  sections.forEach(function(s){ observer.observe(s.el); });
})();
</script>
'@

function Get-Slug([string]$text) {
    $t = $text -replace '<[^>]+>', ''
    $t = $t -replace '&amp;', 'and'
    $t = $t -replace '&[a-zA-Z#0-9]+;', ''
    $t = $t.ToLower()
    $t = $t -replace '[^a-z0-9]+', '-'
    $t = $t.Trim('-')
    return $t
}

foreach ($p in $module00) {
    $path = Join-Path $root "00-prerequisites\documents\$($p.file)"
    if (-not (Test-Path $path)) { Write-Host "MISSING: $path" -ForegroundColor Red; continue }

    $content = Get-Content -Path $path -Raw -Encoding UTF8

    # a) Assign ids to each top-level section and build the TOC
    $toc = New-Object System.Collections.Generic.List[object]
    $usedSlugs = @{}
    $pattern = '<div class="section( full)?">\s*(<div>\s*)?<h2>(.*?)</h2>'
    $evaluator = {
        param($m)
        $title = $m.Groups[3].Value
        $slug = Get-Slug $title
        if ($usedSlugs.ContainsKey($slug)) {
            $i = 2
            while ($usedSlugs.ContainsKey("$slug-$i")) { $i++ }
            $slug = "$slug-$i"
        }
        $usedSlugs[$slug] = $true
        $toc.Add([PSCustomObject]@{slug=$slug; title=$title})
        $g1 = $m.Groups[1].Value
        $g2 = $m.Groups[2].Value
        return "<div class=`"section$g1`" id=`"$slug`">`n    $g2<h2>$title</h2>"
    }
    $content = [regex]::Replace($content, $pattern, [System.Text.RegularExpressions.MatchEvaluator]$evaluator)

    # b) Inject sidebar CSS before @media print (if not present)
    if ($content -notmatch '\.sidebar\{') {
        $content = $content -replace '(\r?\n@media print\{)', ("$sidebarCss" + '$1')
    }

    # c) Build sidebar markup and wrap .page in .layout
    $tocLinks = ($toc | ForEach-Object { "    <a href=`"#$($_.slug)`">$($_.title)</a>" }) -join "`n"
    $sidebarHtml = @"
<div class="layout">
  <aside class="sidebar">
    <div class="toc-title">On This Page</div>
$tocLinks
  </aside>
  <div class="page">
"@
    $content = $content -replace [regex]::Escape('<div class="page">'), $sidebarHtml

    # d) Close the extra .layout div and append scroll-spy script before </body>
    $content = $content -replace '(</div>\r?\n)(</body>)', ("`$1</div>`r`n" + $scrollspyJs + "`r`n`$2")

    # e) Insert the cross-nav after <body>
    $navHtml = Build-Nav -currentModule '00' -currentFile $p.file
    $content = $content -replace '(<body>\r?\n)', ("`$1" + $navHtml + "`r`n")

    Set-Content -Path $path -Value $content -NoNewline -Encoding UTF8
    Write-Host "Built: 00-prerequisites/documents/$($p.file) ($($toc.Count) sections)" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
