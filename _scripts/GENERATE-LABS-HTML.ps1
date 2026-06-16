# AZ-104 Lab HTML Generation Script
# Converts all lab markdown files to professional Azure-styled HTML
# Outputs to corresponding documents/ folder

param(
    [switch]$Verbose
)

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
    $html = [regex]::Replace($html, '\*\*([^*]+?)\*\*', '<strong>$1</strong>')
    $html = [regex]::Replace($html, '__([^_]+?)__', '<strong>$1</strong>')
    $html = [regex]::Replace($html, '\*([^*]+?)\*', '<em>$1</em>')
    $html = [regex]::Replace($html, '_([^_]+?)_', '<em>$1</em>')

    # Links
    $html = [regex]::Replace($html, '\[([^\]]+?)\]\(([^)]+?)\)', '<a href="$2">$1</a>')

    # Inline code
    $html = [regex]::Replace($html, '`([^`]+?)`', '<code>$1</code>')

    # Code blocks (```...```)
    $html = [regex]::Replace($html, '```([^`]*?)```', {
        param($match)
        $code = $match.Groups[1].Value.Trim()
        $escaped = [System.Web.HttpUtility]::HtmlEncode($code)
        return "<pre><code>$escaped</code></pre>"
    }, [System.Text.RegularExpressions.RegexOptions]::Singleline)

    # Blockquote (> ...)
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
:root{
  --bg:#f6f8fc;--card:#fff;--border:#d9e0ef;--text:#1f2937;--muted:#5b6678;
  --primary:#151d63;--panel:#00004C;--panel-shadow:rgba(0,0,76,.18);
}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);font-family:Inter,-apple-system,'Segoe UI',sans-serif;color:var(--text)}
.page{flex:1;min-width:0;padding:28px}

h1{font-size:3.2rem;line-height:1.15;margin:0;color:var(--primary);font-weight:800;letter-spacing:-1px}
.subtitle{font-size:1.4rem;font-weight:600;color:#2d3b77;margin-top:10px}

.badges{display:flex;gap:12px;margin:20px 0 26px;flex-wrap:wrap}
.badge{background:#eef2ff;border:1px solid #d8def7;color:#1e2a78;padding:10px 18px;border-radius:999px;font-weight:600;font-size:.95rem}

.section{display:grid;grid-template-columns:42% 58%;gap:28px;padding:26px 0;border-top:1px solid var(--border)}
.section.full{display:block;padding:26px 0;border-top:1px solid var(--border)}
.section:first-of-type, .section.full:first-of-type{border-top:none}

h2{font-size:2rem;margin:0 0 14px;color:var(--primary);font-weight:800}
h3{font-size:1.4rem;margin:22px 0 10px;color:var(--primary);font-weight:700}
h3:first-child{margin-top:0}
h4{font-size:1.1rem;margin:16px 0 8px;color:#2d3b77;font-weight:700}

p{font-size:1.05rem;line-height:1.65;margin:.5rem 0;color:var(--text)}

ul, ol{margin:.6rem 0;padding-left:1.4rem}
li{margin-bottom:6px;line-height:1.6;font-size:1.02rem}

a{color:#1e2a78;text-decoration:none;border-bottom:1px solid transparent;font-weight:600}
a:hover{border-bottom-color:#1e2a78}

strong{color:var(--primary);font-weight:700}

code{background:#eef2ff;color:#1735ad;padding:2px 6px;border-radius:6px;font:13px/1.4 'SF Mono',Consolas,'Courier New',monospace}
th code,td code{font-size:.92em}

.callout{margin-top:20px;background:#f3f7ff;border:1px solid #bfd0ff;border-radius:14px;padding:18px 22px}
.callout strong{color:#1735ad}
.callout p{margin:0}
.callout p + p{margin-top:8px}

.panel{
  background:var(--panel);
  color:#fff;border-radius:18px;padding:22px 26px;
  box-shadow:0 12px 28px var(--panel-shadow);
  font:15px/1.65 'SF Mono',Consolas,'Courier New',monospace;
  white-space:pre-wrap;
  overflow:auto;
}
.panel.small{font-size:13.5px;line-height:1.6}
.panel + .panel{margin-top:18px}

table{width:100%;border-collapse:collapse;background:#fff;border:1px solid var(--border);border-radius:12px;overflow:hidden;margin:14px 0}
th,td{padding:14px;border:1px solid var(--border);text-align:left;font-size:.98rem}
th{background:#eef2ff;color:var(--primary);font-weight:700}
tr:hover td{background:#fafbff}

.grid2{display:grid;grid-template-columns:1fr 1fr;gap:18px}
.grid3{display:grid;grid-template-columns:repeat(3,1fr);gap:18px}
.grid4{display:grid;grid-template-columns:repeat(4,1fr);gap:18px}

.mistake-card{display:grid;grid-template-columns:1fr 1fr;gap:18px;margin:14px 0 8px}
.mistake-card h4{margin-top:0}

.tip{margin-top:20px;background:#eef4ff;border:1px solid #c8d5ff;border-radius:12px;padding:16px 20px;font-size:1.02rem}
.tip strong{color:#1735ad}

hr.divider{border:none;height:0;margin:0}

.footer{margin-top:48px;padding-top:24px;border-top:1px solid var(--border);font-size:.9rem;color:var(--muted)}
.footer-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:24px}
.footer-item strong{display:block;color:var(--primary);margin-bottom:6px;font-size:.95rem}
.footer-meta{margin-top:24px;padding-top:16px;border-top:1px solid var(--border);text-align:center;font-size:.85rem}

@media (max-width:1000px){
  .section,.grid2,.grid3,.grid4,.mistake-card{grid-template-columns:1fr}
  h1{font-size:2.3rem}
  .page{padding:16px}
  .panel{font-size:13px}
  .sidebar{display:none}
  .layout{display:block}
}

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
.sidebar hr.sidebar-divider{border:none;border-top:1px solid var(--border);margin:14px 0}
.sidebar .toc-title.module-title{margin-top:0}
.sidebar details{margin-bottom:0}
.sidebar summary{cursor:pointer;list-style:none;padding:10px 12px;border-radius:8px;font-weight:600;font-size:.92rem;color:var(--primary);user-select:none;transition:background 0.2s}
.sidebar summary::-webkit-details-marker,.sidebar summary::marker{display:none}
.sidebar details[open]>summary{background:#eef2ff}
.sidebar summary:hover{background:#f0f4ff}
.sidebar details > div{padding:0 0 8px 12px}
.sidebar a{display:block;padding:8px 12px;margin-bottom:2px;border-radius:8px;font-size:.88rem;font-weight:500;color:var(--text);border-bottom:none;border-left:3px solid transparent;line-height:1.4;transition:all 0.15s}
.sidebar a:hover{background:#eef2ff;color:#1e2a78}
.sidebar a.active{background:#eef2ff;color:#1735ad;font-weight:700;border-left-color:var(--primary)}
/* Keyboard Navigation & Accessibility */
a:focus-visible,button:focus-visible,.sidebar a:focus-visible,.sidebar summary:focus-visible,.site-nav summary:focus-visible{outline:2px solid var(--primary);outline-offset:2px}
details:focus-visible > summary{outline:2px solid var(--primary);outline-offset:2px}

/* ===== PROFESSIONAL LAB TEMPLATE STYLES ===== */

/* Time Estimate Display */
.time-estimate-header{display:flex;align-items:center;gap:8px;margin:10px 0 20px;padding:12px 16px;background:#eef2ff;border-radius:8px;border-left:4px solid #1735ad;width:fit-content}
.time-estimate-header .clock-icon{font-size:1.3rem}
.time-estimate-header .time-text{font-weight:600;color:#1735ad;font-size:1.05rem}

/* Section Header with Time Estimate */
.section-header{margin:32px 0 24px 0;padding-bottom:16px;border-bottom:2px solid #d9e0ef;display:flex;justify-content:space-between;align-items:flex-start}
.section-header h2{margin:0;font-size:1.8rem}
.section-time{background:#e3f2fd;border:1px solid #90caf9;border-radius:8px;padding:8px 14px;font-size:0.95rem;font-weight:600;color:#1565c0;display:flex;align-items:center;gap:6px;white-space:nowrap}
.section-time .icon{font-size:1.1rem}

/* Task Box */
.task-box{margin:20px 0;padding:0;background:#fff;border:1px solid #d9e0ef;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(21,29,99,0.06)}
.task-header{display:flex;align-items:center;gap:12px;padding:16px;background:linear-gradient(135deg,#eef2ff 0%,#f5f8ff 100%);border-bottom:1px solid #d9e0ef}
.task-header .task-icon{font-size:1.5rem;color:#1735ad}
.task-header h3{margin:0;font-size:1.15rem;color:var(--primary);font-weight:700}
.task-content{padding:16px}

/* Step and Substep Styling */
.step{margin:16px 0;padding:12px 16px;border-left:4px solid #1735ad;background:#f9fafb;border-radius:0 6px 6px 0}
.step-number{display:inline-block;min-width:32px;height:32px;background:#1735ad;color:#fff;border-radius:50%;text-align:center;line-height:32px;font-weight:700;font-size:0.95rem;margin-right:10px}
.step-content{display:inline;line-height:1.6;color:var(--text)}
.step strong{color:var(--primary)}

.substep{margin:12px 0 12px 48px;padding:8px 12px;background:#fff;border-left:3px solid #c8d5ff;border-radius:0 4px 4px 0;color:var(--text);line-height:1.6}
.substep::before{content:'→ ';color:#1735ad;font-weight:700;margin-right:6px}

/* Callout Boxes */
.callout-box{margin:20px 0;padding:16px;border-radius:10px;border-left:4px solid;display:flex;gap:12px}
.callout-icon{font-size:1.4rem;flex-shrink:0;min-width:24px}
.callout-content{flex:1}
.callout-content h4{margin:0 0 6px 0;font-size:1.05rem}
.callout-content p{margin:0;line-height:1.6}

/* Callout Variants */
.callout-tip{background:#e3f2fd;border-color:#90caf9}
.callout-tip .callout-icon{color:#1976d2}
.callout-tip h4{color:#1565c0}

.callout-warning{background:#fff3e0;border-color:#ffb74d}
.callout-warning .callout-icon{color:#f57c00}
.callout-warning h4{color:#e65100}

.callout-important{background:#ffebee;border-color:#ef5350}
.callout-important .callout-icon{color:#d32f2f}
.callout-important h4{color:#c62828}

.callout-note{background:#f5f5f5;border-color:#bdbdbd}
.callout-note .callout-icon{color:#616161}
.callout-note h4{color:#424242}

/* Code Block */
.code-block{position:relative;margin:16px 0;background:#1e1e1e;border-radius:8px;overflow:hidden;border:1px solid #333;box-shadow:0 2px 8px rgba(0,0,0,0.3)}
.code-block pre{margin:0;padding:16px 40px 16px 16px;color:#e0e0e0;font-family:'SF Mono',Consolas,'Courier New',monospace;font-size:0.93rem;line-height:1.6;overflow-x:auto}
.code-copy-btn{position:absolute;top:10px;right:10px;padding:8px 14px;background:#2d2d2d;color:#a8e6ce;border:1px solid #444;border-radius:6px;cursor:pointer;font-size:0.85rem;font-weight:600;transition:all 0.2s;user-select:none}
.code-copy-btn:hover{background:#3a3a3a;color:#fff;border-color:#555}
.code-copy-btn.copied{background:#27ae60;color:#fff}

/* Syntax Highlighting in Code Blocks */
.code-block .keyword{color:#569cd6;font-weight:500}
.code-block .string{color:#ce9178}
.code-block .number{color:#b5cea8}
.code-block .comment{color:#6a9955}
.code-block .operator{color:#d4d4d4}
.code-block .function{color:#dcdcaa}
.code-block .property{color:#9cdcfe}

/* Success/Completion Box */
.success-box{margin:24px 0;padding:20px;background:#f1f8e9;border:1px solid #c5e1a5;border-radius:10px;border-left:4px solid #7cb342}
.success-box h4{color:#558b2f;margin-top:0;font-size:1.1rem}
.success-items{list-style:none;margin:12px 0;padding:0}
.success-item{padding:8px 0;line-height:1.6;color:var(--text)}
.success-item::before{content:'✓ ';color:#7cb342;font-weight:700;margin-right:8px;font-size:1.1rem}

/* Validation Checklist */
.validation-checklist{margin:24px 0;padding:20px;background:#fff;border:1px solid #d9e0ef;border-radius:10px}
.validation-checklist h4{margin-top:0;color:var(--primary);font-size:1.1rem}
.checklist-item{padding:10px 0;margin:8px 0;line-height:1.6}
.checklist-item input[type="checkbox"]{margin-right:10px;cursor:pointer;width:18px;height:18px}
.checklist-item label{cursor:pointer}

/* Spacing Utilities */
.mt-32{margin-top:32px}
.mb-24{margin-bottom:24px}
.mb-16{margin-bottom:16px}
.mb-8{margin-bottom:8px}

@media (max-width:1000px){
  .section-header{flex-direction:column;gap:12px}
  .section-time{width:100%}
}

@media print{
  .site-nav{display:none}
  body{background:#fff}
  .page{padding:0}
  .panel{box-shadow:none}
  .sidebar{display:none}
  .layout{display:block}
}
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
