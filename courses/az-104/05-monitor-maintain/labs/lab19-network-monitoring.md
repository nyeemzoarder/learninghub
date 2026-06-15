# Lab 19 – Network Monitoring Tools (Network Watcher)

## Objectives
- Enable Network Watcher and explore its diagnostic tools
- Use Connection Troubleshoot to test connectivity
- Capture packets with Packet Capture
- Review NSG flow logs and Traffic Analytics (concepts)

## Prerequisites
- Two VMs in the same/peered VNets (or create new)
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time
35 minutes

---

## Part 1 – Enable Network Watcher

Network Watcher is typically auto-enabled per region when you create networking
resources. To verify/enable:

1. Search for **Network Watcher** > check the region (e.g., **East US**) is
   listed and **Status** is **Enabled**.
2. If not, select the region > **Enable** (or select **Configure** on an
   existing region).

## Part 2 – Setup VMs (if not reusing prior labs)

1. Search for **Resource groups** > **Create**. Name: `rg-az104-lab19`,
   region: `East US`. **Create**.
2. **Virtual networks** > **Create**. **Name**: `vnet-lab19`, **Address space**:
   `10.100.0.0/16`, **Subnets**: `subnet-vms` with `10.100.1.0/24`. **Create**.
3. Create two VMs:
   - **vm-source**: **Ubuntu 22.04 LTS**, **Standard_B1s**, `vnet-lab19`/`subnet-vms`
     with a **public IP**. **Create**.
   - **vm-dest**: same config, but with **no public IP**. **Create**.

## Part 3 – Connection Troubleshoot

1. Go to **Network Watcher** > **Connection troubleshoot** (under **Network
   diagnostic tools**).
2. **Source**:
   - **Resource type**: **Virtual machine**
   - **Virtual machine**: `vm-source`
   - **Network interface**: (auto-selected)
3. **Destination**:
   - **Resource type**: **Virtual machine**
   - **Virtual machine**: `vm-dest`
   - **Port**: 22
4. **Check** — Network Watcher tests connectivity and reports latency, hops,
   and success/failure. Useful for diagnosing "VM A can't reach VM B" scenarios.

## Part 4 – IP flow verify

1. **Network Watcher** > **IP flow verify** (under **Network diagnostic tools**).
2. **VM**: `vm-source`
3. **Network interface**: (auto-selected)
4. **Direction**: **Outbound**
5. **Protocol**: **TCP**
6. **Local IP address/port**: `10.100.1.4:*` (or the VM's actual private IP)
7. **Remote IP address/port**: `10.100.1.5:22` (or `vm-dest`'s private IP)
8. **Check** — should show **Allow** if no NSG rules block it. Try with port 3389
   (RDP) or a blocked port to see **Deny**.

## Part 5 – Next hop

1. **Network Watcher** > **Next hop** (under **Network diagnostic tools**).
2. **VM**: `vm-source`
3. **Network interface**: (auto-selected)
4. **Source IP address**: `10.100.1.4` (or the VM's private IP)
5. **Destination IP address**: `10.100.1.5` (or a destination within the VNet)
6. **Check** — should show **Next hop type**: **VnetLocal** for intra-VNet traffic.
7. Try again with a destination outside the VNet (e.g., `8.8.8.8`) — should show
   **Internet** (traffic exits the VNet).

Useful for validating custom route tables (UDRs) and confirming expected
routing behavior.

## Part 6 – Packet capture

1. **Network Watcher** > **Packet capture** (under **Network diagnostic tools**) >
   **+ Add**.
2. **Create packet capture**:
   - **Name**: `capture01`
   - **VM**: `vm-source`
   - **Network interface**: (auto-selected)
   - **Capture settings**:
     - **Time limit (seconds)**: 60
     - **Maximum file size**: (default 100 MB)
     - **Filters** (optional): leave empty for now
   - **Storage account**: select or **Create new** (stores the `.pcap` file)
   - **Create** — begins capturing.
3. After ~1 minute (or manually **Stop**), go to **Packet captures** > select
   `capture01` > **Download** the `.pcap` file to analyze with Wireshark.

## Part 7 – NSG flow logs & Traffic Analytics (concepts)

1. **Network Watcher** > **NSG flow logs** (under **Logs**) > **+ Add**.
2. Configure (requires an NSG from a prior lab, e.g., Lab 13):
   - **Select NSG**: choose an NSG
   - **Target storage account**: select or create
   - **Retention (days)**: 30
   - **Traffic Analytics**: **Enabled** (optional, requires a Log Analytics workspace)
3. **Save**.

Once enabled:
- **Flow logs** record inbound/outbound traffic through the NSG (stored in a
  storage account blob).
- **Traffic Analytics** (with Log Analytics) aggregates flow logs every 10–60
  minutes and provides visualizations: top talkers, blocked flows, geographic
  distribution, etc.

## Part 8 – Topology

1. **Network Watcher** > **Topology** (under **Monitoring**).
2. **Resource group**: select `rg-az104-lab19` — visualizes VNets, subnets,
   NICs, NSGs, and their relationships in a topology diagram.

## Validation
- [ ] **Connection troubleshoot** returns latency/hop info between VMs
- [ ] **Next hop** returns **VnetLocal** for intra-VNet traffic, **Internet** for external
- [ ] Packet capture session created, data captured, and `.pcap` file available
- [ ] Can describe how to enable NSG flow logs + Traffic Analytics and what they show

## Cleanup
1. **Network Watcher** > **Packet captures** > select `capture01` > **Delete**.
2. **Resource groups** > select `rg-az104-lab19` > **Delete resource group**.

> `NetworkWatcherRG` is a special auto-created resource group — don't delete it;
> it's shared across your subscription's networking diagnostics.

## Exam Tips
- **Network Watcher** tools to know: **IP flow verify** (NSG rule evaluation for specific traffic), **Next hop** (routing decision for a packet), **Connection troubleshoot/Connection monitor** (end-to-end connectivity + latency), **Packet capture** (deep packet inspection), **NSG flow logs + Traffic Analytics** (traffic patterns over time).
- `NetworkWatcherRG` is auto-created the first time Network Watcher is enabled in a region — it's normal and shouldn't be deleted.
- NSG flow logs require a storage account; Traffic Analytics additionally requires a Log Analytics workspace and aggregates flow logs every ~10/60 minutes.
- `show-next-hop` (via **Next hop**) is the fastest way to confirm whether custom route tables (UDRs) are affecting traffic as expected.
