# Professional Lab HTML Generation Script
# Converts lab markdown files to professional HTML with shared CSS framework
# Works with any course structure

param(
    [string]$CourseFolder = "courses/az-104",
    [switch]$Verbose
)

function Format-PowerShellCode {
    param([string]$code)
    $code = $code -replace '\b(New-MgUser|Get-MgUser|Set-MgUser|Remove-MgUser|New-AzResource|Get-AzResource)\b', '<span class="function">$1</span>'
    $code = $code -replace '"([^"]*)"', '<span class="string">"$1"</span>'
    $code = $code -replace "'([^']*)'", '<span class="string">''$1''</span>'
    $code = $code -replace '(#.*)', '<span class="comment">$1</span>'
    $code = $code -replace '\-(\w+)', '<span class="operator">-</span><span class="property">$1</span>'
    return $code
}

function Format-BashCode {
    param([string]$code)
    $code = $code -replace '"([^"]*)"', '<span class="string">"$1"</span>'
    $code = $code -replace "'([^']*)'", '<span class="string">''$1''</span>'
    $code = $code -replace '(#.*)', '<span class="comment">$1</span>'
    $code = $code -replace '\b(curl|wget|git|docker|az|npm|yarn)\b', '<span class="function">$1</span>'
    return $code
}

function Format-JsonCode {
    param([string]$code)
    $code = $code -replace '"([^"]*)":\s*', '<span class="property">"$1"</span>: '
    $code = $code -replace ':\s*"([^"]*)"', ': <span class="string">"$1"</span>'
    $code = $code -replace '(true|false|null)', '<span class="keyword">$1</span>'
    return $code
}

function Convert-MarkdownToHTML {
    param(
        [string]$MarkdownPath,
        [string]$OutputPath,
        [string]$ModuleName,
        [string]$ModuleDir,
        [string]$LabTitle
    )

    # Read markdown file
    $content = Get-Content -Path $MarkdownPath -Raw -Encoding UTF8

    # Debug: Check if markdown has code blocks
    $backtickCount = ([regex]::Matches($content, '```')).Count
    if ($Verbose -and $backtickCount -gt 0) { Write-Host "    Initial backtick markers in markdown: $backtickCount" }

    # Parse markdown to extract structure for TOC
    $lines = $content -split "`n"
    $sections = @()
    $currentSection = $null

    foreach ($line in $lines) {
        if ($line -match '^## (.+)$') {
            $sections += [PSCustomObject]@{
                Level = 2
                Title = $matches[1]
                Id = Convert-TitleToId $matches[1]
            }
        }
        elseif ($line -match '^### (.+)$') {
            $sections += [PSCustomObject]@{
                Level = 3
                Title = $matches[1]
                Id = Convert-TitleToId $matches[1]
            }
        }
        elseif ($line -match '^# (.+)$') {
            $currentSection = $matches[1]
        }
    }

    # Convert markdown to HTML
    $html = $content

    # Task Box Detection FIRST - Convert "### Task: Title" into task-box structure (before H3 conversion)
    $html = [regex]::Replace($html, '(?m)^### Task:(.+?)$', {
        param($match)
        $title = $match.Groups[1].Value.Trim()
        $id = Convert-TitleToId "task-$title"
        return "<div class='task-box'><div class='task-header'><span class='task-icon'>✓</span><h3 id=""$id"">$title</h3></div><div class='task-content'>"
    })

    # Headings (must be done in order from highest to lowest)
    $html = [regex]::Replace($html, '(?m)^# (.+?)$', '<h1>$1</h1>')
    # H2 and H3 with IDs require MatchEvaluator for dynamic ID generation
    $html = [regex]::Replace($html, '(?m)^## (.+?)$', {
        param($match)
        $title = $match.Groups[1].Value
        $id = Convert-TitleToId $title
        return "<h2 id=""$id"">$title</h2>"
    })
    $html = [regex]::Replace($html, '(?m)^### (.+?)$', {
        param($match)
        $title = $match.Groups[1].Value
        $id = Convert-TitleToId $title
        return "<h3 id=""$id"">$title</h3>"
    })
    $html = [regex]::Replace($html, '(?m)^#### (.+?)$', '<h4>$1</h4>')
    $html = [regex]::Replace($html, '(?m)^##### (.+?)$', '<h5>$1</h5>')

    # Bold and italic
    if ($Verbose) { Write-Host "    After headings: $(([regex]::Matches($html, '```')).Count) triple-backtick groups" }
    $html = [regex]::Replace($html, '\*\*([^*]+?)\*\*', '<strong>$1</strong>')
    $html = [regex]::Replace($html, '__([^_]+?)__', '<strong>$1</strong>')
    $html = [regex]::Replace($html, '\*([^*]+?)\*', '<em>$1</em>')
    $html = [regex]::Replace($html, '_([^_]+?)_', '<em>$1</em>')
    if ($Verbose) { Write-Host "    After bold/italic: $(([regex]::Matches($html, '```')).Count) triple-backtick groups" }

    # Code blocks (```language...```) with professional styling - MUST BE BEFORE inline code
    # Simplified pattern that handles any line ending
    $codeBlocksBefore = ([regex]::Matches($html, '```(\w*)[`\s\S]*?```', [System.Text.RegularExpressions.RegexOptions]::Singleline)).Count
    if ($Verbose) { Write-Host "  Code blocks detected: $codeBlocksBefore" }

    $html = [regex]::Replace($html, '```(\w*)[\r\n]+([\s\S]*?)[\r\n]+```', {
        param($match)
        $lang = $match.Groups[1].Value
        $code = $match.Groups[2].Value.Trim()
        $escaped = [System.Web.HttpUtility]::HtmlEncode($code)

        # Apply syntax highlighting for common keywords
        $highlighted = $escaped
        if ($lang -match 'powershell|ps1') {
            $highlighted = Format-PowerShellCode $escaped
        } elseif ($lang -match 'bash|shell|sh') {
            $highlighted = Format-BashCode $escaped
        } elseif ($lang -match 'json') {
            $highlighted = Format-JsonCode $escaped
        }

        return "<div class='code-block'><pre>$highlighted</pre></div>"
    }, [System.Text.RegularExpressions.RegexOptions]::Singleline)

    $codeBlocksAfter = ([regex]::Matches($html, "<div class='code-block'")).Count
    if ($Verbose) { Write-Host "  Code blocks generated: $codeBlocksAfter" }

    # Links
    $html = [regex]::Replace($html, '\[([^\]]+?)\]\(([^)]+?)\)', '<a href="$2">$1</a>')

    # Inline code
    $html = [regex]::Replace($html, '`([^`]+?)`', '<code>$1</code>')

    # Blockquote with callout type detection (Tip:, Warning:, Important:, Note:)
    $html = [regex]::Replace($html, '(?m)^> (\*\*)?((Tip|Warning|Important|Note))(\*\*)?:(.+?)$', {
        param($match)
        $type = $match.Groups[3].Value.ToLower()
        $content = $match.Groups[5].Value.Trim()
        $icons = @{'tip'='ℹ️'; 'warning'='⚠️'; 'important'='❗'; 'note'='📝'}
        $icon = $icons[$type] ?? 'ℹ️'
        return "<div class='callout-box callout-$type'><span class='callout-icon'>$icon</span><div class='callout-content'><h4>$type</h4><p>$content</p></div></div>"
    })

    # Detect time estimate format "⏱️ X minutes" or "⏱️ X-Y minutes" and convert to time badge
    $html = [regex]::Replace($html, '⏱️\s*(\d+(?:-\d+)?)\s*minutes?', {
        param($match)
        $time = $match.Groups[1].Value
        return "<span class='section-time'><span class='icon'>⏱️</span>$time min</span>"
    })

    # Fallback for regular blockquotes
    $html = [regex]::Replace($html, '(?m)^> (.+?)$', '<div class="callout"><p>$1</p></div>')

    # Lists (unordered) - Convert markdown list items to li tags
    $html = [regex]::Replace($html, '(?m)^- (.+?)$', '<li>$1</li>')
    # Wrap consecutive li tags in ul (don't nest)
    $html = [regex]::Replace($html, '(?m)(<li>.*?</li>(\s*<li>.*?</li>)*)', '<ul>$0</ul>')

    # Lists (ordered) - Convert markdown numbered items to li tags
    $html = [regex]::Replace($html, '(?m)^\d+\. (.+?)$', '<li>$1</li>')
    # Wrap consecutive li tags in ol (don't nest)
    $html = [regex]::Replace($html, '(?m)(<li>.*?</li>(\s*<li>.*?</li>)*)', '<ol>$0</ol>')

    # Horizontal rules
    $html = [regex]::Replace($html, '(?m)^---+$', '<hr class="divider">')

    # Tables (simple markdown table support)
    $html = Convert-MarkdownTablesToHTML $html

    # Checkboxes
    $html = [regex]::Replace($html, '\- \[( |x)\] ', '<li><input type="checkbox" $1" disabled> ')

    # Close open task-boxes before h2 headings
    $html = $html -replace '(<div class=''task-content''>.+?)(?=<h2)', '$1</div></div>'
    # Close open task-boxes before next task (h3 with task-box)
    $html = $html -replace '(<div class=''task-content''>.+?)(?=<div class=''task-box'')', '$1</div></div>'
    # Close remaining open task-boxes at end
    $html = $html -replace '(<div class=''task-content''>.+?)$', '$1</div></div>'

    # Paragraph wrapping (for remaining plain lines)
    $paragraphs = @()
    foreach ($line in ($html -split "`n")) {
        $line = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($line)) {
            $paragraphs += ''
        }
        elseif ($line -match '^<(h\d|ul|ol|pre|div|hr|table|blockquote)' -or $line -match '^<li>') {
            $paragraphs += $line
        }
        elseif ($line -ne '') {
            $paragraphs += "<p>$line</p>"
        }
    }
    $html = $paragraphs -join "`n"

    # Extract title for page
    $titleMatch = [regex]::Match($content, '^# (.+)$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
    $pageTitle = if ($titleMatch.Success) { $titleMatch.Groups[1].Value } else { $LabTitle }

    # Generate TOC (returns hashtable with ConceptLinks, LabLinks, PageLinks)
    $tocData = Generate-TableOfContents -Sections $sections -ModuleName $ModuleName -ModuleDir $moduleDir
    $conceptLinksHtml = $tocData.ConceptLinks
    $labLinksHtml = $tocData.LabLinks
    $onThisPageHtml = $tocData.PageLinks

    # Generate navigation
    $navHtml = Generate-Navigation -ModuleName $ModuleName

    # Generate full HTML document
    $generationDate = Get-Date -Format "MMMM dd, yyyy"
    $year = (Get-Date).Year

    $htmlDocument = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>$pageTitle - AZ-104 Labs</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<style>
/* Professional Lab Template - Embedded CSS for local file:// access */
:root{--bg:#f7f9fd;--card:#fff;--border:#e2e8f0;--text:#1a202c;--muted:#64748b;--primary:#1e3a8a;--panel:#0f172a;--panel-shadow:rgba(15,23,42,.12);--section-gap:48px;}
*{box-sizing:border-box}body{margin:0;background:var(--bg);font-family:Inter,-apple-system,'Segoe UI',sans-serif;color:var(--text);line-height:1.6}.page{flex:1;min-width:0;padding:48px;max-width:1100px;margin:0 auto}
h1{font-size:3.4rem;line-height:1.2;margin:0 0 12px 0;color:var(--primary);font-weight:800;letter-spacing:-0.5px}h2{font-size:2.2rem;margin:0 0 24px 0;color:var(--primary);font-weight:800;letter-spacing:-0.5px}h3{font-size:1.45rem;margin:32px 0 16px 0;color:var(--primary);font-weight:700;letter-spacing:-0.3px}h3:first-child{margin-top:0}h4{font-size:1.1rem;margin:20px 0 12px 0;color:#1e3a8a;font-weight:700}
p{font-size:1.05rem;line-height:1.7;margin:12px 0;color:var(--text)}ul,ol{margin:16px 0;padding-left:24px}li{margin-bottom:10px;line-height:1.7;font-size:1.03rem;color:var(--text)}
a{color:#1e40af;text-decoration:none;border-bottom:2px solid transparent;font-weight:600;transition:border-color 0.2s}a:hover{border-bottom-color:#1e40af}strong{color:var(--primary);font-weight:700}code{background:#f0f4ff;color:#1e40af;padding:4px 8px;border-radius:6px;font:13px/1.5 'SF Mono',Consolas,'Courier New',monospace;font-weight:500}
.task-box{margin:24px 0;padding:0;background:#fff;border:1px solid var(--border);border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(30,64,175,.06);transition:box-shadow 0.2s,border-color 0.2s}.task-box:hover{box-shadow:0 4px 12px rgba(30,64,175,.12);border-color:#c7d2fe}
.task-header{display:flex;align-items:center;gap:12px;padding:18px 20px;background:linear-gradient(135deg,#dbeafe 0%,#eff6ff 100%);border-bottom:1px solid var(--border)}.task-header .task-icon{font-size:1.4rem;color:#1e40af}.task-header h3{margin:0;font-size:1.2rem;color:var(--primary);font-weight:700}.task-content{padding:20px}
.code-block{position:relative;margin:24px 0;background:#0f172a;border-radius:10px;overflow:hidden;border:1px solid #1e293b;box-shadow:0 4px 12px rgba(15,23,42,.25)}.code-block pre{margin:0;padding:20px 48px 20px 20px;color:#e2e8f0;font-family:'SF Mono',Consolas,'Courier New',monospace;font-size:0.92rem;line-height:1.7;overflow-x:auto}
.code-copy-btn{position:absolute;top:12px;right:12px;padding:8px 14px;background:#1e293b;color:#60a5fa;border:1px solid #334155;border-radius:6px;cursor:pointer;font-size:0.85rem;font-weight:600;transition:all 0.2s;user-select:none;box-shadow:0 1px 3px rgba(0,0,0,.2)}.code-copy-btn:hover{background:#334155;color:#93c5fd;border-color:#475569}.code-block .keyword{color:#569cd6}.code-block .string{color:#ce9178}.code-block .comment{color:#6a9955}.code-block .operator{color:#d4d4d4}.code-block .function{color:#dcdcaa}.code-block .property{color:#9cdcfe}
.callout-box{margin:24px 0;padding:18px 20px;border-radius:10px;border-left:4px solid;display:flex;gap:14px;box-shadow:0 1px 3px rgba(0,0,0,.05)}.callout-icon{font-size:1.5rem;flex-shrink:0;min-width:28px;text-align:center}.callout-content{flex:1}.callout-content h4{margin:0 0 8px 0;font-size:1.08rem;font-weight:700}.callout-content p{margin:8px 0;line-height:1.7;font-size:1.02rem}.callout-content p:first-child{margin-top:0}
.callout-tip{background:#eff6ff;border-color:#3b82f6}.callout-tip .callout-icon{color:#1e40af}.callout-tip h4{color:#1e40af}.callout-warning{background:#fefce8;border-color:#eab308}.callout-warning .callout-icon{color:#ca8a04}.callout-warning h4{color:#92400e}.callout-important{background:#fee2e2;border-color:#ef4444}.callout-important .callout-icon{color:#dc2626}.callout-important h4{color:#991b1b}
.section-time{background:#dbeafe;border:1px solid #93c5fd;border-radius:8px;padding:10px 16px;font-size:0.95rem;font-weight:600;color:#1e40af;display:inline-flex;align-items:center;gap:6px;white-space:nowrap}.layout{max-width:1500px;margin:auto;display:flex;align-items:flex-start;gap:32px}.sidebar{flex:0 0 280px;position:sticky;top:88px;max-height:calc(100vh - 108px);overflow-y:auto;padding:24px;background:#fff;border:1px solid var(--border);border-radius:12px;box-shadow:0 2px 8px rgba(30,64,175,.06)}.sidebar summary{cursor:pointer;list-style:none;padding:10px 12px;border-radius:8px;font-weight:600;font-size:.93rem;color:var(--primary);user-select:none;transition:all 0.2s}.sidebar summary::-webkit-details-marker{display:none}.sidebar details[open]>summary{background:#dbeafe}.sidebar summary:hover{background:#eff6ff}.sidebar a{display:block;padding:9px 12px;margin-bottom:2px;border-radius:8px;font-size:.89rem;font-weight:500;color:var(--text);border-bottom:none;border-left:3px solid transparent;line-height:1.5;transition:all 0.15s;text-decoration:none;color:#1a202c}.sidebar a:hover{background:#eff6ff;color:var(--primary)}.site-nav{position:sticky;top:0;z-index:1000;background:var(--primary);color:#fff;display:flex;align-items:center;gap:16px;flex-wrap:wrap;padding:14px 32px;font-size:.93rem;box-shadow:0 4px 12px rgba(0,0,0,.1);font-family:Inter,-apple-system,'Segoe UI',sans-serif}.site-nav .nav-brand{font-weight:800;font-size:1.1rem;margin-right:auto;color:#fff;letter-spacing:-0.3px}.site-nav summary{cursor:pointer;list-style:none;padding:8px 16px;border-radius:8px;background:rgba(255,255,255,.12);font-weight:600;color:#fff;user-select:none;transition:background 0.2s}
</style>
</head>
<body>
$navHtml
<div class="layout">
  <aside class="sidebar" aria-label="Page navigation">
    <details open>
      <summary>▶ $ModuleName</summary>
      <div>
        $conceptLinksHtml
      </div>
    </details>
    <details>
      <summary>▶ Labs</summary>
      <div>
        $labLinksHtml
      </div>
    </details>
    <details>
      <summary>▶ On This Page</summary>
      <div>
        $onThisPageHtml
      </div>
    </details>
  </aside>
  <div class="page">
  $html
  </div>
</div>
<script>
/* Sidebar Active Link Tracking */
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

/* Code Block Copy Button Functionality */
document.addEventListener('DOMContentLoaded', function(){
  var codeBlocks = document.querySelectorAll('.code-block');
  codeBlocks.forEach(function(block){
    var pre = block.querySelector('pre');
    if (!pre) return;

    var btn = document.createElement('button');
    btn.className = 'code-copy-btn';
    btn.textContent = 'Copy';
    btn.type = 'button';
    btn.setAttribute('aria-label', 'Copy code to clipboard');

    btn.addEventListener('click', function(){
      var code = pre.textContent;
      navigator.clipboard.writeText(code).then(function(){
        var original = btn.textContent;
        btn.textContent = '✓ Copied!';
        btn.classList.add('copied');
        setTimeout(function(){
          btn.textContent = original;
          btn.classList.remove('copied');
        }, 2000);
      }).catch(function(){
        alert('Failed to copy code');
      });
    });

    block.appendChild(btn);
  });
});
</script>
</body>
</html>
"@

    return $htmlDocument
}

function Convert-TitleToId {
    param([string]$Title)
    return $Title.ToLower() -replace '[^\w\s-]', '' -replace '\s+', '-'
}

function Generate-TableOfContents {
    param(
        [PSCustomObject[]]$Sections,
        [string]$ModuleName,
        [string]$ModuleDir = ""
    )

    # Build concept links
    $conceptLinks = Get-ConceptLinks $ModuleDir
    $conceptHtml = if ($conceptLinks.Count -gt 0) { $conceptLinks -join "`n" } else { "" }

    # Build lab links
    $labLinks = Get-LabLinks $ModuleDir
    $labHtml = if ($labLinks.Count -gt 0) { $labLinks -join "`n" } else { "" }

    # Build on-this-page links (h2 sections)
    $pageLinks = @()
    foreach ($section in $Sections | Where-Object { $_.Level -eq 2 }) {
        $pageLinks += "<a href=`"#$($section.Id)`">$($section.Title)</a>"
    }
    $pageHtml = $pageLinks -join "`n"

    return @{
        ConceptLinks = $conceptHtml
        LabLinks = $labHtml
        PageLinks = $pageHtml
    }
}

function Get-ConceptLinks {
    param([string]$ModuleDir)

    $links = @()

    # Map module directories to concept links
    $conceptMap = @{
        "00-prerequisites" = @(
            '<a href="01-cloud-computing-fundamentals.html">01 - Cloud Computing Fundamentals</a>',
            '<a href="02-networking-basics.html">02 - Networking Basics</a>',
            '<a href="03-identity-and-access-fundamentals.html">03 - Identity &amp; Access Fundamentals</a>',
            '<a href="04-azure-portal-navigation.html">04 - Azure Portal Navigation</a>'
        )
        "01-identity-governance" = @(
            '<a href="01-entra-id-overview.html">01 - Entra ID Overview</a>',
            '<a href="02-rbac-fundamentals.html">02 - RBAC Fundamentals</a>',
            '<a href="03-management-groups-and-azure-policy.html">03 - Management Groups &amp; Azure Policy</a>',
            '<a href="04-access-control-scenarios.html">04 - Access Control Scenarios</a>',
            '<a href="05-identity-best-practices.html">05 - Identity Best Practices</a>'
        )
        "02-storage" = @(
            '<a href="01-storage-redundancy-options.html">01 - Storage Redundancy Options</a>'
        )
        "03-compute" = @(
            '<a href="01-compute-options-comparison.html">01 - Compute Options Comparison</a>'
        )
        "04-networking" = @(
            '<a href="01-vnets-and-subnets.html">01 - VNets &amp; Subnets</a>',
            '<a href="02-network-security-groups.html">02 - Network Security Groups</a>',
            '<a href="03-routing-fundamentals.html">03 - Routing Fundamentals</a>',
            '<a href="04-vnet-peering.html">04 - VNet Peering</a>',
            '<a href="05-vpn-and-expressroute.html">05 - VPN &amp; ExpressRoute</a>',
            '<a href="06-hub-spoke-topology.html">06 - Hub-Spoke Topology</a>',
            '<a href="07-private-endpoints-service-endpoints.html">07 - Private Endpoints &amp; Service Endpoints</a>',
            '<a href="08-network-security-advanced.html">08 - Network Security Advanced</a>'
        )
        "05-monitor-maintain" = @(
            '<a href="01-monitoring-data-flow.html">01 - Monitoring Data Flow</a>'
        )
    }

    if ($conceptMap.ContainsKey($ModuleDir)) {
        $links = $conceptMap[$ModuleDir]
    }

    return $links
}

function Get-LabLinks {
    param([string]$ModuleDir)

    $links = @()

    # Map module directories to lab links
    $labMap = @{
        "00-prerequisites" = @(
            '<a href="lab00-azure-portal-navigation.html">Lab 00 - Portal Navigation</a>'
        )
        "01-identity-governance" = @(
            '<a href="lab01-entra-users-groups.html">Lab 01 - Entra Users &amp; Groups</a>',
            '<a href="lab02-rbac-azure-policy.html">Lab 02 - RBAC &amp; Azure Policy</a>',
            '<a href="lab03-management-groups-subscriptions.html">Lab 03 - Management Groups</a>'
        )
        "02-storage" = @(
            '<a href="lab04-storage-accounts.html">Lab 04 - Storage Accounts</a>',
            '<a href="lab05-blob-security-lifecycle.html">Lab 05 - Blob Security &amp; Lifecycle</a>',
            '<a href="lab06-azure-files-file-sync.html">Lab 06 - Azure Files &amp; File Sync</a>'
        )
        "03-compute" = @(
            '<a href="lab07-arm-bicep-templates.html">Lab 07 - ARM &amp; Bicep Templates</a>',
            '<a href="lab08-virtual-machines.html">Lab 08 - Virtual Machines</a>',
            '<a href="lab09-vm-availability-scaling.html">Lab 09 - VM Availability &amp; Scaling</a>',
            '<a href="lab10-containers-aci-acr.html">Lab 10 - Containers, ACI &amp; ACR</a>',
            '<a href="lab11-app-service.html">Lab 11 - App Service</a>'
        )
        "04-networking" = @(
            '<a href="lab12-vnet-subnets.html">Lab 12 - VNet &amp; Subnets</a>',
            '<a href="lab13-nsg-asg.html">Lab 13 - NSG &amp; ASG</a>',
            '<a href="lab14-vnet-peering-vpn.html">Lab 14 - VNet Peering &amp; VPN</a>',
            '<a href="lab15-load-balancer-app-gateway.html">Lab 15 - Load Balancer &amp; App Gateway</a>',
            '<a href="lab16-dns-name-resolution.html">Lab 16 - DNS &amp; Name Resolution</a>'
        )
        "05-monitor-maintain" = @(
            '<a href="lab17-azure-monitor-alerts.html">Lab 17 - Azure Monitor &amp; Alerts</a>',
            '<a href="lab18-backup-recovery.html">Lab 18 - Backup &amp; Recovery</a>',
            '<a href="lab19-network-monitoring.html">Lab 19 - Network Monitoring</a>'
        )
    }

    if ($labMap.ContainsKey($ModuleDir)) {
        $links = $labMap[$ModuleDir]
    }

    return $links
}

function Generate-Navigation {
    param([string]$ModuleName, [string]$ModuleDir = "")

    $nav = @"
<nav class="site-nav" aria-label="Main site navigation">
  <a class="nav-brand" href="../../index.html">AZ-104 Learning Hub</a>
  <details class="nav-group" aria-label="Learning module selector">
    <summary>Learning Module</summary>
    <div class="nav-menu">
      <a href="../../00-prerequisites/documents/module-home.html"$(if($ModuleDir -eq "00-prerequisites") { " class=""active""" })>00 - Prerequisites</a>
      <a href="../../01-identity-governance/documents/module-home.html"$(if($ModuleDir -eq "01-identity-governance") { " class=""active""" })>01 - Identity &amp; Governance</a>
      <a href="../../02-storage/documents/module-home.html"$(if($ModuleDir -eq "02-storage") { " class=""active""" })>02 - Storage</a>
      <a href="../../03-compute/documents/module-home.html"$(if($ModuleDir -eq "03-compute") { " class=""active""" })>03 - Compute</a>
      <a href="../../04-networking/documents/module-home.html"$(if($ModuleDir -eq "04-networking") { " class=""active""" })>04 - Networking</a>
      <a href="../../05-monitor-maintain/documents/module-home.html"$(if($ModuleDir -eq "05-monitor-maintain") { " class=""active""" })>05 - Monitor &amp; Maintain</a>
    </div>
  </details>
</nav>
"@

    return $nav
}

function Convert-MarkdownTablesToHTML {
    param([string]$Html)

    # Simple markdown table detection and conversion
    $lines = $Html -split "`n"
    $result = @()
    $inTable = $false
    $tableLines = @()

    foreach ($line in $lines) {
        if ($line -match '^\|.*\|$') {
            if (-not $inTable) {
                $inTable = $true
                $tableLines = @()
            }
            $tableLines += $line
        }
        else {
            if ($inTable) {
                # Convert accumulated table lines
                if ($tableLines.Count -ge 2) {
                    $result += Convert-TableLinesToHtml $tableLines
                }
                $inTable = $false
                $tableLines = @()
            }
            $result += $line
        }
    }

    return $result -join "`n"
}

function Convert-TableLinesToHtml {
    param([string[]]$TableLines)

    if ($TableLines.Count -lt 2) { return $TableLines }

    $html = "<table>`n"

    # Header row
    $headerCells = $TableLines[0] -split '\|' | Where-Object { $_ -match '\S' }
    $html += "<tr>`n"
    foreach ($cell in $headerCells) {
        $html += "  <th>$($cell.Trim())</th>`n"
    }
    $html += "</tr>`n"

    # Skip separator row (index 1)
    # Data rows (starting from index 2)
    for ($i = 2; $i -lt $TableLines.Count; $i++) {
        $cells = $TableLines[$i] -split '\|' | Where-Object { $_ -match '\S' }
        if ($cells.Count -gt 0) {
            $html += "<tr>`n"
            foreach ($cell in $cells) {
                $html += "  <td>$($cell.Trim())</td>`n"
            }
            $html += "</tr>`n"
        }
    }

    $html += "</table>`n"
    return $html
}

# Main script execution
Write-Host "Starting Lab HTML Generation..." -ForegroundColor Cyan
Write-Host ""

# Find all lab markdown files
$labDir = Join-Path (Get-Item $PSScriptRoot).Parent.FullName "courses/az-104"
$labFiles = Get-ChildItem -Path $labDir -Filter "lab*.md" -Recurse

if ($Verbose) {
    Write-Host "Found $($labFiles.Count) lab files" -ForegroundColor Yellow
    $labFiles | ForEach-Object { Write-Host "  - $_" }
    Write-Host ""
}

$generatedCount = 0
$errorCount = 0

foreach ($labFile in $labFiles) {
    try {
        # Determine module info from path
        $relPath = $labFile.FullName -replace [regex]::Escape((Get-Item $labDir).FullName), ''
        $pathParts = $relPath -split '[\\/]' | Where-Object { $_ }

        $moduleDir = $pathParts[0]  # e.g., "00-prerequisites"
        $labName = $labFile.BaseName  # e.g., "lab00-azure-portal-navigation"

        # Skip professionally designed labs (Lab 01-06, 07, 12) - they use custom professional template
        # These labs have manual professional formatting that should not be regenerated
        if ($labName -match "^lab0[1-6]-|^lab07-|^lab12-") {
            if ($Verbose) {
                Write-Host "⏭️  Skipping $labName (professional design template)" -ForegroundColor Green
            }
            continue
        }

        # Get module name for display
        $moduleName = switch ($moduleDir) {
            "00-prerequisites" { "Module 00 - Prerequisites" }
            "01-identity-governance" { "Module 01 - Identity &amp; Governance" }
            "02-storage" { "Module 02 - Storage" }
            "03-compute" { "Module 03 - Compute" }
            "04-networking" { "Module 04 - Networking" }
            "05-monitor-maintain" { "Module 05 - Monitor &amp; Maintain" }
            default { "AZ-104" }
        }

        # Ensure documents directory exists
        $documentsDir = Join-Path $labDir $moduleDir "documents"
        if (-not (Test-Path $documentsDir)) {
            New-Item -ItemType Directory -Path $documentsDir -Force | Out-Null
        }

        # Output path
        $outputFile = Join-Path $documentsDir "$labName.html"

        # Read lab title from markdown
        $content = Get-Content $labFile.FullName -Raw
        $titleMatch = [regex]::Match($content, '^# (.+?)(?:\n|$)', [System.Text.RegularExpressions.RegexOptions]::Multiline)
        $labTitle = if ($titleMatch.Success) { $titleMatch.Groups[1].Value } else { "Lab - $labName" }

        # Generate HTML
        $html = Convert-MarkdownToHTML -MarkdownPath $labFile.FullName -OutputPath $outputFile -ModuleName $moduleName -ModuleDir $moduleDir -LabTitle $labTitle

        # Write HTML file
        Set-Content -Path $outputFile -Value $html -Encoding UTF8

        Write-Host "Generated: $($labFile.Name) -> $(Split-Path $outputFile -Leaf)" -ForegroundColor Green
        $generatedCount++
    }
    catch {
        Write-Host "Error processing $($labFile.Name): $($_.Exception.Message)" -ForegroundColor Red
        $errorCount++
    }
}

Write-Host ""
Write-Host "Generation Complete" -ForegroundColor Cyan
Write-Host "  Generated: $generatedCount files"
if ($errorCount -gt 0) {
    Write-Host "  Errors: $errorCount files" -ForegroundColor Red
}
Write-Host ""
