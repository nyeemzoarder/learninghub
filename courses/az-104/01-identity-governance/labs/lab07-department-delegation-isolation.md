# Lab 07 – Department Delegation & Multi-Team Isolation

## Real-Life Scenario

**Company: TechCorp Enterprise (500+ employees)**

TechCorp has grown from startup to enterprise scale. Three departments now manage their own Azure infrastructure independently:
- **Finance Department**: 50 people, 3 subscriptions (Prod, Staging, Dev), $15K/month spend
- **Engineering Department**: 100 people, 4 subscriptions (Prod, Staging, Dev, ML), $28K/month spend
- **Operations**: 25 people, 2 subscriptions (Infrastructure, Security), $4K/month spend

**The Challenge:**
- Central IT is overwhelmed managing everyone's access
- Finance VP wants to manage Finance subscriptions without IT gate-keeping
- Engineering VP wants autonomy for their team
- But nobody should see other departments' data (confidential!)
- Central IT needs to maintain overall control and compliance

**The Problem:**
```
Current (Broken):
├─ Everything goes through IT (bottleneck)
├─ IT is hiring just to handle access requests
├─ Departments frustrated with slow change management
├─ No financial accountability per department
└─ Risk: Finance accessing Engineering data by mistake
```

**Your Challenge:** Implement department-based delegation with isolation

**The Solution You'll Build:**
```
MANAGEMENT GROUP HIERARCHY:
Root (TechCorp)
├── Finance Department (MG)
│   ├── Finance-Prod (Sub)
│   ├── Finance-Staging (Sub)
│   └── Finance-Dev (Sub)
├── Engineering Department (MG)
│   ├── Eng-Prod (Sub)
│   ├── Eng-Staging (Sub)
│   ├── Eng-Dev (Sub)
│   └── Eng-ML (Sub)
└── Operations (MG)
    ├── Ops-Infrastructure (Sub)
    └── Ops-Security (Sub)

ACCESS MODEL:
Finance VP:
├─ Can see: Finance Department subscriptions ONLY
├─ Cannot see: Engineering or Operations data
├─ Role: Contributor on Finance MG (affects all Finance subs)
└─ Result: Manages Finance independently

Engineering VP:
├─ Can see: Engineering Department subscriptions ONLY
├─ Cannot see: Finance or Operations data
├─ Role: Contributor on Engineering MG
└─ Result: Manages Engineering independently

IT Director:
├─ Can see: EVERYTHING (Root scope)
├─ Role: Owner at Root
└─ Result: Central oversight + emergency access

RESULT: Departments autonomous + Isolated + Auditable
```

---

## Prerequisites

**Required Knowledge:**
- [Lab 01: Entra ID - Users & Groups](lab01-entra-users-groups.md)
- [Lab 02: RBAC & Azure Policy](lab02-rbac-azure-policy.md)
- [Lab 03: Management Groups & Subscriptions](lab03-management-groups-subscriptions.md)

**Required Permissions:**
- Global Administrator or User Access Administrator
- Root Management Group access
- At least 6+ subscriptions (or ability to create them)

**Scope:** Tenant-wide (affects all subscriptions)

---

## Estimated Time

**Total: 100 minutes**
- Part 1: Design MG hierarchy (20 min)
- Part 2: Create management groups (20 min)
- Part 3: Organize subscriptions (15 min)
- Part 4: Create department groups (15 min)
- Part 5: Configure scoped RBAC (20 min)
- Part 6: Test isolation (10 min)

**Difficulty: Advanced**

---

## Part 1 – Design Management Group Hierarchy

### The Challenge

Before you build the hierarchy, design it. Poor design = painful refactoring later.

### What You'll Learn

- How to think about management group organization
- How to avoid common design mistakes
- How to plan for scale

### Step-by-Step Tasks

**Step 1: Understand the Requirements**

TechCorp needs:
```
DESIGN REQUIREMENTS:
├─ 3 departments with autonomous management
├─ Each department sees only their subscriptions
├─ Each department has Prod/Staging/Dev environments
├─ IT maintains central control
├─ Policies cascade to all departments
└─ Cost tracking by department
```

**Step 2: Design the Hierarchy**

Create your MG design:

```
ROOT (TechCorp Tenant Root Group)
└── Purpose: Apply tenant-wide policies

├── mg-finance (Finance Department)
│   ├── Purpose: Isolate Finance resources
│   ├── Subscriptions:
│   │   ├─ finance-prod
│   │   ├─ finance-staging
│   │   └─ finance-dev
│   └── Owner: Finance VP (Contributor role)
│
├── mg-engineering (Engineering Department)
│   ├── Purpose: Isolate Engineering resources
│   ├── Subscriptions:
│   │   ├─ eng-prod
│   │   ├─ eng-staging
│   │   ├─ eng-dev
│   │   └─ eng-ml
│   └── Owner: Engineering VP (Contributor role)
│
└── mg-operations (Operations Department)
    ├── Purpose: Infrastructure/security
    ├── Subscriptions:
    │   ├─ ops-infrastructure
    │   └─ ops-security
    └── Owner: Operations Director (Contributor role)
```

**Step 3: Plan RBAC Assignments**

Document which groups get which roles at which scopes:

```
RBAC PLAN:

ROOT SCOPE:
├─ grp-it-admins: Owner (view everything, override anything)
├─ grp-auditors: Reader (audit everything)
└─ Security policy: Applied to all subscriptions

FINANCE MG:
├─ grp-finance-admins: Contributor (manage Finance subs)
├─ grp-finance-users: Reader (view Finance resources)
└─ Finance-specific policies

ENGINEERING MG:
├─ grp-engineering-admins: Contributor (manage Eng subs)
├─ grp-engineering-users: Reader (view Eng resources)
└─ Engineering-specific policies

OPERATIONS MG:
├─ grp-ops-admins: Contributor (manage Ops subs)
├─ grp-ops-users: Reader (view Ops resources)
└─ Ops-specific policies
```

**Step 4: Document Design**

Create a design document:

```
MANAGEMENT GROUP DESIGN DOCUMENT
════════════════════════════════════════════════════════════

DESIGNED FOR: TechCorp Enterprise

HIERARCHY STRUCTURE:
(paste your hierarchy diagram)

DEPARTMENT DETAILS:

Finance Department:
├─ Subscriptions: 3 (prod, staging, dev)
├─ Expected cost: $15K/month
├─ Admin group: grp-finance-admins
├─ Member count: 50 people
└─ Isolation: Complete (no cross-access)

Engineering Department:
├─ Subscriptions: 4 (prod, staging, dev, ml)
├─ Expected cost: $28K/month
├─ Admin group: grp-engineering-admins
├─ Member count: 100 people
└─ Isolation: Complete (no cross-access)

Operations Department:
├─ Subscriptions: 2 (infrastructure, security)
├─ Expected cost: $4K/month
├─ Admin group: grp-ops-admins
├─ Member count: 25 people
└─ Isolation: Complete (no cross-access)

APPROVAL: Design reviewed and approved ☐
```

### Validation Checklist

- [ ] Hierarchy designed with 3 departments
- [ ] Each department has 2-4 subscriptions planned
- [ ] Scope assignments documented
- [ ] Groups and roles defined
- [ ] Design document created
- [ ] Design reviewed for conflicts/gaps

### Success Criteria

✅ Complete: Clear MG hierarchy designed  
✅ Department isolation planned  
✅ RBAC assignment strategy defined  
✅ Ready to implement  

---

## Part 2 – Create Management Groups

### The Challenge

Implement your design by creating the management group hierarchy.

### What You'll Learn

- How to create management groups
- How to nest management groups
- How to verify hierarchy is correct

### Step-by-Step Tasks

**Step 1: Create Top-Level Department Groups**

1. Go to **Management groups**
2. Click **+ Create management group**

3. Create Finance Department MG:
```
Name: mg-finance
Display Name: Finance Department
Parent: Root Management Group
Description: Finance department subscriptions and access
```

4. Create Engineering Department MG:
```
Name: mg-engineering
Display Name: Engineering Department
Parent: Root Management Group
Description: Engineering department subscriptions and access
```

5. Create Operations MG:
```
Name: mg-operations
Display Name: Operations Department
Parent: Root Management Group
Description: Operations subscriptions and access
```

**Step 2: Verify Hierarchy**

1. Go to **Management groups** > **Hierarchy**
2. Expand the tree view
3. Verify structure matches your design:

```
Tenant Root Group
├── mg-finance
├── mg-engineering
└── mg-operations
```

**Step 3: Document Creation**

```
MANAGEMENT GROUP CREATION LOG
════════════════════════════════════════════════════════════

Created: mg-finance
├─ Display Name: Finance Department
├─ Parent: Root Management Group
├─ Created: __________ (date)
└─ Status: ✓ Created

Created: mg-engineering
├─ Display Name: Engineering Department
├─ Parent: Root Management Group
├─ Created: __________ (date)
└─ Status: ✓ Created

Created: mg-operations
├─ Display Name: Operations Department
├─ Parent: Root Management Group
├─ Created: __________ (date)
└─ Status: ✓ Created

HIERARCHY STATUS: ✓ Complete
```

### Validation Checklist

- [ ] Created mg-finance MG
- [ ] Created mg-engineering MG
- [ ] Created mg-operations MG
- [ ] All nested under Root
- [ ] Hierarchy verified in Azure Portal
- [ ] Creation log completed

### Success Criteria

✅ Complete: All 3 department MGs created  
✅ Hierarchy matches design  
✅ All MGs visible in Azure Portal  

---

## Part 3 – Organize Subscriptions Under Management Groups

### The Challenge

Move existing subscriptions into the right management groups.

### What You'll Learn

- How to move subscriptions to management groups
- How to verify subscriptions are in correct location
- How to troubleshoot subscription movement

### Step-by-Step Tasks

**Step 1: Identify Your Subscriptions**

List which subscriptions you'll move to each MG:

```
SUBSCRIPTION ASSIGNMENT PLAN:

Finance Department (mg-finance):
├─ Subscription 1: finance-prod
├─ Subscription 2: finance-staging
└─ Subscription 3: finance-dev

Engineering Department (mg-engineering):
├─ Subscription 4: eng-prod
├─ Subscription 5: eng-staging
├─ Subscription 6: eng-dev
└─ Subscription 7: eng-ml

Operations (mg-operations):
├─ Subscription 8: ops-infrastructure
└─ Subscription 9: ops-security

OR use existing subscriptions if you have them
```

**Step 2: Move Subscriptions to Finance MG**

1. Go to **Management groups** > **mg-finance**
2. Click **Subscriptions** tab
3. Click **Add subscription**
4. Select your Finance subscriptions (or create new ones)
5. Click **Save**

Repeat for each Finance subscription.

**Step 3: Move Subscriptions to Engineering MG**

1. Go to **Management groups** > **mg-engineering**
2. Repeat the process for Engineering subscriptions

**Step 4: Move Subscriptions to Operations MG**

1. Go to **Management groups** > **mg-operations**
2. Repeat for Operations subscriptions

**Step 5: Verify Subscription Organization**

For each MG:
1. Click the MG name
2. Go to **Subscriptions** tab
3. Verify correct subscriptions appear
4. Document:

```
SUBSCRIPTION ORGANIZATION VERIFICATION:

mg-finance subscriptions:
├─ finance-prod: ✓ Present
├─ finance-staging: ✓ Present
└─ finance-dev: ✓ Present
└─ Status: COMPLETE

mg-engineering subscriptions:
├─ eng-prod: ✓ Present
├─ eng-staging: ✓ Present
├─ eng-dev: ✓ Present
└─ eng-ml: ✓ Present
└─ Status: COMPLETE

mg-operations subscriptions:
├─ ops-infrastructure: ✓ Present
└─ ops-security: ✓ Present
└─ Status: COMPLETE
```

### Validation Checklist

- [ ] Identified all subscriptions to organize
- [ ] Moved Finance subscriptions to mg-finance
- [ ] Moved Engineering subscriptions to mg-engineering
- [ ] Moved Operations subscriptions to mg-operations
- [ ] Verified each MG has correct subscriptions
- [ ] All subscriptions organized

### Success Criteria

✅ Complete: All subscriptions in correct MGs  
✅ No subscriptions under Root  
✅ Department isolation at subscription level  

---

## Part 4 – Create Department Entra Groups

### The Challenge

You need groups to assign roles. Create groups for each department.

### What You'll Learn

- How to create department-specific groups
- How to organize groups for scalability
- How to plan group naming

### Step-by-Step Tasks

**Step 1: Create Finance Groups**

1. Go to **Entra ID** > **Groups** > **New group**

2. Create Finance Admins:
```
Name: grp-finance-admins
Type: Security
Description: Finance department administrators (can manage Finance subscriptions)
Members: Add Finance VPs, Finance IT staff
```

3. Create Finance Users:
```
Name: grp-finance-users
Type: Security
Description: Finance department users (read-only access to Finance)
Members: Add Finance employees
```

**Step 2: Create Engineering Groups**

1. Create Engineering Admins:
```
Name: grp-engineering-admins
Type: Security
Description: Engineering department administrators
Members: Add Engineering VPs, Engineering leads
```

2. Create Engineering Users:
```
Name: grp-engineering-users
Type: Security
Description: Engineering department users (read-only)
Members: Add Engineering employees
```

**Step 3: Create Operations Groups**

1. Create Operations Admins:
```
Name: grp-ops-admins
Type: Security
Description: Operations administrators
Members: Add Operations director, senior ops engineers
```

2. Create Operations Users:
```
Name: grp-ops-users
Type: Security
Description: Operations staff (read-only)
Members: Add Operations team members
```

**Step 4: Create IT & Auditor Groups**

1. Create IT Admins:
```
Name: grp-it-admins
Type: Security
Description: IT administrators with Root scope access
Members: Add IT directors, cloud architects
```

2. Create Auditors:
```
Name: grp-auditors
Type: Security
Description: Auditors and compliance team (read-only everywhere)
Members: Add internal auditors, compliance officers
```

**Step 5: Document Groups**

```
ENTRA GROUPS CREATED:

Department Admin Groups:
├─ grp-finance-admins (Members: _____)
├─ grp-engineering-admins (Members: _____)
└─ grp-ops-admins (Members: _____)

Department User Groups:
├─ grp-finance-users (Members: _____)
├─ grp-engineering-users (Members: _____)
└─ grp-ops-users (Members: _____)

Infrastructure Groups:
├─ grp-it-admins (Members: _____)
└─ grp-auditors (Members: _____)

TOTAL: 8 groups created ✓
```

### Validation Checklist

- [ ] Created 3 department admin groups
- [ ] Created 3 department user groups
- [ ] Created IT admin group
- [ ] Created auditor group
- [ ] All groups have appropriate members
- [ ] All groups documented

### Success Criteria

✅ Complete: 8 groups created  
✅ Department groups properly scoped  
✅ Clear naming convention  

---

## Part 5 – Configure Scoped RBAC Assignments

### The Challenge

Assign roles to groups at management group scope so they have access only to their department.

### What You'll Learn

- How to assign roles at MG scope
- How to enforce department isolation with RBAC
- How to prevent cross-department access

### Step-by-Step Tasks

**Step 1: Assign Finance Department Roles**

1. Go to **Management groups** > **mg-finance** > **Access control (IAM)**
2. Click **+ Add** > **Add role assignment**

3. For **grp-finance-admins**:
```
Role: Contributor
Scope: mg-finance (management group)
Members: grp-finance-admins
Effect: Can create, modify, delete Finance resources
Result: Finance VP controls Finance subscriptions
```

4. For **grp-finance-users**:
```
Role: Reader
Scope: mg-finance
Members: grp-finance-users
Effect: Can view Finance resources (read-only)
```

**Step 2: Assign Engineering Department Roles**

1. Go to **Management groups** > **mg-engineering** > **Access control (IAM)**

2. For **grp-engineering-admins**:
```
Role: Contributor
Scope: mg-engineering
Members: grp-engineering-admins
Effect: Can manage Engineering subscriptions
```

3. For **grp-engineering-users**:
```
Role: Reader
Scope: mg-engineering
Members: grp-engineering-users
Effect: Read-only access to Engineering
```

**Step 3: Assign Operations Roles**

1. Go to **Management groups** > **mg-operations** > **Access control (IAM)**

2. For **grp-ops-admins**:
```
Role: Contributor
Scope: mg-operations
Members: grp-ops-admins
```

3. For **grp-ops-users**:
```
Role: Reader
Scope: mg-operations
Members: grp-ops-users
```

**Step 4: Assign IT and Auditor Roles at Root**

1. Go to **Root Management Group** > **Access control (IAM)**

2. For **grp-it-admins**:
```
Role: Owner
Scope: Root (all subscriptions)
Members: grp-it-admins
Effect: IT has complete control everywhere
Reason: Emergency access, central oversight
```

3. For **grp-auditors**:
```
Role: Reader
Scope: Root (can view everything)
Members: grp-auditors
Effect: Can audit all departments
Reason: Compliance and audit trail review
```

**Step 5: Document RBAC Configuration**

```
RBAC ASSIGNMENT MATRIX - FINAL
════════════════════════════════════════════════════════════

FINANCE DEPARTMENT (mg-finance):
├─ grp-finance-admins: Contributor ✓
├─ grp-finance-users: Reader ✓
└─ Result: Finance autonomous, isolated

ENGINEERING DEPARTMENT (mg-engineering):
├─ grp-engineering-admins: Contributor ✓
├─ grp-engineering-users: Reader ✓
└─ Result: Engineering autonomous, isolated

OPERATIONS (mg-operations):
├─ grp-ops-admins: Contributor ✓
├─ grp-ops-users: Reader ✓
└─ Result: Operations autonomous, isolated

CENTRAL IT (Root):
├─ grp-it-admins: Owner ✓
├─ grp-auditors: Reader ✓
└─ Result: IT maintains oversight + audit access

ISOLATION VERIFIED:
├─ Finance VP: Sees Finance subs ONLY ✓
├─ Engineering VP: Sees Engineering subs ONLY ✓
├─ Operations Director: Sees Operations subs ONLY ✓
├─ IT Director: Sees EVERYTHING (Root) ✓
└─ Auditors: Sees EVERYTHING (read-only) ✓
```

### Validation Checklist

- [ ] Assigned Contributor to grp-finance-admins on mg-finance
- [ ] Assigned Contributor to grp-engineering-admins on mg-engineering
- [ ] Assigned Contributor to grp-ops-admins on mg-operations
- [ ] Assigned Owner to grp-it-admins at Root
- [ ] Assigned Reader to grp-auditors at Root
- [ ] All assignments visible in IAM
- [ ] Scopes verified (MG vs Root)

### Success Criteria

✅ Complete: All RBAC assignments configured  
✅ Department isolation enforced via RBAC  
✅ Central IT maintains Root control  
✅ Auditors have read-only Root access  

---

## Part 6 – Test Department Isolation

### The Challenge

Verify that isolation actually works. Don't trust configuration - test it!

### What You'll Learn

- How to test access from different perspectives
- How to verify isolation is enforced
- How to troubleshoot access issues

### Step-by-Step Tasks

**Step 1: Test Finance Admin Access**

Simulate Finance VP signing in:

```
TEST: Finance VP can see Finance subscriptions

Method 1: Use "Check access" in IAM
├─ Go to any subscription > Access control (IAM) > Check access
├─ Enter Finance VP email
└─ Verify: Can access Finance subs, CANNOT access Engineering/Ops

Method 2: Sign in as Finance VP
├─ Open new browser (InPrivate/Incognito)
├─ Sign in as Finance VP user
├─ Navigate to Subscriptions blade
├─ Record which subscriptions are visible
```

**Expected Results:**
```
Finance VP (grp-finance-admins):

Can See:
├─ finance-prod ✓
├─ finance-staging ✓
└─ finance-dev ✓

Cannot See:
├─ eng-prod ✗
├─ eng-staging ✗
├─ eng-dev ✗
├─ eng-ml ✗
├─ ops-infrastructure ✗
└─ ops-security ✗

Result: ISOLATION VERIFIED ✓
```

**Step 2: Test Engineering Admin Access**

```
TEST: Engineering VP can see Engineering subscriptions ONLY

Expected Results:

Can See:
├─ eng-prod ✓
├─ eng-staging ✓
├─ eng-dev ✓
└─ eng-ml ✓

Cannot See:
├─ finance-prod ✗
├─ finance-staging ✗
├─ finance-dev ✗
├─ ops-infrastructure ✗
└─ ops-security ✗

Result: ISOLATION VERIFIED ✓
```

**Step 3: Test Operations Admin Access**

```
TEST: Operations Director can see Operations subs ONLY

Expected Results:

Can See:
├─ ops-infrastructure ✓
└─ ops-security ✓

Cannot See:
├─ finance-* ✗
├─ eng-* ✗
└─ All other subscriptions ✗

Result: ISOLATION VERIFIED ✓
```

**Step 4: Test IT Admin Access (Should see everything)**

```
TEST: IT Director can see ALL subscriptions

Expected Results:

Can See: ALL subscriptions ✓
├─ finance-* ✓
├─ eng-* ✓
├─ ops-* ✓
└─ Any other subscriptions ✓

Result: Central oversight verified ✓
```

**Step 5: Test Auditor Access (Read-only everywhere)**

```
TEST: Auditor can view everything but not modify

Expected Results:

Can See: ALL subscriptions (read-only) ✓
Can Modify: NOTHING ✗
├─ Cannot create resources
├─ Cannot delete resources
├─ Cannot change policies
└─ Can only view and audit ✓

Result: Read-only auditing verified ✓
```

**Step 6: Create Isolation Test Report**

```
DEPARTMENT ISOLATION TEST REPORT
════════════════════════════════════════════════════════════

Test Date: _______________
Tester: _______________

FINANCE ADMIN ISOLATION:
├─ Can see Finance subs: ✓ PASS / ✗ FAIL
├─ Cannot see Engineering: ✓ PASS / ✗ FAIL
├─ Cannot see Operations: ✓ PASS / ✗ FAIL
└─ Result: ✓ ISOLATED / ✗ FAILED

ENGINEERING ADMIN ISOLATION:
├─ Can see Engineering subs: ✓ PASS / ✗ FAIL
├─ Cannot see Finance: ✓ PASS / ✗ FAIL
├─ Cannot see Operations: ✓ PASS / ✗ FAIL
└─ Result: ✓ ISOLATED / ✗ FAILED

OPERATIONS ADMIN ISOLATION:
├─ Can see Operations subs: ✓ PASS / ✗ FAIL
├─ Cannot see Finance: ✓ PASS / ✗ FAIL
├─ Cannot see Engineering: ✓ PASS / ✗ FAIL
└─ Result: ✓ ISOLATED / ✗ FAILED

IT ADMIN OVERVIEW:
├─ Can see all subscriptions: ✓ PASS / ✗ FAIL
├─ Can modify resources: ✓ PASS / ✗ FAIL
└─ Result: ✓ CENTRAL CONTROL / ✗ FAILED

AUDITOR ACCESS:
├─ Can view all subscriptions: ✓ PASS / ✗ FAIL
├─ Cannot modify anything: ✓ PASS / ✗ FAIL
└─ Result: ✓ READ-ONLY AUDIT / ✗ FAILED

OVERALL: ✓ ALL TESTS PASS / ✗ SOME FAILURES
```

### Validation Checklist

- [ ] Tested Finance VP access (can see Finance only)
- [ ] Tested Engineering VP access (can see Engineering only)
- [ ] Tested Operations admin access (can see Operations only)
- [ ] Tested IT admin access (can see everything)
- [ ] Tested auditor access (read-only everywhere)
- [ ] All isolation verified
- [ ] Test report completed

### Success Criteria

✅ Complete: All isolation tests passed  
✅ Department admins cannot see other departments  
✅ IT maintains central oversight  
✅ Auditors have read-only access  

---

## Final Assessment: Department Delegation Checklist

After completing all 6 parts, verify everything is in place:

```
DEPARTMENT DELEGATION & ISOLATION FINAL CHECKLIST
════════════════════════════════════════════════════════════

DESIGN & PLANNING
├─ [ ] MG hierarchy designed
├─ [ ] Subscription organization planned
├─ [ ] RBAC strategy documented
└─ [ ] Status: ✓ COMPLETE

MANAGEMENT GROUPS
├─ [ ] mg-finance created
├─ [ ] mg-engineering created
├─ [ ] mg-operations created
└─ [ ] Status: ✓ COMPLETE

SUBSCRIPTIONS
├─ [ ] Finance subs moved to mg-finance
├─ [ ] Engineering subs moved to mg-engineering
├─ [ ] Operations subs moved to mg-operations
└─ [ ] Status: ✓ COMPLETE

ENTRA GROUPS
├─ [ ] 3 department admin groups created
├─ [ ] 3 department user groups created
├─ [ ] IT admin group created
├─ [ ] Auditor group created
└─ [ ] Status: ✓ COMPLETE

RBAC ASSIGNMENTS
├─ [ ] Finance admins: Contributor on mg-finance
├─ [ ] Engineering admins: Contributor on mg-engineering
├─ [ ] Operations admins: Contributor on mg-operations
├─ [ ] IT admins: Owner at Root
├─ [ ] Auditors: Reader at Root
└─ [ ] Status: ✓ COMPLETE

ISOLATION TESTING
├─ [ ] Finance VP: Isolated to Finance subs
├─ [ ] Engineering VP: Isolated to Engineering subs
├─ [ ] Operations Director: Isolated to Operations subs
├─ [ ] IT Director: Can see everything
├─ [ ] Auditors: Read-only everywhere
└─ [ ] Status: ✓ COMPLETE

DOCUMENTATION
├─ [ ] Design document created
├─ [ ] MG creation log completed
├─ [ ] Subscription organization verified
├─ [ ] RBAC matrix documented
├─ [ ] Isolation test report completed
└─ [ ] Status: ✓ COMPLETE

OVERALL COMPLETION: ___ 100% ___ Partial (identify gaps)
```

---

## Key Takeaways

✅ **Management Groups enable delegation** - Each department manages their own scope  
✅ **Scope isolation prevents data leaks** - Finance VP cannot see Engineering data  
✅ **RBAC at MG level cascades to subscriptions** - Changes at MG level affect all child subscriptions  
✅ **Central IT maintains overview** - Root Owner role provides emergency access  
✅ **Auditors need Root Reader access** - Can see everything for compliance  

---

## Real-World Application

You've now implemented patterns used by:
- **Google, Amazon, Microsoft**: Multi-department organizations
- **Enterprise IT teams**: Department delegation at scale
- **Large SaaS companies**: Autonomous team structure
- **Financial services**: Regulatory-required segregation

---

## Next Steps

1. **Document the structure** - Share MG hierarchy with all departments
2. **Train department admins** - Help them understand their autonomy and responsibility
3. **Monitor usage** - Track departmental spending and resource creation
4. **Apply department policies** - Add Finance-specific, Engineering-specific policies
5. **Set up alerts** - Cost alerts per department (from Lab 06)
6. **Audit quarterly** - Review access and resource organization

