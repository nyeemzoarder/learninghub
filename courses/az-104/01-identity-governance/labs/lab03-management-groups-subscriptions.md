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

### Why Management Groups?

> Important: Management Groups are the FOUNDATION of Azure governance at scale. Policies and RBAC assigned at MG level apply to all subscriptions beneath them.

### Step 1: Create the hierarchy

1. Search for **Management groups**
2. Select **Add management group** > **Management group ID**: `mg-contoso` > **Save**
3. Select **Add management group** again > **Management group ID**: `mg-corp` > **Save**
4. Open `mg-corp` > **Details** > **Change parent** > select `mg-contoso`
5. Repeat for `mg-sandbox` with parent = `mg-contoso`

### Resulting structure:

```
Root (Tenant Root Group)
└── mg-contoso
    ├── mg-corp
    └── mg-sandbox
```

> Tip: The Tenant Root Group is automatic. You create everything beneath it. Deep hierarchies (3+ levels) are common in large enterprises.

---

## Part 2 – Move subscription under management group

### Step 1: Associate subscription with MG

1. **Management groups** > select `mg-sandbox` > **Subscriptions** tab
2. Select **Add subscription** > choose your subscription > confirm move

> Important: Policies and RBAC assigned at `mg-contoso` or `mg-sandbox` now apply automatically to this subscription and all resources in it.

### Step 2: Verify the move

1. Go back to **Management groups** > select each MG to confirm your subscription appears under `mg-sandbox`

---

## Part 3 – Resource groups and tagging strategy

### Understanding Tags

> Tip: Tags are KEY for cost allocation, automation, and compliance reporting. Always tag resources at creation time—adding tags later is error-prone.

### Step 1: Create resource group with tags

1. Search for **Resource groups** > **Create**
2. **Resource group**: `rg-az104-lab03`  
   **Region**: `East US`
3. **Tags** tab: add the following:
   - Key: `Environment` → Value: `Lab`
   - Key: `CostCenter` → Value: `Training`
   - Key: `Owner` → Value: `yourname`
4. **Review + create** > **Create**

### Step 2: Update tags on existing resources

If you need to modify tags later:

1. Open the resource group > **Tags** (left menu)
2. Edit name-value pairs > **Save**

> Warning: Portal doesn't warn you before overwriting tags. Be careful when bulk-updating tags on many resources.

---

## Part 4 – Resource locks (prevent accidents)

### Lock Types

| Lock Type | What It Prevents | Use Case |
|-----------|-----------------|----------|
| **Delete** | Deletion | Prevent accidental resource group removal |
| **Read-only** | Any modification | Lock down production resources |

### Step 1: Apply Delete lock

1. Open `rg-az104-lab03` > **Locks** (under **Settings**)
2. Select **Add**:
   - **Lock name**: `lock-no-delete`
   - **Lock type**: **Delete**
3. **OK**

### Step 2: Test the Delete lock

1. Go to **Overview** > **Delete resource group**
2. Type the name to confirm deletion
3. Click **Delete**
4. Expect this error:

```
The resource group is locked and cannot be deleted.
Lock name: lock-no-delete
```

This proves the lock is working! ✓

### Step 3: Test Read-only lock

1. Select a resource (e.g., storage account from Lab 02)
2. **Locks** > **Add** > **Lock type**: **Read-only** > **OK**
3. Try to edit properties or delete—both will be blocked
4. **Remove the Read-only lock** afterward so it doesn't interfere with other labs

---

## Part 5 – Cost Management basics

### Step 1: Analyze costs

1. Go to **Cost Management + Billing** > **Cost analysis**
2. Filter by **Resource group** = `rg-az104-lab03`
3. Observe current costs (may be $0.00 in sandbox)

> Tip: Cost analysis updates with a 24-48 hour delay. This lab shows the UI, but real data takes time to populate.

### Step 2: Set a budget alert

1. **Cost Management + Billing** > **Budgets** > **Add**
2. **Name**: `lab03-budget`
3. **Amount**: $10 (per month)
4. **Scope**: `rg-az104-lab03`
5. **Alert thresholds**: set email alert at **80%**
6. **Create**

### Step 3: Check Advisor recommendations

1. Go to **Advisor** > **Cost**
2. Review any recommendations (may be empty in a new sandbox)

---

## Success Criteria

✓ Management group hierarchy exists: `mg-contoso` > `mg-corp` and `mg-sandbox`  
✓ Your subscription is child of `mg-sandbox`  
✓ `rg-az104-lab03` has all three tags: `Environment`, `CostCenter`, `Owner`  
✓ Delete lock `lock-no-delete` prevents resource group deletion  
✓ Budget alert configured for `rg-az104-lab03`

---

## Cleanup (If Needed)

To clean up all resources created in this lab:

```powershell
# Remove Delete lock
Remove-AzManagementGroupDeployment -ResourceGroupName "rg-az104-lab03" -Name "lock-no-delete"

# Delete resource group
Remove-AzResourceGroup -Name "rg-az104-lab03" -Force

# Move subscription back to tenant root
Update-AzManagementGroup -GroupId "mg-sandbox" -Remove

# Delete management groups (children first!)
Remove-AzManagementGroup -GroupId "mg-sandbox" -AsJob
Remove-AzManagementGroup -GroupId "mg-corp" -AsJob
Remove-AzManagementGroup -GroupId "mg-contoso" -AsJob

# Remove budget
Remove-AzBudget -Name "lab03-budget" -ResourceGroupName "rg-az104-lab03"
```

---

## Key Takeaways

- **Management Groups** = governance at subscription level (multiple subscriptions)
- **Subscriptions** = billing boundary (one per department/project)
- **Resource Groups** = organizing container for resources
- **Tags** = metadata for cost allocation, automation, compliance
- **Locks** = safety mechanism to prevent accidental deletion/modification
- **Cost Management** = understand and control Azure spending

---

## Next Steps

Proceed to Lab 04 to learn about storage accounts and data organization.
