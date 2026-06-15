# Lab 03 – Management Groups, Subscriptions & Resource Organization

## Objectives
- Create a management group hierarchy
- Move a subscription into a management group
- Organize resources using resource groups, tags, and locks
- Understand cost management basics (budgets, cost analysis)

## Prerequisites
- Global Administrator or User Access Administrator with root management group access
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time
30 minutes

---

## Part 1 – Create a management group hierarchy

1. Search for **Management groups**.
2. Select **Add management group**. Set **Management group ID** to `mg-contoso`
   and a display name, then **Save**.
3. Select **Add management group** again for `mg-corp`. After it's created,
   open it, go to **Details**, select **Change parent**, and set the parent to
   `mg-contoso`.
4. Repeat step 3 to create `mg-sandbox` and set its parent to `mg-contoso` as well.

Resulting hierarchy:
```
Root (Tenant Root Group)
└── mg-contoso
    ├── mg-corp
    └── mg-sandbox
```

## Part 2 – Move your subscription under mg-sandbox

1. **Management groups** > select `mg-sandbox` > **Subscriptions** tab.
2. Select **Add subscription**, choose your subscription from the list, and
   confirm the move.

> Policies/RBAC assigned at `mg-contoso` or `mg-sandbox` now apply to this subscription.

## Part 3 – Resource groups and tagging strategy

1. Search for **Resource groups** > **Create**.
2. **Resource group**: `rg-az104-lab03`. **Region**: `East US`.
3. On the **Tags** tab, add:
   - `Environment` = `Lab`
   - `CostCenter` = `Training`
   - `Owner` = `yourname`
4. **Review + create** > **Create**.

If you need to add or change tags on an existing resource group later, open
the resource group > **Tags** (left-hand menu or **Overview** page) > add/edit
the name-value pairs > **Save**.

## Part 4 – Resource locks

1. Open `rg-az104-lab03` > **Locks** (under **Settings**).
2. Select **Add**. **Lock name**: `lock-no-delete`. **Lock type**: **Delete**
   (this is the Portal's label for **CanNotDelete**).
3. **OK**.
4. Try to delete the resource group: **Overview** > **Delete resource group**,
   type the name to confirm, and select **Delete**. It should fail with a
   message that the resource group is locked.
5. To explore the other lock type, select a single resource (e.g., the storage
   account from Lab 02) > **Locks** > **Add** > **Lock type**: **Read-only**.
   Observe that you can still view the resource's properties, but any attempt
   to edit or delete it is blocked.
6. Remove the **Read-only** lock from that resource afterwards so it doesn't
   interfere with other labs.

## Part 5 – Cost Management basics

1. Go to **Cost Management + Billing** > **Cost analysis**. Filter by
   `rg-az104-lab03` using the **Resource group** filter.
2. **Budgets** > **Add** — create a budget of $10/month scoped to
   `rg-az104-lab03`, with an alert at 80% via email.
3. Review **Advisor** > **Cost** recommendations (may be empty in a new sandbox).

## Validation
- [ ] Management group hierarchy `mg-contoso > mg-corp, mg-sandbox` exists
      (**Management groups** view)
- [ ] Subscription is a child of `mg-sandbox`
- [ ] `rg-az104-lab03` has `Environment`/`CostCenter`/`Owner` tags (check the
      **Tags** page)
- [ ] `lock-no-delete` (**Delete** lock) prevents resource group deletion
- [ ] A budget alert exists for `rg-az104-lab03` (**Cost Management + Billing** >
      **Budgets**)

## Cleanup
1. `rg-az104-lab03` > **Locks** > select `lock-no-delete` > **Delete**.
2. **Resource groups** > select `rg-az104-lab03` > **Delete resource group**
   (type the name to confirm).
3. (Optional) **Management groups** > `mg-sandbox` > **Subscriptions** tab >
   move your subscription back to the tenant root group.
4. **Management groups** > select `mg-sandbox`, `mg-corp`, then `mg-contoso`
   (children first) > **Details** > **Delete**.
5. Remove the budget via **Cost Management + Billing** > **Budgets**.

## Exam Tips
- Management group hierarchy max depth: 6 levels (excluding root and subscription/resource levels).
- A subscription can only belong to **one** management group at a time.
- Lock types: **Read-only** (no writes/deletes) vs **Delete**/`CanNotDelete` (writes ok, no delete). Locks apply to child resources too and override RBAC permissions (even Owners are blocked).
- Tags don't inherit automatically from RG to resources unless you use Azure Policy `Modify`/`Inherit a tag` policies.
