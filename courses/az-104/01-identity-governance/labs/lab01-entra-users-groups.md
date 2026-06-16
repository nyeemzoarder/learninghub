# Lab 01 – Microsoft Entra ID: Users, Groups & Administrative Units

## Real-Life Scenario

**Company: Contoso Ltd**

Contoso is a mid-sized company with 100 employees across three departments:
- **Sales:** 30 employees
- **Finance:** 20 employees  
- **IT:** 10 employees

**The Challenge:** 
The IT department is overwhelmed with password reset requests. Instead of IT handling ALL password resets company-wide, you need to:
1. **Empower department heads** to reset passwords for their own team members (delegation)
2. **Restrict their power** so Sales lead can ONLY manage Sales users, Finance lead can ONLY manage Finance users
3. Use **Groups** to identify who they are (Sales lead, Finance lead, IT staff)
4. Use **Admin Units** to limit where they can use their power (Sales department only, Finance department only)

---

## Objectives

- Create users representing real departments (Sales, Finance, IT)
- Organize users into groups by department
- Understand **Groups = WHO (identify role)** vs **Admin Units = WHERE (limit scope)**
- Create administrative units scoped to each department
- Delegate User Administrator role with admin unit scope
- Verify that scoped admins can manage only their own department

## Prerequisites

- An Entra ID tenant with Global Administrator or User Administrator role
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated Time

⏱️ 50 minutes total

---

## Part 1 – Create Users (Represent Real Employees)

⏱️ 10-12 minutes

> Important: Each user created in this lab will receive an auto-generated password. Record these for testing later—users must change their password on first sign-in.

### Task: Create Sales Department Users

1. Go to **Microsoft Entra ID** > **Users** > **New user** > **Create new user**.

2. Create three Sales users with these details:

```txt
Display Name: Sarah Chen
Username: sarah.chen@<yourtenant>.onmicrosoft.com
Department: Sales
```

```txt
Display Name: Tom Wilson
Username: tom.wilson@<yourtenant>.onmicrosoft.com
Department: Sales
```

```txt
Display Name: Lisa Brown
Username: lisa.brown@<yourtenant>.onmicrosoft.com
Department: Sales
```

3. For each user:
   - Click **Auto-generate password** (record the temporary password)
   - ✅ Check **Require password change on first sign-in**
   - Set **Usage location** to your country (required for licensing)
   - **Critical:** Set **Department** field to "Sales" (used for dynamic grouping later)

> Tip: You can bulk-create users via PowerShell for faster setup in large environments.

### Bulk Create Users with PowerShell (Optional)

```powershell
$tenantId = "<your-tenant-id>"
Connect-MgGraph -TenantId $tenantId -Scopes "User.ReadWrite.All"

$users = @(
    @{DisplayName="Sarah Chen"; UserPrincipalName="sarah.chen@contoso.onmicrosoft.com"; Department="Sales"},
    @{DisplayName="Tom Wilson"; UserPrincipalName="tom.wilson@contoso.onmicrosoft.com"; Department="Sales"},
    @{DisplayName="Lisa Brown"; UserPrincipalName="lisa.brown@contoso.onmicrosoft.com"; Department="Sales"}
)

foreach ($user in $users) {
    $password = -join ((33..126) | Get-Random -Count 12 | ForEach-Object {[char]$_})
    New-MgUser -DisplayName $user.DisplayName -UserPrincipalName $user.UserPrincipalName `
        -PasswordProfile @{Password=$password;ForceChangePasswordNextSignIn=$true} `
        -Department $user.Department
}
```

---

### Task: Create Finance Department Users

1. Go to **Microsoft Entra ID** > **Users** > **New user** > **Create new user**.

2. Create three Finance users:

```txt
Display Name: Bob Johnson
Username: bob.johnson@<yourtenant>.onmicrosoft.com
Department: Finance
```

```txt
Display Name: Emma Davis
Username: emma.davis@<yourtenant>.onmicrosoft.com
Department: Finance
```

```txt
Display Name: Mike Lopez
Username: mike.lopez@<yourtenant>.onmicrosoft.com
Department: Finance
```

3. For each Finance user, ensure **Department** field is set to "Finance".

---

### Task: Create Department Administrators

1. Create two admin users who will manage their departments:

```txt
Display Name: James Park (Sales Manager)
Username: james.park@<yourtenant>.onmicrosoft.com
Department: Sales
```

```txt
Display Name: Rachel Green (Finance Manager)
Username: rachel.green@<yourtenant>.onmicrosoft.com
Department: Finance
```

2. **Verification:** Go to **Microsoft Entra ID** > **Users**. Confirm all 8 users appear in the list.

---

## Part 2 – Create Groups by Department (Identify WHO)

⏱️ 8-10 minutes

**Why Groups?** Groups answer the question: "WHO is this person?" They tell you their role or department.
- `grp-sales` → "These people are in Sales" (Sales team members)
- `grp-sales-admins` → "These people are Sales managers" (Sales team leads who can help with password resets)
- `grp-finance` → "These people are in Finance"
- `grp-finance-admins` → "These people are Finance managers"

### Task: Create the Sales Department Group

1. Go to **Entra ID** > **Groups** > **New group**.
2. Fill in:
   - **Group type:** Security
   - **Group name:** `grp-sales`
   - **Membership type:** Assigned
   - **Members:** Add Sarah Chen, Tom Wilson, Lisa Brown (the Sales employees)
3. Click **Create**.

> Note: Security groups are used for access control. Microsoft 365 groups are for collaboration. For this lab, use Security.

---

### Task: Create the Sales Admins Group

1. Go to **Groups** > **New group**.
2. Fill in:
   - **Group type:** Security
   - **Group name:** `grp-sales-admins`
   - **Membership type:** Assigned
   - **Members:** Add James Park (Sales Manager)
3. Click **Create**.

---

### Task: Create the Finance Department Group

1. Go to **Groups** > **New group**.
2. Fill in:
   - **Group type:** Security
   - **Group name:** `grp-finance`
   - **Membership type:** Assigned
   - **Members:** Add Bob Johnson, Emma Davis, Mike Lopez (the Finance employees)
3. Click **Create**.

---

### Task: Create the Finance Admins Group

1. Go to **Groups** > **New group**.
2. Fill in:
   - **Group type:** Security
   - **Group name:** `grp-finance-admins`
   - **Membership type:** Assigned
   - **Members:** Add Rachel Green (Finance Manager)
3. Click **Create**.

---

### Verification: Confirm All Groups Exist

- ✅ `grp-sales` (3 members: Sarah, Tom, Lisa)
- ✅ `grp-sales-admins` (1 member: James)
- ✅ `grp-finance` (3 members: Bob, Emma, Mike)
- ✅ `grp-finance-admins` (1 member: Rachel)

---

## Part 3 – Optional: Dynamic Groups (Auto-manage Membership)

⏱️ 5 minutes

**Why Dynamic Groups?** Instead of manually adding/removing users, let rules handle it. When someone's department changes, they're automatically added/removed.

> Note: This requires **Entra ID P1/P2 licensing**. Skip if your tenant doesn't have it.

### Create Dynamic User Groups

1. Go to **Groups** > **New group** > **Membership type: Dynamic User**.
2. **Group name:** `grp-all-employees-dynamic`
3. Add a rule: `(user.accountEnabled -eq true)` (all enabled users automatically join)
4. Click **Create**.

**Real-world value:** When Contoso hires a new Sales person, they don't need to manually add them to `grp-sales`. A dynamic rule like `(user.department -eq "Sales")` would do it automatically.

---

## Part 4 – Administrative Units: Limit WHERE Admins Can Use Their Power

⏱️ 12-15 minutes

> Important: Critical Concept — Groups and Admin Units work together:
> - **Groups** answer "WHO is this person?" (James is in `grp-sales-admins` → he's a Sales manager)
> - **Admin Units** answer "WHERE can they work?" (James can reset passwords only in the Sales department)

> Warning: Without Admin Units, a manager with User Administrator role can reset passwords for ANYONE in your tenant. This is a major security risk. Always use Admin Units to scope delegated admin powers.

**Example Security Impact:**
- James (scoped to `au-sales`) CAN reset passwords for Sales users
- James CAN'T see or reset passwords for Finance users
- Rachel (scoped to `au-finance`) CAN reset only Finance passwords

### Task: Create Admin Unit for Sales Department

1. Go to **Entra ID** > **Roles & administrators** > **Administrative units** > **+ New administrative unit**.
2. Fill in:
   - **Name:** `au-sales`
   - **Description:** "Sales department scope — for Sales manager delegation"
3. Click **Create**.

---

### Task: Add Sales Users to the Admin Unit

1. Open `au-sales` > **Members** > **+ Add members**.
2. Add the Sales users: **Sarah Chen, Tom Wilson, Lisa Brown** (the Sales team members).
   - Note: You DON'T add James Park here — he's the admin, not a member being managed.
3. Click **Add**.

---

### Task: Create Admin Unit for Finance Department

1. Go back to **Administrative units** > **+ New administrative unit**.
2. Fill in:
   - **Name:** `au-finance`
   - **Description:** "Finance department scope — for Finance manager delegation"
3. Click **Create**.

---

### Task: Add Finance Users to the Finance Admin Unit

1. Open `au-finance` > **Members** > **+ Add members**.
2. Add the Finance users: **Bob Johnson, Emma Davis, Mike Lopez** (the Finance team members).
3. Click **Add**.

---

### Task: Assign Scoped Admin Role to Sales Manager (THE KEY PART)

**This is where Groups and Admin Units work together:**

1. In `au-sales`, go to **Roles and administrators** > **+ Add assignments**.
2. Search for and select **User Administrator** role.
3. **Assign to:** James Park (Sales Manager).
4. Click **Assign**.

**Result:** James Park now has the "User Administrator" role, but ONLY scoped to `au-sales`. This means:
- ✅ James CAN reset passwords for Sarah, Tom, Lisa (Sales users in au-sales)
- ✅ James CAN unlock accounts for Sales users
- ❌ James CANNOT reset Finance passwords
- ❌ James CANNOT see Finance users in his admin scope

---

### Task: Assign Scoped Admin Role to Finance Manager

1. In `au-finance`, go to **Roles and administrators** > **+ Add assignments**.
2. Search for and select **User Administrator** role.
3. **Assign to:** Rachel Green (Finance Manager).
4. Click **Assign**.

**Result:** Rachel now has the same power as James, but scoped to Finance only.

---

### Task: Verification — Confirm Scoped Admin Roles Are Working

1. Go to **Entra ID** > **Roles & administrators** > **Administrative units**.

**Verify the following exist:**
- ✅ `au-sales` with 3 members (Sarah, Tom, Lisa)
- ✅ `au-finance` with 3 members (Bob, Emma, Mike)
- ✅ James Park has "User Administrator" role in `au-sales`
- ✅ Rachel Green has "User Administrator" role in `au-finance`

2. **Optional:** Sign in as James Park and navigate to **Entra ID** > **Users**. Notice he only sees Sales users — Finance users are hidden from his view. This is the power of Admin Units!

---

## Part 5 – Self-Service Password Reset (SSPR) for Employees

⏱️ 5 minutes

Now that we have scoped admins (James and Rachel), employees should be able to reset their own passwords without waiting for IT.

1. Go to **Entra ID** > **Password reset**.
2. Set **Self-service password reset enabled** to **Selected**.
3. Under **Select group**, choose **All** (all users can reset their own passwords) OR select just `grp-sales` and `grp-finance` to limit it.
4. Review the **Authentication methods** (email, mobile app, security questions, etc.).
5. Click **Save**.

**Real-world benefit:** Sarah from Sales can reset her own password without contacting James. This reduces administrative burden on scoped admins.

---

## Success Criteria

✓ **All 8 users created** (3 Sales, 3 Finance, 2 managers)  
✓ **All 4 groups created** (grp-sales, grp-sales-admins, grp-finance, grp-finance-admins)  
✓ **2 admin units created** (au-sales, au-finance)  
✓ **Scoped admin roles assigned** (James to au-sales, Rachel to au-finance)  
✓ **SSPR enabled** for employees to reset their own passwords  

---

## Cleanup (If Needed)

To remove all resources created in this lab:

```powershell
# Connect to Entra ID
Connect-MgGraph -TenantId "<your-tenant-id>" -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All"

# Delete all 8 users
$users = @("sarah.chen", "tom.wilson", "lisa.brown", "bob.johnson", "emma.davis", "mike.lopez", "james.park", "rachel.green")
foreach ($user in $users) {
    Remove-MgUser -UserId "$user@<yourtenant>.onmicrosoft.com"
}

# Delete all 4 groups
$groups = @("grp-sales", "grp-sales-admins", "grp-finance", "grp-finance-admins")
foreach ($group in $groups) {
    $gObj = Get-MgGroup -Filter "displayName eq '$group'"
    Remove-MgGroup -GroupId $gObj.Id
}

# Delete administrative units (if using Azure CLI)
# az account set --subscription "<subscription-id>"
# az ad-admin-unit delete --id "<au-sales-id>"
# az ad-admin-unit delete --id "<au-finance-id>"
```

---

## Key Takeaways

**Groups vs Admin Units:**
- **Groups** = Answer "WHO is this person?" (identity/role)
- **Admin Units** = Answer "WHERE can they work?" (scope/boundary)

**Delegation Best Practices:**
- Always use Admin Units to scope delegated admin roles
- Never assign admin roles without Admin Unit scoping
- Use groups to identify administrators, not to scope their power

**SSPR Benefits:**
- Reduces helpdesk ticket volume
- Improves user experience
- Keeps sensitive admin work with scoped admins

**Security:** The combination of Groups + Admin Units + SSPR creates a secure, scalable identity governance system where:
- Managers (James, Rachel) can only manage their own department
- Users can reset their own passwords
- IT can focus on strategic work instead of password resets
