# Compute Options Comparison

> Module: [03 – Compute](../README.md)

## Why this matters

This module covers four different ways to run a workload in Azure (VMs, VM
Scale Sets, containers via ACI, and App Service). Exam scenarios often
describe a workload's requirements and ask which compute option fits best —
the comparison below is the fastest way to reason through those questions.

## Core idea

All four options run *your code or container*, but they differ in how much
of the stack you manage and how they handle scaling:

- **Virtual Machines (VMs)** — full IaaS. You manage the OS, patching,
  scaling.
- **Virtual Machine Scale Sets (VMSS)** — a group of identical VMs that scale
  in/out automatically based on rules. Still IaaS, but Azure handles adding/
  removing instances.
- **Azure Container Instances (ACI)** — run a single container (or container
  group) without managing any VM. Fast startup, billed per second.
- **App Service** — PaaS for web apps/APIs. You deploy code or a container;
  Azure manages the OS, runtime, and scaling (via an App Service Plan).

## How it works

| | VM | VMSS | ACI | App Service |
|---|----|------|-----|-------------|
| You manage OS? | Yes | Yes (per instance, but uniform) | No | No |
| Scaling | Manual (resize/add VMs) | Automatic (autoscale rules) | None (per-container) | Automatic (autoscale on App Service Plan) |
| Startup time | Minutes | Minutes | Seconds | Seconds (already running) |
| Billing | Per VM, while running | Per VM instance, while running | Per second, while running | Per App Service Plan tier |
| Best for | Custom OS configs, legacy apps, full control | Stateless workloads needing elastic scale (web tier, batch) | Short-lived/burst jobs, simple single-container workloads | Web apps/APIs where you don't want to manage infrastructure |
| Covered in | Lab 08 | Lab 09 | Lab 10 | Lab 11 |

> AKS (Azure Kubernetes Service) is mentioned for comparison in Lab 10 but is
> **not** an AZ-104 deployment target in this course — AZ-104 expects you to
> *know it exists* and roughly when you'd choose it over ACI (many containers,
> complex orchestration needs), not to operate a cluster.

## Example

A team needs to run a stateless web API that gets a traffic spike every
weekday morning and is idle overnight.

- A single **VM** would be wasteful (paying for idle capacity overnight) or
  under-provisioned (can't handle the morning spike without manual resizing).
- **VMSS** with autoscale rules (scale out when CPU > 70%, scale in when CPU
  < 20%) handles the spike automatically — but the team still patches the OS
  image.
- **App Service** with autoscale is the best fit if the API is a standard web
  framework (.NET, Node, Python, etc.) — no OS management, and the autoscale
  experience is similar to VMSS but fully PaaS.
- **ACI** would suit a short batch job (e.g., a nightly report generator) far
  better than a long-running API, since it's billed per second and has no
  built-in scaling for sustained load.

## Related diagram

See [compute-options-comparison.drawio](../diagrams/compute-options-comparison.drawio)
for a visual of the IaaS→PaaS spectrum these four options sit on.

## Common pitfalls / exam traps

- **VMSS ≠ Availability Set** — an Availability Set (Lab 09) is a *static*
  grouping for fault/update domain spreading; VMSS *dynamically* adds/removes
  instances.
- **ACI has no built-in autoscaling** — for container workloads that need to
  scale, the exam expects you to know AKS or App Service for Containers is
  the better fit, not ACI.
- **App Service Plan tier** determines available features (deployment slots
  require Standard tier or higher) and is billed regardless of how many apps
  run on it — multiple web apps can share one plan.

## See also

- [Lab 08 – Virtual Machines](../labs/lab08-virtual-machines.md)
- [Lab 09 – VM Availability & Scaling](../labs/lab09-vm-availability-scaling.md)
- [Lab 10 – Containers (ACI & ACR)](../labs/lab10-containers-aci-acr.md)
- [Lab 11 – Azure App Service](../labs/lab11-app-service.md)
- [Glossary](../../resources/glossary.md)
