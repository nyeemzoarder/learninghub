# Project Structure

Complete guide to the Learning Hub repository organization and how everything fits together.

---

## Directory Layout

```
learninghub/
│
├── courses/                          ← All course content
│   ├── az-104/                       ← Existing Azure Administrator course
│   │   ├── 00-prerequisites/
│   │   │   ├── concepts/             ← Theory pages (markdown)
│   │   │   ├── labs/                 ← Lab exercises (markdown)
│   │   │   └── documents/            ← Generated HTML files
│   │   ├── 01-identity-governance/
│   │   ├── 02-storage/
│   │   ├── ... [more modules]
│   │   └── README.md                 ← Course overview
│   │
│   ├── az-900/                       ← [NEW] Azure Fundamentals
│   │   └── [same structure]
│   │
│   └── dp-100/                       ← [FUTURE] Data Science
│       └── [same structure]
│
├── _styles/                          ← Shared design system
│   └── lab-template.css              ← Professional lab styling (14KB)
│                                        → ALL labs use this file
│                                        → Edit once, affects entire site
│
├── _templates/                       ← Templates for creating content
│   └── COURSE-LAB-TEMPLATE.md        ← Markdown template for labs
│                                        → Copy this when creating new labs
│
├── _scripts/                         ← Automation scripts
│   ├── GENERATE-LABS-HTML.ps1        ← Converts markdown → HTML
│   │                                    → Runs automatically
│   │                                    → Course-agnostic
│   │
│   ├── SETUP-NEW-COURSE.ps1          ← Creates new course structure
│   │                                    → One-command setup
│   │                                    → Creates folders, README, templates
│   │
│   └── [other scripts]
│
├── COURSE-CREATION-GUIDE.md          ← How to add new courses
├── PROJECT-STRUCTURE.md              ← This file
└── README.md                         ← Site overview
```

---

## Key Files Explained

### `_styles/lab-template.css`
**The single source of truth for design**

- 14KB professional CSS framework
- Used by ALL labs across ALL courses
- Contains:
  - Typography (headings, body text)
  - Component styles (task boxes, callouts, code blocks)
  - Color system (primary blue, warning yellow, error red)
  - Responsive grid
  - Print styles

**To change design:** Edit this one file. Every lab updates immediately.

### `_templates/COURSE-LAB-TEMPLATE.md`
**Starting point for every new lab**

- Pre-formatted markdown structure
- Shows best practices for:
  - Headings and sections
  - Code blocks with language tags
  - Tips/warnings/callouts
  - Checklists
  - Real-world scenarios

**To create a lab:** Copy this, fill in your content.

### `_scripts/GENERATE-LABS-HTML.ps1`
**Converts markdown to professional HTML**

- Reads all `.md` files in course `labs/` folders
- Generates HTML with:
  - Professional styling (links to `_styles/lab-template.css`)
  - Sidebar navigation ("On This Page")
  - Copy buttons on code blocks
  - Table of contents with active link tracking
  - Cross-module navigation bar

**To regenerate:** `./_scripts/GENERATE-LABS-HTML.ps1 -CourseFolder "courses/az-104"`

### `_scripts/SETUP-NEW-COURSE.ps1`
**One-command course initialization**

Creates:
- Folder structure
- Course README
- Initial lab templates
- Generates HTML

**Usage:** `./_scripts/SETUP-NEW-COURSE.ps1 -CourseCode "az-900" -CourseName "Azure Fundamentals"`

---

## Content Hierarchy

```
Markdown Files (you edit these)
        ↓
  GENERATE-LABS-HTML.ps1
        ↓
HTML Files (deployed to site)
        ↓
    Links to _styles/lab-template.css
        ↓
Professional design appears in browser
```

### Example Flow

1. **You create:** `courses/az-900/01-basics/labs/lab01-intro.md`
2. **Script generates:** `courses/az-900/01-basics/documents/lab01-intro.html`
3. **HTML includes:** `<link rel="stylesheet" href="../../_styles/lab-template.css">`
4. **Browser applies:** Professional styling from `_styles/lab-template.css`
5. **Result:** Beautiful lab page with copy buttons, navigation, tables, etc.

---

## File Types

### `.md` (Markdown)
- **Location:** `courses/[code]/[module]/{concepts,labs}/`
- **Purpose:** Author content here
- **Format:** Plain text with markdown syntax
- **What you do:** Write, edit, version control
- **What gets generated:** HTML versions in `documents/` folder

### `.html` (HTML)
- **Location:** `courses/[code]/[module]/documents/`
- **Purpose:** Web pages served to users
- **Auto-generated:** By `GENERATE-LABS-HTML.ps1`
- **Don't edit directly:** Always edit `.md` source, then regenerate
- **Refresh cycle:** Run script → Commit → Push → Site updates

### `.css` (Stylesheet)
- **Location:** `_styles/lab-template.css`
- **Purpose:** All visual styling
- **Shared:** Used by every lab in every course
- **Edit:** When you want to change design globally
- **Impact:** Affects all 100+ pages instantly

### `.ps1` (PowerShell)
- **Location:** `_scripts/`
- **Purpose:** Automation
- **Run:** From project root: `./_scripts/[script-name].ps1`
- **Don't edit:** Unless you're a developer extending functionality

---

## Workflow: Creating a New Course

### Quick Path (15 minutes)

```powershell
# 1. Run setup script
./_scripts/SETUP-NEW-COURSE.ps1 -CourseCode "az-900" -CourseName "Azure Fundamentals"

# 2. Edit markdown files
notepad courses/az-900/01-basics/labs/lab01-your-topic.md

# 3. Regenerate HTML
./_scripts/GENERATE-LABS-HTML.ps1 -CourseFolder "courses/az-900"

# 4. Test in browser
start courses/az-900/01-basics/documents/lab01-your-topic.html

# 5. Commit and push
git add -A
git commit -m "Add AZ-900 course"
git push origin main
```

Done! Course is live with professional design.

---

## Design System Variables

Edit `_styles/lab-template.css` `:root` section to change:

```css
--bg:#f7f9fd;              /* Page background */
--card:#fff;               /* Card backgrounds */
--border:#e2e8f0;          /* Border color */
--text:#1a202c;            /* Main text */
--muted:#64748b;           /* Secondary text */
--primary:#1e3a8a;         /* Primary blue */
--panel:#0f172a;           /* Code block background */
```

Change one variable → Entire site updates.

---

## Common File Sizes

```
_styles/lab-template.css           ~14 KB   (shared by all labs)
Single lab HTML (generated)        ~30 KB   (markdown source ~10 KB)
Full AZ-104 course (20 labs)       ~600 KB  total
```

---

## Version Control

### What to commit:
- ✅ `.md` files (content)
- ✅ Updated `.ps1` scripts
- ✅ `_styles/lab-template.css` changes
- ✅ `.md` templates

### What gets auto-generated (commit after first time, then update):
- ✅ `.html` files (for first-time course setup)
- ✅ `documents/` folder

### What to ignore (usually):
- ❌ Node modules, dependencies
- ❌ Build artifacts
- ❌ IDE settings (if using .gitignore)

---

## Deployment

### Local Testing
1. Generate HTML: `./_scripts/GENERATE-LABS-HTML.ps1`
2. Open `.html` file in browser
3. Test layout, navigation, copy buttons

### GitHub Push
```powershell
git add -A
git commit -m "Course description"
git push origin main
```

### Live Site
- GitHub Actions automatically deploys to Azure Static Web Apps
- Takes ~2-5 minutes after push
- Live at: `https://learninghub.yourdomain.com/`

---

## Maintenance

### Regular Tasks

**Add a lab:**
1. Create `.md` in `courses/[code]/[module]/labs/`
2. Run `GENERATE-LABS-HTML.ps1`
3. Commit and push

**Update course:** Edit `.md` → Regenerate → Commit → Push

**Change design:** Edit `_styles/lab-template.css` → Commit → Push
(No regeneration needed)

**Add new course:** Run `SETUP-NEW-COURSE.ps1` → Add content → Commit → Push

---

## Scalability

Current state:
- ✅ 1 course (AZ-104, 20 labs)
- ✅ Professional design system in place
- ✅ Automation scripts ready

Ready to scale to:
- 5+ courses (100+ labs)
- Multiple contributors
- Different certification paths
- Localized content

How it scales:
- New course? Copy structure, use same scripts
- Design change? Edit one CSS file
- New feature? Update scripts once, affects all

---

## Next Steps

See `COURSE-CREATION-GUIDE.md` for detailed workflows.

For quick reference:
- **Create course:** `./_scripts/SETUP-NEW-COURSE.ps1`
- **Create lab:** Use `_templates/COURSE-LAB-TEMPLATE.md`
- **Generate HTML:** `./_scripts/GENERATE-LABS-HTML.ps1`
- **Change design:** Edit `_styles/lab-template.css`

Questions? Check COURSE-CREATION-GUIDE.md or existing course structure.
