# Deploying the Learning Hub to Azure Static Web Apps

This guide documents how the **AZ-104 Learning Hub** (`courses/az-104/`) was
published as a free, GitHub-integrated **Azure Static Web App**, reachable at
a custom domain (`www.learninghub.2bd.net`). It's written so a future
contributor can repeat the process for a new course, recover from common
errors, or simply understand how the live site stays in sync with this repo.

## Architecture at a glance

```
GitHub repo (nyeemzoarder/learninghub)
   └── courses/az-104/            ← "app_location" — treated as the site root
         ├── index.html           ← landing page (served at /)
         ├── staticwebapp.config.json
         ├── 00-prerequisites/...
         ├── 01-identity-governance/...
         └── 04-networking/...

        │  git push to "main"
        ▼
GitHub Actions workflow (.github/workflows/azure-static-web-apps-*.yml)
   - auto-created by Azure when the Static Web App resource was made
   - builds nothing (static HTML/CSS/JS — no build step needed)
   - uploads courses/az-104/* to Azure
        │
        ▼
Azure Static Web App (Free tier)
   - default URL: https://<random-name>.azurestaticapps.net
   - custom domain: https://www.learninghub.2bd.net (free managed TLS)
```

Every `git push` to `main` automatically triggers the GitHub Actions
workflow, which redeploys the site within 1-3 minutes. **There is no manual
deploy step** — editing files and pushing is the entire release process.

---

## Phase 1 — Prepare the site for hosting (local changes)

These files make `courses/az-104/` behave like a self-contained website root:

- **`courses/az-104/index.html`** — landing page with hero section, module
  cards (linking to each module's docs), and the same "On This Page" sidebar
  used on every content page.
- **`courses/az-104/staticwebapp.config.json`** — Azure SWA configuration:
  - `mimeTypes` — ensures `.md` and `.pdf` files are served with correct
    content types instead of generic downloads.
  - `navigationFallback` / `responseOverrides` — routes unknown URLs and 404s
    back to `index.html`.
- **`.gitignore`** (repo root) — excludes `.claude/` (local Claude Code
  config/memory — must never be pushed to a public repo), `.swa/` (Azure SWA
  CLI local emulator state), and common OS/editor junk files.
- **Cross-page navigation** — every HTML page's `<a class="nav-brand">` links
  back to `../../index.html` (all content pages live exactly two folders
  below `courses/az-104/`, so this relative path is the same everywhere).

If you add a new module (e.g. `02-storage/`) with real content, update
`index.html`'s module card for it (remove the `coming-soon` class and add
links to its `documents/*.html` files).

---

## Phase 2 — Push the repo to GitHub

One-time setup, run from the repo root
(`C:\Users\nyeemzoarder\.claude\context\learning-hub`):

```powershell
# 1. Configure git identity (skip if already set globally)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 2. Initialize the repo
git init

# 3. Verify .claude/ is NOT in the list of files to be tracked
git status

# 4. Stage and commit everything
git add .
git commit -m "Initial commit: AZ-104 Learning Hub"

# 5. Connect to GitHub and push
git branch -M main
git remote add origin https://github.com/nyeemzoarder/learninghub.git
git push -u origin main
```

A GitHub sign-in window will appear on the first push — authenticate with the
account that owns `nyeemzoarder/learninghub`.

### Making future changes
After Phase 3 is complete, any edit just needs:

```powershell
git add <changed files>
git commit -m "Describe the change"
git push
```

### Common error: push rejected ("fetch first")
```
! [rejected]  main -> main (fetch first)
hint: Updates were rejected because the remote contains work that you do not
have locally...
```
This happens when Azure (or anyone else) has committed to GitHub since your
last pull — most commonly, Azure auto-commits a
`.github/workflows/azure-static-web-apps-*.yml` file when the Static Web App
resource is first created. Fix:

```powershell
git pull origin main
git push
```

`git pull` may open **Vim** to write a merge commit message (you'll see
`Merge branch 'main' of https://github.com/...`). To accept the default
message and continue:

1. Type `:wq`
2. Press **Enter**

Then run `git push` again.

---

## Phase 3 — Create the Azure Static Web App

Done once via the [Azure Portal](https://portal.azure.com), signed in as
`nyeem@suruzahammedoutlook.onmicrosoft.com`:

1. **Create a resource** → search **"Static Web App"** → **Create**.
2. **Basics**:
   - Resource Group: new, e.g. `rg-learninghub`
   - Name: `learninghub`
   - Plan type: **Free**
   - Region: any (e.g. East US 2) — only matters if using Azure Functions
3. **Deployment details**:
   - Source: **GitHub** → sign in/authorize → select
     - Organization: `nyeemzoarder`
     - Repository: `learninghub`
     - Branch: `main`
4. **Build Details** (critical):
   - Build Presets: **Custom**
   - App location: `/courses/az-104`
   - Api location: *(empty)*
   - Output location: *(empty)*
5. **Review + create** → **Create**.

Azure then:
- Creates the Static Web App resource.
- Commits a new GitHub Actions workflow file to the repo.
- That commit triggers the first deployment automatically.

### Verifying the deployment
- GitHub repo → **Actions** tab → watch the workflow run (green check = success).
- Azure Portal → Static Web App → **Overview** → open the
  `https://<random-name>.azurestaticapps.net` URL.

---

## Phase 4 — Custom domain (`www.learninghub.2bd.net`)

Azure Static Web Apps validates custom domains via a **CNAME record** that
points your domain at the app's default `*.azurestaticapps.net` hostname.

1. **Azure Portal** → Static Web App → **Custom domains** → **+ Add** →
   "Custom domain on other DNS" → enter the domain name.
2. **At the DNS provider** (the panel managing `2bd.net`'s DNS), add:

   | Type | Name/Alias | Points to / Value | TTL |
   |------|------------|--------------------|-----|
   | CNAME | `www.learninghub` *(or just `www`, depending on the zone you're editing)* | `<random-name>.azurestaticapps.net` | 1 hour |

   > **Note:** Many basic DNS panels refuse a CNAME at a zone's apex (an
   > empty alias or `@`) — error: *"Hostname can not start with period /
   > CNAME name can't be empty"*. That's why the live site uses
   > `www.learninghub.2bd.net` rather than the bare `learninghub.2bd.net`.
   > If the bare domain is required, look for a **"Domain Forwarding" /
   > "URL Redirect"** feature in the DNS panel to redirect
   > `learninghub.2bd.net` → `https://www.learninghub.2bd.net`.

3. Back in Azure, click **Validate / Add**. DNS propagation can take minutes
   to hours.
4. Once status shows **Ready**, Azure provisions a free managed TLS
   certificate automatically (another ~10-30 minutes).
5. Verify by opening `https://www.learninghub.2bd.net` and checking for the
   HTTPS lock icon.

---

## Cost notes

- **Azure Static Web Apps Free tier**: 100 GB bandwidth/month, free managed
  SSL certificates, no charge for custom domains. No Azure Functions are used
  here, so there's nothing to scale or meter beyond bandwidth.
- **GitHub Actions**: public repos get unlimited free minutes for the build
  jobs this workflow runs.
- The only ongoing "cost" is keeping the GitHub repo and Azure subscription
  active — there's no compute to shut down.

---

## Troubleshooting checklist

| Symptom | Cause | Fix |
|---|---|---|
| `git push` rejected with "fetch first" | Azure committed the workflow file to GitHub after your last pull | `git pull origin main` (handle Vim merge message with `:wq`), then `git push` |
| Site shows Azure's default "waiting for deployment" page | GitHub Actions workflow still running or failed | Check the **Actions** tab in GitHub for errors |
| `.md`/`.pdf` files download instead of opening | Missing/incorrect `staticwebapp.config.json` | Confirm `mimeTypes` entries exist and the file is inside `courses/az-104/` |
| New page doesn't show on the live site | Forgot to `git add`/commit/push the new file | `git status` to confirm it's tracked, then commit & push |
| Custom domain validation fails | CNAME not propagated yet, or wrong target hostname | Re-check the exact `*.azurestaticapps.net` value in Azure's Overview page; wait and retry |
| CNAME rejected at DNS panel ("alias is empty") | Panel doesn't allow records at the zone apex | Use a `www` (or other) subdomain instead, and optionally set up domain forwarding for the bare domain |
