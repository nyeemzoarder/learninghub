# Lab 14 – VNet Peering & VPN Gateway

## Objectives
- Peer two VNets and verify connectivity
- Configure peering options (gateway transit, forwarded traffic, access)
- (Overview + optional deploy) Create a Site-to-Site VPN gateway

## Prerequisites
- None
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time
40 minutes (VPN gateway provisioning alone can take ~30 min — plan accordingly)

---

## Part 1 – Create two VNets (non-overlapping address spaces)

> Important: VNet address spaces MUST NOT overlap for peering to work. Check both VNets' address ranges before creating peering links.

1. Search for **Virtual networks** > **Create**.
   - **Resource group**: **Create new** `rg-az104-lab14`
   - **Name**: `vnet-hub14`
   - **Address space**: `10.70.0.0/16`
   - **Subnets**: `subnet-hub` with `10.70.1.0/24`
   - **Create**.

2. Repeat to create **vnet-spoke14**:
   - **Address space**: `10.71.0.0/16` (non-overlapping)
   - **Subnets**: `subnet-spoke` with `10.71.1.0/24`
   - **Create**.

## Part 2 – Create VNet peering (both directions)

1. Go to **vnet-hub14** > **Peerings** (under **Settings**) > **+ Add**.
2. **Add peering**:
   - **Peering link name**: `hub-to-spoke`
   - **Remote virtual network**:
     - **Select by ID** > choose `vnet-spoke14`
   - **Allow access between VNets**: **Checked**
   - **Add**.

3. Go to **vnet-spoke14** > **Peerings** > **+ Add**.
4. **Add peering**:
   - **Peering link name**: `spoke-to-hub`
   - **Remote virtual network**: select `vnet-hub14`
   - **Allow access between VNets**: **Checked**
   - **Add**.

Both peerings should now show **Connected** status.

## Part 3 – Test connectivity

1. Create two VMs:
   - **Virtual machines** > **Create** > `vm-hub`, **Ubuntu 22.04 LTS**,
     `vnet-hub14`/`subnet-hub` with a **public IP**. **Create**.
   - Create `vm-spoke`, **Ubuntu 22.04 LTS**, `vnet-spoke14`/`subnet-spoke**
     with **No public IP**. **Create**.

2. SSH into `vm-hub` using its public IP, then ping/SSH to `vm-spoke`'s private IP
   (e.g., `10.71.1.x`) — should succeed over the peering connection (private
   IPs, no public exposure needed).

## Part 4 – Peering options: gateway transit & forwarded traffic

1. Go to **hub-to-spoke** peering > **Edit peering**:
   - **Allow forwarded traffic**: **Checked** (lets traffic NOT originating in
     the peered VNet pass through — needed for NVAs/firewalls)
   - **Save**.

2. Discuss (no need to configure now): **Allow gateway transit** lets the spoke
   use the hub's VPN/ExpressRoute gateway (hub-spoke topology) — set on the hub
   side; spoke side sets **Use remote gateways**.

> Note: VNet peering is **not transitive** — if spoke A peers with hub, and hub
> peers with spoke B, A cannot reach B unless explicitly peered (or via gateway
> transit + an NVA).

## Part 5 – (Optional) Site-to-Site VPN Gateway

This part provisions a real gateway — **expensive and slow (~30 min)**. Only
do this if you want hands-on VPN experience; otherwise read through for concepts.

1. Go to **vnet-hub14** > **Subnets** > **+ Subnet**. Create:
   - **Name**: `GatewaySubnet` (reserved name)
   - **Address range**: `10.70.255.0/27`
   - **Add**.

2. Search for **Virtual network gateways** > **Create**.
   - **Name**: `vpngw-lab14`
   - **Region**: `East US`
   - **Gateway type**: **VPN**
   - **VPN type**: **Route-based**
   - **Virtual network**: `vnet-hub14`
   - **Gateway subnet**: `GatewaySubnet`
   - **Public IP**: **Create new** (e.g., `pip-vpngw`)
   - **SKU**: **VpnGw1**
   - **Create** (provisioning takes ~30 minutes).

3. While it's provisioning, go to **Local network gateways** > **Create** to
   represent the on-prem side:
   - **Name**: `lng-onprem`
   - **Endpoint**: **IP address**
   - **IP address**: `203.0.113.1` (a placeholder on-prem public IP)
   - **Address space**: `192.168.1.0/24` (a placeholder on-prem network)
   - **Create**.

4. Once the VPN gateway finishes provisioning, go to **vpngw-lab14** >
   **Connections** > **+ Add** to create a **Site-to-Site (IPSec)** connection:
   - **Name**: `conn-onprem`
   - **Connection type**: **Site-to-Site (IPSec)**
   - **Local network gateway**: `lng-onprem`
   - **Shared key**: `P@ssw0rd123!` (used for IPSec negotiation)
   - **Create**.

## Validation
- [ ] Both peerings (`hub-to-spoke` and `spoke-to-hub`) show **Connected** status
- [ ] `vm-hub` can reach `vm-spoke`'s private IP across the peering
- [ ] Can explain gateway transit vs forwarded traffic vs non-transitive peering
- [ ] (If completed) VPN gateway provisioned and connection created

## Cleanup
1. **Resource groups** > select `rg-az104-lab14` > **Delete resource group**.
   > If you deployed the VPN gateway, deletion can take 10-15+ minutes — that's normal.

## Exam Tips
- VNet Peering is **low-latency, private-backbone** connectivity between VNets — can span regions (global peering) and subscriptions/tenants.
- Peering is **not transitive** — a common exam trap. Hub-spoke transitive routing needs gateway transit + NVA/route tables, or Azure Virtual WAN.
- VPN Gateway SKUs (VpnGw1-5) determine throughput/tunnel counts; **Policy-based** vs **Route-based** VPN types — route-based is more flexible and required for most scenarios (P2S, multiple connections).
- `GatewaySubnet` is a reserved name and must not have an NSG attached.
