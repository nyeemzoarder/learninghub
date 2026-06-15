# Entra ID Overview: The Identity Foundation

## Opening Hook

**Why this matters:** Before you can grant any Azure permission, you need identities to grant them to. Microsoft Entra ID is Azure's identity service—it's how you manage who your users are, organize them into groups, and control who gets licenses. Every single RBAC role assignment starts here. Without understanding Entra ID, you can't understand identity governance.

---

## Before You Start

- **Prerequisites:** [00-Prerequisites: Identity & Access Fundamentals](../../../00-prerequisites/03-identity-and-access-fundamentals.md)
- **Time to understand:** 15 minutes
- **Difficulty:** 🟢 **Beginner** (foundational, no identity experience needed)
- **What you'll learn:** What Entra ID is, core identity objects, how groups work, administrative units

---

## The Simple Idea

### What Is Entra ID?

**Entra ID** = Microsoft's **cloud identity service** where you manage:
- **Who** your users are
- **What groups** they belong to
- **What licenses** they have
- **What roles** can manage them

Think of it like **HR records for cloud applications**—it's the central registry of all identities in your organization.

### Real-World Analogy: Company Directory

```
Company (Your Organization)
│
├── HR Department (Entra ID)
│   ├── Database: All employees (Users)
│   ├── Teams: Sales team, Dev team, Finance (Groups)
│   ├── Permissions: "Who reports to whom" (Administrative Units)
│   └── Licenses: "Who gets Office 365?" (Group-based licensing)
│
└── Finance Department (Azure Services)
    └── Uses Entra ID to know "who is John?" and "what permissions does he have?"
```

Entra ID is the **single source of truth** for identity in your Azure organization.

### What's a Tenant?

A **tenant** is your organization's **dedicated, isolated instance** of Entra ID.

```
Microsoft Entra ID (the service)
├── TechCorp Tenant (company A)
│   ├── Users: sara@techcorp.com, mike@techcorp.com
│   └── Groups: Sales Team, Dev Team
├── AnotherCompany Tenant (company B)
│   ├── Users: john@anothercompany.com
│   └── Groups: Different teams
└── YetAnotherCompany Tenant (company C)
    └── Completely isolated from A and B
```

Each company is **completely isolated**. Users in TechCorp can't see AnotherCompany's data.

---

## Key Identity Objects

| Object | What It Is | Example | Why It Matters |
|--------|-----------|---------|---|
| **User** | Individual identity that can sign in | sara@company.com | RBAC role assigned to individuals |
| **Group** | Collection of users | grp-sales (50 people) | Assign permissions to many at once |
| **Admin Unit** | Scoped container for delegation | au-sales (Sales dept only) | Delegate admin over subset (not all users) |
| **App Registration** | Identity for applications/services | myapp-service | Apps authenticate to Azure securely |
| **Tenant** | Your org's isolated Entra instance | contoso.onmicrosoft.com | Isolation boundary |

---

## How It Actually Works

### Step 1: Create a User

```
Admin creates user: sara@company.com
↓
Entra ID now knows: "Sara is a person in our organization"
```

### Step 2: Add User to Groups

```
Sara joins groups:
├── grp-sales (all sales people)
├── grp-salesadmins (sales team leads)
└── grp-microsoft365 (Office 365 users)

Result: Sara inherits permissions from each group
```

### Step 3: Assign Licenses to Groups

```
License assignment: Office 365 → grp-microsoft365
↓
Sara (member of grp-microsoft365) automatically gets Office 365 ✓
Mike (also in the group) automatically gets it ✓
```

### Step 4: Create Admin Scope (Administrative Units)

```
Admin creates: au-sales (Sales department scope)
│
├── Members: Everyone in Sales department
│
└── Purpose: "Sales team lead can reset passwords, but ONLY for Sales dept"
```

### Step 5: Delegate Admin Role (Scoped)

```
Assign role: User Administrator
To: John (Sales team lead)
Scoped to: au-sales (Sales dept only)

Result:
├── John can reset passwords → ONLY for Sales users ✓
├── John CANNOT reset passwords → for Finance users ✗
├── John CANNOT add users → to other departments ✗
└── Delegation achieved without tenant-wide admin access ✓
```

---

## Mental Model: Entra ID as Organization Chart + HR System

```
CEO (Global Administrator—can do anything)
│
├─ VP Sales (User Administrator for Sales unit)
│  └─ Can manage Sales users only
│  └─ Cannot see Finance users
│
├─ VP Finance (User Administrator for Finance unit)
│  └─ Can manage Finance users only
│  └─ Cannot see Sales users
│
└─ VP IT (Global Admin)
   └─ Can manage all users and settings
```

Each VP has power only in their area (scoped), yet all use the same Entra ID tenant.

---

## Worked Example: Real Scenario

### The Scenario

**Contoso has 100 employees:**
- Sales: 50 people
- Finance: 30 people
- IT: 20 people

**Goal:** Manage identities efficiently, delegate admin duties, assign licenses automatically.

### Solution Using Groups + Admin Units

#### Step 1: Create Groups
```
Group: grp-sales
├── Members: All Sales employees (50 people)
└── Membership: Dynamic rule — "department eq Sales"

Group: grp-finance
├── Members: All Finance employees (30 people)
└── Membership: Dynamic rule — "department eq Finance"

Group: grp-allemployees-office365
├── Members: Everyone (100 people)
└── Membership: Dynamic rule — "user.accountEnabled eq true"
```

#### Step 2: Assign Licenses to Groups
```
Office 365 license → grp-allemployees-office365
└─ All 100 employees automatically get Office 365 ✓

Teams license → grp-sales + grp-finance
└─ 80 employees automatically get Teams ✓
```

#### Step 3: Create Administrative Units
```
Admin Unit: au-sales
├── Members: Everyone in Sales department
└── Purpose: Scope admin roles to Sales only

Admin Unit: au-finance
├── Members: Everyone in Finance department
└── Purpose: Scope admin roles to Finance only
```

#### Step 4: Delegate Admin Roles
```
Assignment 1:
  Role: User Administrator
  Person: Sarah (Sales team lead)
  Scope: au-sales
  Result: Sarah can reset passwords for Sales only ✓

Assignment 2:
  Role: User Administrator
  Person: Bob (Finance team lead)
  Scope: au-finance
  Result: Bob can reset passwords for Finance only ✓

Assignment 3:
  Role: Global Administrator
  Person: Alice (IT director)
  Scope: Tenant-wide
  Result: Alice can do anything, manage all departments ✓
```

### Benefit
```
When new Sales employee joins:
└─ HR enters their info
└─ Dynamic group rule matches them to grp-sales
└─ Automatically added to grp-allemployees-office365
└─ Automatically gets Office 365 + Teams licenses
└─ Falls under Sarah's admin scope (au-sales)
└─ Sarah can manage their password without IT intervention
└─ ZERO manual steps! ✓
```

---

## Common Mistakes (What NOT to Do)

### ❌ Mistake 1: Confusing Entra Roles with Azure RBAC

**Wrong:**
```
Admin is Global Administrator in Entra ID
├─ Can create users, reset passwords, manage licenses
├─ Makes them THINK they can delete Azure resources
└─ They can't! (Completely different permission system) ✗
```

**Why it fails:** Two separate permission systems:
- **Entra Roles** = manage identities
- **Azure RBAC** = manage Azure services/resources

**Fix:**
```
Understand they're separate:
├─ Global Administrator (Entra) ≠ Owner (Azure RBAC)
├─ User Administrator (Entra) ≠ Contributor (Azure RBAC)
└─ To manage both, you need roles in BOTH systems
```

---

### ❌ Mistake 2: Using Assigned Groups for Dynamic Needs

**Wrong:**
```
Create group: grp-salesreps
├─ Manually add 50 people
├─ When someone new joins Sales → admin must manually add them
├─ When someone leaves → admin must manually remove them
└─ Result: Manual overhead, human error ✗
```

**Why it fails:** Doesn't scale. Manual processes are error-prone.

**Fix:**
```
Use dynamic groups:
└─ grp-salesreps
   ├─ Membership rule: "department eq Sales"
   ├─ When new Sales employee joins → automatically added ✓
   ├─ When they leave Sales → automatically removed ✓
   └─ Zero manual work ✓

But watch: Dynamic groups require Entra ID P1/P2 licensing!
```

---

### ❌ Mistake 3: Assigning Licenses Individually

**Wrong:**
```
Admin assigns Office 365 license to:
├─ User 1 (manually)
├─ User 2 (manually)
├─ User 3 (manually)
└─ ... (50 more times, error-prone, tedious) ✗
```

**Why it fails:** Doesn't scale. Easy to forget someone.

**Fix:**
```
Use group-based licensing:
└─ Create grp-office365-users (dynamic group)
└─ Assign Office 365 to the GROUP
└─ All members automatically get license ✓
└─ New members get it automatically ✓
```

---

## How This Connects to Other Topics

### Related to Module 01 (Identity & Governance)
- **Entra ID** = Create identities (users, groups)
- **RBAC** = Grant permissions TO those identities
- **Management Groups & Policy** = Enforce policies across subscriptions that Entra users access

### Related to Module 02, 03, 04, 05
- **All modules** rely on Entra ID identities
- Every RBAC role assignment requires an Entra identity
- Every Azure access is authenticated through Entra ID

---

## See It In Action

**Associated lab:** [Lab 01: Entra ID: Users, Groups & Admin Units](../labs/lab01-entra-users-groups.md)

**Suggested learning sequence:**
1. ✅ Read this doc (Entra ID Overview - foundational)
2. ✅ Read [RBAC Fundamentals](02-rbac-fundamentals.md) (use Entra identities for role assignment)
3. ✅ Read [Management Groups & Policy](03-management-groups-and-azure-policy.md) (govern Entra users at scale)
4. ✅ Work through Lab 01 (create users, groups, admin units)

---

## Key Takeaways

- **Entra ID = cloud identity system** (who your users are)
- **Tenant = isolated org instance** (separate from other companies)
- **Users** are individual identities
- **Groups** are collections (use for permissions and licenses)
- **Dynamic groups** auto-add/remove members (requires P1/P2)
- **Group-based licensing** = auto-license thousands
- **Admin Units** scope admin roles (VP of Sales manages only Sales)
- **Entra roles ≠ Azure RBAC** (different systems, both needed)
- **Delegation = admin scope** (let managers handle their own people)

---

## Next Steps

1. **Learn:** Read this doc (you're here)
2. **Understand:** Read [RBAC Fundamentals](02-rbac-fundamentals.md) (Entra identities get Azure permissions)
3. **Govern:** Read [Management Groups & Policy](03-management-groups-and-azure-policy.md) (scale governance)
4. **Practice:** [Lab 01: Entra ID Users, Groups & Admin Units](../labs/lab01-entra-users-groups.md)
5. **Secure:** Read [Access Control Scenarios](04-access-control-scenarios.md) (real-world patterns)
