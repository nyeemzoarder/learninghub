# Cloud Computing Fundamentals

> [Prerequisites](../README.md) for the [AZ-104 course](../../README.md)

## Why this matters

AZ-104 assumes you understand the basic vocabulary of cloud computing —
service models, regions, and who is responsible for what. This shows up
throughout the exam, especially in questions about availability, disaster
recovery, and choosing between services.

## Service models: IaaS, PaaS, SaaS

| Model | What the provider manages | What you manage | Azure examples |
|-------|---------------------------|------------------|-----------------|
| **IaaS** (Infrastructure as a Service) | Physical hardware, virtualization, networking | OS, runtime, apps, data | Virtual Machines, Virtual Networks |
| **PaaS** (Platform as a Service) | Infrastructure + OS + runtime | Apps and data | App Service, Azure SQL Database |
| **SaaS** (Software as a Service) | Everything, including the application | Your data/config only | Microsoft 365, Dynamics 365 |

**Example:** Running a web app on a VM you configure yourself (install IIS or
nginx, patch the OS) is **IaaS**. Deploying the same app to **App Service**
— where Azure handles the OS and runtime — is **PaaS**. AZ-104 covers both
(Module 03 – Compute includes VMs *and* App Service).

## The shared responsibility model

As you move from IaaS → PaaS → SaaS, Microsoft takes on more responsibility
and you take on less. But **security of your data, identities, and access
management is always your responsibility**, regardless of model. This is why
Identity & Governance (Module 01) is weighted so heavily on the exam — it's
the part you always own.

## Regions, region pairs, and availability zones

- A **region** is a set of Microsoft datacenters in a geographic area (e.g.,
  *East US*). Most resources are deployed to a specific region.
- An **availability zone (AZ)** is a physically separate datacenter (with
  independent power, cooling, networking) *within* a region. Regions that
  support AZs typically have 3.
- A **region pair** is a pre-defined pairing of two regions in the same
  geography (e.g., *East US* ↔ *West US*) used for disaster recovery —
  services like geo-redundant storage (GRS) replicate to the paired region.

**Example:** Deploying VMs across **3 availability zones** in *East US*
protects against a datacenter-level failure (power/cooling outage in one
building). Enabling **GRS** on a storage account in *East US* additionally
protects against a *regional* disaster by replicating data to *West US*.

You'll see AZs again in Module 03 (VM availability) and region pairs again in
Module 02 (storage redundancy) and Module 05 (Azure Site Recovery).

## Resource hierarchy (preview)

Azure organizes everything under a hierarchy:

```
Management Group
  └── Subscription
        └── Resource Group
              └── Resource (VM, storage account, VNet, ...)
```

Module 01 covers this hierarchy in depth (management groups, subscriptions,
resource groups, and how policies/RBAC apply at each level). For now, just
know that every resource you create in these labs lives inside a
**resource group** — which is why every lab's cleanup step is "delete the
resource group."

## See also

- [Glossary](../../resources/glossary.md)
- [Module 01 – Identity & Governance](../../01-identity-governance/README.md)
