# Prerequisites — General Foundations

> Part of the [AZ-104 course](../README.md).

Read this module **once**, before starting Module 01. It covers the
background concepts that the rest of the course assumes you already have:
basic cloud computing vocabulary, enough networking to understand VNets and
DNS, identity concepts that underpin Entra ID and RBAC, and how to find your
way around the Azure Portal.

If you're already comfortable with a topic, skip its doc — each module's
"Before you start" section links back to the specific doc it relies on, so
you can always jump back here later.

## Contents

1. [Cloud Computing Fundamentals](concepts/01-cloud-computing-fundamentals.md) —
   IaaS/PaaS/SaaS, regions and availability zones, the shared responsibility
   model
2. [Networking Basics](concepts/02-networking-basics.md) — IP addressing, CIDR
   notation, subnets, DNS, routing — needed before Module 04 (Networking)
3. [Identity & Access Fundamentals](concepts/03-identity-and-access-fundamentals.md) —
   authentication vs. authorization, directories, roles — needed before
   Module 01 (Identity & Governance)
4. [Azure Portal Navigation](concepts/04-azure-portal-navigation.md) — blades,
   resource groups, search, and the scope of this course (Portal-only)

## How these labs are scoped

Every lab in this course is written for the **Azure Portal** —
[portal.azure.com](https://portal.azure.com). No Azure CLI, PowerShell, or
Bicep/ARM knowledge is assumed (the one exception, Lab 07, is an optional
deep-dive into ARM/Bicep templates and is called out separately in the
[Compute module](../03-compute/README.md)).
