# Lab 09 – VM Availability & Scaling

## Objectives
- Deploy VMs into an Availability Set and across Availability Zones
- Create a Virtual Machine Scale Set (VMSS) with autoscale rules
- Configure VM uptime/availability options and understand SLAs

## Prerequisites
- None (creates its own RG/VNet)
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time
40 minutes

---

## Part 1 – Resource group and network

1. Search for **Resource groups** > **Create**. Name: `rg-az104-lab09`,
   region: `East US`. **Review + create** > **Create**.
2. Search for **Virtual networks** > **Create**. **Resource group**:
   `rg-az104-lab09`, **Name**: `vnet-lab09`, **Address space**: `10.40.0.0/16`.
   **Subnets** tab: **subnet-vms** with range `10.40.1.0/24`. **Create**.

## Part 2 – Availability Set

1. Search for **Availability sets** > **Create**. **Resource group**:
   `rg-az104-lab09`, **Name**: `avset-lab09`,
   **Fault domains**: 2, **Update domains**: 5. **Create**.
2. Create two Linux VMs in this set:
   - **Virtual machines** > **Create** > **Basics**: `vm-av1`, image **Ubuntu
     22.04 LTS**, size **Standard_B1s**, `vnet-lab09`/`subnet-vms`. **Advanced**
     tab: set **Availability set** to `avset-lab09`. **Create**.
   - Repeat for `vm-av2`.
3. Both VMs are now automatically distributed across fault/update domains for
   maintenance window and power outage protection within the same datacenter.

## Part 3 – Availability Zones

1. Create two more Linux VMs, each in a different availability zone:
   - **Virtual machines** > **Create** > **Basics**: `vm-zone1`, image **Ubuntu
     22.04 LTS**, size **Standard_B1s**, `vnet-lab09`/`subnet-vms`. **Advanced**
     tab: **Availability zone** = **Zone 1**. **Create**.
   - Repeat for `vm-zone2`, setting zone to **Zone 2**.

> Note: VMs cannot be in both an Availability Set and an Availability Zone —
> they're mutually exclusive. Not all regions/sizes support zones.

## Part 4 – Virtual Machine Scale Set

1. Search for **Virtual machine scale sets** > **Create**.
2. **Basics** tab:
   - **Resource group**: `rg-az104-lab09`
   - **Name**: `vmss-lab09`
   - **Region**: `East US`
   - **Image**: **Ubuntu Server 22.04 LTS**
   - **Size**: **Standard_B1s**
   - **Initial instance count**: 2
   - **Username**: `azureuser`
   - **SSH public key**: **Generate new key pair** or use existing
3. **Networking** tab: **Virtual network**: `vnet-lab09`, **Subnet**:
   `subnet-vms`, **Public IP per instance**: disabled (or keep default),
   **Load balancer**: create new (e.g., `lb-vmss09`).
4. **Scaling** tab: **Initial instance count**: 2.
5. **Management** tab: **Upgrade policy**: **Automatic**.
6. **Review + create** > **Create**.

## Part 5 – Autoscale rules

1. Go to **vmss-lab09** > **Scaling** (under **Settings**) > **Configure
   autoscale** (or go to **Monitor** > **Autoscale settings** for the VMSS
   resource).
2. Set **Minimum number of instances**: 2, **Maximum**: 5, **Default**: 2.
3. Create a rule: **Scale out when CPU > 70%**
   - **Metric**: CPU Percentage
   - **Operator**: Greater than
   - **Threshold**: 70
   - **Duration**: 5 minutes
   - **Action**: Increase instance count by 1
4. Create another rule: **Scale in when CPU < 30%**
   - **Metric**: CPU Percentage
   - **Operator**: Less than
   - **Threshold**: 30
   - **Duration**: 5 minutes
   - **Action**: Decrease instance count by 1
5. **Save**.

## Part 6 – Manual scale & instance management

1. Go to **vmss-lab09** > **Scaling** > set **Custom autoscale** to **Off**
   (to control manually), then set **Instance count** to 3 > **Save**.
2. Go to **Instances** to view all VMSS instances — the count should now show 3.
3. To upgrade all instances with a new image/config: go to **Instances** >
   select all checkboxes > **Upgrade** (rolls out the new model progressively
   based on the upgrade policy).

## Validation
- [ ] `avset-lab09` contains `vm-av1` and `vm-av2` (check **Availability sets**
      > select the set > **Instances**)
- [ ] `vm-zone1` in Zone 1, `vm-zone2` in Zone 2 (check each VM's **Overview**
      > **Availability**)
- [ ] VMSS `vmss-lab09` running with 2+ instances behind load balancer
      (**vmss-lab09** > **Instances**)
- [ ] Autoscale profile has scale-out (CPU>70%) and scale-in (CPU<30%) rules
      (**vmss-lab09** > **Scaling**)
- [ ] Manual scale to 3 instances succeeds

## Cleanup
1. **Resource groups** > select `rg-az104-lab09` > **Delete resource group**.

## Exam Tips
- **Availability Set**: fault domains (separate power/network) and update domains (separate maintenance reboots) within one datacenter — protects against rack-level failure. SLA ~99.95%.
- **Availability Zones**: physically separate datacenters within a region, each with independent power/cooling/network — protects against datacenter-level failure. SLA ~99.99% when spanning 2+ zones.
- VMSS supports up to 1,000 instances (100 with custom images), and autoscale is based on Azure Monitor metrics (CPU, memory, custom metrics, schedules).
- Upgrade policy modes for VMSS: **Manual**, **Automatic**, **Rolling**.
