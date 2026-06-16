# ============================================================
# Azure AZ-104 Learning Hub — Left-Hand "On This Page" Sidebar
# Adds a sticky table-of-contents sidebar (with scroll-spy
# active-link highlighting) to every HTML page, linking to
# each top-level (h2) section on that page.
# ============================================================

$root = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..\courses\az-104"
$root = Resolve-Path $root

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

$targets = @(
    @{dir='01-identity-governance'; file='01-entra-id-overview.html'},
    @{dir='01-identity-governance'; file='02-rbac-fundamentals.html'},
    @{dir='01-identity-governance'; file='03-management-groups-and-azure-policy.html'},
    @{dir='01-identity-governance'; file='04-access-control-scenarios.html'},
    @{dir='01-identity-governance'; file='05-identity-best-practices.html'},
    @{dir='04-networking'; file='06-hub-spoke-topology.html'},
    @{dir='04-networking'; file='01-vnets-and-subnets.html'},
    @{dir='04-networking'; file='02-network-security-groups.html'},
    @{dir='04-networking'; file='03-routing-fundamentals.html'},
    @{dir='04-networking'; file='04-vnet-peering.html'},
    @{dir='04-networking'; file='05-vpn-and-expressroute.html'},
    @{dir='04-networking'; file='07-private-endpoints-service-endpoints.html'},
    @{dir='04-networking'; file='08-network-security-advanced.html'}
)

foreach ($t in $targets) {
    $path = Join-Path $root "$($t.dir)\documents\$($t.file)"
    if (-not (Test-Path $path)) {
        Write-Host "MISSING: $path" -ForegroundColor Red
        continue
    }

    $content = Get-Content -Path $path -Raw -Encoding UTF8

    if ($content -match '<aside class="sidebar">') {
        Write-Host "Already has sidebar: $($t.file)" -ForegroundColor Yellow
        continue
    }

    # 1) Find each top-level section's <h2> and assign it an id, building the TOC list
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

    if ($toc.Count -eq 0) {
        Write-Host "WARNING: no sections found in $($t.file)" -ForegroundColor Red
        continue
    }

    # 2) Inject sidebar CSS before @media print
    if ($content -notmatch '\.sidebar\{') {
        $content = $content -replace '(\r?\n@media print\{)', ("$sidebarCss" + '$1')
    }

    # 3) Re-purpose .page rule for flex layout
    $content = $content -replace [regex]::Escape('.page{max-width:1400px;margin:auto;padding:28px}'), '.page{flex:1;min-width:0;padding:28px}'

    # 4) Hide sidebar / collapse layout on narrow screens and print
    $content = $content -replace '(\.panel\{font-size:13px\}\r?\n)\}', "`$1  .sidebar{display:none}`r`n  .layout{display:block}`r`n}"
    $content = $content -replace '(\.panel\{box-shadow:none\}\r?\n)\}', "`$1  .sidebar{display:none}`r`n  .layout{display:block}`r`n}"

    # 5) Build the sidebar markup
    $tocLinks = ($toc | ForEach-Object { "    <a href=`"#$($_.slug)`">$($_.title)</a>" }) -join "`n"
    $sidebarHtml = @"
<div class="layout">
  <aside class="sidebar">
    <div class="toc-title">On This Page</div>
$tocLinks
  </aside>
  <div class="page">
"@

    # 6) Replace the opening <div class="page"> with <div class="layout"><aside>...</aside><div class="page">
    $content = $content -replace [regex]::Escape('<div class="page">'), $sidebarHtml

    # 7) Close the extra .layout div and append scroll-spy script before </body>
    $content = $content -replace '(</div>\r?\n)(</body>)', ("`$1</div>`r`n" + $scrollspyJs + "`r`n`$2")

    Set-Content -Path $path -Value $content -NoNewline -Encoding UTF8
    Write-Host "Updated: $($t.dir)/documents/$($t.file) ($($toc.Count) sections)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done." -ForegroundColor Cyan
