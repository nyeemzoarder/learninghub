# Lab 02 – Role-Based Access Control (RBAC) & Azure Policy

## Objectives
- Assign built-in roles at different scopes (subscription, RG, resource)
- Create a custom RBAC role
- Create and assign an Azure Policy definition and an initiative
- Use Policy to enforce tagging and allowed locations

## Prerequisites
- Owner or User Access Administrator on the subscription
- Lab 01 users/groups (optional, can use any test user)

## Estimated time
45 minutes

---

## Part 1 – Create a resource group for this lab

1. Search for **Resource groups** > **Create**.
2. **Subscription**: your subscription. **Resource group**: `rg-az104-lab02`.
   **Region**: `East US`.
3. Select **Review + create** > **Create**.

## Part 2 – Assign built-in roles

1. Go to **rg-az104-lab02** > **Access control (IAM)** > **Add** > **Add role assignment**.
2. Role tab: select **Reader**. Select **Next**.
3. Members tab: **Assign access to** = **User, group, or service principal** >
   **Select members** > choose `grp-az104-lab` (from Lab 01).
4. **Review + assign**.
5. Repeat at the **resource** level: create a storage account (see Lab 04 if not
   yet created). Open the storage account > **Access control (IAM)** > **Add role
   assignment** > Role = **Storage Blob Data Contributor** > assign to Bob —
   this grants Bob access only at the storage account scope, not the whole RG.
6. To list current assignments at any scope, open **Access control (IAM)** >
   **Role assignments** tab and filter as needed.

## Part 3 – Create a custom role

1. Go to the subscription (or `rg-az104-lab02`) > **Access control (IAM)** >
   **Add** > **Add custom role**.
2. **Basics** tab:
   - **Custom role name**: `VM Operator (Start/Stop only)`
   - **Description**: `Can start and restart VMs but not create or delete them`
   - **Baseline permissions**: **Clone a role** > select **Virtual Machine
     Contributor** as the starting point.
3. **Permissions** tab: select **Edit permissions in JSON** and replace the
   `actions`/`notActions` arrays so the role only includes:
   ```json
   "actions": [
     "Microsoft.Compute/virtualMachines/start/action",
     "Microsoft.Compute/virtualMachines/restart/action",
     "Microsoft.Compute/virtualMachines/read"
   ],
   "notActions": []
   ```
4. **Assignable scopes** tab: confirm the scope is your subscription (or narrow
   it to `rg-az104-lab02` using **+ Add assignable scopes**).
5. **Review + create** > **Create**.
6. Assign the new role: **Access control (IAM)** > **Add role assignment** >
   search for **VM Operator (Start/Stop only)** under **Custom roles** > assign
   it to `carol@<yourtenant>.onmicrosoft.com` at the `rg-az104-lab02` scope.

## Part 4 – Azure Policy: deny resources without a tag

1. Search for **Policy** > **Definitions** > search the built-in definition
   **"Require a tag on resource groups"**.
2. Select it > **Assign**.
3. **Basics** tab: **Scope** = your subscription.
4. **Parameters** tab: set `Tag Name` = `CostCenter`.
5. Confirm the **Effect** parameter (shown on the Parameters tab, or under
   **Advanced** depending on the definition) is set to **Deny**.
6. **Review + create** > **Create**.
7. Test it: go to **Resource groups** > **Create**, name it `rg-policy-test`,
   region `East US`, and select **Review + create**. Expect a policy validation
   error (`RequestDisallowedByPolicy`) because the `CostCenter` tag is missing —
   do not proceed past this point.

## Part 5 – Azure Policy: allowed locations initiative

1. **Policy** > **Assignments** > **Assign initiative** > search **"Allowed locations"**.
2. **Scope**: `rg-az104-lab02`. **Parameters** tab: **Allowed locations** =
   `East US`, `East US 2`.
3. **Review + create** > **Create**.
4. Test it: try to create a resource (e.g., a new storage account) inside
   `rg-az104-lab02` with **Region** set to `West US`. The **Review + create**
   step should report a policy violation and block creation.

## Part 6 – Review compliance

1. **Policy** > **Compliance** — review the compliance state for your assignments
   (state may take a few minutes to evaluate after assignment).
2. **Policy** > **Remediation** — note this is used for `DeployIfNotExists`/`Modify`
   policies (e.g., auto-enabling diagnostic settings) to bring *existing*
   non-compliant resources into compliance.

## Validation
- [ ] `grp-az104-lab` has **Reader** on `rg-az104-lab02` (check via **Access
      control (IAM)** > **Role assignments**)
- [ ] Bob has **Storage Blob Data Contributor** scoped to the storage account only
- [ ] Custom role **VM Operator (Start/Stop only)** exists under **Access control
      (IAM)** > **Roles** (filter by **Custom roles**) and is assigned to Carol
- [ ] Creating `rg-policy-test` without a `CostCenter` tag is denied
- [ ] Creating a resource in `West US` within `rg-az104-lab02` is denied

## Cleanup
1. **Policy** > **Assignments** > delete the **"Require a tag on resource
   groups"** assignment and the **"Allowed locations"** initiative assignment.
2. **rg-az104-lab02** > **Access control (IAM)** > **Role assignments** > remove
   Carol's **VM Operator (Start/Stop only)** assignment.
3. Subscription > **Access control (IAM)** > **Roles** > find **VM Operator
   (Start/Stop only)** under **Custom roles** > **...** > **Delete**.
4. **Resource groups** > select `rg-az104-lab02` > **Delete resource group**
   (type the name to confirm).
5. If `rg-policy-test` was somehow created, delete it the same way.

## Exam Tips
- RBAC = **who can do what** (data plane/management plane access). Policy = **what configurations are allowed**, regardless of who.
- Role assignments are inherited down the hierarchy: Management Group → Subscription → Resource Group → Resource.
- Deny policies block non-compliant *new* resources; `audit` only flags; `DeployIfNotExists`/`Modify` need remediation tasks for *existing* resources.
- Custom roles need **Assignable scopes** — without the right scope, the role can't be assigned where you need it.
