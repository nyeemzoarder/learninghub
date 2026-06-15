# Lab 08 – Virtual Machines

## Objectives
- Deploy a Linux and a Windows VM
- Configure VM sizing, disks (OS + data disk), and extensions
- Connect via SSH/RDP and Azure Bastion
- Resize a VM and manage VM power states/costs

## Prerequisites
- None (creates its own RG/VNet)
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time
50 minutes

---

## Part 1 – Resource group and networking

1. Search for **Resource groups** > **Create**. Name: `rg-az104-lab08`,
   region: `East US`. **Review + create** > **Create**.
2. Search for **Virtual networks** > **Create**. **Resource group**:
   `rg-az104-lab08`, **Name**: `vnet-lab08`, **Address space**: `10.30.0.0/16`.
   **Subnets** tab: create subnet **subnet-vms** with address range `10.30.1.0/24`.
   **Review + create** > **Create**.

## Part 2 – Deploy a Linux VM

1. Search for **Virtual machines** > **Create** > **Azure virtual machine**.
2. **Basics** tab:
   - **Resource group**: `rg-az104-lab08`
   - **VM name**: `vm-linux01`
   - **Region**: `East US`
   - **Image**: search **Ubuntu** > select **Ubuntu Server 22.04 LTS**
   - **VM architecture**: x64
   - **Size**: **Standard_B1s**
   - **Authentication type**: **SSH public key**
   - **Username**: `azureuser`
   - **SSH public key source**: **Generate new key pair** (save the private key
     when prompted)
3. **Networking** tab: **Virtual network**: `vnet-lab08`, **Subnet**:
   `subnet-vms`, **Public IP**: create new (e.g., `pip-vm-linux01`),
   **Public inbound ports**: allow **SSH (22)**.
4. **Disks** tab: leave defaults (OS disk type Standard).
5. **Management** tab: review **Monitoring** options (optional).
6. **Review + create** > **Create**. When finished, **Download private key
   and create resource** (or just **Create** if you want to generate the key
   pair separately).

### Connect via SSH
1. Go to **vm-linux01** > **Overview** > copy its **Public IP address**.
2. Open a terminal/SSH client and run:
   ```
   ssh -i <private-key-file> azureuser@<public-ip>
   ```

## Part 3 – Deploy a Windows VM

1. **Virtual machines** > **Create** > **Azure virtual machine**.
2. **Basics** tab:
   - **Resource group**: `rg-az104-lab08`
   - **VM name**: `vm-win01`
   - **Region**: `East US`
   - **Image**: search **Windows Server** > select **Windows Server 2022 Datacenter**
   - **VM architecture**: x64
   - **Size**: **Standard_B2s** (more resources for Windows desktop experience)
   - **Authentication type**: **Password**
   - **Username**: `azureuser`
   - **Password**: set a strong password (meet Azure requirements)
   - **Confirm password**
3. **Networking** tab: **Virtual network**: `vnet-lab08`, **Subnet**:
   `subnet-vms`, **Public IP**: create new, **Public inbound ports**:
   allow **RDP (3389)**.
4. **Disks** and **Management** tabs: leave defaults.
5. **Review + create** > **Create**.

### Connect via RDP
1. Go to **vm-win01** > **Overview** > click **Connect** (top menu) > **RDP**.
2. Select **Download RDP file** > open the .rdp file > enter username
   (`azureuser`) and the password you set > **Connect**.

## Part 4 – Add a data disk

1. Go to **vm-linux01** > **Disks** > **Create and attach a new disk** (top
   toolbar).
2. **Disk name**: `disk-data01`. **Size**: 32 GiB. **Storage type**: **Standard
   HDD**. **Attach** (or **Create** > then **Attach**).
3. On the Linux VM (via SSH), partition and mount the new disk:
   ```bash
   # List disks (the new one is likely /dev/sdc)
   sudo lsblk
   
   # Partition, format, and mount (example):
   sudo parted /dev/sdc --script mklabel gpt mkpart xfspart xfs 0% 100%
   sudo mkfs.xfs /dev/sdc1
   sudo mkdir /data
   sudo mount /dev/sdc1 /data
   ```

## Part 5 – VM Extensions (Custom Script)

1. Go to **vm-linux01** > **Extensions + applications** (under **Settings**) >
   **+ Add**.
2. Search for **Custom Script Extension** > **Create**.
3. **Script file** tab: in the inline script box, enter:
   ```bash
   apt-get update
   apt-get install -y nginx
   ```
4. **Review + create** > **Create** (installation runs asynchronously; check
   **Activity log** for progress).
5. Open **Networking** > **Inbound port rules** > **+ Add inbound port rule**
   > port 80 (HTTP) > **Add**, so nginx is reachable.
6. In a browser, open `http://<public-ip>` to confirm nginx serves the default
   page.

## Part 6 – Azure Bastion (secure RDP/SSH without public IP)

1. **Virtual networks** > select `vnet-lab08` > **Subnets** > **+ Subnet**.
   Create **AzureBastionSubnet** with address range `10.30.2.0/27`.
2. **Virtual networks** > select `vnet-lab08` > **Bastion** (left-hand menu) >
   **+ Add**.
3. **Bastion host name**: `bastion-lab08`. **Public IP**: create new
   (e.g., `pip-bastion`). **SKU**: **Basic** (cheapest).
4. **Create** (takes ~10 minutes). Once deployed:
5. Go to **vm-win01** (or any VM without a public IP) > **Connect** > **Bastion** >
   enter **Username**/**Password** > **Connect** (opens an RDP/SSH session in
   the browser).

> **Cost note:** Bastion is billed hourly — delete it when done (step 5 under
> **Cleanup**) if cost is a concern.

## Part 7 – Resize and power states

1. Go to **vm-linux01** > **Size** (under **Settings**).
2. Select a new size (e.g., **Standard_B2s**) > **Resize**.
   - The VM **must be deallocated** to resize — the Portal handles this
     automatically.
3. Once resized, the VM **starts automatically** (or select **Start** manually
   if it's still stopped).
4. To manage power states without resizing, go to **vm-linux01** >
   **Overview** > **Stop** (deallocates, stops compute billing) or **Start**.

### Understanding VM states
- **Running**: billable for compute, network, disk.
- **Stopped** (deallocated): no compute billing, but storage/IP charges remain.
- **Deallocated** is the only state that avoids hourly compute costs.

## Validation
- [ ] `vm-linux01` reachable via SSH with public IP
- [ ] `vm-win01` reachable via RDP
- [ ] Data disk `/dev/sdc` attached and mounted on Linux VM
- [ ] nginx installed and reachable on port 80
- [ ] Bastion host deployed and can connect to `vm-win01` (or another VM)
- [ ] VM successfully resized while deallocated

## Cleanup
1. If Bastion is deployed: **Virtual networks** > `vnet-lab08` > **Bastion** >
   select the Bastion host > **Delete**.
2. **Resource groups** > select `rg-az104-lab08` > **Delete resource group**
   (type the name to confirm). This deletes all VMs, disks, VNet, and public IPs.

## Exam Tips
- **Stopped vs Deallocated**: only *deallocated* VMs stop compute billing; storage/IP charges continue regardless.
- Resizing often requires the VM to be deallocated, and the target size must be available in the current hardware cluster/availability set.
- Azure Bastion provides RDP/SSH over TLS via the Portal — no public IP needed on the VM NIC, reducing attack surface.
- VM extensions (Custom Script, DSC, etc.) run post-deployment configuration — they're managed via the **Extensions + applications** blade.
