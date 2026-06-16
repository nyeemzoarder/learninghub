# Lab 02 – Role-Based Access Control (RBAC) & Azure Policy

## Objectives

- Assign built-in roles at different scopes (subscription, resource group, resource)
- Create a custom RBAC role
- Create and assign an Azure Policy definition and initiative
- Use Policy to enforce tagging and allowed locations

## Prerequisites

- Owner or User Access Administrator on the subscription
- Lab 01 users/groups (optional, can use any test user)

## Estimated time

45 minutes

---

## Part 1 – Create a resource group for this lab

### Step 1: Create resource group

1. Search for **Resource groups** > **Create**
2. **Subscription**: your subscription. **Resource group**: `rg-az104-lab02`
   **Region**: `East US`
3. Select **Review + create** > **Create**

> Tip: Resource groups are free containers. Always organize resources into RGs by project, environment, or cost center.

---

## Part 2 – Assign built-in roles

### Understanding RBAC Scopes

> Important: RBAC assignments inherit down the hierarchy. Subscription → Resource Group → Resource. An assignment at the RG level applies to all resources within it.

### Step 1: Assign Reader role at Resource Group scope

1. Go to **rg-az104-lab02** > **Access control (IAM)** > **Add** > **Add role assignment**
2. **Role** tab: select **Reader**. Select **Next**
3. **Members** tab: 
   - **Assign access to** = **User, group, or service principal**
   - **Select members** > choose `grp-az104-lab` (from Lab 01)
4. **Review + assign**

### Step 2: Assign Storage role at Resource scope

> Warning: Resource-level assignments are more restrictive. Bob here can only access this one storage account, not others in the RG.

1. Create a storage account (or use one from Lab 04)
2. Open the storage account > **Access control (IAM)** > **Add role assignment**
3. Role = **Storage Blob Data Contributor** > assign to **Bob**
   - This grants Bob access **only** at this storage account scope, not the whole RG

### Step 3: View current assignments

1. Go to **Access control (IAM)** > **Role assignments** tab
2. Filter by role, user, or scope as needed

---

## Part 3 – Create a custom role

### Why Custom Roles?

> Tip: Built-in roles like "Virtual Machine Contributor" are too broad. Custom roles let you grant minimal permissions—only what's needed.

### Step 1: Start custom role

1. Go to the subscription > **Access control (IAM)** > **Add** > **Add custom role**
2. **Basics** tab:
   - **Custom role name**: `VM Operator (Start/Stop only)`
   - **Description**: `Can start and restart VMs but not create or delete them`
   - **Baseline permissions**: **Clone a role** > select **Virtual Machine Contributor**

### Step 2: Edit permissions

1. **Permissions** tab: select **Edit permissions in JSON**
2. Replace the `actions`/`notActions` arrays with:

```json
{
  "actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/restart/action",
    "Microsoft.Compute/virtualMachines/read"
  ],
  "notActions": []
}
```

3. **Assignable scopes** tab: confirm scope is your subscription

### Step 3: Assign custom role

1. **Access control (IAM)** > **Add role assignment**
2. Search for **VM Operator (Start/Stop only)** under **Custom roles**
3. Assign to `carol@<yourtenant>.onmicrosoft.com` at `rg-az104-lab02` scope

---

## Part 4 – Azure Policy: enforce required tags

### Understanding Policy

> Important: Policies PREVENT creation/modification of resources that don't comply. Unlike RBAC (who can do what), Policy (what is allowed to be created).

### Step 1: Find and assign policy

1. Search for **Policy** > **Definitions**
2. Search for **"Require a tag on resource groups"**
3. Select it > **Assign**
4. **Basics** tab: **Scope** = your subscription
5. **Parameters** tab: set `Tag Name` = `CostCenter`
6. **Effect**: confirm it's **Deny** (blocks creation without tag)
7. **Review + create** > **Create**

### Step 2: Test the policy

> Warning: This will block resource creation. Expect a policy error.

1. Go to **Resource groups** > **Create**
2. Name: `rg-policy-test`, Region: `East US`
3. Select **Review + create** and expect this error:

```
RequestDisallowedByPolicy
The request is denied by an Azure policy.
Reason: Resource group does not have required tags.
```

4. **Do not proceed** past this validation error
5. This proves the policy is working!

---

## Part 5 – Azure Policy: enforce allowed locations

### Step 1: Create initiative (multi-policy)

1. Go to **Policy** > **Definitions** > **+ Policy Definition**
2. **Name**: `Allowed Azure Locations`
3. **Category**: **General**
4. **Description**: `Restrict resource creation to approved regions only`
5. **Policy rule** (replace template with):

```json
{
  "policyRule": {
    "if": {
      "not": {
        "field": "location",
        "in": [
          "East US",
          "West US",
          "West Europe"
        ]
      }
    },
    "then": {
      "effect": "Deny"
    }
  }
}
```

6. **Review + create** > **Create**

### Step 2: Assign the policy

1. **Policy** > **Assignments** > **Assign Policy**
2. **Scope**: your subscription
3. **Policy definition**: select `Allowed Azure Locations`
4. **Effect**: **Deny**
5. **Review + create** > **Assign**

### Step 3: Test the policy

1. Try to create a resource in **Central US** (not in the allowed list)
2. Expect a **Deny** error
3. Try creating in **East US** (in the allowed list)
4. Should succeed

---

## Success Criteria

✓ Resource group `rg-az104-lab02` created
✓ Reader role assigned to group at RG scope
✓ Storage Blob Data Contributor assigned to Bob at resource scope
✓ Custom role `VM Operator (Start/Stop only)` created and assigned
✓ Tag policy prevents resource group creation without `CostCenter` tag
✓ Location policy allows only East US, West US, West Europe

---

## Cleanup (If Needed)

To remove policies and role assignments:

```powershell
# Remove policy assignments
Remove-AzPolicyAssignment -Name "Require a tag on resource groups" -Scope "/subscriptions/[subscription-id]"
Remove-AzPolicyAssignment -Name "Allowed Azure Locations" -Scope "/subscriptions/[subscription-id]"

# Remove custom role
Remove-AzRoleDefinition -Id "[role-id]" -Force

# Remove resource group (includes all resources inside)
Remove-AzResourceGroup -Name "rg-az104-lab02" -Force
```

> Tip: Keeping test RGs around helps you learn. Only delete if you're confident you won't need them.

---

## Key Takeaways

- **RBAC** = WHO can do WHAT (identity-based)
- **Policy** = WHAT resources can be created (compliance-based)
- **Scopes matter**: Assignment at subscription affects all RGs; assignment at RG affects only resources in that RG
- **Least privilege**: Custom roles let you grant only what's needed
- **Policy prevents**: Unlike RBAC (which is permissive), Policy actively prevents non-compliant operations

---

## Next Steps

Proceed to Lab 03 to learn about Management Groups and subscription organization at scale.
