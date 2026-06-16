# Azure Portal Navigation

> [Prerequisites](README.md) for the [AZ-104 course](../README.md)

## Why this matters

Every lab in this course is written for the Azure Portal at
[portal.azure.com](https://portal.azure.com). If you've never used it
before, a few minutes learning the layout will make every lab's
instructions much faster to follow.

## The basics

- **Search bar** (top of every page): the fastest way to get anywhere. Type
  a service name (e.g., "Virtual machines", "Resource groups") and select it
  from the results. Every lab in this course starts with "Search for
  **\<service\>**" — this is what that means.
- **Blade**: the Portal's term for a panel/page. Clicking into a resource
  opens its "blade," which has a left-hand menu of sections (Overview,
  Settings, Monitoring, etc.).
- **+ Create**: the button to start creating a new resource. Creation
  wizards are organized into **tabs** (Basics, Networking, Management,
  Tags, Review + create) — labs reference these by tab name.
- **Review + create**: the final tab of almost every creation wizard. Azure
  validates your configuration here before letting you click **Create**.

## Resource groups

A **resource group** is a logical container for related resources. Nearly
every lab's first step is creating a resource group (named `rg-az104-labXX`
by convention — see [Naming Conventions](../README.md#naming-conventions)),
and the last step ("Cleanup") is deleting it — which deletes everything
inside it in one action. This keeps costs predictable: if you forget
anything else, deleting the resource group cleans it up.

## Useful Portal features used throughout this course

- **Resource groups > \<name\> > Overview**: shows all resources in the
  group — useful for confirming what you've created so far.
- **All resources**: a flat view of everything in your subscription,
  filterable by resource group, type, or location.
- **Notifications** (bell icon, top right): shows deployment progress —
  useful when a "Create" action takes a few minutes (e.g., VMs, gateways).
- **Cloud Shell** (terminal icon, top right): gives you a browser-based CLI.
  **Not used in this course** — every lab is deliberately Portal-only — but
  worth knowing it exists, since some Microsoft Learn docs default to it.

## Cost awareness

The Portal shows estimated costs in some creation wizards (e.g., VM size
selection shows an hourly estimate). Combined with the **Cost tip** repeated
throughout this course — always run each lab's **Cleanup** section — this is
enough to keep a free/trial subscription's spend near zero.

## See also

- [Cloud Computing Fundamentals](01-cloud-computing-fundamentals.md)
- [Module 01 – Identity & Governance](../01-identity-governance/README.md) (first hands-on module)
