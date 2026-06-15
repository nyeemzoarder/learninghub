# Exporting Diagrams as PNG/SVG

## Option 2: Using drawio-cli (Automated)

This guide walks you through exporting all `.drawio` source files to PNG format automatically using the command line.

### Step 1: Install Node.js (if not already installed)

drawio-cli requires Node.js and npm. Check if you have them:

```powershell
node --version
npm --version
```

If you don't have Node.js installed:
- Go to [nodejs.org](https://nodejs.org)
- Download the **LTS (Long-Term Support)** version
- Run the installer and follow the prompts
- Restart your terminal/PowerShell after installation

### Step 2: Install drawio-cli

Open PowerShell and run:

```powershell
npm install -g @jgraph/drawio-cli
```

This installs drawio-cli globally so you can use it from any directory.

**Verify installation:**

```powershell
drawio --version
```

You should see a version number printed.

### Step 3: Navigate to the learning-hub directory

```powershell
cd "c:\Users\nyeemzoarder\.claude\context\learning-hub"
```

### Step 4: Export all diagrams to PNG

Run this command to export all `.drawio` files to PNG format:

```powershell
drawio --export --format png --output . courses/az-104/*/diagrams/*.drawio
```

**What this does:**
- `--export` — export the diagrams
- `--format png` — save as PNG (you can also use `svg`, `pdf`, etc.)
- `--output .` — save PNG files in the *same directory* as the source `.drawio` files
- `courses/az-104/*/diagrams/*.drawio` — all `.drawio` files in any module's diagrams folder

### Step 5: Verify the export

List the diagrams folder to confirm PNG files were created:

```powershell
Get-ChildItem "courses\az-104\*\diagrams\" -Recurse | Select-Object Name
```

You should see both `.drawio` and `.png` files listed, e.g.:
```
entra-id-rbac-hierarchy.drawio
entra-id-rbac-hierarchy.png
storage-redundancy-options.drawio
storage-redundancy-options.png
... etc
```

### Step 6 (Optional): Embed PNGs in markdown

In any module `README.md`, you can now reference the PNG files for quick preview:

```markdown
## Diagrams

![Hub-Spoke Topology](diagrams/hub-spoke-topology.png)

Open in [diagrams.net](https://app.diagrams.net) (File > Open from > Device) to edit.
```

---

## Troubleshooting

**Error: "drawio: command not found"**
- npm install did not complete successfully — try again: `npm install -g @jgraph/drawio-cli`
- Or, you may need to restart your terminal after installation

**Error: "No such file or directory"**
- Make sure you're in the correct directory: `cd "c:\Users\nyeemzoarder\.claude\context\learning-hub"`
- Or use absolute paths in the command

**Command succeeds but no PNG files appear**
- Check the `courses/az-104/*/diagrams/` folders manually with File Explorer to see if they were created
- Try exporting a single file first for testing: `drawio --export --format png courses/az-104/01-identity-governance/diagrams/entra-id-rbac-hierarchy.drawio`

---

## One-off export (single diagram)

If you only want to export one specific diagram:

```powershell
drawio --export --format png courses/az-104/01-identity-governance/diagrams/entra-id-rbac-hierarchy.drawio
```

This creates `entra-id-rbac-hierarchy.png` in the same folder.

## Re-export after editing

If you edit a `.drawio` file in diagrams.net and save it, re-run the export command above to update the PNG files.
