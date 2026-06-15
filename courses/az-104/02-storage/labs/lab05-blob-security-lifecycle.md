# Lab 05 – Blob Security & Lifecycle Management

## Objectives
- Configure blob container access levels and soft delete
- Implement a lifecycle management policy to transition/expire blobs
- Enable blob versioning and point-in-time restore
- Configure static website hosting on a storage account

## Prerequisites
- Storage account from Lab 04 (or create a new one)
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time
35 minutes

---

## Part 1 – Setup

1. Search for **Resource groups** > **Create**. Name: `rg-az104-lab05`,
   region: `East US`. **Review + create** > **Create**.
2. Search for **Storage accounts** > **Create**. **Resource group**:
   `rg-az104-lab05`, **Storage account name**: `stoaz104lab05<unique>`,
   **Region**: `East US`, **Performance**: Standard, **Redundancy**: LRS,
   **Account kind**: StorageV2. **Review + create** > **Create**.
3. Open the storage account > **Containers** > **+ Container**. Name: `data`.

## Part 2 – Container access level

1. **Containers** > select `data` > **Change access level** (top toolbar).
2. Set **Public access level** to **Blob (anonymous read access for blobs only)**.

   > Note: many subscriptions have **Allow Blob public access** disabled at
   > the account level by default. If the option is greyed out, go to the
   > storage account > **Configuration** and set **Allow Blob public access**
   > to **Enabled** first.
3. Open `data` > **Upload** > upload a small text file named `public.txt`
   (content: "public file").
4. Select `public.txt` > copy its **URL** from the properties pane and open
   `https://<account>.blob.core.windows.net/data/public.txt` in a private/
   incognito browser window to confirm anonymous read access.
5. Set the access level back to **Private (no anonymous access)** afterward.

## Part 3 – Enable soft delete & versioning

1. Open the storage account > **Data protection** (under **Data management**).
2. Enable **Enable soft delete for blobs** — set retention to 7 days.
3. Enable **Enable versioning for blobs**.
4. Enable **Enable point-in-time restore for containers** (requires versioning,
   change feed, and soft delete — the Portal will enable change feed
   automatically if needed).
5. **Save**.

### Test soft delete and versioning

1. Go to **Containers** > `data` > **Upload** > upload a file named `test.txt`
   containing `v1`.
2. Upload `test.txt` again (same name, different content `v2`) with
   **Overwrite if files already exist** checked — this creates a new blob
   version.
3. Select `test.txt` > **Delete** to delete the blob.
4. In the `data` container view, toggle **Show deleted blobs** (top toolbar) —
   `test.txt` should appear greyed out/marked as deleted.
5. Select the deleted `test.txt` > **Undelete** to restore it.
6. Select `test.txt` > **Version history** (or the **...** menu > **Blob
   versions**) to confirm at least 2 versions are listed.

## Part 4 – Lifecycle management policy

1. Open the storage account > **Lifecycle management** (under **Data
   management**) > **+ Add rule**.
2. **Details** tab:
   - **Rule name**: `move-to-cool-then-delete`
   - **Rule scope**: **Limit blobs with filters**
   - **Blob type**: **Block blobs**
3. **Base blobs** tab:
   - Check **Move to cool storage** > **More than** `30` days after
     modification.
   - Check **Move to archive storage** > **More than** `90` days after
     modification.
   - Check **Delete the blob** > **More than** `365` days after modification.
4. **Snapshots** tab: check **Delete the snapshot** > **More than** `90` days
   after creation.
5. **Filter set** tab: under **Blob prefix**, enter `data/`.
6. **Add** to save the rule.

## Part 5 – Static website hosting

1. Open the storage account > **Static website** (under **Data management**).
2. Set **Static website** to **Enabled**.
3. **Index document name**: `index.html`. **Error document path**: `404.html`.
4. **Save** — note the **Primary endpoint** URL that appears.
5. Create a local file `index.html` containing `<h1>AZ-104 Lab 05</h1>`.
6. Go to **Containers** > the `$web` container (created automatically) >
   **Upload** > upload `index.html`.
7. Open the **Primary endpoint** URL from step 4 in a browser to confirm the
   page loads.

## Validation
- [ ] Soft-deleted blob `test.txt` restored successfully via **Undelete**
- [ ] At least 2 versions of `test.txt` are listed under **Blob versions**
- [ ] Lifecycle rule `move-to-cool-then-delete` is visible under **Lifecycle
      management**
- [ ] Static website index page loads via the **Primary endpoint** URL

## Cleanup
1. Search for **Resource groups** > select `rg-az104-lab05` > **Delete resource
   group** (type the name to confirm).

## Exam Tips
- Container access levels: **Private** (no anonymous access), **Blob** (anonymous read of blobs, no listing), **Container** (anonymous read + listing).
- Lifecycle rules act on **last modified date** by default (or `daysAfterCreation`/`daysAfterLastAccessTime` with access tracking enabled).
- Point-in-time restore requires: versioning + change feed + soft delete all enabled, and only works for block blobs.
- Static website content is served from the special `$web` container; custom domains + Azure CDN/Front Door are often layered on top.
