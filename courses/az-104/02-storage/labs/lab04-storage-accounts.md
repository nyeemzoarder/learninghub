# Lab 04 – Storage Accounts

## Objectives

- Create storage accounts with different redundancy/performance tiers
- Configure access keys, SAS tokens, and network rules
- Work with blob containers, queues, tables, and file shares
- Move/copy data using the Portal's Storage browser

## Prerequisites

- A resource group (we'll create one)
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time

40 minutes

---

## Part 1 – Create the resource group and storage account

### Step 1: Create resource group

1. Search for **Resource groups** > **Create**
2. Name: `rg-az104-lab04`, Region: `East US`
3. **Review + create** > **Create**

### Step 2: Create storage account

1. Search for **Storage accounts** > **Create**
2. **Basics** tab:
   - **Resource group**: `rg-az104-lab04`
   - **Storage account name**: `stoaz104lab<unique>` (3–24 chars, lowercase + numbers only)
   - **Region**: `East US`
   - **Performance**: **Standard**
   - **Redundancy**: **Locally-redundant storage (LRS)**
3. Leave **Advanced** defaults (StorageV2, Hot tier)
4. **Review + create** > **Create**

> Important: Storage account names must be GLOBALLY unique across all Azure customers. If your first choice is taken, add numbers until it's unique.

---

## Part 2 – Explore redundancy & performance options

### Understanding Redundancy

| Option | Copies | Locations | Cost | Best For |
|--------|--------|-----------|------|----------|
| **LRS** | 3 | 1 Datacenter | $$$ | Dev/Test |
| **ZRS** | 3 | 3 AZs (1 region) | $$$$ | Production (regional) |
| **GRS** | 6 | 2 Regions | $$$$$ | Disaster recovery |

### Step 1: View redundancy options

1. Open the storage account > **Redundancy** (under **Data management**)
2. Note the options: **LRS, ZRS, GRS, GZRS, RA-GRS, RA-GZRS**
3. Observe that changing redundancy is easy, but note the cost implications

### Step 2: Understand performance tiers

1. Go to **Configuration** > **Access tier**
   - **Hot**: Frequent access (cheapest storage, expensive per-operation)
   - **Cool**: Infrequent access (cheaper per-operation, expensive storage)
   - **Archive**: Long-term (cheapest storage, slow retrieval)

> Tip: Changing access tier between Hot/Cool is free and instant. Archive requires rehydration (24-48 hours).

---

## Part 3 – Containers, blobs, queues, tables, file shares

### Step 1: Create and upload to blob container

1. Open the storage account > **Containers** (under **Data storage**)
2. Select **+ Container**, name: `demo-container`, **Public access level**: **Private**
3. Open `demo-container` > **Upload**
4. Create a small text file locally (e.g., `sample.txt` with text "hello az104")
5. Upload it to the container

> Warning: Setting Public access to "Blob" or "Container" allows anonymous download. Only do this for non-sensitive data.

### Step 2: Create queue and table

1. **Queues** (under **Data storage**) > **+ Queue**, name: `demo-queue`
2. **Tables** (under **Data storage**) > **+ Table**, name: `demotable`

> Tip: Queues = async messaging. Tables = NoSQL key-value store. File Shares = SMB protocol (like network drives).

### Step 3: Create file share

1. **File shares** (under **Data storage**) > **+ File share**
   - **Name**: `demo-share`
   - **Quota**: `5` GiB
   - **Tier**: **Transaction optimized**
2. Create

---

## Part 4 – Access keys vs SAS vs Microsoft Entra authorization

### Access Patterns

| Method | Security | Use Case |
|--------|----------|----------|
| **Access Keys** | Full admin | Internal apps only |
| **SAS** | Time-limited | Temporary external access |
| **Entra ID** | Role-based | Production (recommended) |

### Step 1: View Access Keys

1. **Access keys** (under **Security + networking**)
2. Note: two keys (`key1`, `key2`) for rotation without downtime

> Important: Never commit access keys to GitHub. Always rotate keys when they're exposed.

### Step 2: Generate SAS token

1. **Shared Access Signature** (under **Security + networking**)
2. **Allowed services**: **Blob**
3. **Allowed resource types**: **Container, Object**
4. **Allowed permissions**: **Read**
5. **Start and expiry time**: set expiry to 1 hour from now
6. **Allowed protocols**: **HTTPS only**
7. Select **Generate SAS and connection string**
8. Copy the **Blob SAS URL**

### Step 3: Test SAS access

1. Construct the full URL:
   ```
   https://<account>.blob.core.windows.net/demo-container/sample.txt?<sas-token>
   ```
2. Open in browser—you should download `sample.txt`
3. After 1 hour, this URL will expire and access will fail

> Tip: SAS tokens are great for temporary sharing. Generate new ones for each user/device to minimize blast radius if leaked.

### Step 4: Test Entra ID access

1. Go to the storage account > **Access control (IAM)** > **Add role assignment**
2. **Role**: **Storage Blob Data Reader**
3. **Assign to**: your user account
4. Open **Containers** > `demo-container`
5. In the top toolbar, switch **Authentication method** from **Access key** to **Microsoft Entra user account**
6. Confirm you can still view `sample.txt`

> Important: This uses your Entra identity + RBAC instead of account keys. This is the most secure approach for production.

---

## Part 5 – Network rules

### Restricting Access

> Warning: Network rules can lock you out if misconfigured. Always test before deploying to production.

### Step 1: Enable network rules

1. **Networking** (under **Security + networking**)
2. **Public network access**: select **Enabled from selected virtual networks and IP addresses**
3. Under **Firewall**, select **Add your client IP address** to allow-list your current IP
4. **Save**

### Step 2: Test the restriction

1. Confirm you can still access the storage account (you're on the allow-list)
2. Try accessing from a different network/VPN (should fail with 403 Forbidden)
3. Observe that having the access key alone is NOT enough—network rules now take precedence

> Tip: In production, use Service Endpoints or Private Endpoints instead of IP ranges for more security.

### Step 3: Revert for simplicity

1. Go back to **Networking** > **Public network access**: **Enable from all networks**
2. **Save** (to not interfere with other labs)

---

## Part 6 – Copy data with Storage browser

### Step 1: Copy blob between containers

1. **Storage browser** > **Blob containers** > `demo-container` > select `sample.txt`
2. **Copy**
3. Create a new container `demo-container-2` (or navigate to an existing empty one)
4. **Paste**—the blob is now copied

> Tip: This is the Portal equivalent of `azcopy`. For large data migrations, use AzCopy CLI for speed.

### Step 2: Download and upload

1. Select `sample.txt` > **Download** (pulls to your local machine)
2. Modify the file locally
3. Go back to **Upload** > upload the modified file
4. Confirm the updated file is in the container

---

## Success Criteria

✓ Storage account created with StorageV2, LRS, Hot tier  
✓ Container, queue, table, and file share all exist  
✓ SAS URL grants time-limited read access to blob  
✓ Entra ID authentication works (view blob with your user account)  
✓ Network rule restricts access to allow-listed IPs  
✓ Blob successfully copied between containers

---

## Cleanup (If Needed)

```powershell
# Delete storage account (includes all containers, blobs, queues, tables)
Remove-AzStorageAccount -ResourceGroupName "rg-az104-lab04" -Name "stoaz104lab<unique>" -Force

# Delete resource group
Remove-AzResourceGroup -Name "rg-az104-lab04" -Force
```

---

## Key Takeaways

- **LRS** is cheap but not HA. **GRS** replicates to another region for disaster recovery
- **SAS tokens** are time-limited and granular—perfect for sharing data without keys
- **Network rules** add another layer of security on top of access keys
- **Entra ID authentication** is the modern approach—don't rely on access keys in production
- **Storage browser** is convenient for small files; use **AzCopy** for bulk data

---

## Next Steps

Proceed to Lab 05 to learn about blob security and lifecycle management.
