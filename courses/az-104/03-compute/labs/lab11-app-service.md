# Lab 11 – Azure App Service

## Objectives
- Create an App Service plan and web app
- Configure deployment slots and slot swapping
- Configure application/connection-string settings, scaling, and autoscale
- Configure custom domains and TLS (overview), and diagnostics logging

## Prerequisites
- None (creates its own RG)
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time
35 minutes

---

## Part 1 – App Service plan and web app

1. Search for **App Services** > **Create** > **Web App**.
2. **Basics** tab:
   - **Resource group**: **Create new** `rg-az104-lab11`
   - **Name**: `app-az104lab11-<unique>`
   - **Publish**: **Code**
   - **Runtime stack**: **Node 20 LTS**
   - **Operating System**: **Linux**
   - **Region**: `East US`
3. **App Service Plan** section: **Create new** plan
   - **Name**: `plan-az104lab11`
   - **SKU and size**: **Standard (S1)** (required for deployment slots)
4. **Review + create** > **Create**.

### Browse the app
1. Go to the app > **Overview** > copy the **Default domain** (e.g.,
   `app-az104lab11-<unique>.azurewebsites.net`).
2. Open it in a browser — shows the default App Service welcome page.

## Part 2 – App settings & connection strings

1. Open the app > **Configuration** (under **Settings**).
2. **Application settings** tab > **+ New application setting**:
   - **Name**: `ENVIRONMENT`, **Value**: `lab`, **Deployment slot setting**:
     unchecked (applies to all slots)
   - **Name**: `FEATURE_FLAG_X`, **Value**: `true`
3. **Connection Strings** tab > **+ New connection string**:
   - **Name**: `DefaultConnection`
   - **Value**: `Server=tcp:example.database.windows.net;Database=demo;`
   - **Type**: **SQLAzure**
   - **Deployment slot setting**: unchecked
4. **Save** > **Continue** (if prompted about restarting the app).

These settings are injected into the app's environment at runtime.

## Part 3 – Deployment slots

1. Open the app > **Deployment slots** (under **Deployment**) > **+ Add slot**.
2. **Name**: `staging`, **Clone settings from**: select the production slot (or
   leave unchecked). **Add**.
3. This creates a `staging` slot with its own subdomain (e.g.,
   `app-az104lab11-<unique>-staging.azurewebsites.net`).

### Deploy different content to staging
(Example: upload a simple HTML file or a zipped app package.)

1. Go to the **staging** slot > **Deployment Center** (or **Advanced Tools** >
   **Kudu** SSH console).
2. Or, use the **Zip Deploy** feature: go to the slot > **Deployment Center** >
   choose **Zip Deploy** > upload a `.zip` containing your app code.

### Swap staging into production
1. Go to the app's **Deployment slots** > select `staging` > **Swap** (top toolbar).
2. **Source**: `staging`, **Target**: `production`. **Swap**.
3. The slots exchange DNS names — `staging` now serves the production URL, and
   vice versa. This swap is near-instant (no downtime).

> **Slot-specific settings**: if a setting is marked **Deployment slot
> setting**, it does NOT swap — useful for keeping staging pointed at a test
> database while production points at the prod database.

## Part 4 – Scale up (plan tier) and scale out (instance count)

### Scale up (vertical)
1. Open the app > **Scale up (App Service plan)** (under **Settings**).
2. Select a higher SKU (e.g., **Standard (S2)** or **Premium (P1v3)**) > **Apply**.
   This increases CPU/RAM per instance.

### Scale out (horizontal)
1. Open the app > **Scale out (App Service plan)** (under **Settings**).
2. Increase **Instance count** to 2 or 3 > **Save**.
   This adds more instances behind the app's load balancer.

### Configure autoscale
1. Go to **Monitor** > **Autoscale settings** (in the Azure Portal sidebar, or
   search for **Autoscale settings**).
2. **Create autoscale setting**:
   - **Resource group**: `rg-az104-lab11`
   - **Resource name**: `plan-az104lab11`
   - **Resource type**: **App Service plans**
3. **Autoscale setting name**: `autoscale-app11`.
4. **Default**: minimum 1, maximum 3, current 1.
5. **Add a rule**:
   - **Metric**: **CPU Percentage**
   - **Operator**: **Greater than**
   - **Threshold**: 70
   - **Duration**: 5 minutes
   - **Operation**: **Increase count by 1**
6. **Save**.

Now the App Service plan scales out automatically when CPU exceeds 70%.

## Part 5 – Diagnostics logging

1. Open the app > **App Service logs** (under **Monitoring**).
2. **Application logging**: set **Level** to **Information**. **Filesystem** or
   **Blob Storage** (Filesystem for quick testing).
3. **Web server logging**: **Filesystem** > **Retention period**: 35 days.
4. **Save**.
5. **Log stream** (under **Monitoring**) shows real-time logs from the app.

## Part 6 – Custom domains & TLS (overview)

1. **Custom domains** (under **Settings**):
   - To add a custom domain, you need a DNS provider and a TLS certificate.
   - Create a CNAME record (`your-domain.com` → `app-az104lab11-<unique>.azurewebsites.net`).
   - Add the domain in the Portal > **Custom domains** > **Add custom domain**.
   - Bind a certificate via **TLS/SSL settings** (use **App Service Managed
     Certificate**, which is free for custom domains).

2. **TLS/SSL settings** (under **Settings**):
   - Bind a certificate (managed or self-signed).
   - Set **HTTPS Only** to enforce HTTPS.
   - Set **Minimum TLS version** (e.g., TLS 1.2).

> Skip actual domain purchase and certificate binding in this lab — just
> understand where these settings live.

## Part 7 – Backup & restore (overview)

1. **Backups** (under **Settings**) — requires **Standard** tier or higher.
2. Create a backup target (storage account + container).
3. Configure a scheduled backup including the connected database if present.
4. Restore a backup by selecting it > **Restore**.

> Backup setup is available on **Standard** tier and above.

## Validation
- [ ] Web app reachable via default hostname
- [ ] App settings (ENVIRONMENT, FEATURE_FLAG_X) and connection string configured
- [ ] Staging slot created and accessible via separate subdomain
- [ ] Slot swap succeeds (staging and production exchange DNS names)
- [ ] Plan scaled up (higher SKU) and out (more instances)
- [ ] Autoscale rule created based on CPU percentage
- [ ] Application logs visible via **Log stream**

## Cleanup
1. **Resource groups** > select `rg-az104-lab11` > **Delete resource group**.

## Exam Tips
- Deployment slots are available on **Standard** tier and above; "swap" is near-instant and avoids downtime — slot-specific app settings/connection strings don't swap if marked sticky.
- Scaling **up** = change SKU/tier (more CPU/RAM/features per instance). Scaling **out** = more instances. Autoscale only does scale out/in, never SKU changes.
- `HTTPS Only` and minimum TLS version are common security exam scenarios.
- App Service supports deployment from: ZIP/WAR deploy, local Git, GitHub Actions/Azure DevOps CI/CD, container images (Web App for Containers).
