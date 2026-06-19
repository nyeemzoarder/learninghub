# Lab 05 – Environment Segregation: Dev, Staging & Production Isolation

## Real-Life Scenario

**Company: TechCorp Inc**

TechCorp is a fast-growing SaaS company with 50+ engineers shipping new features daily. Last month, a junior developer accidentally deleted the production database because they had Owner access everywhere.

**The Problem:**
- 10 junior developers: Full access everywhere (can accidentally delete prod)
- 5 senior developers: Full access everywhere (no peer review on prod changes)
- 3 DevOps engineers: Manual deployments, no control over who changes what
- Result: **Risk of production outages from human error**

**Your Challenge:** Design and implement environment-based access control

**The Solution You'll Build:**
```
DEV Subscription (Junior Playground)
├─ Junior devs: Full Contributor access (create, delete, experiment)
├─ Senior devs: Full Contributor access
├─ DevOps: Full Contributor access
└─ Policy: None (safe to break things here)

STAGING Subscription (Validated Changes)
├─ Junior devs: Read-only (can't touch)
├─ Senior devs: Full Contributor access (test changes)
├─ DevOps: Full Contributor access
└─ Policy: Enforce backup tags, encryption

PROD Subscription (Locked Down)
├─ Junior devs: Read-only (observe only)
├─ Senior devs: Read-only (can't modify directly)
├─ DevOps: Full Contributor access (deploy via pipeline)
└─ Policies:
   ├─ Deny VM deletion
   ├─ Deny database deletion
   ├─ Require encryption
   ├─ Require backup tags
   ├─ Require premium VM types
   └─ Audit all changes
```

**Success Criteria:**
- Junior dev can create resources in Dev, cannot touch Prod
- Senior dev can see but not modify Prod
- DevOps can deploy to Prod with full audit trail
- Policies prevent dangerous operations
- All access changes logged

---

## Prerequisites

**Required Knowledge:**
- [Lab 01: Entra ID - Users & Groups](lab01-entra-users-groups.md)
- [Lab 02: RBAC & Azure Policy](lab02-rbac-azure-policy.md)
- [Lab 03: Management Groups & Subscriptions](lab03-management-groups-subscriptions.md)

**Required Permissions:**
- Multiple Azure subscriptions (or ability to create 3 new ones)
- Owner role on all subscriptions
- Global Administrator or User Administrator in Entra ID

**Cost Note:** This lab uses 3 subscriptions. Even if empty, some charges may apply. Use free trial subscriptions if possible.

---

## Estimated Time

**Total: 120 minutes**
- Part 1: Set up subscriptions & groups (20 min)
- Part 2: Configure RBAC per environment (30 min)
- Part 3: Create environment-specific policies (25 min)
- Part 4: Test access controls (25 min)
- Part 5: Verify policies prevent mistakes (20 min)

**Difficulty: Advanced**

---

## Part 1 – Set Up Subscriptions & Entra Groups

### The Challenge

You need 3 isolated environments with different access rules.

### What You'll Learn

- How to organize subscriptions by environment
- How to create groups for different roles
- How to plan access before implementing

### Step-by-Step Tasks

**Step 1: Create or Identify Three Subscriptions**

You need 3 subscriptions (one for each environment):

```
Dev Subscription:
├─ Name: TechCorp-Dev-Sub or dev-environment
├─ Purpose: Junior developer playground
└─ Existing subscription ID: _______________

Staging Subscription:
├─ Name: TechCorp-Staging-Sub or staging-environment
├─ Purpose: Pre-production testing
└─ Existing subscription ID: _______________

Prod Subscription:
├─ Name: TechCorp-Prod-Sub or prod-environment
├─ Purpose: Live customer data
└─ Existing subscription ID: _______________
```

If you don't have 3 subscriptions:
1. Go to **Subscriptions** > **Add subscription**
2. Create 3 new subscriptions (free trial subscriptions work)
3. Name them appropriately

**Step 2: Document Subscription IDs**

For each subscription:
1. Go to **Subscriptions** blade
2. Find the subscription ID (36-character UUID)
3. Record it:

```
Dev Subscription ID: ________________________________
Staging Subscription ID: ________________________________
Prod Subscription ID: ________________________________
```

**Step 3: Create Entra Groups for Developer Tiers**

These groups will determine who gets what access:

1. Go to **Entra ID** > **Groups** > **New group**

2. Create Group 1: Junior Developers
```
Name: grp-junior-developers
Type: Security
Description: Entry-level developers (limited to Dev environment)
Members: [Add test users representing junior devs]
```

3. Create Group 2: Senior Developers
```
Name: grp-senior-developers
Type: Security
Description: Senior developers (all environments, Prod read-only)
Members: [Add test users representing senior devs]
```

4. Create Group 3: DevOps Engineers
```
Name: grp-devops-engineers
Type: Security
Description: DevOps team (full access all environments for deployment)
Members: [Add test users representing DevOps team]
```

5. Create Group 4: Developers (All)
```
Name: grp-all-developers
Type: Security
Description: All developers (for nested group management)
Members: grp-junior-developers + grp-senior-developers
```

**Step 4: Document Your Setup**

Create a reference table:

```
SUBSCRIPTION & GROUP MAPPING
═════════════════════════════════════════════════════════════

SUBSCRIPTIONS:
├─ Dev: [ID] ____________________
├─ Staging: [ID] ____________________
└─ Prod: [ID] ____________________

ENTRA GROUPS:
├─ grp-junior-developers (Members: _____ people)
├─ grp-senior-developers (Members: _____ people)
├─ grp-devops-engineers (Members: _____ people)
└─ grp-all-developers (nested group)

READY FOR NEXT STEP: ☐ Yes ☐ No
```

### Validation Checklist

- [ ] 3 subscriptions identified/created
- [ ] Subscription IDs documented
- [ ] 4 Entra groups created
- [ ] Groups have appropriate members
- [ ] Groups documented for reference

### Success Criteria

✅ Complete: All 3 subscriptions accessible  
✅ All 4 groups created with correct members  
✅ Ready to assign RBAC roles  

---

## Part 2 – Configure RBAC Per Environment

### The Challenge

Assign roles so that each group has the right access for their environment.

### What You'll Learn

- How to assign different roles per subscription
- How to implement environment-based access control
- How to enforce separation of duties

### Step-by-Step Tasks

**Step 1: Configure DEV Subscription Access**

Dev is a playground - minimal restrictions.

```
DEV SUBSCRIPTION: Full access for development

grp-junior-developers:
├─ Role: Contributor
├─ Scope: Dev subscription
├─ Effect: Can create, modify, DELETE resources
└─ Reason: Safe to experiment; mistakes are acceptable here

grp-senior-developers:
├─ Role: Contributor
├─ Scope: Dev subscription
├─ Effect: Same as juniors in Dev
└─ Reason: Collaborate with juniors, review their code

grp-devops-engineers:
├─ Role: Contributor
├─ Scope: Dev subscription
├─ Effect: Full access
└─ Reason: Test deployment automation
```

**To implement:**

1. Go to **Dev Subscription** > **Access control (IAM)** > **Add role assignment**
2. For **grp-junior-developers**:
   - Role: **Contributor**
   - Scope: **Dev Subscription**
   - Click Assign
3. Repeat for **grp-senior-developers** and **grp-devops-engineers**

**Step 2: Configure STAGING Subscription Access**

Staging is controlled - only seniors and DevOps can modify.

```
STAGING SUBSCRIPTION: Controlled changes only

grp-junior-developers:
├─ Role: Reader
├─ Scope: Staging subscription
├─ Effect: Can VIEW but NOT MODIFY
└─ Reason: Juniors learn by observing, can't break staging

grp-senior-developers:
├─ Role: Contributor
├─ Scope: Staging subscription
├─ Effect: Can create, modify, test before prod
└─ Reason: Validate changes in staging before production

grp-devops-engineers:
├─ Role: Contributor
├─ Scope: Staging subscription
├─ Effect: Full access
└─ Reason: Test deployment pipeline
```

**To implement:**

1. Go to **Staging Subscription** > **Access control (IAM)** > **Add role assignment**
2. For **grp-junior-developers**:
   - Role: **Reader**
   - Click Assign
3. For **grp-senior-developers**:
   - Role: **Contributor**
   - Click Assign
4. For **grp-devops-engineers**:
   - Role: **Contributor**
   - Click Assign

**Step 3: Configure PROD Subscription Access**

Prod is locked down - only DevOps can deploy, everyone else read-only.

```
PROD SUBSCRIPTION: Locked down - view-only except DevOps

grp-junior-developers:
├─ Role: Reader
├─ Scope: Prod subscription
├─ Effect: Can VIEW customer data (for debugging)
├─ Cannot: Modify, delete, change anything
└─ Reason: Developers can troubleshoot production issues

grp-senior-developers:
├─ Role: Reader
├─ Scope: Prod subscription
├─ Effect: Can VIEW (same as juniors)
├─ Cannot: Modify directly (must go through DevOps)
└─ Reason: Code review → DevOps deploys → senior verifies

grp-devops-engineers:
├─ Role: Contributor
├─ Scope: Prod subscription
├─ Effect: FULL ACCESS (only them!)
├─ Deploy via pipeline ← Automated, audited
└─ Reason: Controlled deployments with full audit trail
```

**To implement:**

1. Go to **Prod Subscription** > **Access control (IAM)** > **Add role assignment**
2. For **grp-junior-developers**:
   - Role: **Reader**
   - Click Assign
3. For **grp-senior-developers**:
   - Role: **Reader**
   - Click Assign
4. For **grp-devops-engineers**:
   - Role: **Contributor**
   - Click Assign

**Step 4: Create a RBAC Matrix (Documentation)**

Document what you just configured:

```
RBAC ASSIGNMENT MATRIX
═════════════════════════════════════════════════════════════

┌──────────────────────┬──────────┬─────────┬──────┐
│ Group                │   Dev    │ Staging │ Prod │
├──────────────────────┼──────────┼─────────┼──────┤
│ Junior Developers    │ Contrib  │ Reader  │ Read │
│ Senior Developers    │ Contrib  │ Contrib │ Read │
│ DevOps Engineers     │ Contrib  │ Contrib │ Cont │
└──────────────────────┴──────────┴─────────┴──────┘

Legend: Contrib = Contributor, Read = Reader, Cont = Contributor

RESULT:
├─ Dev: Everyone has full access (playground)
├─ Staging: Seniors + DevOps can modify, juniors observe
└─ Prod: Only DevOps can modify, everyone else read-only
```

### Validation Checklist

- [ ] Dev subscription: All 3 groups have Contributor role
- [ ] Staging subscription: Juniors = Reader, Seniors/DevOps = Contributor
- [ ] Prod subscription: Juniors/Seniors = Reader, DevOps = Contributor
- [ ] RBAC matrix documented
- [ ] Access assignments verified in IAM

### Success Criteria

✅ Complete: Environment-based RBAC implemented  
✅ Junior devs have different access in each environment  
✅ DevOps is only one with Prod Contributor access  
✅ All assignments documented  

---

## Part 3 – Create Environment-Specific Policies

### The Challenge

Policies provide safety guardrails - prevent dangerous operations even if someone tries to do them.

### What You'll Learn

- How to create policies scoped to specific subscriptions
- How to prevent specific dangerous operations
- How to enforce compliance in production

### Step-by-Step Tasks

**Step 1: Create Dev Policies (Minimal)**

Dev is a sandbox - allow anything:

1. Go to **Dev Subscription** > **Policies** > **Definitions**
2. No mandatory policies needed for Dev (allow experimentation)

**Step 2: Create Staging Policies (Moderate)**

Staging needs to match Prod characteristics:

1. Go to **Staging Subscription** > **Policies** > **Assignments**
2. Click **Assign policy**

**Policy 1: Require backup tag**
```
Name: Require-Backup-Tag-Staging
Effect: Deny
Condition: Resources without tag "backup" = "enabled"
Result: Cannot create resources without backup tag
Reason: Staging must be recoverable
```

**Policy 2: Enforce encryption**
```
Name: Require-Encryption-Staging
Effect: Modify (auto-enable)
Condition: Storage accounts without encryption
Result: Auto-enables encryption if missing
Reason: Prepare for Prod's encryption requirement
```

**Step 3: Create Prod Policies (Strict)**

Production needs maximum protection:

1. Go to **Prod Subscription** > **Policies** > **Assignments**

**Policy 1: Deny resource deletion**
```
Name: Deny-Dangerous-Deletes-Prod
Effect: Deny
Conditions:
├─ Deny deletion of Virtual Machines
├─ Deny deletion of SQL Databases
├─ Deny deletion of Storage Accounts
└─ Deny deletion of Key Vaults
Exceptions: DevOps group only (requires override)
Result: Accidental deletion impossible
```

**Policy 2: Require backup tags**
```
Name: Require-Backup-Tag-Prod
Effect: Deny
Condition: Resources without tag "backup" = "enabled"
Result: Cannot deploy without backup protection
```

**Policy 3: Enforce encryption**
```
Name: Enforce-Encryption-Prod
Effect: Modify
Conditions:
├─ Auto-enable storage account encryption
├─ Auto-enable disk encryption on VMs
└─ Auto-enable database encryption
Result: All Prod data encrypted by default
```

**Policy 4: Require premium VM types**
```
Name: Limit-VM-Types-Prod
Effect: Deny
Condition: Deny non-premium VM sizes
Allowed: Standard_D2s_v3, Standard_D4s_v3, Standard_D8s_v3
Result: Prevent slow VMs in production
```

**Policy 5: Enforce region restriction**
```
Name: Prod-US-Regions-Only
Effect: Deny
Condition: Deny resources outside US regions
Allowed regions: eastus, eastus2, westus, westus2
Result: Keep customer data in US (compliance)
```

**Step 4: Document Policies**

```
POLICY ENFORCEMENT BY ENVIRONMENT
════════════════════════════════════════════════════════════

DEV SUBSCRIPTION:
├─ Policies: None (experimental environment)
├─ Philosophy: Fail fast, learn from mistakes
└─ Result: Junior devs can try anything

STAGING SUBSCRIPTION:
├─ Policy: Require backup tag
├─ Policy: Enforce encryption (auto-enable)
└─ Result: Staging mirrors Prod safety

PROD SUBSCRIPTION:
├─ Policy: Deny dangerous deletes (VM, DB, storage)
├─ Policy: Require backup tag
├─ Policy: Enforce encryption
├─ Policy: Premium VM types only
├─ Policy: US regions only
└─ Result: Production protected from common mistakes
```

### Validation Checklist

- [ ] Staging policies created (2 minimum)
- [ ] Prod policies created (5 as outlined)
- [ ] All policies tested (verify they exist)
- [ ] Policy scope verified (correct subscriptions)
- [ ] Policy effects confirmed (Deny or Modify)

### Success Criteria

✅ Complete: Policies prevent dangerous operations  
✅ Staging has moderate policies  
✅ Prod has strict protective policies  
✅ All policies documented  

---

## Part 4 – Test Access Controls

### The Challenge

Verify that access control actually works. Don't trust configuration - test it!

### What You'll Learn

- How to test access from different user perspectives
- How to verify RBAC is working
- How to detect access control problems early

### Step-by-Step Tasks

**Step 1: Test Junior Developer Access**

Simulate a junior developer signing in:

```
TEST SCENARIO: Junior dev trying to access each environment

Option 1: Use a test junior dev account
├─ Sign in as junior developer user
├─ Navigate to each subscription
└─ Record what you see

Option 2: Use Access Control (IAM) > "Check access"
├─ Go to each subscription
├─ Click Check access
├─ Enter junior dev user name
└─ View what they can access
```

**Expected Results:**
```
Dev Subscription:
├─ Can see: All resources ✓
├─ Can create: Resources ✓
├─ Can delete: Resources ✓
└─ Result: PASS ✓

Staging Subscription:
├─ Can see: All resources ✓
├─ Can create: Resources ✗ (Denied - Reader role)
├─ Can delete: Resources ✗ (Denied - Reader role)
└─ Result: PASS ✓

Prod Subscription:
├─ Can see: All resources ✓
├─ Can create: Resources ✗ (Denied - Reader role)
├─ Can delete: Resources ✗ (Denied - Reader role)
└─ Result: PASS ✓
```

Document results:
```
Junior Developer Access Test: ___ PASS ✓ ___ FAIL ✗

Expected: Full in Dev, Read-only in Staging/Prod
Actual: [Your results]
```

**Step 2: Test Senior Developer Access**

```
TEST SCENARIO: Senior dev accessing all environments

Expected Results:
Dev: Contributor (create, modify, delete) ✓
Staging: Contributor (create, modify, delete) ✓
Prod: Reader (view only, cannot modify) ✓

Verification Method:
├─ Check access for senior dev in IAM
└─ Record findings
```

**Step 3: Test DevOps Engineer Access**

```
TEST SCENARIO: DevOps engineer deploying to all environments

Expected Results:
Dev: Contributor ✓
Staging: Contributor ✓
Prod: Contributor (can deploy) ✓

Verification: DevOps should have full access everywhere
```

**Step 4: Create Access Test Report**

```
ACCESS CONTROL TEST REPORT
════════════════════════════════════════════════════════════

Test Date: _______________
Tester: _______________

GROUP: Junior Developers
├─ Dev Access: PASS ✓ / FAIL ✗
├─ Staging Access: PASS ✓ / FAIL ✗
└─ Prod Access: PASS ✓ / FAIL ✗

GROUP: Senior Developers
├─ Dev Access: PASS ✓ / FAIL ✗
├─ Staging Access: PASS ✓ / FAIL ✗
└─ Prod Access: PASS ✓ / FAIL ✗

GROUP: DevOps Engineers
├─ Dev Access: PASS ✓ / FAIL ✗
├─ Staging Access: PASS ✓ / FAIL ✗
└─ Prod Access: PASS ✓ / FAIL ✗

OVERALL: ALL PASS ✓ / SOME FAIL ✗
```

### Validation Checklist

- [ ] Tested junior dev access to all 3 subscriptions
- [ ] Tested senior dev access to all 3 subscriptions
- [ ] Tested DevOps engineer access to all 3 subscriptions
- [ ] All access levels match expected configuration
- [ ] Access test report completed

### Success Criteria

✅ Complete: All access controls verified working  
✅ Junior devs: Full in Dev, read-only elsewhere  
✅ Senior devs: Contributor in Dev/Staging, read-only in Prod  
✅ DevOps: Full access all environments  

---

## Part 5 – Verify Policies Prevent Mistakes

### The Challenge

Policies only work if they actually stop dangerous operations. Test them!

### What You'll Learn

- How to verify policies are enforced
- How to understand policy denial messages
- How to handle policy overrides (if needed)

### Step-by-Step Tasks

**Step 1: Test Prod Policy - Deny VM Deletion**

Attempt to delete a VM in Prod (should be blocked):

1. Create a test VM in Prod subscription (if one exists)
2. Attempt to delete it:
   - Go to **Prod Subscription** > **Virtual Machines** > [VM]
   - Click **Delete**
   - Expected: Policy blocks deletion with message

**Expected Denial Message:**
```
Policy denied this operation:
Name: Deny-Dangerous-Deletes-Prod
Effect: VM deletion denied in Prod
Reason: Production safety guardrail

To override:
├─ Must be DevOps engineer
├─ Must have override permissions
└─ Deletion tracked in audit logs
```

**Document result:**
```
Policy Test: VM Deletion in Prod
├─ Attempted: Delete VM
├─ Expected: Denied by policy
├─ Actual: ___ Denied ✓ ___ Allowed ✗
├─ Message: _______________
└─ Result: PASS ✓ / FAIL ✗
```

**Step 2: Test Prod Policy - Backup Tag Requirement**

Attempt to create a resource without backup tag (should be denied):

1. Go to **Prod Subscription** > **Storage accounts** > **Create**
2. Fill in basic details
3. Skip the "backup" tag
4. Attempt to create:
   - Expected: Policy denies creation

**Document result:**
```
Policy Test: Missing Backup Tag in Prod
├─ Attempted: Create storage without backup tag
├─ Expected: Denied
├─ Actual: ___ Denied ✓ ___ Allowed ✗
└─ Result: PASS ✓ / FAIL ✗
```

**Step 3: Test Policy Enforcement Success**

Create a resource WITH all required tags (should succeed):

1. Create a storage account in Prod with:
   - Name: test-storage-[timestamp]
   - Add tags: backup=enabled
2. Expected: Creation succeeds

**Document result:**
```
Policy Test: Resource with Required Tags
├─ Created: Storage account with backup tag
├─ Expected: Success
├─ Actual: ___ Success ✓ ___ Denied ✗
└─ Result: PASS ✓ / FAIL ✗
```

**Step 4: Create Policy Verification Report**

```
POLICY VERIFICATION REPORT
════════════════════════════════════════════════════════════

DENIAL TESTS (Verify policies block dangerous operations)
├─ Deny VM Deletion: PASS ✓ / FAIL ✗
├─ Deny DB Deletion: PASS ✓ / FAIL ✗
├─ Deny Untagged Resources: PASS ✓ / FAIL ✗
└─ Overall Denial Tests: ___ All Pass ___ Some Fail

ENFORCEMENT TESTS (Verify creation with proper tags succeeds)
├─ Storage with backup tag: PASS ✓ / FAIL ✗
├─ VM with encryption: PASS ✓ / FAIL ✗
└─ Overall Enforcement: ___ All Pass ___ Some Fail

CONCLUSION:
Policies are: ___ Working Correctly ___ Need Adjustment
```

### Validation Checklist

- [ ] Attempted to delete resource in Prod (was denied)
- [ ] Attempted to create resource without tags (was denied)
- [ ] Created resource with proper tags (succeeded)
- [ ] Denial messages documented
- [ ] Policy verification report completed

### Success Criteria

✅ Complete: All policy tests performed  
✅ Policies successfully block dangerous operations  
✅ Compliant resources can be created  
✅ Audit trail shows enforcement  

---

## Final Assessment: Environment Isolation Checklist

After completing all 5 parts, verify everything is in place:

```
ENVIRONMENT SEGREGATION FINAL CHECKLIST
════════════════════════════════════════════════════════════

SUBSCRIPTIONS & GROUPS
├─ [ ] 3 subscriptions (Dev, Staging, Prod) created
├─ [ ] 4 Entra groups created
├─ [ ] Groups populated with test members
└─ [ ] All documented

RBAC CONFIGURATION
├─ [ ] Dev: All groups = Contributor
├─ [ ] Staging: Juniors=Reader, Seniors+DevOps=Contributor
├─ [ ] Prod: Juniors+Seniors=Reader, DevOps=Contributor
└─ [ ] All assignments verified in IAM

POLICIES
├─ [ ] Dev: No mandatory policies (sandbox)
├─ [ ] Staging: Backup tag + encryption policies
├─ [ ] Prod: 5 strict policies (deny deletes, require tags, etc.)
└─ [ ] All policies tested and verified

ACCESS TESTING
├─ [ ] Junior dev: Full→Read→Read (Dev→Staging→Prod) ✓
├─ [ ] Senior dev: Full→Full→Read (Dev→Staging→Prod) ✓
├─ [ ] DevOps: Full→Full→Full (all environments) ✓
└─ [ ] All tests documented

POLICY ENFORCEMENT
├─ [ ] Attempted VM deletion in Prod: Denied ✓
├─ [ ] Attempted resource without tags: Denied ✓
├─ [ ] Created resource with proper tags: Success ✓
└─ [ ] All policy tests documented

DOCUMENTATION
├─ [ ] Subscription IDs recorded
├─ [ ] RBAC matrix created
├─ [ ] Policy list documented
├─ [ ] Access test report completed
└─ [ ] All findings summarized

OVERALL COMPLETION: ___ 100% ___ Partial (identify gaps)
```

---

## Key Takeaways

✅ **Environment isolation prevents production incidents** - Different access per environment catches mistakes before they reach customers  
✅ **RBAC enforces role-based access** - Junior devs can't accidentally touch Prod  
✅ **Policies provide safety guardrails** - Even if someone bypasses RBAC, policies protect critical resources  
✅ **Three-tier approach scales** - Dev/Staging/Prod is the industry standard  
✅ **Testing is critical** - Don't assume RBAC works, verify it  

---

## Real-World Application

You've now implemented the pattern used by:
- **Google, Amazon, Microsoft**: Dev/Staging/Prod per team
- **DevOps teams everywhere**: Environment-based access control
- **Enterprise cloud strategies**: Production safety guardrails
- **SaaS companies**: Preventing customer data incidents

---

## Next Steps

1. **Review** your complete access control configuration
2. **Document** the setup for your team (share this lab guide)
3. **Monitor** access logs to verify policies are working
4. **Train** team members on the access control model
5. **Iterate** as needed (add more policies, refine RBAC)
6. **Apply to real workloads** when confident in the setup

