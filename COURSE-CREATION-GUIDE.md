# Course Creation Guide

This guide explains how to create new courses using the professional lab template framework. The system is designed for scalability—add new courses quickly while maintaining consistent design.

---

## Quick Start (5 minutes)

```powershell
# 1. Create course folder structure
mkdir courses/az-900/00-module-one/concepts
mkdir courses/az-900/00-module-one/documents
mkdir courses/az-900/00-module-one/labs

# 2. Copy markdown lab templates
cp _templates/COURSE-LAB-TEMPLATE.md courses/az-900/00-module-one/labs/lab01-topic.md

# 3. Generate HTML from markdown
./_scripts/GENERATE-LABS-HTML.ps1 -CourseFolder "courses/az-900"

# 4. Deploy to GitHub
git add -A && git commit -m "Add AZ-900 course" && git push
```

Done! All labs automatically get professional design + copy buttons + sidebar navigation.

---

## Detailed Workflow

### 1. Plan Your Course Structure

```
courses/[course-code]/
├── 00-module-name/
│   ├── concepts/          ← Theory pages
│   │   ├── 01-topic.md
│   │   ├── 02-topic.md
│   │   └── 03-topic.md
│   ├── labs/              ← Hands-on labs
│   │   ├── lab00-intro.md
│   │   ├── lab01-task.md
│   │   └── lab02-task.md
│   └── documents/         ← Generated HTML (auto-created)
│       └── *.html
├── 01-module-name/
│   └── ...
└── README.md              ← Course overview
```

**Module Naming Convention:**
- `00-foundations` (prerequisites)
- `01-core-concepts` (main topics)
- `02-implementation` (hands-on skills)
- `03-advanced` (expert topics)

### 2. Write Markdown Content

**Use the template:** `_templates/COURSE-LAB-TEMPLATE.md`

Key formatting rules:
- Use `# ` for page title (required)
- Use `## ` for main sections
- Use `### ` for subsections
- Code blocks auto-highlight: ` ```powershell `, ` ```bash `
- Blockquotes `> ` become callout boxes
- Lists become interactive checkboxes

Example:
```markdown
# Lab 01 – Basic Concepts

## Real-Life Scenario

Company XYZ needs...

## Objectives

- Objective 1
- Objective 2

## Part 1 – First Task

Instructions here.

> **Tip:** Important hint
```

### 3. Generate HTML

The PowerShell script converts all markdown to professional HTML automatically:

```powershell
# Generate labs for a specific course
./_scripts/GENERATE-LABS-HTML.ps1 -CourseFolder "courses/az-900"

# This creates:
# - Sidebar navigation with "On This Page" links
# - Copy buttons on all code blocks
# - Professional styling (from shared _styles/lab-template.css)
# - Cross-module navigation
# - Mobile-responsive layout
```

**What the script does:**
1. Finds all `.md` files in `courses/[course]/*/labs/`
2. Converts markdown to semantic HTML
3. Injects professional CSS link: `<link rel="stylesheet" href="../../_styles/lab-template.css">`
4. Generates table of contents with active link tracking
5. Saves to `[path]/documents/` folder

### 4. Test Locally

Open the generated HTML in your browser:
```
courses/[course-code]/[module]/documents/lab01-topic.html
```

Check:
- [ ] Layout looks professional
- [ ] Code blocks have copy buttons
- [ ] Sidebar navigation works
- [ ] Links are active where expected
- [ ] Mobile responsive

### 5. Deploy to GitHub

```powershell
git add -A
git commit -m "Add [Course Name] course with [N] labs"
git push origin main
```

**GitHub Actions** auto-deploys to Azure Static Web Apps.

---

## Design Standards

### Professional Framework

All labs use **`_styles/lab-template.css`** which includes:

**Typography:**
- Headings: Bold, dark blue (`#1e3a8a`), strong hierarchy
- Body: Light sans-serif, high contrast, accessible

**Components:**
- **Task boxes:** Gradient headers, icon indicators
- **Callouts:** Tip (blue), Warning (yellow), Important (red), Note (purple)
- **Code blocks:** Dark theme, syntax highlighting, copy button
- **Tables:** Clean borders, hover effects
- **Checklists:** Interactive validation items

**Colors:**
- Primary: `#1e3a8a` (Blue)
- Background: `#f7f9fd` (Light)
- Text: `#1a202c` (Dark)
- Success: `#16a34a` (Green)
- Warning: `#ca8a04` (Amber)
- Error: `#dc2626` (Red)

### Naming Conventions

**Courses:**
- Use official certification code: `az-104`, `az-900`, `dp-100`
- Folder format: `courses/[code]`

**Modules:**
- Two-digit prefix: `00-`, `01-`, `02-`
- Descriptive name: `00-prerequisites`, `01-core-concepts`

**Labs:**
- Filename: `lab[##]-[slug].md`
- Example: `lab01-create-virtual-machines.md`
- Output: `lab01-create-virtual-machines.html`

**Markdown:**
- Use semantic headings (# = page title, ## = section, ### = subsection)
- Code fences specify language: ` ```powershell `, ` ```bash `, ` ```json `
- Blockquotes `> ` for tips/warnings

### Best Practices

1. **Keep labs focused** — One learning objective per lab (30-60 min)
2. **Provide copy-paste commands** — Users learn by doing, not typing
3. **Show expected output** — Help users verify they succeeded
4. **Real-world context** — Explain WHY, not just HOW
5. **Include cleanup steps** — Help users avoid extra costs
6. **Link between labs** — Create progression paths

---

## File Organization

```
learninghub/
├── _styles/
│   └── lab-template.css          ← Shared design (edit once, affects all)
├── _templates/
│   └── COURSE-LAB-TEMPLATE.md    ← Markdown template for new labs
├── _scripts/
│   └── GENERATE-LABS-HTML.ps1    ← Auto-generates HTML from markdown
├── courses/
│   ├── az-104/                   ← Existing course
│   ├── az-900/                   ← New course (you create this)
│   └── dp-100/                   ← Future course
└── COURSE-CREATION-GUIDE.md      ← This file

What you edit:          What gets auto-generated:
.md files               HTML files + Navigation
```

---

## Common Tasks

### Add a New Lab to Existing Course

1. Create markdown file in `courses/[code]/[module]/labs/`
2. Use `_templates/COURSE-LAB-TEMPLATE.md` as starting point
3. Run: `./_scripts/GENERATE-LABS-HTML.ps1 -CourseFolder "courses/[code]"`
4. Push to GitHub

### Create an Entire New Course

1. Create folder: `mkdir -p courses/[code]/00-intro/labs`
2. Write 5-10 markdown lab files
3. Run generation script
4. Test locally
5. Push to GitHub

### Update Design System

1. Edit `_styles/lab-template.css`
2. **All 100+ labs automatically refresh**
3. No need to regenerate HTML
4. No need to update course files

### Fix a Lab's Content

1. Edit the `.md` file
2. Regenerate HTML: `./_scripts/GENERATE-LABS-HTML.ps1`
3. Commit and push
4. Live site updates automatically

---

## Troubleshooting

### "CSS not loading" → Check path

The generated HTML should have:
```html
<link rel="stylesheet" href="../../_styles/lab-template.css">
```

For different nesting depths:
- `courses/az-104/00-prerequisites/documents/lab00.html` → `../../_styles/lab-template.css` ✓
- `courses/az-900/00-intro/documents/lab01.html` → `../../_styles/lab-template.css` ✓

### "Navigation not working" → Check markdown structure

Script requires:
- `# ` for page title (exactly once)
- `## ` for sections (auto-creates sidebar links)
- Sections with IDs: `<h2 id="slug-name">`

### "Copy buttons not working" → Check code fence syntax

Must use proper markdown code blocks:
```markdown
`​`​`powershell
Command here
`​`​`
```

Not: Indented code or `<pre><code>` tags.

---

## Next: Phase 3 (Future)

Future enhancements planned:
- [ ] CLI tool: `npm install @learninghub/create-course`
- [ ] Web interface: Drag-drop course builder
- [ ] Content collaboration: GitHub-based workflow
- [ ] Analytics: Track which labs users complete
- [ ] Localization: Translate courses to multiple languages

---

## Questions?

See existing courses for examples:
- `courses/az-104/` — Complete reference implementation
- `_templates/COURSE-LAB-TEMPLATE.md` — Start here for new labs
- `_styles/lab-template.css` — Design system source

For styling questions, check the CSS custom properties at the top of `lab-template.css`.
