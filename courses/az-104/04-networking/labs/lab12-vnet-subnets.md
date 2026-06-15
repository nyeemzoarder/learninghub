# Lab 12 – Virtual Networks & Subnets

## Objectives
- Create a VNet with multiple subnets
- Configure IP addressing, service endpoints, and private endpoints
- Deploy resources into specific subnets
- Understand VNet/subnet design constraints (reserved IPs, address space planning)

## Prerequisites
- None
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time
35 minutes

---

## Part 1 – Create the VNet and subnets

1. Search for **Virtual networks** > **Create**.
2. **Basics** tab:
   - **Resource group**: **Create new** `rg-az104-lab12`
   - **Name**: `vnet-hub`
   - **Region**: `East US`
3. **IP Addresses** tab:
   - **IPv4 address space**: `10.50.0.0/16`
   - **Subnets**: Create the first subnet
     - **Subnet name**: `subnet-web`
     - **Subnet address range**: `10.50.1.0/24`
4. **Review + create** > **Create**.

### Add more subnets
1. Go to **vnet-hub** > **Subnets** > **+ Subnet**.
2. Create `subnet-data`:
   - **Name**: `subnet-data`
   - **Address range**: `10.50.2.0/24`
   - **Add**
3. Repeat for `subnet-mgmt`:
   - **Name**: `subnet-mgmt`
   - **Address range**: `10.50.3.0/24`
   - **Add**

All three subnets are now part of `vnet-hub`. Note that each `/24` subnet
reserves 5 IPs (.0 network, .1 gateway, .2/.3 DNS, broadcast):
available usable IPs per subnet = 251 (or 256 - 5).

## Part 2 – Static private IP

1. Search for **Virtual machines** > **Create** > **Azure virtual machine**.
2. **Basics**: `vm-data01`, **Ubuntu 22.04 LTS**, size **Standard_B1s**.
3. **Networking** tab:
   - **Virtual network**: `vnet-hub`
   - **Subnet**: `subnet-data`
   - **Public IP**: **None** (we'll keep this VM private)
   - **NIC network security group**: **Basic** (or create one)
4. **Advanced** tab: **Private IP address**: `10.50.2.10`.
5. **Review + create** > **Create**.

The VM now has a static private IP `10.50.2.10` inside `subnet-data`, with no
public IP (only reachable from within the VNet or via Bastion/VPN).

## Part 3 – Service Endpoints

Service Endpoints extend your VNet's identity to a service (e.g., Storage) over
the Azure backbone, keeping the service's public endpoint but restricting
access to specified subnets.

1. Go to **vnet-hub** > **Subnets** > select `subnet-data` > **Service
   endpoints** > **+ Add**.
2. Select **Microsoft.Storage** > **Add**.

### Restrict storage to this subnet
1. Search for **Storage accounts** > **Create**.
   - **Resource group**: `rg-az104-lab12`
   - **Name**: `stoaz104lab12<unique>`
   - **Region**: `East US`
   - **Performance**: Standard, **Redundancy**: LRS
   - **Review + create** > **Create**

2. Go to **stoaz104lab12<unique>** > **Networking** (under **Security +
   networking**).
3. Set **Public network access** to **Enabled from selected virtual networks
   and IP addresses**.
4. Under **Virtual networks**, select **+ Add existing virtual network** >
   choose `vnet-hub`, subnet `subnet-data` > **Add**.
5. Set **Default action** to **Deny**.
6. **Save**.

Now only resources in `subnet-data` (via the service endpoint) can reach this
storage account by default — public internet access is denied.

## Part 4 – Private Endpoint

Private Endpoints give a PaaS resource (like Storage) a private IP **inside**
your VNet — traffic never traverses the public internet.

1. Go to **vnet-hub** > **Subnets** > select `subnet-mgmt`. (On some Portal
   versions, you may need to go to the subnet and ensure private endpoint
   policies are not disabled — skip this step if the UI differs.)

2. Search for **Private endpoints** > **Create**.
3. **Basics** tab:
   - **Resource group**: `rg-az104-lab12`
   - **Name**: `pe-storage`
   - **Region**: `East US`
4. **Resource** tab: **Connect to an Azure resource** > **Resource type**:
   **Microsoft.Storage/storageAccounts** > **Resource**: select
   `stoaz104lab12<unique>` > **Sub-resource**: **blob**.
5. **Configuration** tab:
   - **Virtual network**: `vnet-hub`
   - **Subnet**: `subnet-mgmt`
   - **Private DNS integration**: **Yes** (auto-creates a private DNS zone)
6. **Review + create** > **Create**.

The storage account now has a private IP inside `subnet-mgmt` — VNet traffic
reaches it without ever hitting the public internet.

## Part 5 – IP address planning exercise

Given `10.50.0.0/16` (65,536 addresses), design subnets for these requirements:
- `subnet-web`: 250 hosts → `/24` (10.50.1.0/24) ✓ (already created)
- `subnet-data`: 60 hosts → `/26` (10.50.2.0/26) — can subdivide the /24 further
- `subnet-aks`: 1,000+ hosts → `/22` (10.40.4.0/22)
- `AzureBastionSubnet`: minimum `/26` (for Bastion)
- `GatewaySubnet`: minimum `/27` (for VPN/ExpressRoute, recommended `/26`)

Key constraints:
- Subnets cannot overlap.
- Special reserved subnet names: `GatewaySubnet`, `AzureBastionSubnet`,
  `AzureFirewallSubnet` — these control where specific services can deploy.
- Each subnet automatically reserves 5 IPs.

## Validation
- [ ] VNet `vnet-hub` with 3 subnets created, no overlapping address spaces
- [ ] VM `vm-data01` deployed with fixed private IP `10.50.2.10` and no public IP
- [ ] Storage account reachable only from `subnet-data` via service endpoint
- [ ] Private endpoint `pe-storage` has a private IP in `subnet-mgmt`

## Cleanup
1. **Resource groups** > select `rg-az104-lab12` > **Delete resource group**.

## Exam Tips
- Each subnet reserves 5 IPs (.0, .1, .2, .3, and broadcast/last address) — relevant for sizing questions.
- **Service Endpoint**: extends VNet identity to the service over Azure backbone, resource keeps its public IP but can restrict access to specific subnets. **Private Endpoint**: gives the PaaS resource a private IP inside your VNet — fully removes public exposure.
- VNets cannot span regions; subnets cannot span VNets; address spaces should not overlap if you plan to peer VNets.
- Special reserved subnet names: `GatewaySubnet` (VPN/ExpressRoute gateways), `AzureBastionSubnet`, `AzureFirewallSubnet`.
