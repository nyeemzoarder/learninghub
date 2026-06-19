# Lab 18 – Backup & Recovery

## Objectives
- Create a Recovery Services vault
- Configure and run a VM backup, then restore a file/disk
- Configure Azure Site Recovery (overview/concepts)
- Understand backup policies, retention, and soft delete for vaults

## Prerequisites
- A VM (small size to minimize backup time/cost)
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time
45 minutes (initial backup can take a while to complete — plan for waiting)

---

## Part 1 – Setup

1. Search for **Resource groups** > **Create**. Name: `rg-az104-lab18`,
   region: `East US`. **Create**.
2. Create a VM:
   - **Virtual machines** > **Create** > `vm-backup01`, **Ubuntu 22.04 LTS**,
     **Standard_B1s**. **Create**.
3. Search for **Recovery Services vaults** > **Create**.
   - **Resource group**: `rg-az104-lab18`
   - **Name**: `rsv-az104lab18`
   - **Region**: `East US`
   - **Create**.

## Part 2 – Enable backup with default policy

> Important: The first backup is a full backup and takes longer than incremental backups. Plan for the VM to be under load during the backup process.

1. Go to **rsv-az104lab18** > **Backup** (under **Getting started**).
2. **Where is your workload running?**: **Azure**
3. **What do you want to backup?**: **Virtual machine**
4. **Select VMs to backup**: check `vm-backup01` > **Enable backup**.
   - Uses the **DefaultPolicy** (daily backup at 10:00 AM, retention 30 days).

## Part 3 – Review/customize backup policy

1. Go to **rsv-az104lab18** > **Backup policies** (under **Manage**).
2. Select **DefaultPolicy** — review daily retention, weekly/monthly/yearly tiers.
3. To create a custom policy:
   - **+ Add** > **VM backup policy**
   - **Policy name**: `custom-policy`
   - **Daily backup**: enabled, time 11:00 PM
   - **Retention**: daily 30 days, weekly 12 weeks
   - **Save**.

## Part 4 – Trigger an on-demand backup

1. Go to **rsv-az104lab18** > **Backup items** (under **Protected items**) >
   select `vm-backup01`.
2. **Backup Now** (top toolbar):
   - **Retain Backup Till**: set to 30 days from today
   - **OK**.

The backup job begins. **Backup jobs** (under **Manage**) shows progress. This
can take 15–30+ minutes for the first backup.

## Part 5 – Recovery Services vault settings: soft delete & redundancy

> Tip: Use **Geo-redundant (GRS)** replication for production backups to protect against regional disasters. LRS is acceptable for non-critical backups or cost-sensitive scenarios.

1. Go to **rsv-az104lab18** > **Properties** (under **Settings**).
2. **Backup configuration**:
   - **Storage replication type**: **Locally-redundant (LRS)** or **Geo-redundant (GRS)** — GRS replicates to a secondary region for DR.
   - **Soft delete**: **Enabled by default** on new vaults — protects backup data for 14 days after accidental/malicious deletion.

## Part 6 – Azure Site Recovery (concepts, no full deployment)

ASR provides VM-level disaster recovery by continuously replicating VM disks
to another region. Workflow:
1. Enable replication for a source VM to a target region/VNet.
2. Configure replication policy (RPO threshold, retention of recovery points).
3. Test failover (non-disruptive, isolated network) to validate DR readiness.
4. Planned/unplanned failover moves the workload to the target region.
5. Failback once the primary region is healthy.

To explore in the Portal (without full setup):
- **rsv-az104lab18** > **Replicated items** (under **Protected items**) — shows
  VMs being replicated via ASR (empty until configured).

## Part 7 – Restore (after backup completes)

Once the backup job finishes:

1. Go to **rsv-az104lab18** > **Backup items** > select `vm-backup01`.
2. **Restore VM** (top toolbar):
   - **Restore point**: select the latest recovery point
   - **Restore configuration**:
     - **Restore type**: **Create new virtual machine**
     - **Virtual machine name**: `vm-backup01-restored`
     - **Resource group**: create new or select existing
     - **Virtual network**: select a VNet
     - **Subnet**: select a subnet
     - **Restore** — creates a new VM from the backup.

   Alternative: **Restore disks** to restore individual disks to a storage
   account for file-level recovery.

## Validation
- [ ] Recovery Services vault created
- [ ] VM backup enabled with a backup policy
- [ ] On-demand backup job completes successfully (check **Backup jobs**)
- [ ] Recovery point listed in `vm-backup01`'s backup items
- [ ] Can describe ASR failover/failback workflow and RPO/RTO concepts

## Cleanup
1. Go to **rsv-az104lab18** > **Backup items** > select `vm-backup01` >
   **Stop Backup** (top toolbar).
2. **Delete Backup Data**: **Yes** (delete retained backups) > **Stop Backup**.
3. **Resource groups** > select `rg-az104-lab18` > **Delete resource group**.

> A Recovery Services vault can't be deleted while it has protected items or
> retained backup data — disable protection first.

## Exam Tips
- Backup is **item-level** (VM, files, SQL, etc.) for operational recovery; **ASR** is **DR-focused**, replicating entire VMs to another region for failover.
- Vault soft delete retains deleted backup data for 14 days — protects against ransomware/accidental deletion.
- RPO (Recovery Point Objective) = acceptable data loss window; RTO (Recovery Time Objective) = acceptable downtime — ASR lets you configure/test against these.
- You must disable protection (and optionally delete backup data) before a vault can be deleted.
