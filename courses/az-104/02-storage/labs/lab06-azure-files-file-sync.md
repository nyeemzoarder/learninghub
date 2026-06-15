# Lab 06 – Azure Files & Azure File Sync

## Objectives
- Create an Azure file share and mount it from a VM
- Configure share-level and directory-level permissions (Entra Kerberos overview)
- Set up Azure File Sync between an on-prem-style server and Azure file share (conceptual + portal walkthrough)
- Configure file share snapshots

## Prerequisites
- Storage account (from Lab 04/05 or new)
- A Windows VM for mounting (can reuse Lab 08's VM, or skip mounting if no VM yet)
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time
30 minutes

---

## Part 1 – Create a file share

1. Search for **Resource groups** > **Create**. Name: `rg-az104-lab06`,
   region: `East US`. **Review + create** > **Create**.
2. Search for **Storage accounts** > **Create**. **Resource group**:
   `rg-az104-lab06`, **Storage account name**: `stoaz104lab06<unique>`,
   **Region**: `East US`, **Performance**: Standard, **Redundancy**: LRS.
   **Review + create** > **Create**.
3. Open the storage account > **File shares** (under **Data storage**) >
   **+ File share**. Name: `teamshare`, **Quota**: 10 GiB,
   **Tier**: Transaction optimized. **Create**.

## Part 2 – Mount the share from a Windows machine

1. Open **File shares** > `teamshare` > **Connect** (top toolbar).
2. Select the drive letter (e.g., `Z:`), choose **Windows**, and the Portal
   generates a ready-to-use `net use` command containing the share path,
   storage account name, and a storage key — for example:
   ```
   net use Z: \\<account>.file.core.windows.net\teamshare /u:AZURE\<account> <storage-key>
   ```
3. Copy this command and run it in a **Command Prompt** (not PowerShell) on
   the Windows VM. This is the OS-level mount step — the Portal's **Connect**
   dialog is the only place this command needs to come from.

> Port 445 (SMB) must be allowed outbound — many corporate/ISP networks block it.
> Use Azure VPN/ExpressRoute or Azure File Sync to avoid relying on port 445 over the internet.

## Part 3 – Snapshots

1. Open **File shares** > `teamshare` > **Snapshots** (left-hand menu) >
   **+ Add snapshot**.
2. Using the mounted drive (or **Storage browser** > **File shares** >
   `teamshare`), upload a test file, take a snapshot, then modify or delete
   the file.
3. Back in **Snapshots**, select the snapshot's timestamp link to browse its
   contents, locate the original file, and use **Restore** (or download +
   re-upload) to recover it.
4. The **Snapshots** list also shows each snapshot's creation time, equivalent
   to listing share snapshots.

## Part 4 – Identity-based access (Entra Kerberos) — overview

1. Open the storage account > **File shares** > **Configuration** (or
   account-level **Data storage** > **File shares** > **Active directory**).
2. Note the two options: **On-premises Active Directory Domain Services** and
   **Microsoft Entra Kerberos** (for hybrid-joined/Entra-joined Windows
   clients, no AD DS needed).
3. With Entra Kerberos enabled, go to **Access control (IAM)** > **Add role
   assignment** and assign **Storage File Data SMB Share Contributor** or
   **Storage File Data SMB Share Reader** to users/groups — this controls
   share-level access; NTFS permissions on folders/files still apply for
   granular control.
4. *(Full AD DS setup is out of scope for this lab — understand the concept and where it's configured.)*

## Part 5 – Azure File Sync (conceptual walkthrough)

Azure File Sync requires a Windows Server VM registered as a "server endpoint" —
deploying a full sync topology is heavy for a quick lab, so walk through the
Portal flow without completing it:

1. Search for **Storage Sync Services** > **Create**. **Resource group**:
   `rg-az104-lab06`, **Name**: `az104-sync-service`, **Region**: `East US`.
   **Review + create** > **Create**.
2. Open `az104-sync-service` > **Sync groups** > **+ Sync group**. Name:
   `sg-teamshare`, **Azure file share**: select `teamshare` from the storage
   account created earlier (this becomes the **cloud endpoint**).
3. To add a **server endpoint**, you'd install the Azure File Sync agent
   (downloaded from the **Storage Sync Service** > **Overview** page) on a
   Windows Server, register it with the Storage Sync Service via the agent's
   registration wizard, then add the local folder path as a server endpoint
   from within the sync group.
4. Review **Cloud Tiering** options in the server endpoint configuration —
   frequently-accessed files stay on local server disk, infrequently-used
   files become tiered placeholders pointing to the cloud copy.

## Validation
- [ ] File share `teamshare` created with 10 GiB quota
- [ ] A snapshot exists and can be browsed under **Snapshots**
- [ ] You can explain identity-based access options for Azure Files (AD DS vs Entra Kerberos vs storage account key)
- [ ] You can explain the role of cloud endpoint, server endpoint, and cloud tiering in Azure File Sync

## Cleanup
1. Search for **Resource groups** > select `rg-az104-lab06` > **Delete resource
   group** (type the name to confirm).
2. On the Windows VM, remove the mapped drive: open **This PC**, right-click
   the `Z:` drive > **Disconnect**, or run `net use Z: /delete` in Command
   Prompt.

## Exam Tips
- SMB requires TCP 445 outbound — a common reason "mount fails" in exam scenarios. NFS shares (premium file shares only) avoid this but require VNet connectivity (no public endpoint).
- Azure File Sync keeps an Azure file share as the central source of truth, syncing to one or more Windows Server endpoints, with optional cloud tiering for capacity savings.
- Snapshots are read-only, point-in-time, incremental copies of a share — used for quick recovery of individual files.
