# Identity & Access Fundamentals

> [Prerequisites](README.md) for the [AZ-104 course](../README.md)

## Why this matters

Identity & Governance is the **largest single domain** on the AZ-104 exam
(20–25%). Module 01 builds directly on the concepts below — read this first
if terms like "tenant," "directory," or "role-based access" are new to you.

## Authentication vs. authorization

These two terms are often confused but mean different things:

- **Authentication (AuthN)** — *proving who you are* (e.g., signing in with a
  username and password, or MFA).
- **Authorization (AuthZ)** — *what you're allowed to do once you're signed
  in* (e.g., can you create a VM in this subscription?).

Microsoft Entra ID (formerly Azure AD) handles **authentication**.
**Role-Based Access Control (RBAC)** handles **authorization**. Module 01
covers both — Lab 01 focuses on Entra ID identities, Lab 02 on RBAC.

## Tenants and directories

A **Microsoft Entra tenant** (directory) is a dedicated, isolated instance of
Entra ID — essentially "your organization's identity database" in the cloud.
When you sign up for Azure, a tenant is created automatically. Every
**user**, **group**, and **app registration** lives inside a tenant.

**Example:** Your organization `contoso.com` has one Entra tenant. All
employees' user accounts, the security groups they belong to, and any
custom applications registered for SSO all live in that one tenant — even if
the organization has multiple Azure *subscriptions* (billing/resource
containers) underneath it.

> A tenant is *not* the same as a subscription. One tenant can be linked to
> many subscriptions; Module 01 (Lab 03) covers how subscriptions,
> management groups, and resource groups relate.

## Users, groups, and roles

- A **user** is an identity that can sign in (a person, or in some cases a
  service).
- A **group** is a collection of users (and/or other groups) — used to
  assign permissions or licenses to many users at once instead of
  individually.
- A **role** is a named set of permissions. Entra ID has built-in
  **administrator roles** (e.g., *User Administrator*, *Global Administrator*)
  that control what someone can do *to the directory itself* (manage users,
  reset passwords, etc.) — distinct from Azure RBAC roles, which control what
  someone can do *to Azure resources* (VMs, storage, networks).

| | Entra ID roles | Azure RBAC roles |
|---|------------------|---------------------|
| Controls access to | The directory (users, groups, licenses) | Azure resources (subscriptions, resource groups, individual resources) |
| Example role | *User Administrator* | *Contributor*, *Reader*, *Virtual Machine Contributor* |
| Covered in | Lab 01 | Lab 02 |

## Why this distinction matters on the exam

A classic exam scenario: "User A can sign in but can't create any resources."
This is almost always an **Azure RBAC** problem (no role assignment on the
subscription/resource group), not an Entra ID problem — because *signing in
successfully* already proves authentication works. Knowing which layer
(AuthN vs. AuthZ) a symptom points to is a recurring exam pattern.

## See also

- [Glossary](../resources/glossary.md)
- [Module 01 – Identity & Governance](../01-identity-governance/README.md)
- [RBAC Fundamentals](../01-identity-governance/concepts/02-rbac-fundamentals.md)
