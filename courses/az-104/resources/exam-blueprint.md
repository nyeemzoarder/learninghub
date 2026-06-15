# AZ-104 Exam Blueprint & Lab Map

> Part of the [AZ-104 course](../README.md).

The AZ-104: Microsoft Azure Administrator exam covers five skill domains.
This table maps each domain to the module and labs that cover it.

| # | Exam Domain (approx. weight) | Module | Labs |
|---|-------------------------------|--------|------|
| 1 | Manage Azure identities and governance (20–25%) | [Module 01 – Identity & Governance](../01-identity-governance/README.md) | [Lab 01 – Entra ID Users & Groups](../01-identity-governance/labs/lab01-entra-users-groups.md), [Lab 02 – RBAC & Azure Policy](../01-identity-governance/labs/lab02-rbac-azure-policy.md), [Lab 03 – Management Groups, Subscriptions & Resource Organization](../01-identity-governance/labs/lab03-management-groups-subscriptions.md) |
| 2 | Implement and manage storage (15–20%) | [Module 02 – Storage](../02-storage/README.md) | [Lab 04 – Storage Accounts](../02-storage/labs/lab04-storage-accounts.md), [Lab 05 – Blob Security & Lifecycle Management](../02-storage/labs/lab05-blob-security-lifecycle.md), [Lab 06 – Azure Files & File Sync](../02-storage/labs/lab06-azure-files-file-sync.md) |
| 3 | Deploy and manage Azure compute resources (20–25%) | [Module 03 – Compute](../03-compute/README.md) | [Lab 07 – ARM/Bicep Templates](../03-compute/labs/lab07-arm-bicep-templates.md) *(optional)*, [Lab 08 – Virtual Machines](../03-compute/labs/lab08-virtual-machines.md), [Lab 09 – VM Availability & Scaling](../03-compute/labs/lab09-vm-availability-scaling.md), [Lab 10 – Containers (ACI & ACR)](../03-compute/labs/lab10-containers-aci-acr.md), [Lab 11 – Azure App Service](../03-compute/labs/lab11-app-service.md) |
| 4 | Implement and manage virtual networking (15–20%) | [Module 04 – Networking](../04-networking/README.md) | [Lab 12 – VNets & Subnets](../04-networking/labs/lab12-vnet-subnets.md), [Lab 13 – NSGs & ASGs](../04-networking/labs/lab13-nsg-asg.md), [Lab 14 – VNet Peering & VPN Gateway](../04-networking/labs/lab14-vnet-peering-vpn.md), [Lab 15 – Load Balancer & Application Gateway](../04-networking/labs/lab15-load-balancer-app-gateway.md), [Lab 16 – DNS & Name Resolution](../04-networking/labs/lab16-dns-name-resolution.md) |
| 5 | Monitor and maintain Azure resources (10–15%) | [Module 05 – Monitor & Maintain](../05-monitor-maintain/README.md) | [Lab 17 – Azure Monitor & Alerts](../05-monitor-maintain/labs/lab17-azure-monitor-alerts.md), [Lab 18 – Backup & Recovery](../05-monitor-maintain/labs/lab18-backup-recovery.md), [Lab 19 – Network Monitoring Tools](../05-monitor-maintain/labs/lab19-network-monitoring.md) |

## Suggested order

Work top to bottom — later labs reuse resources (VNets, RGs, VMs) created in
earlier ones. Each lab states which prior labs it depends on under
**Prerequisites**.

Before starting, read [00-prerequisites](../00-prerequisites/README.md) once
for the cloud/networking/identity vocabulary used throughout.
