# Module 01 – Identity & Governance

> Part of the [AZ-104 course](../README.md).

## Before you start

- [Identity & Access Fundamentals](../00-prerequisites/03-identity-and-access-fundamentals.md) —
  authentication vs. authorization, tenants, and how Entra ID roles differ
  from Azure RBAC roles
- [Cloud Computing Fundamentals](../00-prerequisites/01-cloud-computing-fundamentals.md) —
  the resource hierarchy (management group → subscription → resource group)

## Learning objectives

By the end of this module you should be able to:
- Create and manage users, groups, and administrative units in Microsoft
  Entra ID, including group-based licensing and SSPR
- Assign built-in and custom RBAC roles at different scopes, and understand
  scope inheritance
- Create and assign Azure Policy definitions/initiatives to enforce tagging
  and allowed locations
- Build a management group hierarchy and organize resources using resource
  groups, tags, and locks

## Concepts

- [Entra ID Overview](concepts/01-entra-id-overview.md) — tenants, users,
  groups, administrative units, and licensing
- RBAC Fundamentals — *TODO*
- Management Groups & Policy — *TODO*

## Diagrams

- [Entra ID & RBAC Scope Hierarchy](diagrams/entra-id-rbac-hierarchy.drawio) —
  open in [diagrams.net](https://app.diagrams.net) (File > Open from > Device)

## Labs

Work through in order — later labs may reuse resources from earlier ones:

1. [Lab 01 – Entra ID: Users, Groups & Administrative Units](labs/lab01-entra-users-groups.md)
2. [Lab 02 – RBAC & Azure Policy](labs/lab02-rbac-azure-policy.md)
3. [Lab 03 – Management Groups, Subscriptions & Resource Organization](labs/lab03-management-groups-subscriptions.md)

## Exam domain

Maps to **Manage Azure identities and governance (20–25%)** — see the
[exam blueprint](../resources/exam-blueprint.md) for the full breakdown.
