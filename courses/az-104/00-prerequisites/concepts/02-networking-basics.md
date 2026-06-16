# Networking Basics

> [Prerequisites](README.md) for the [AZ-104 course](../README.md)

## Why this matters

Module 04 (Networking) is 15–20% of the exam and assumes you can read IP
addresses, CIDR notation, and basic routing/DNS concepts. This doc is a
refresher — if you've never worked with subnets before, read it carefully
before Lab 12.

## IP addresses and CIDR notation

An IPv4 address (e.g., `10.0.1.4`) is 32 bits, written as four 8-bit numbers
(0–255) separated by dots. **CIDR notation** (`10.0.0.0/16`) describes a
*range* of addresses: the `/16` says the first 16 bits are fixed (the
network portion), leaving 16 bits (65,536 addresses) free for hosts.

| CIDR | Addresses | Typical use in these labs |
|------|-----------|----------------------------|
| `/16` | 65,536 | A Virtual Network's address space (e.g., `10.0.0.0/16`) |
| `/24` | 256 | A subnet within that VNet (e.g., `10.0.1.0/24`) |
| `/29` | 8 | A small subnet (e.g., for Azure Bastion, which requires `/26` minimum) |

**Example:** A VNet with address space `10.0.0.0/16` can contain subnets
`10.0.1.0/24`, `10.0.2.0/24`, etc. — each a /24 slice of the /16 range.
Azure reserves the **first 4 and last 1** addresses in every subnet for its
own use (e.g., in `10.0.1.0/24`, addresses `.0`–`.3` and `.255` aren't
assignable to VMs), so a `/24` actually gives you 251 usable addresses.

## Private vs. public IP addresses

- **Private IPs** (e.g., `10.x.x.x`, `172.16.x.x`–`172.31.x.x`,
  `192.168.x.x`) are only reachable within the VNet (or peered/connected
  networks). Every VM gets one.
- **Public IPs** are reachable from the internet. A VM only has one if you
  explicitly attach a Public IP resource to its network interface.

## Subnets and VNets

A **Virtual Network (VNet)** is an isolated network in Azure, divided into
**subnets**. Resources (VMs, App Service with VNet integration, etc.) are
deployed into a subnet. Subnets are used to:
- Apply different **Network Security Group (NSG)** rules to different tiers
  (e.g., a web subnet vs. a database subnet)
- Delegate a subnet to a specific Azure service (e.g., Azure Bastion requires
  its own subnet named `AzureBastionSubnet`)

## DNS basics

**DNS (Domain Name System)** translates names (`www.contoso.com`) to IP
addresses. Key record types you'll encounter in Module 04:

| Record type | Purpose | Example |
|-------------|---------|---------|
| **A** | Maps a name to an IPv4 address | `www` → `203.0.113.10` |
| **CNAME** | Aliases one name to another name | `app` → `www.contoso.com` |
| **MX** | Specifies mail servers for a domain | `@` → `mail.contoso.com` |

Azure provides two relevant DNS services: **Azure DNS** (hosts public/private
DNS zones, Lab 16) and a built-in resolver at `168.63.129.16` that every VNet
uses by default for name resolution and platform communication.

## Routing basics

Azure automatically creates **system routes** so that traffic within a VNet
(and to the internet) flows correctly. You can override this with **custom
route tables (UDRs — User Defined Routes)** — e.g., to force traffic through
a firewall appliance. Module 04/05 labs use Network Watcher's **Next hop**
tool to inspect which route a packet would take.

## See also

- [Glossary](../resources/glossary.md)
- [Module 04 – Networking](../04-networking/README.md)
