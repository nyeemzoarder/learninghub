# Module 03 – Compute

> Part of the [AZ-104 course](../README.md).

## Before you start

- [Cloud Computing Fundamentals](../00-prerequisites/01-cloud-computing-fundamentals.md) —
  IaaS vs. PaaS (VMs vs. App Service/containers), availability zones

## Learning objectives

By the end of this module you should be able to:
- Deploy Linux and Windows VMs, configure sizing/disks/extensions, and
  connect via SSH/RDP/Bastion
- Deploy VMs into availability sets and across availability zones, and build
  a Virtual Machine Scale Set with autoscale
- Build and push container images with ACR and run them with ACI
- Deploy an App Service web app with deployment slots, scaling, and autoscale
- (Optional deep-dive) Author and deploy ARM/Bicep templates

## A note on Lab 07

Every other lab in this course is Portal-only. **Lab 07 (ARM Templates &
Bicep)** is the one exception — it's an Azure CLI/Bicep walkthrough, kept in
its original form as an **optional deep-dive** for learners who want
infrastructure-as-code exposure. You can skip it without missing any
Portal-based exam objective covered elsewhere in this module.

## Concepts

- [Compute Options Comparison](concepts/01-compute-options-comparison.md) —
  VMs vs. VM Scale Sets vs. Containers (ACI) vs. App Service
- VM Availability Options — *TODO*
- App Service Deployment Slots — *TODO*

## Diagrams

- [Compute Options Comparison](diagrams/compute-options-comparison.drawio) —
  open in [diagrams.net](https://app.diagrams.net) (File > Open from > Device)

## Labs

Work through in order — later labs may reuse resources from earlier ones:

1. [Lab 07 – ARM Templates & Bicep](labs/lab07-arm-bicep-templates.md) *(optional, CLI/Bicep)*
2. [Lab 08 – Virtual Machines](labs/lab08-virtual-machines.md)
3. [Lab 09 – VM Availability & Scaling](labs/lab09-vm-availability-scaling.md)
4. [Lab 10 – Containers (ACI & ACR)](labs/lab10-containers-aci-acr.md)
5. [Lab 11 – Azure App Service](labs/lab11-app-service.md)

## Exam domain

Maps to **Deploy and manage Azure compute resources (20–25%)** — see the
[exam blueprint](../resources/exam-blueprint.md) for the full breakdown.
