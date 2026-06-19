# Lab 04 – Identity Security Hardening & Best Practices

## Real-Life Scenario

**Company: Acme Corporation**

Acme Corp is a mid-sized SaaS company with 500+ employees and Azure infrastructure managing critical customer data. Last month, their annual security audit revealed **serious identity and access control gaps:**

**Audit Findings:**
- 47 users with Owner role who only need Reader/Contributor
- 23 inactive employee accounts still have active access
- Zero MFA protection on administrative accounts
- No alerting for suspicious sign-in patterns
- 180+ individual role assignments (should be group-based)
- No formal approval process for privilege elevation
- 8 departing employees with lingering access credentials
- 12 apps using hardcoded passwords instead of managed identities

**Your Role:** Identity Security Engineer

**Mission:** Implement all 8 best practices to remediate these findings and pass a follow-up audit.

**Success Criteria:** Complete all parts, implement all best practices, document findings.

---

## Prerequisites

**Required Knowledge:**
- [Lab 01: Entra ID - Users & Groups](lab01-entra-users-groups.md)
- [Lab 02: RBAC & Azure Policy](lab02-rbac-azure-policy.md)
- [Lab 03: Management Groups & Subscriptions](lab03-management-groups-subscriptions.md)

**Required Permissions:**
- Global Administrator or User Administrator role in Entra ID
- Owner role on test subscription
- Access to Azure Portal

---

## Estimated Time

**Total: 250 minutes (~4+ hours)**
- Part 1: 30 minutes
- Part 2: 30 minutes
- Part 3: 40 minutes
- Part 4: 30 minutes
- Part 5: 30 minutes
- Part 6: 40 minutes
- Part 7: 20 minutes
- Part 8: 30 minutes

**Difficulty: Advanced**

---

## Part 1 – Least Privilege Assessment & Remediation

### The Challenge

Acme Corp has a "just give them Owner role" culture. Your first task: identify over-privileged users and reduce their access to minimum required.

### What You'll Learn

- How to audit current RBAC assignments
- How to identify over-privileged roles
- How to create custom roles for specific needs
- How to reduce attack surface

### Step-by-Step Tasks

**Step 1: Audit Current Role Assignments**

1. Navigate to **Azure Portal** > **Subscriptions** > **Access control (IAM)**
2. Review all role assignments at subscription level
3. Document users with each role:
   - Owner roles (should be <5 people)
   - Contributor roles (should be business-justified)
   - Reader roles (should be majority)
4. Identify candidates for privilege reduction

**Example Documentation Format:**
```
Current State Analysis:
├─ Owner (10 users - reduce to 3)
│  ├─ Alice Smith (CTO) - KEEP
│  ├─ Bob Johnson (DevOps Lead) - REDUCE to Contributor
│  └─ Charlie Lee (Developer) - REDUCE to specific contributor role
├─ Contributor (35 users - acceptable)
├─ Reader (80 users - acceptable)
└─ Custom Roles (0 - NEED TO CREATE)
```

**Step 2: Identify Principle of Least Privilege Violations**

Create a table with each user and recommended action:

```
| User | Current Role | Job Function | Recommended Role | Justification |
|------|-------------|--------------|------------------|---------------|
| Bob Johnson | Owner | Deploy containers | AcrPush + App Service Contributor | Only needs to push images and manage App Service |
| Charlie Lee | Owner | Debug issues | Reader + VM Contributor (staging only) | Should not have production access |
```

**Step 3: Create Custom Roles (If Needed)**

For users needing specific permissions that don't fit built-in roles:

1. Navigate to **Azure Portal** > **Subscriptions** > **Access control (IAM)** > **Roles**
2. Click **Create a custom role**
3. Example: "Blob Storage Operator" role
   - Permissions: Read blobs, Upload blobs, Delete own blobs
   - Exclude: Delete storage account, Change access policies
4. Name: `Storage Blob Operator - Development`
5. Assign to specific user/group

**Step 4: Remove Over-Privileged Access**

For each user identified in Step 1:

1. Go to **Access control (IAM)**
2. Click the user's current role (e.g., Owner)
3. Select **Remove**
4. Confirm removal
5. Add appropriate lower-privilege role

Example actions:
```
Alice Smith: Owner (KEEP) - CEO needs full access
Bob Johnson: Owner → Contributor (reduce from Owner, keep deployment capability)
Charlie Lee: Owner → Container Registry Acrpush role (only push images)
Diana Park: Contributor → Reader + Virtual Machine Contributor (read-only, can only manage VMs)
```

### Validation Checklist

- [ ] Documented all current role assignments
- [ ] Identified at least 3 users with excessive privileges
- [ ] Created at least 1 custom role for specific needs
- [ ] Reduced privilege for 2+ over-privileged users
- [ ] Verified reduced users can still perform their jobs
- [ ] No Owner roles remain except for essential administrators

### Success Criteria

✅ Complete: Privilege surface reduced by minimum 40%  
✅ All Owner roles are business-justified  
✅ Custom roles created for specific job functions  
✅ Access changes documented with justification  

---

## Part 2 – Quarterly Access Review & Orphaned Account Cleanup

### The Challenge

Acme has 23 inactive employee accounts with active access. Find and clean up orphaned accounts and permission creep.

### What You'll Learn

- How to identify inactive users
- How to review access by user
- How to disable and remove access safely
- How to clean up permission creep

### Step-by-Step Tasks

**Step 1: Identify Inactive Accounts**

1. Go to **Azure Portal** > **Entra ID** > **Users**
2. Create a list of users with:
   - Last sign-in date > 90 days ago (or never signed in)
   - Still assigned to groups/roles
   - Status: Active (should be Disabled if not needed)

3. For each inactive user, document:
   - Name
   - Department
   - Last sign-in date
   - Current groups
   - Current role assignments

**Example Inactive Accounts Found:**
```
Michael Brown
├─ Department: Engineering (transferred to DevOps)
├─ Last Sign-in: 180 days ago
├─ Groups: grp-engineers-deploy, grp-production-access
├─ Roles: Contributor (test subscription)
└─ Status: INACTIVE - should be disabled

Sarah Davis
├─ Department: Marketing (left company 6 months ago)
├─ Last Sign-in: 200 days ago
├─ Groups: grp-all-users, grp-marketing
├─ Roles: Reader (production)
└─ Status: ORPHANED - should be deleted
```

**Step 2: Conduct Quarterly Access Review**

For each user with access, ask:

```
Access Review Questionnaire:
1. Is this user still employed? → If NO, disable/delete
2. Are they in the correct role for their current job? → If NO, update
3. When was their access last used? → If >90 days, question necessity
4. Do they still need each group membership? → If NO, remove
5. Any suspicious activity on this account? → If YES, investigate
```

**Step 3: Remediate Findings**

For each finding:

**If User is Inactive (>90 days, employed):**
1. Contact manager: "Does [user] need [role] for [resource]?"
2. If NO: Remove from groups and role assignments
3. If MAYBE: Add calendar reminder for follow-up in 30 days
4. Document decision

**If User Has Left Company:**
1. Go to **Entra ID** > **Users**
2. Find user
3. Click **Delete user**
4. Confirm deletion (this removes all group memberships and roles)

**If Permission Creep (user has many roles they don't need):**
1. Review each role assignment
2. Ask: "Is this still needed?"
3. Remove unnecessary assignments

**Step 4: Document Access Review**

Create a summary:
```
Q2 2024 Access Review Summary
────────────────────────────

Actions Taken:
├─ 6 inactive users: Removed from groups and roles
├─ 4 departed employees: Accounts deleted
├─ 12 users: Updated roles to match current job
├─ 8 users: Removed from unnecessary groups

Permission Creep Eliminated:
├─ 23 unnecessary role assignments removed
├─ 15 obsolete group memberships cleaned

Next Steps:
└─ Schedule Q3 review for [date]
```

### Validation Checklist

- [ ] Identified all inactive accounts (>90 days)
- [ ] Reviewed access for minimum 15 users
- [ ] Documented access review findings
- [ ] Removed access for at least 2 inactive users
- [ ] Deleted at least 1 orphaned account
- [ ] Created remediation summary with dates

### Success Criteria

✅ Complete: Removed access for all orphaned accounts  
✅ Cleaned up minimum 20 unnecessary role assignments  
✅ Documented quarterly review process  
✅ Established future review schedule  

---

## Part 3 – Enable MFA & Conditional Access Policies

### The Challenge

Zero MFA protection on 12 administrative accounts. Implement MFA and configure conditional access for risk-based authentication.

### What You'll Learn

- How to enforce MFA for admin roles
- How to configure Conditional Access policies
- How to set up risk-based authentication
- How to balance security with usability

### Step-by-Step Tasks

**Step 1: Configure MFA for Global Admin Roles**

1. Navigate to **Azure Portal** > **Entra ID** > **Security** > **Conditional Access**
2. Click **+ New policy**
3. Name: "Require MFA for Global Admins"

4. Configure:
   - **Users**: Select role: Global Administrator
   - **Cloud apps or actions**: All cloud apps
   - **Conditions**: None required (applies to all sign-ins)
   - **Grant**: Require multi-factor authentication

5. Enable: **On**
6. Click **Create**

**Step 2: Test MFA Enforcement**

1. Sign out of Azure Portal
2. Sign in with a Global Admin account
3. Verify MFA prompt appears
4. Complete MFA challenge (use Authenticator app, Windows Hello, or FIDO2)
5. Verify successful sign-in

**Step 3: Configure Risk-Based Conditional Access**

Create a policy that requires MFA only for risky sign-ins:

1. **New policy**: "Risk-Based MFA for All Users"

2. Configure:
   - **Users**: All users
   - **Cloud apps**: All cloud apps
   - **Conditions**:
     - Sign-in risk: High, Medium
   - **Grant**: Require multi-factor authentication

3. Enable and Create

**Step 4: Set Up Unusual Location Detection**

1. **New policy**: "Block or Require MFA for Unusual Locations"

2. Configure:
   - **Users**: All users (except emergency access accounts)
   - **Cloud apps**: All cloud apps
   - **Conditions**:
     - Locations: Exclude Trusted locations, Include All other locations
     - New/Unfamiliar locations: Yes
   - **Grant**: Require multi-factor authentication

3. Enable and Create

**Step 5: Test Conditional Access Policies**

Test scenarios:
- [ ] Sign in from normal location → No MFA required
- [ ] Sign in from new/unusual location → MFA required
- [ ] Admin sign-in → MFA always required
- [ ] Risky sign-in (multiple failed attempts) → MFA required

**Step 6: Register MFA Methods for All Users**

For successful MFA, users need registered devices:

1. **Entra ID** > **Users** > **Per-user MFA**
2. For each admin user:
   - Send them: "Please register MFA: https://aka.ms/setupsecurityinfo"
   - Ask them to register:
     - Primary: Authenticator app (Microsoft Authenticator)
     - Backup: Windows Hello or FIDO2 key

### Validation Checklist

- [ ] MFA required policy created for Global Admins
- [ ] Tested MFA prompt on admin sign-in
- [ ] Risk-based MFA policy configured
- [ ] Unusual location policy configured
- [ ] All admin users have registered MFA method
- [ ] Conditional Access policies enabled and tested

### Success Criteria

✅ Complete: All admins require MFA on every sign-in  
✅ Risk-based MFA configured for all users  
✅ Unusual location detection active  
✅ MFA methods registered and tested  

---

## Part 4 – Sign-in Monitoring & Security Alerts

### The Challenge

No alerting for suspicious sign-ins. Configure monitoring to detect breach patterns and create alerts.

### What You'll Learn

- How to review sign-in logs
- How to identify suspicious patterns
- How to set up Azure Monitor alerts
- How to create action plans for incidents

### Step-by-Step Tasks

**Step 1: Review Sign-in Logs**

1. Navigate to **Azure Portal** > **Entra ID** > **Sign-in logs**
2. Review last 7 days of sign-ins
3. Look for:
   - Failed sign-in attempts (>5 from same user)
   - Sign-ins from unusual locations
   - Sign-ins outside business hours
   - Bulk changes by unusual users
   - Access to sensitive resources

4. Document suspicious patterns:
```
Sign-In Analysis (Last 7 Days)
────────────────────────────

High Risk Findings:
├─ User: john.smith@acme.com
│  ├─ Failed attempts: 12 in 1 hour (password guessing attempt?)
│  ├─ Location: Unknown (VPN detected)
│  ├─ Time: 2:00 AM (unusual)
│  └─ Action: INVESTIGATE - potential compromise
│
├─ User: admin@acme.com
│  ├─ Bulk access changes: Added to 5 sensitive groups
│  ├─ Location: Malaysia (company is US-based)
│  ├─ Time: Outside business hours
│  └─ Action: VERIFY - possible unauthorized access
```

**Step 2: Create Azure Monitor Alerts**

1. Go to **Azure Portal** > **Monitor** > **Alerts** > **Create** > **Alert Rule**

2. **Alert 1: Failed Sign-in Attempts**
   - **Resource**: Entra ID
   - **Signal**: Sign-in activity (Entra ID logs)
   - **Condition**: 
     - > 5 failed sign-in attempts 
     - Within 5 minutes
   - **Action**: Email to security team

3. **Alert 2: Sign-in from Unusual Location**
   - **Condition**: 
     - Sign-in risk level = High
     - Unfamiliar location detected
   - **Action**: Email admin, create ticket

4. **Alert 3: Bulk Changes by One User**
   - **Condition**:
     - Multiple role assignments by single user
     - Multiple group membership changes by single user
   - **Action**: Require manual review before completion

5. Test alerts:
   - [ ] Attempt multiple failed sign-ins → Alert triggers
   - [ ] Sign in from VPN/new location → Alert triggers

**Step 3: Create Incident Response Playbook**

Document what to do when alerts fire:

```
Incident Response Playbook
═══════════════════════════

Alert: Multiple Failed Sign-in Attempts
──────────────────────────────
1. Check alert: How many failed attempts?
2. Contact user: "Is this you? Any account issues?"
3. If user: "Use password reset or MFA recovery"
4. If compromised: Lock account immediately
5. Document: When, who, what actions taken

Alert: Sign-in from Unusual Location
──────────────────────────────
1. Check alert: Where is the location?
2. Contact user: "Did you sign in from [location]?"
3. If YES: Approve and add location to trusted list (optional)
4. If NO: Password reset + full account audit
5. Document: Security incident

Alert: Bulk Changes by User
──────────────────────────────
1. Review: What changes were made?
2. Verify: Are they legitimate/authorized?
3. If legitimate: Document business reason
4. If suspicious: Roll back changes immediately
5. Contact user: Investigate if account compromised
```

**Step 4: Test Monitoring & Alerts**

Simulate suspicious activity:

1. **Test Failed Sign-ins**: Attempt to sign in with wrong password 6 times
   - Verify: Account locks after 5 failed attempts
   - Verify: Alert fires
   - Verify: Email received

2. **Test Unusual Location**: Use a VPN to sign in
   - Verify: Location shows differently
   - Verify: Conditional Access triggers MFA
   - Verify: Alert created (if configured)

### Validation Checklist

- [ ] Reviewed sign-in logs and documented findings
- [ ] Created at least 2 monitor alert rules
- [ ] Tested alert by triggering suspicious activity
- [ ] Received alert notification (email/Teams)
- [ ] Created incident response playbook
- [ ] Established escalation process

### Success Criteria

✅ Complete: Monitor alerts detect suspicious sign-in patterns  
✅ All alerts configured and tested  
✅ Incident response procedures documented  
✅ Security team knows escalation process  

---

## Part 5 – Group-Based Access Governance

### The Challenge

180+ individual role assignments instead of group-based. Migrate all human access to groups for scalability.

### What You'll Learn

- How to create security groups for access management
- How to migrate individual assignments to groups
- How to implement group-based RBAC
- How to audit group membership at scale

### Step-by-Step Tasks

**Step 1: Plan Group Structure**

Create a group naming scheme and structure:

```
Group Naming Convention: grp-[department]-[role]

Examples:
├─ grp-engineering-contributors (Contributor role)
├─ grp-engineering-readers (Reader role)
├─ grp-operations-admins (Owner role on OPS resources)
├─ grp-marketing-readers (Reader role)
├─ grp-finance-auditors (Reader role on billing)
├─ grp-support-vm-managers (VM Operator role)
└─ grp-security-admins (Global Admin)
```

**Step 2: Create Security Groups**

1. Go to **Azure Portal** > **Entra ID** > **Groups** > **New group**
2. Create security groups based on your plan:

For each group:
- **Group type**: Security
- **Group name**: grp-[department]-[role]
- **Description**: "Access [resource] with [role] for [department]"
- **Membership**: Start empty (add users in next step)

Example creation:
```
Group: grp-engineering-contributors
├─ Type: Security
├─ Description: Engineering team with Contributor role on development resources
├─ Members: (to be populated)
└─ Owners: Engineering Lead + Security Team
```

**Step 3: Populate Groups**

1. For each group, identify current users with that role
2. Add them to appropriate group:
   - Go to **Entra ID** > **Groups** > [Group Name]
   - Click **Members** > **Add members**
   - Select all users needing that role
   - Click **Select**

3. Document migration:
```
Migration Plan
──────────────

grp-engineering-contributors:
├─ From: 15 individual Contributor assignments
├─ To: grp-engineering-contributors (15 members)
├─ Verification: Each member can still perform their job
└─ Status: ✅ Migrated

grp-operations-admins:
├─ From: 8 individual Owner assignments
├─ To: grp-operations-admins (8 members)
├─ Verification: OPS team confirms access
└─ Status: ✅ Migrated
```

**Step 4: Assign Roles to Groups**

1. Go to **Azure Portal** > **Subscriptions** > **Access control (IAM)**
2. Click **+ Add** > **Add role assignment**
3. For each group:
   - **Role**: [Appropriate role - e.g., Contributor]
   - **Assign access to**: Groups
   - **Members**: Select group (e.g., grp-engineering-contributors)
   - **Click Assign**

4. Verify group now has the role:
   - Go back to **Access control (IAM)**
   - Confirm group appears with assigned role

**Step 5: Remove Individual Assignments**

Once groups are in place and tested:

1. Go to **Access control (IAM)**
2. For each individual user with a role:
   - If they're now in a group with same role: Remove individual assignment
   - Click their role, select **Remove**
   - Confirm removal

3. Document removals:
```
Individual Assignments Removed:
├─ Alice Smith: Removed Contributor (now in grp-engineering-contributors)
├─ Bob Johnson: Removed Contributor (now in grp-operations-admins)
├─ Charlie Lee: Removed Reader (now in grp-marketing-readers)
└─ Total: 45 individual assignments removed
```

**Step 6: Audit Group Membership**

Create a process for regular group audits:

1. Monthly group review:
   ```
   Group Audit Checklist (Monthly)
   ──────────────────────────────
   
   For each group:
   - [ ] Review member list
   - [ ] Verify each member still needs the role
   - [ ] Verify no one is missing who should be in it
   - [ ] Check owner is still appropriate person
   - [ ] Document any changes
   ```

### Validation Checklist

- [ ] Created at least 5 security groups
- [ ] Migrated minimum 50 individual assignments to groups
- [ ] Assigned groups to appropriate roles
- [ ] Removed individual assignments (groups in place)
- [ ] Verified group members can still perform their jobs
- [ ] Zero individual user role assignments remain (except service principals)

### Success Criteria

✅ Complete: All human access is group-based  
✅ All individual assignments migrated  
✅ Group audit process established  
✅ Scalable, auditable access model in place  

---

## Part 6 – Approval Workflows & Entitlement Management

### The Challenge

No formal approval process. Implement Entitlement Management so privileged roles require proper authorization.

### What You'll Learn

- How to set up Entitlement Management
- How to create access packages
- How to configure approval workflows
- How to enforce separation of duty

### Step-by-Step Tasks

**Step 1: Enable Entitlement Management**

1. Go to **Azure Portal** > **Entra ID** > **Identity Governance** > **Entitlement Management**
2. If not already enabled, click **Enable**
3. Confirm you want to enable Entitlement Management for your tenant

**Step 2: Create Sensitive Role Access Package**

1. Click **Access packages** > **New access package**
2. Create access package for sensitive roles:

**Access Package 1: Production Contributor Access**

```
Name: Production-Contributor-Access
Description: Request Contributor role on production subscription
Purpose: Deploy and manage production resources

Catalog: Default

Resources:
├─ Subscription: Production (Add)
├─ Role: Contributor
└─ Scope: Subscription

Who can request:
├─ Users: All employees (members)
├─ Admin: All employees (members)

Approval Policy:
├─ Approver 1: Direct manager (auto)
├─ Approver 2: Security team (manual)
├─ Approver 3: Resource owner (manual)
├─ Same person cannot approve own request
├─ Auto-denial if no approval in 7 days

Access period:
├─ Duration: 90 days
├─ Auto-review: Yes (before expiration)
├─ Recertification: Quarterly
```

**Step 3: Set Up Approval Workflow Details**

For each access package, define:

```
Approval Workflow: Production Contributor Access
═════════════════════════════════════════════════

Request Submission:
1. User submits: "I need Contributor role on Production for project X"
2. System captures: Who, What, When, Business justification

Approval Stage 1 - Manager Review (24 hrs):
├─ Approver: Direct manager
├─ Question: "Does [user] need this for their job?"
├─ Options: Approve / Deny / Request more info
├─ If Approved: → Go to Stage 2
├─ If Denied: → Notify user, process ends

Approval Stage 2 - Security Review (48 hrs):
├─ Approver: Security team
├─ Question: "Are there security concerns with this assignment?"
├─ Review: User's history, role sensitivity, usage patterns
├─ If Approved: → Go to Stage 3
├─ If Denied: → Notify user and manager, process ends

Approval Stage 3 - Resource Owner Review (48 hrs):
├─ Approver: Production subscription owner
├─ Question: "Should this person have access to production?"
├─ If Approved: → Provision access
├─ If Denied: → Deny request, process ends

Provisioning:
├─ System auto-assigns group to Contributor role
├─ Start date: Immediately (or scheduled)
├─ Expiration date: 90 days from approval
├─ Notification: User + manager + approvers

Post-Approval:
├─ Day 60: Reminder to user access expires in 30 days
├─ Day 85: Auto-review reminder for everyone
├─ Day 90: Access expires, role automatically removed
├─ User can re-request for extension (repeats approval process)
```

**Step 4: Test Approval Workflow**

1. Create a test user account (or have colleague test)
2. Request access: Go to **Access packages** (as test user)
3. Find: "Production-Contributor-Access"
4. Click **Request access**
5. Submit request with business justification

Track approval flow:
- [ ] Manager receives approval request
- [ ] Manager approves (or denies)
- [ ] Security team receives approval request
- [ ] Security team approves
- [ ] Resource owner receives approval request
- [ ] Resource owner approves
- [ ] Access provisioned automatically
- [ ] User can now access production

**Step 5: Document Approval Audit Trail**

Verify audit trail is captured:

1. Go to **Entitlement Management** > **Catalogs** > **Default**
2. Click **Access package**: Production-Contributor-Access
3. Review request history:
   - Requester
   - What was requested
   - Approval chain
   - Who approved when
   - When access was provisioned
   - When access expires

Document in audit log:
```
Access Request Audit Trail Example
───────────────────────────────────

Request #1 - Production Contributor Access
├─ Requester: John Smith (john@acme.com)
├─ Submitted: 2024-06-15 10:30 AM
├─ Business Justification: "Deploy new feature to production API"
├─ Approval 1: Manager (Sarah Johnson) - Approved 2024-06-15 11:00 AM
├─ Approval 2: Security (sec-team@acme.com) - Approved 2024-06-15 2:30 PM
├─ Approval 3: Owner (ops-lead@acme.com) - Approved 2024-06-15 3:45 PM
├─ Provisioning: 2024-06-15 3:50 PM
├─ Access Type: Group membership in grp-production-contributors
├─ Expiration: 2024-09-13
└─ Status: ✅ Approved & Provisioned

(Full audit trail available for compliance/investigation)
```

### Validation Checklist

- [ ] Entitlement Management enabled
- [ ] Created access package for sensitive role
- [ ] Configured 3-stage approval workflow
- [ ] Assigned approvers for each stage
- [ ] Tested request submission
- [ ] Tested approval process (all 3 stages)
- [ ] Verified access provisioned after approval
- [ ] Reviewed audit trail

### Success Criteria

✅ Complete: Formal approval process for all privileged access  
✅ Separation of duty enforced (no self-approval)  
✅ All approvals logged with full audit trail  
✅ Access automatically expires after 90 days  

---

## Part 7 – Secure Offboarding & Account Cleanup

### The Challenge

Former employees still have access. Implement rapid offboarding process to disable accounts within 24 hours.

### What You'll Learn

- How to disable user accounts safely
- How to remove all access in bulk
- How to audit for orphaned accounts
- How to create offboarding checklist

### Step-by-Step Tasks

**Step 1: Create Offboarding Process**

1. Document offboarding checklist to give to HR/managers:

```
Employee Offboarding Checklist
═══════════════════════════════

Employee Name: ________________
Department: ________________
Last Day: ________________
Departure Date: ________________

BEFORE Last Day (Day -1):
├─ [ ] Request IT to disable account access
├─ [ ] Collect company laptop, phone, badges
├─ [ ] Transfer file ownership (OneDrive, Teams)
├─ [ ] Download/backup employee data

ON Last Day (Day 0):
├─ [ ] Disable Entra ID account (immediately)
├─ [ ] Revoke group memberships
├─ [ ] Remove role assignments
├─ [ ] Disable MFA phone/app
├─ [ ] Revoke Teams/Office 365 access

AFTER Last Day (Day +30):
├─ [ ] If not needed: Delete Entra ID account
├─ [ ] Audit for any remaining access
├─ [ ] Verify mailbox retention policy active
└─ [ ] Mark as complete in audit log
```

**Step 2: Disable Account (Immediate)**

Simulate offboarding for a test user:

1. Go to **Entra ID** > **Users**
2. Find employee to offboard
3. Click their name
4. Click **Disable account**
5. Confirm: Account is now disabled

Verify disabled:
- [ ] User cannot sign in
- [ ] All Sessions are signed out
- [ ] User marked "Blocked Sign in" = Yes

**Step 3: Remove All Access**

For the disabled user, remove:

**Remove from Groups:**
1. Go to **Entra ID** > **Groups**
2. For each group the user is in:
   - Click group name
   - Click **Members**
   - Find user
   - Click **Remove**

Example removals:
```
Group Removals for Departing Employee:
├─ Removed from: grp-all-employees
├─ Removed from: grp-engineering-contributors
├─ Removed from: grp-production-access
├─ Removed from: grp-aws-access
└─ Total: 8 groups
```

**Remove Role Assignments:**
1. Go to **Subscriptions** > **Access control (IAM)**
2. Search for user
3. For each role:
   - Click role
   - Click **Remove**
   - Confirm

**Step 4: Verify All Access Removed**

1. Try to sign in as departing employee:
   - Username: [their email]
   - Password: [any password]
   - Expected: "Sign in failed" message
   - ✅ Verification: Cannot sign in

2. Check no remaining access:
   - Go to **Entra ID** > **Users** > [User]
   - Group memberships: None
   - Role assignments: None
   - MFA methods: Disabled

**Step 5: Delete Account (After 30 days)**

If employee data retention period passed:

1. Go to **Entra ID** > **Users**
2. Click disabled user
3. Click **Delete user**
4. Confirm deletion
5. Log deletion in audit trail

**Step 6: Audit for Orphaned Accounts**

Monthly task - find accounts we missed:

1. Go to **Entra ID** > **Users**
2. Filter: Status = Disabled
3. For each disabled user >30 days old:
   - Verify: They were supposed to be disabled
   - Verify: No lingering access
   - Action: Delete if retention passed
4. Create audit report

```
Monthly Orphaned Account Audit
────────────────────────────────

Disabled accounts found: 12
Accounts properly cleaned: 12
├─ 4 deleted (retention period passed)
├─ 8 still in retention (delete after: [date])

No access found for disabled accounts ✅

Recommendations:
└─ Continue monthly audits
```

### Validation Checklist

- [ ] Created offboarding checklist
- [ ] Disabled test user account
- [ ] Verified disabled user cannot sign in
- [ ] Removed from all groups
- [ ] Removed all role assignments
- [ ] Verified zero remaining access
- [ ] Planned account deletion after retention

### Success Criteria

✅ Complete: All departing employees disabled within 24 hours  
✅ Zero access remains for disabled accounts  
✅ Offboarding process documented  
✅ Monthly audit process established  

---

## Part 8 – App Authentication Best Practices

### The Challenge

12 apps using hardcoded passwords for Azure authentication. Migrate to managed identities (zero secrets).

### What You'll Learn

- How to compare authentication methods
- How to create and use managed identities
- How to create and rotate certificates
- How to eliminate hardcoded secrets

### Step-by-Step Tasks

**Step 1: Audit Current App Authentication**

Document how each app authenticates:

```
Application Authentication Audit
═════════════════════════════════

App 1: DataExport Service
├─ Current: Hardcoded password in appsettings.json
├─ Location: Web server (production)
├─ Risk Level: 🔴 HIGH (password in code)
├─ Change to: Managed Identity

App 2: Backup Automation
├─ Current: Hardcoded password in environment variable
├─ Location: Automation account
├─ Risk Level: 🔴 HIGH (password in config)
├─ Change to: Managed Identity

App 3: Legacy Service
├─ Current: Service principal with certificate
├─ Location: On-premises
├─ Risk Level: 🟡 MEDIUM (certificate needs rotation)
├─ Change to: Renew certificate, set rotation reminder

Summary:
├─ Apps using passwords: 9 (CRITICAL - must migrate)
├─ Apps using certificates: 2 (OK - set rotation reminder)
├─ Apps using managed identity: 1 (BEST PRACTICE)
└─ Action Items: Migrate 9 to managed identity
```

**Step 2: Create Managed Identity for Azure App**

For apps running ON Azure (VM, App Service, Container, Function):

**Scenario: WebApi running on Azure App Service**

1. Go to **Azure Portal** > **App Services** > [App Name]
2. Click **Identity** (left menu)
3. Click **System assigned** tab
4. Set **Status**: ON
5. Click **Save**

Verify managed identity created:
- [ ] Principal ID is displayed
- [ ] Tenant ID is shown
- [ ] Status: Enabled

**Step 3: Grant Permissions to Managed Identity**

The managed identity needs permissions to access Azure resources:

1. Go to **Subscriptions** > **Access control (IAM)**
2. Click **+ Add** > **Add role assignment**
3. Configure:
   - **Role**: Appropriate for app (e.g., Contributor for deployment)
   - **Assign access to**: Managed Identity
   - **Members**: Select your app (e.g., "WebApi-prod")
4. Click **Assign**

Verify permissions:
- [ ] App role appears in IAM
- [ ] App can authenticate without password

**Step 4: Update App Code to Use Managed Identity**

Update app to use managed identity instead of password:

**Before (Hardcoded Password - INSECURE):**
```csharp
// NEVER DO THIS!
var credential = new UsernamePasswordCredential(
    username: "app@acme.com",
    password: "SuperSecretPassword123!" // In code = BAD!
);
var client = new BlobContainerClient(
    new Uri("https://storage.blob.core.windows.net/container"),
    credential);
```

**After (Managed Identity - SECURE):**
```csharp
// CORRECT: Use managed identity
var credential = new ManagedIdentityCredential();
var client = new BlobContainerClient(
    new Uri("https://storage.blob.core.windows.net/container"),
    credential);
```

No credentials needed!

**Step 5: Remove Hardcoded Passwords**

Once app is updated and tested:

1. Remove password from code:
   - Delete from appsettings.json
   - Delete from appsettings.production.json
   - Delete from environment variables
   - Delete from Key Vault (if stored there)

2. Remove old service principal:
   - Go to **Entra ID** > **App registrations**
   - Find old app service principal
   - Click **Delete**

3. Verify no passwords remain:
   - Code review
   - Configuration check
   - Grep for "password" in codebase

**Step 6: Compare Authentication Methods for Off-Azure Apps**

For apps NOT running on Azure (on-premises, external cloud):

| Method | Security | Effort | Use Case |
|--------|----------|--------|----------|
| **Password** | 🔴 Low | ⚠️ Minimal | Never. Seriously. |
| **Certificate** | 🟢 Good | 📌 Medium | Off-Azure apps, set rotation reminder |
| **Managed ID** | 🟢️ Best | ✅ None | Apps on Azure only |

**For On-Premises Apps: Use Certificate**

1. Create service principal with certificate
2. Set calendar reminder for rotation (every 12 months)
3. Document certificate thumbprint
4. Plan rotation process before expiration

```
On-Premises App: Legacy Service
────────────────────────────
Authentication: Service Principal + Certificate
Certificate Thumbprint: ABC123DEF456...
Expiration Date: 2025-06-15
Rotation Reminder: 2025-05-15 (30 days before)
Rotation Steps:
├─ Generate new certificate
├─ Upload to app service principal
├─ Update app config with new thumbprint
├─ Test with new cert
└─ Decommission old cert
```

**Step 7: Create Secrets Cleanup Checklist**

1. Audit all passwords/secrets still in use:
   ```
   find . -type f \( -name "*.json" -o -name "*.config" \) \
     | xargs grep -l "password\|secret\|credential"
   ```

2. For each found:
   - [ ] Is it needed?
   - [ ] Can it be replaced with managed identity/certificate?
   - [ ] If needed: Move to Azure Key Vault (not in code)

### Validation Checklist

- [ ] Audited all app authentication methods
- [ ] Created managed identity for at least 1 Azure app
- [ ] Granted role permissions to managed identity
- [ ] Updated app code to use managed identity
- [ ] Verified app works without hardcoded password
- [ ] Removed hardcoded password from code
- [ ] Deleted old service principal
- [ ] Documented off-Azure app authentication (certificate)
- [ ] Created secrets cleanup checklist

### Success Criteria

✅ Complete: All hardcoded passwords removed  
✅ Zero secrets in code  
✅ Apps using zero-secret authentication  
✅ Certificate rotation process documented  

---

## Final Assessment: Security Hardening Checklist

After completing all 8 parts, verify all best practices are implemented:

```
SECURITY HARDENING FINAL CHECKLIST
════════════════════════════════════

✅ Part 1: Least Privilege
   ├─ [ ] Owner roles reduced to essential only
   ├─ [ ] Custom roles created for specific needs
   ├─ [ ] All users have minimum necessary access
   └─ [ ] 40%+ privilege surface reduced

✅ Part 2: Access Reviews
   ├─ [ ] Quarterly access review process defined
   ├─ [ ] Inactive accounts identified (>90 days)
   ├─ [ ] Orphaned accounts disabled/deleted
   └─ [ ] Permission creep cleaned up

✅ Part 3: MFA & Conditional Access
   ├─ [ ] MFA required for all admins
   ├─ [ ] Risk-based MFA configured for all users
   ├─ [ ] Unusual location detection active
   └─ [ ] MFA methods registered and tested

✅ Part 4: Sign-in Monitoring
   ├─ [ ] Failed sign-in alerts configured
   ├─ [ ] Unusual location alerts active
   ├─ [ ] Suspicious activity detected and investigated
   └─ [ ] Incident response playbook created

✅ Part 5: Group-Based Governance
   ├─ [ ] Security groups created for all roles
   ├─ [ ] 50+ individual assignments migrated to groups
   ├─ [ ] Zero individual user assignments remain
   └─ [ ] Group membership audit process established

✅ Part 6: Approval Workflows
   ├─ [ ] Entitlement Management enabled
   ├─ [ ] Access packages created for sensitive roles
   ├─ [ ] 3-stage approval workflow implemented
   ├─ [ ] Separation of duty enforced
   └─ [ ] Audit trail captured for all requests

✅ Part 7: Offboarding
   ├─ [ ] Offboarding checklist created
   ├─ [ ] Accounts disabled within 24 hours
   ├─ [ ] All access removed immediately
   ├─ [ ] Monthly orphaned account audit established
   └─ [ ] Zero access remains for former employees

✅ Part 8: App Authentication
   ├─ [ ] App authentication audit completed
   ├─ [ ] Managed identities implemented for Azure apps
   ├─ [ ] All hardcoded passwords removed
   ├─ [ ] Certificate rotation process documented
   └─ [ ] Zero secrets in code

OVERALL SECURITY POSTURE
════════════════════════

Before (Audit Findings):
├─ 47 over-privileged users with Owner
├─ 23 inactive accounts with access
├─ 0 MFA on admin accounts
├─ No monitoring or alerts
├─ 180+ individual access assignments
├─ No approval process
├─ 8 departed employees with access
└─ 12 apps with hardcoded passwords
Result: 🔴 HIGH RISK - Multiple critical findings

After (Implementation Complete):
├─ Owner roles: 3 only (essential)
├─ Inactive accounts: 0 (all cleaned)
├─ MFA: 100% on admins, risk-based for all
├─ Monitoring: Active with alerts
├─ Access: 100% group-based
├─ Approvals: Formal workflow with audit trail
├─ Offboarding: 24-hour SLA
└─ Passwords: 0 in code, all managed identities
Result: ✅ COMPLIANT - Audit findings remediated

COMPLIANCE EVIDENCE
═══════════════════

Generate audit report for security team:
- [ ] Access review results
- [ ] MFA compliance report
- [ ] Sign-in monitoring logs
- [ ] Approval audit trail
- [ ] Offboarding verification
- [ ] Secrets cleanup completion

Next Steps:
├─ Schedule follow-up audit: 90 days
├─ Establish monthly review cadence
├─ Update security policies with new procedures
└─ Train team on new processes
```

---

## Key Takeaways

✅ **Least Privilege** - Give minimum access needed, nothing more  
✅ **Regular Reviews** - Quarterly access audits catch permission creep  
✅ **MFA** - Makes password theft much less valuable  
✅ **Monitoring** - Sign-in logs detect compromise early  
✅ **Groups** - Easier to manage than individual assignments  
✅ **Approvals** - Formal workflow prevents unauthorized access  
✅ **Offboarding** - Disable accounts within 24 hours  
✅ **Secrets** - Zero hardcoded passwords, use managed identities  

---

## Success Indicators

After completing this lab, you should:

✅ Understand how to audit and enforce least privilege  
✅ Know how to conduct quarterly access reviews  
✅ Be able to implement MFA and conditional access  
✅ Understand sign-in log analysis  
✅ Know how to scale access with groups  
✅ Be able to implement approval workflows  
✅ Understand rapid offboarding procedures  
✅ Know when to use managed identities vs certificates  

---

## Next Steps

1. **Complete all 8 parts** of this lab
2. **Document findings** in your audit report
3. **Share with security team** for validation
4. **Create remediation plan** with timeline
5. **Implement changes** in production
6. **Schedule quarterly reviews** to maintain compliance
7. **Train team** on new security processes
8. **Consider advanced topics**: Passwordless sign-in, risk-based access, zero trust

