# Glossary

> Part of the [AZ-104 course](../README.md).

Cross-module reference for terms used throughout the labs and concept docs.

| Term | Definition |
|------|------------|
| **AMA** | Azure Monitor Agent — collects telemetry from VMs per a Data Collection Rule (DCR). Replaces the legacy Log Analytics (MMA) agent. See [Module 05](../05-monitor-maintain/README.md). |
| **ASG** | Application Security Group — a tag-like grouping of NICs used as a source/destination in NSG rules instead of IP ranges. See [Lab 13](../04-networking/labs/lab13-nsg-asg.md). |
| **Availability Set** | A logical grouping of VMs spread across fault and update domains within a datacenter. See [Lab 09](../03-compute/labs/lab09-vm-availability-scaling.md). |
| **Availability Zone (AZ)** | A physically separate datacenter within a region, with independent power/cooling/networking. See [prerequisites](../00-prerequisites/01-cloud-computing-fundamentals.md). |
| **CIDR** | Compact notation for an IP address range, e.g. `10.0.0.0/16`. See [Networking Basics](../00-prerequisites/02-networking-basics.md). |
| **DCR** | Data Collection Rule — defines what telemetry AMA collects and where it's sent. |
| **Entra Tenant** | A dedicated, isolated instance of Microsoft Entra ID — your organization's identity directory. See [Module 01](../01-identity-governance/README.md). |
| **GRS / GZRS / LRS / ZRS** | Storage redundancy options — see [Storage Redundancy Options](../02-storage/concepts/01-storage-redundancy-options.md). |
| **Hub-spoke** | A network topology pattern with a central hub VNet (shared services) and peered spoke VNets. See [Hub-Spoke Topology](../04-networking/concepts/01-hub-spoke-topology.md). |
| **KQL** | Kusto Query Language — used to query Log Analytics workspaces. See [Lab 17](../05-monitor-maintain/labs/lab17-azure-monitor-alerts.md). |
| **Management Group** | A container above subscriptions in the Azure resource hierarchy, used to apply policies/RBAC across multiple subscriptions. See [Lab 03](../01-identity-governance/labs/lab03-management-groups-subscriptions.md). |
| **NSG** | Network Security Group — stateful firewall rules applied at subnet or NIC level. See [Lab 13](../04-networking/labs/lab13-nsg-asg.md). |
| **RBAC** | Role-Based Access Control — Azure's authorization system, assigning roles to identities at a scope. See [prerequisites](../00-prerequisites/03-identity-and-access-fundamentals.md). |
| **Region pair** | A predefined pairing of two Azure regions in the same geography, used for geo-redundant replication. See [prerequisites](../00-prerequisites/01-cloud-computing-fundamentals.md). |
| **Resource Group** | A logical container for related Azure resources — the unit of deployment and cleanup used throughout this course. |
| **SAS token** | Shared Access Signature — a time-limited, scoped credential for accessing storage resources without sharing account keys. See [Lab 04](../02-storage/labs/lab04-storage-accounts.md). |
| **Scope (RBAC)** | The level (management group, subscription, resource group, or resource) at which a role assignment applies and is inherited downward. |
| **SSPR** | Self-Service Password Reset — lets users reset their own Entra ID password with MFA verification. See [Lab 01](../01-identity-governance/labs/lab01-entra-users-groups.md). |
| **UDR** | User Defined Route — a custom route that overrides Azure's default system routes. See [Networking Basics](../00-prerequisites/02-networking-basics.md). |
| **VMSS** | Virtual Machine Scale Set — a group of identical, autoscaling VMs. See [Lab 09](../03-compute/labs/lab09-vm-availability-scaling.md). |
| **VNet peering** | A connection linking two VNets so resources can communicate via Azure's backbone, without traversing the public internet. Non-transitive. See [Lab 14](../04-networking/labs/lab14-vnet-peering-vpn.md). |
