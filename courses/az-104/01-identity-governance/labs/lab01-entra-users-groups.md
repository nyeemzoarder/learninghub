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

50 minutes

---

## Part 1 – Create Users (Represent Real Employees)

> Important: Each user created in this lab will receive an auto-generated password. Record these for testing later—users must change their password on first sign-in.

### Create Sales Department Users

1. Go to **Microsoft Entra ID** > **Users** > **New user** > **Create new user**.
2. Create three Sales users:
   - **Display name:** Sarah Chen | **Username:** sarah.chen@\<yourtenant\>.onmicrosoft.com | **Department:** Sales
   - **Display name:** Tom Wilson | **Username:** tom.wilson@\<yourtenant\>.onmicrosoft.com | **Department:** Sales
   - **Display name:** Lisa Brown | **Username:** lisa.brown@\<yourtenant\>.onmicrosoft.com | **Department:** Sales

3. For each user:
   - Click **Auto-generate password** (record the temporary password)
   - ✅ Check **Require password change on first sign-in**
   - Set **Usage location** to your country (required for licensing)
   - **Critical:** Set **Department** field to "Sales" (this will be used for dynamic grouping and admin unit scoping later)

> Tip: You can bulk-create users via PowerShell for faster setup. See the **Appendix** section for a script example.

### Create Finance Department Users

4. Create three Finance users:
   - **Display name:** Bob Johnson | **Username:** bob.johnson@\<yourtenant\>.onmicrosoft.com | **Department:** Finance
   - **Display name:** Emma Davis | **Username:** emma.davis@\<yourtenant\>.onmicrosoft.com | **Department:** Finance
   - **Display name:** Mike Lopez | **Username:** mike.lopez@\<yourtenant\>.onmicrosoft.com | **Department:** Finance

5. Set Department to "Finance" for each.

### Create Department Administrators

6. Create two admin users who will manage their departments:
   - **Display name:** James Park (Sales Manager) | **Username:** james.park@\<yourtenant\>.onmicrosoft.com | **Department:** Sales
   - **Display name:** Rachel Green (Finance Manager) | **Username:** rachel.green@\<yourtenant\>.onmicrosoft.com | **Department:** Finance

7. **Verification:** Go to **Microsoft Entra ID** > **Users**. Confirm all 8 users appear in the list.

## Part 2 – Create Groups by Department (Identify WHO)

**Why Groups?** Groups answer the question: "WHO is this person?" They tell you their role or department.
- `grp-sales` → "These people are in Sales" (Sales team members)
- `grp-sales-admins` → "These people are Sales managers" (Sales team leads who can help with password resets)
- `grp-finance` → "These people are in Finance"
- `grp-finance-admins` → "These people are Finance managers"

### Step 1: Create the Sales Department Group

1. Go to **Entra ID** > **Groups** > **New group**.
2. Fill in:
   - **Group type:** Security
   - **Group name:** `grp-sales`
   - **Membership type:** Assigned
   - **Members:** Add Sarah Chen, Tom Wilson, Lisa Brown (the Sales employees)
3. Click **Create**.

### Step 2: Create the Sales Admins Group (The managers)

4. Go to **Groups** > **New group**.
5. Fill in:
   - **Group type:** Security
   - **Group name:** `grp-sales-admins`
   - **Membership type:** Assigned
   - **Members:** Add James Park (Sales Manager)
6. Click **Create**.

### Step 3: Create the Finance Department Group

7. Go to **Groups** > **New group**.
8. Fill in:
   - **Group type:** Security
   - **Group name:** `grp-finance`
   - **Membership type:** Assigned
   - **Members:** Add Bob Johnson, Emma Davis, Mike Lopez (the Finance employees)
9. Click **Create**.

### Step 4: Create the Finance Admins Group

10. Go to **Groups** > **New group**.
11. Fill in:
    - **Group type:** Security
    - **Group name:** `grp-finance-admins`
    - **Membership type:** Assigned
    - **Members:** Add Rachel Green (Finance Manager)
12. Click **Create**.

### Step 5: Verification

13. Go to **Entra ID** > **Groups** and confirm all four groups exist:
    - ✅ `grp-sales` (3 members: Sarah, Tom, Lisa)
    - ✅ `grp-sales-admins` (1 member: James)
    - ✅ `grp-finance` (3 members: Bob, Emma, Mike)
    - ✅ `grp-finance-admins` (1 member: Rachel)

## Part 3 – Optional: Dynamic Groups (Auto-manage Membership)

**Why Dynamic Groups?** Instead of manually adding/removing users, let rules handle it. When someone's department changes, they're automatically added/removed.

**Note:** This requires **Entra ID P1/P2 licensing**. Skip if your tenant doesn't have it.

1. Go to **Groups** > **New group** > **Membership type: Dynamic User**.
2. **Group name:** `grp-all-employees-dynamic`
3. Add a rule: `(user.accountEnabled -eq true)` (all enabled users automatically join)
4. Click **Create**.

**Real-world value:** When Contoso hires a new Sales person, they don't need to manually add them to `grp-sales`. A dynamic rule like `(user.department -eq "Sales")` would do it automatically.

If dynamic groups aren't available in your tenant, just understand the concept and move to Part 4.

## Part 4 – Administrative Units: Limit WHERE Admins Can Use Their Power

> Important: Critical Concept — Groups and Admin Units work together:
> - **Groups** answer "WHO is this person?" (James is in `grp-sales-admins` → he's a Sales manager)
> - **Admin Units** answer "WHERE can they work?" (James can reset passwords only in the Sales department)

> Warning: Without Admin Units, a manager with User Administrator role can reset passwords for ANYONE in your tenant. This is a major security risk. Always use Admin Units to scope delegated admin powers.

**Example:** With Admin Units:
- James (scoped to `au-sales`) CAN reset passwords for Sales users
- James CAN'T see or reset passwords for Finance users
- Rachel (scoped to `au-finance`) CAN reset only Finance passwords

### Step 1: Create Admin Unit for Sales Department

1. Go to **Entra ID** > **Roles & administrators** > **Administrative units** > **+ New administrative unit**.
2. Fill in:
   - **Name:** `au-sales`
   - **Description:** "Sales department scope — for Sales manager delegation"
3. Click **Create**.

### Step 2: Add Sales Users to the Admin Unit

4. Open `au-sales` > **Members** > **+ Add members**.
5. Add the Sales users: **Sarah Chen, Tom Wilson, Lisa Brown** (the Sales team members).
   - Note: You DON'T add James Park here — he's the admin, not a member being managed.
6. Click **Add**.

### Step 3: Create Admin Unit for Finance Department

7. Go back to **Administrative units** > **+ New administrative unit**.
8. Fill in:
   - **Name:** `au-finance`
   - **Description:** "Finance department scope — for Finance manager delegation"
9. Click **Create**.

### Step 4: Add Finance Users to the Finance Admin Unit

10. Open `au-finance` > **Members** > **+ Add members**.
11. Add the Finance users: **Bob Johnson, Emma Davis, Mike Lopez** (the Finance team members).
12. Click **Add**.

### Step 5: Assign Scoped Admin Role to Sales Manager (THE KEY PART)

**This is where Groups and Admin Units work together:**

13. In `au-sales`, go to **Roles and administrators** > **+ Add assignments**.
14. Search for and select **User Administrator** role.
15. **Assign to:** James Park (Sales Manager).
16. Click **Assign**.

**Result:** James Park now has the "User Administrator" role, but ONLY scoped to `au-sales`. This means:
- ✅ James CAN reset passwords for Sarah, Tom, Lisa (Sales users in au-sales)
- ✅ James CAN unlock accounts for Sales users
- ❌ James CANNOT reset Finance passwords
- ❌ James CANNOT see Finance users in his admin scope

### Step 6: Assign Scoped Admin Role to Finance Manager

17. In `au-finance`, go to **Roles and administrators** > **+ Add assignments**.
18. Search for and select **User Administrator** role.
19. **Assign to:** Rachel Green (Finance Manager).
20. Click **Assign**.

**Result:** Rachel now has the same power as James, but scoped to Finance only.

### Step 7: Verification (The Proof It Works)

21. Go to **Entra ID** > **Roles & administrators** > **Administrative units**.
    - ✅ `au-sales` exists with 3 members (Sarah, Tom, Lisa)
    - ✅ `au-finance` exists with 3 members (Bob, Emma, Mike)
    - ✅ James Park has "User Administrator" role in `au-sales`
    - ✅ Rachel Green has "User Administrator" role in `au-finance`

22. **Optional:** Sign in as James Park and navigate to **Entra ID** > **Users**. Notice he only sees Sales users — Finance users are hidden from his view. This is the power of Admin Units!

## Part 5 – Self-Service Password Reset (SSPR) for Employees

Now that we have scoped admins (James and Rachel), employees should be able to reset their own passwords without waiting for IT.

1. Go to **Entra ID** > **Password reset**.
2. Set **Self-service password reset enabled** to **Selected**.
3. Under **Select group**, choose **All** (all users can reset their own passwords) OR select just `grp-sales` and `grp-finance` to limit it.
4. Review the **Authentication methods** (email, mobile app, security questions, etc.).
5. Click **Save**.

**Real-world benefit:** Sarah from Sales can reset her own password without contacting James. This reduces administrative burden on scoped admins.

---

## Validation Checklist

- [ ] **Users Created:** Go to **Entra ID** > **Users** and verify 8 users exist:
      - Sales employees: Sarah Chen, Tom Wilson, Lisa Brown
      - Finance employees: Bob Johnson, Emma Davis, Mike Lopez
      - Department heads: James Park (Sales Manager), Rachel Green (Finance Manager)

- [ ] **Groups Created:** Go to **Entra ID** > **Groups** and verify 4 groups:
      - `grp-sales` (3 members: Sarah, Tom, Lisa)
      - `grp-sales-admins` (1 member: James)
      - `grp-finance` (3 members: Bob, Emma, Mike)
      - `grp-finance-admins` (1 member: Rachel)

- [ ] **Admin Units Created:** Go to **Entra ID** > **Roles & administrators** > **Administrative units**:
      - `au-sales` exists and contains 3 members (Sarah, Tom, Lisa)
      - `au-finance` exists and contains 3 members (Bob, Emma, Mike)

- [ ] **Scoped Admin Roles:** In each admin unit's **Roles and administrators**:
      - James Park has "User Administrator" role in `au-sales`
      - Rachel Green has "User Administrator" role in `au-finance`

- [ ] **SSPR Enabled:** Go to **Password reset** and confirm SSPR is enabled for your selected groups.

---

## Cleanup (If Needed)

To delete all lab resources:

1. Go to **Entra ID** > **Users** > select all 8 users > **Delete**.
   
2. Go to **Entra ID** > **Groups** > select `grp-sales`, `grp-sales-admins`, `grp-finance`, `grp-finance-admins` > **Delete**.

3. Go to **Entra ID** > **Roles & administrators** > **Administrative units** > select `au-sales` and `au-finance` > **Delete**.

---

## Key Takeaways from This Lab

### Groups vs Admin Units (The Most Important Concept)

| Aspect | Groups | Admin Units |
|--------|--------|--------------|
| **Answer the question** | WHO is this person? | WHERE can they use power? |
| **Purpose** | Identify role/department | Limit scope of delegation |
| **Example** | `grp-sales-admins` = "James is a Sales manager" | `au-sales` = "James can only manage Sales users" |
| **Without it** | James is just an employee | James would have unrestricted admin power (dangerous) |
| **With it** | James belongs to the admin group | James can ONLY manage Sales, not Finance or other depts |

### Exam Tips

- **Groups = WHO (identity)** — Answer "What role/department is this person?"
- **Admin Units = WHERE (scope)** — Answer "What users can this admin manage?"
- **Difference between Assigned vs Dynamic groups:**
  - **Assigned:** Manually add/remove members (good for small, stable teams)
  - **Dynamic:** Rules auto-add/remove members (good for scale, e.g., all Sales dept)
- **Admin Units scope** admin roles, NOT resource access. RBAC (Lab 02) scopes resource access.
- **Group-based licensing** auto-assigns/removes licenses as membership changes.
- A user can be in MULTIPLE groups AND multiple admin units.
- Without Admin Units, any admin role is tenant-wide and unrestricted (security risk).
- Admin Units are essential for delegating admin tasks in large organizations.
