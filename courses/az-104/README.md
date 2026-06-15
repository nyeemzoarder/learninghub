# AZ-104: Microsoft Azure Administrator

A self-paced, modular course covering the AZ-104 exam skills outline using
the Azure Portal. Each module pairs **concept docs** (the why/how, with
worked examples), **diagrams** (draw.io architecture visuals), and
**hands-on labs** (step-by-step Portal walkthroughs with validation and
cleanup).

## Start here

1. [00 – Prerequisites](00-prerequisites/README.md) — general foundations:
   cloud computing basics, networking basics, identity fundamentals, and
   Azure Portal navigation. Read once before Module 01.
2. Work through Modules 01–05 in order (see [exam blueprint](resources/exam-blueprint.md)
   for the full domain/lab map).

## Prerequisites (Azure account)

- An Azure subscription (a [free account](https://azure.microsoft.com/free/) with credit is fine for most labs)
- Signed in at [portal.azure.com](https://portal.azure.com)
- A web browser (Microsoft Edge, Chrome, Firefox, Safari, or similar)

> **Cost tip:** Always run the *Cleanup* section at the end of each lab via
> the **Delete resource group** Portal action. Several labs deploy VMs,
> gateways, or Bastion hosts that incur hourly charges.

## Modules

| Module | Exam Domain (approx. weight) |
|--------|-------------------------------|
| [00 – Prerequisites](00-prerequisites/README.md) | — (foundations, not exam-weighted) |
| [01 – Identity & Governance](01-identity-governance/README.md) | Manage Azure identities and governance (20–25%) |
| [02 – Storage](02-storage/README.md) | Implement and manage storage (15–20%) |
| [03 – Compute](03-compute/README.md) | Deploy and manage Azure compute resources (20–25%) |
| [04 – Networking](04-networking/README.md) | Implement and manage virtual networking (15–20%) |
| [05 – Monitor & Maintain](05-monitor-maintain/README.md) | Monitor and maintain Azure resources (10–15%) |

Full domain-to-lab mapping: [resources/exam-blueprint.md](resources/exam-blueprint.md)

## A note on Lab 07

Every lab in this course is Portal-only, **except Lab 07** (ARM Templates &
Bicep) in Module 03 — kept in its original Azure CLI/Bicep form as an
optional infrastructure-as-code deep-dive. Skip it freely; no other lab
depends on it.

## Resources

- [Glossary](resources/glossary.md) — cross-module term reference
- [Exam blueprint](resources/exam-blueprint.md) — domain weights and lab map
- [Cheat sheets](resources/cheat-sheets/README.md) — quick-reference tables

## Naming conventions used throughout

- Resource group per lab: `rg-az104-lab##`
- Region: `eastus` (swap for your preferred region — keep it consistent across labs)
- Admin username: `azureuser`

## Module folder structure

Each module follows the same shape (see [_templates/](../../_templates/) for
the templates used to create new content):

```
0X-module-name/
├── README.md       # objectives, concept/lab/diagram index
├── concepts/        # theory + worked examples
├── diagrams/         # .drawio architecture diagrams
└── labs/             # step-by-step Portal labs
```
