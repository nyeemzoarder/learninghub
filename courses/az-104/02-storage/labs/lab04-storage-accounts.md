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

1. Search for **Resource groups** > **Create**. Name: `rg-az104-lab04`,
   region: `East US`. **Review + create** > **Create**.
2. Search for **Storage accounts** > **Create**.
3. **Basics** tab:
   - **Resource group**: `rg-az104-lab04`
   - **Storage account name**: `stoaz104lab<unique>` (lowercase letters/numbers
     only, 3–24 chars, globally unique)
   - **Region**: `East US`
   - **Performance**: **Standard**
   - **Redundancy**: **Locally-redundant storage (LRS)**
4. Leave **Advanced** defaults (Account kind **StorageV2**, **Access tier: Hot**).
5. **Review + create** > **Create**.

## Part 2 – Explore redundancy & performance options

1. Open the storage account > **Redundancy** (under **Data management**).
   Note options: LRS, ZRS, GRS, GZRS, RA-GRS, RA-GZRS.
2. On the create blade (or **Configuration** for an existing account), note
   that **Premium** performance requires a different account kind
   (FileStorage/BlockBlobStorage) and can't be changed after creation.
3. **Configuration** > **Access tier** (Hot/Cool/Cold/Archive) — only applies
   to Blob/StorageV2 accounts and can be changed in place.

## Part 3 – Containers, blobs, queues, tables, file shares

1. Open the storage account > **Containers** (under **Data storage**) >
   **+ Container**. Name: `demo-container`. **Public access level**: **Private**.
2. Open `demo-container` > **Upload** > select or create a small text file
   (e.g., `sample.txt` containing "hello az104") > **Upload**.
3. **Queues** (under **Data storage**) > **+ Queue**. Name: `demo-queue`.
4. **Tables** (under **Data storage**) > **+ Table**. Name: `demotable`.
5. **File shares** (under **Data storage**) > **+ File share**. Name:
   `demo-share`, **Quota**: 5 GiB, **Tier**: Transaction optimized.

## Part 4 – Access keys vs SAS vs Microsoft Entra authorization

1. **Access keys** (under **Security + networking**) — note there are two
   keys (`key1`/`key2`) so you can rotate one while the other is still in use.
2. **Shared Access Signature** (under **Security + networking**):
   - **Allowed services**: Blob. **Allowed resource types**: Container, Object.
   - **Allowed permissions**: Read.
   - **Start and expiry date/time**: set expiry to 1 hour from now.
   - **Allowed protocols**: **HTTPS only**.
   - Select **Generate SAS and connection string**.
   - Copy the **Blob SAS URL**, append `/demo-container/sample.txt` worth of
     path before the `?` (i.e., construct
     `https://<account>.blob.core.windows.net/demo-container/sample.txt?<sas-token>`)
     and open it in a browser to confirm read access.
3. **Microsoft Entra authorization**:
   - Go to the storage account > **Access control (IAM)** > **Add role
     assignment** > Role: **Storage Blob Data Reader** > assign it to yourself
     at the storage account scope.
   - Open **Containers** > `demo-container`. In the top toolbar, set
     **Authentication method** to **Microsoft Entra user account** (instead of
     **Access key**) and confirm you can still list/view `sample.txt` — this
     uses your Entra identity + RBAC instead of the account key.

## Part 5 – Network rules

1. **Networking** (under **Security + networking**) > **Public network access**:
   select **Enabled from selected virtual networks and IP addresses**.
2. Under **Firewall**, select **Add your client IP address** to add your
   current public IP to the allow list. **Save**.
3. Confirm that requests from outside the allow list now fail (test from a
   different network/VPN if available) — note that having the access key alone
   no longer grants access once network rules are in effect.
4. Re-enable **All networks** for lab simplicity afterward.

## Part 6 – Copying data with the Storage browser

1. Open the storage account > **Storage browser** > **Blob containers** >
   `demo-container`.
2. Select `sample.txt` > **Copy** (or right-click > **Copy**).
3. Navigate into a new/empty container (or create one, `demo-container-2`) and
   select **Paste** to copy the blob — this is the Portal-native equivalent of
   an AzCopy copy operation.
4. Use **Download** on a blob to pull it to your local machine, and **Upload**
   to push local files back up — both available from the **Storage browser**
   toolbar for blobs, file shares, queues, and tables.

## Validation
- [ ] Storage account created with StorageV2, LRS, Hot tier
- [ ] Container, queue, table, and file share all exist
- [ ] SAS URL grants time-limited read access to the blob
- [ ] Entra ID role-based access to blobs works when **Authentication method**
      is set to **Microsoft Entra user account** in the container browser
- [ ] Network rule restricts access to allow-listed IPs
- [ ] `sample.txt` copied to `demo-container-2` via **Storage browser**

## Cleanup
1. Search for **Resource groups** > select `rg-az104-lab04` > **Delete resource
   group** (type the name to confirm).

## Exam Tips
- **LRS** = 3 copies, 1 datacenter. **ZRS** = 3 AZs, 1 region. **GRS/GZRS** = paired secondary region (read-only unless failover, or RA- prefix for read access to secondary).
- SAS types: **Account SAS** (broad, multiple services), **Service SAS** (one service, e.g., Blob), **User Delegation SAS** (Entra ID-backed, most secure — recommended).
- Changing performance tier (Standard↔Premium) requires migration to a new account; access tier (Hot/Cool/Archive) can change in place (Archive has rehydration delay).
- Setting the container's **Authentication method** to **Microsoft Entra user account** uses your Entra identity + RBAC instead of account keys.
