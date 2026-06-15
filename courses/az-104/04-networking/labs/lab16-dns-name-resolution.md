# Lab 16 – DNS & Name Resolution

## Objectives
- Create an Azure DNS public zone and records
- Create a Private DNS zone and link it to a VNet with autoregistration
- Configure custom DNS servers for a VNet and understand Azure-provided DNS

## Prerequisites
- None (a real registered domain is NOT required for the public zone exercise — you just won't be able to delegate it)
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time
30 minutes

---

## Part 1 – Public DNS zone

1. Search for **DNS zones** > **Create**.
2. **Basics**:
   - **Resource group**: **Create new** `rg-az104-lab16`
   - **Name**: `contoso-az104lab.com` (doesn't need to be a real domain)
   - **Create**.

3. Go to **contoso-az104lab.com** > **Record sets** > **+ Record set**:
   - **Name**: `www`
   - **Type**: **A**
   - **TTL**: 3600
   - **IP Address**: `203.0.113.10` (a test IP)
   - **Create**.

4. Create another record set (CNAME):
   - **Name**: `app`
   - **Type**: **CNAME**
   - **TTL**: 3600
   - **Canonical name**: `www.contoso-az104lab.com`
   - **Create**.

5. Create an MX record:
   - **Name**: `@` (root)
   - **Type**: **MX**
   - **TTL**: 3600
   - **Mail exchange**: `mail.contoso-az104lab.com`
   - **Preference**: 10
   - **Create**.

### View nameservers
1. Go to **contoso-az104lab.com** > **Overview** — the **Nameservers** are
   listed (e.g., `ns1-07.azure-dns.com`, etc.). In a real scenario, you'd
   update these NS records at your domain registrar to delegate the domain to
   Azure DNS.

## Part 2 – Private DNS zone

1. Search for **Private DNS zones** > **Create**.
2. **Basics**:
   - **Resource group**: `rg-az104-lab16`
   - **Name**: `contoso.internal`
   - **Create**.

3. Create a VNet (or reuse from a prior lab):
   - **Virtual networks** > **Create**. **Resource group**: `rg-az104-lab16`,
     **Name**: `vnet-dns16`, **Address space**: `10.90.0.0/16`,
     **Subnets**: `subnet-vms` with `10.90.1.0/24`. **Create**.

4. Link the private DNS zone to the VNet:
   - Go to **contoso.internal** > **Virtual network links** (under **Settings**) >
     **+ Add**.
   - **Link name**: `link-vnet-dns16`
   - **Virtual network**: `vnet-dns16`
   - **Enable autoregistration**: **Checked**
   - **Create**.

## Part 3 – Test autoregistration

1. Create a VM:
   - **Virtual machines** > **Create** > `vm-dns01`, **Ubuntu 22.04 LTS**,
     **Standard_B1s**, `vnet-dns16`/`subnet-vms`. **Create**.

2. After the VM deploys, go to **contoso.internal** > **Record sets**. The VM
   should automatically appear as `vm-dns01` with an **A** record pointing to
   its private IP (e.g., `10.90.1.4`).

## Part 4 – Custom/manual A record in private zone

1. Go to **contoso.internal** > **Record sets** > **+ Record set**:
   - **Name**: `db01`
   - **Type**: **A**
   - **TTL**: 3600
   - **IP Address**: `10.90.1.50` (a custom IP for a database server)
   - **Create**.

## Part 5 – Custom DNS servers for a VNet (overview)

1. Go to **vnet-dns16** > **DNS servers** (under **Settings**).
2. Default is **Inherited from Azure** (uses Azure-provided DNS `168.63.129.16`).
3. To use custom DNS:
   - Set to **Custom**.
   - Add custom DNS server IPs (e.g., `10.90.1.4`, `168.63.129.16` for failover).
   - **Save**.

> Note: Changing DNS servers requires VMs to restart to pick up new settings — discuss,
> no need to apply for this lab.

## Validation
- [ ] Public zone `contoso-az104lab.com` has A, CNAME, and MX records
- [ ] Private zone `contoso.internal` linked to `vnet-dns16` with autoregistration enabled
- [ ] `vm-dns01` automatically appears as an A record in the private zone
- [ ] Manual A record `db01.contoso.internal` resolves to `10.90.1.50`
- [ ] Can explain why `168.63.129.16` matters when using custom DNS servers

## Cleanup
1. **Resource groups** > select `rg-az104-lab16` > **Delete resource group**.

## Exam Tips
- Azure Private DNS zones provide name resolution **within and across VNets** (via virtual network links) without managing your own DNS servers.
- **Autoregistration** only works for VMs (registers A and PTR records) and only one zone per VNet can have autoregistration enabled.
- `168.63.129.16` is a special, platform-wide virtual IP used for communication with Azure platform resources (DNS, health probes, license checks) — keep it in custom DNS configs.
- Public DNS zones in Azure host your zone's records; you still need to update NS records at your domain registrar to delegate the domain to Azure DNS.
