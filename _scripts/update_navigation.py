#!/usr/bin/env python3
"""
Update navigation and sidebar structure for Module 00, 01, and 04 HTML files
"""

import re
import os
from pathlib import Path

base_dir = Path("/c/Users/nyeemzoarder/.claude/context/learning-hub/courses/az-104")

# Define modules and their files
modules = {
    "00-prerequisites": {
        "display_name": "Module 00 - Prerequisites",
        "concepts": ["01-cloud-computing-fundamentals", "02-networking-basics", "03-identity-and-access-fundamentals", "04-azure-portal-navigation"],
        "labs": ["lab00-azure-portal-navigation"]
    },
    "01-identity-governance": {
        "display_name": "Module 01 - Identity & Governance",
        "concepts": ["01-entra-id-overview", "02-rbac-fundamentals", "03-management-groups-and-azure-policy", "04-access-control-scenarios", "05-identity-best-practices"],
        "labs": ["lab01-entra-users-groups", "lab02-rbac-azure-policy", "lab03-management-groups-subscriptions"]
    },
    "04-networking": {
        "display_name": "Module 04 - Networking",
        "concepts": ["01-vnets-and-subnets", "02-network-security-groups", "03-routing-fundamentals", "04-vnet-peering", "05-vpn-and-expressroute", "06-hub-spoke-topology", "07-private-endpoints-service-endpoints", "08-network-security-advanced"],
        "labs": ["lab12-vnet-subnets", "lab13-nsg-asg", "lab14-vnet-peering-vpn", "lab15-load-balancer-app-gateway", "lab16-dns-name-resolution"]
    }
}

NEW_NAV = '''<nav class="site-nav">
  <a class="nav-brand" href="../../index.html">AZ-104 Learning Hub</a>
  <details class="nav-group">
    <summary>Module 00 - Prerequisites</summary>
    <div class="nav-menu">
      <a href="../../00-prerequisites/documents/module-home.html"{mod00_active}>Module 00 Home</a>
    </div>
  </details>
  <details class="nav-group">
    <summary>Module 01 - Identity &amp; Governance</summary>
    <div class="nav-menu">
      <a href="../../01-identity-governance/documents/module-home.html"{mod01_active}>Module 01 Home</a>
    </div>
  </details>
  <details class="nav-group">
    <summary>Module 04 - Networking</summary>
    <div class="nav-menu">
      <a href="../../04-networking/documents/module-home.html"{mod04_active}>Module 04 Home</a>
    </div>
  </details>
</nav>'''

SIDEBAR_CSS = '''.sidebar details{margin-bottom:0}
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
.sidebar hr.sidebar-divider{border:none;border-top:1px solid var(--border);margin:12px 0}'''

def extract_page_title(html_content, filename):
    """Extract a simple title from filename for breadcrumb"""
    # Extract from filename
    title = filename.replace(".html", "")
    title = title.replace("-", " ").title()
    return title

def get_module_for_file(filename):
    """Determine which module a file belongs to"""
    for module_dir, module_info in modules.items():
        all_files = module_info["concepts"] + module_info["labs"]
        for f in all_files:
            if filename.startswith(f):
                return module_dir
    return None

def update_navigation(content, current_module):
    """Update the site navigation"""
    # Create nav with active state for current module
    nav = NEW_NAV
    nav = nav.replace("{mod00_active}", ' class="active"' if current_module == "00-prerequisites" else "")
    nav = nav.replace("{mod01_active}", ' class="active"' if current_module == "01-identity-governance" else "")
    nav = nav.replace("{mod04_active}", ' class="active"' if current_module == "04-networking" else "")

    # Replace old nav
    pattern = r'<nav class="site-nav">.*?</nav>'
    content = re.sub(pattern, nav, content, flags=re.DOTALL)

    return content

def update_sidebar_css(content):
    """Update sidebar CSS to support collapsible sections"""
    # Check if already updated
    if ".sidebar details{" in content:
        return content

    # Find old sidebar CSS and replace
    pattern = r'\/\* ===== Page Sidebar \(On This Page\) ===== \*\/.*?\.sidebar a\.active\{[^}]*border-left-color:var\(--primary\)\}'

    new_css = '''/* ===== Page Sidebar (Collapsible) ===== */
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
''' + SIDEBAR_CSS

    content = re.sub(pattern, new_css, content, flags=re.DOTALL)

    return content

def update_sidebar_html(content, current_module, filename):
    """Update sidebar HTML to use collapsible sections"""
    module_info = modules[current_module]

    # Build concepts links
    concepts_html = ""
    for concept in module_info["concepts"]:
        concepts_html += f'        <a href="{concept}.html">{extract_page_title(None, concept)}</a>\n'

    # Build labs links
    labs_html = ""
    if module_info["labs"]:
        labs_section = '    <details>\n      <summary>▶ Labs</summary>\n      <div>\n'
        for lab in module_info["labs"]:
            labs_section += f'        <a href="{lab}.html">{extract_page_title(None, lab)}</a>\n'
        labs_section += '      </div>\n    </details>\n'
    else:
        labs_section = ""

    # Build "On This Page" section - extract from existing anchors
    page_anchors_html = '        <a href="#overview">Overview</a>\n'

    # New sidebar HTML
    new_sidebar = f'''  <aside class="sidebar">
    <details open>
      <summary>▶ {module_info["display_name"]}</summary>
      <div>
{concepts_html}      </div>
    </details>
{labs_section}    <details>
      <summary>▶ On This Page</summary>
      <div>
{page_anchors_html}      </div>
    </details>
  </aside>'''

    # Replace old sidebar
    pattern = r'  <aside class="sidebar">.*?</aside>'
    content = re.sub(pattern, new_sidebar, content, flags=re.DOTALL)

    return content

def process_file(filepath):
    """Process a single HTML file"""
    filename = Path(filepath).name
    current_module = get_module_for_file(filename)

    if not current_module:
        print(f"  Skipping: {filename} (module not found)")
        return

    print(f"  Processing: {filename}")

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Update navigation
    content = update_navigation(content, current_module)

    # Update sidebar CSS
    content = update_sidebar_css(content)

    # Only update sidebar HTML if it has the old structure
    if '.toc-title module-title' in content or 'div class="toc-title' in content:
        content = update_sidebar_html(content, current_module, filename)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

def main():
    """Main function"""
    for module_dir, module_info in modules.items():
        print(f"\nProcessing module: {module_dir}")
        docs_path = base_dir / module_dir / "documents"

        # Process all files
        all_files = module_info["concepts"] + module_info["labs"]
        for filename_base in all_files:
            filepath = docs_path / f"{filename_base}.html"
            if filepath.exists():
                process_file(filepath)
            else:
                print(f"  File not found: {filepath}")

if __name__ == "__main__":
    main()
    print("\nNavigation update complete!")
