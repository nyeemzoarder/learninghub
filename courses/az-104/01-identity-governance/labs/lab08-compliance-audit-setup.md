# Lab 08 – Compliance & Audit Setup (SOC 2 & Data Governance)

## Real-Life Scenario

**Company: FinServe Solutions (Financial Services SaaS)**

FinServe is a payment processing company handling millions in customer transactions. Last month, their auditors asked:

**"How do we know nobody tampered with customer data? Can you prove nobody deleted audit logs? Show me your audit trail for who accessed sensitive data."**

**The Problem:**
- ❌ No activity logging configured
- ❌ Audit logs not retained long-term
- ❌ Cannot prove who accessed what when
- ❌ No compliance evidence for SOC 2 audit
- ❌ Cannot detect suspicious activity
- ❌ Risk: "We don't know if we've been breached"

**Compliance Requirements:**
```
SOC 2 Type II Audit Requirements:
├─ Activity logging enabled
├─ 90-day retention minimum
├─ Immutable audit trail
├─ Role-based access to logs (auditor can view, not modify)
├─ Encryption for logs at rest and in transit
├─ Monthly compliance reporting
└─ Detection of unauthorized access attempts
```

**Your Challenge:** Implement audit & compliance infrastructure

**The Solution You'll Build:**
```
COMPLIANCE ARCHITECTURE:

Activity Logs (Who did what)
├─ All subscription activities logged
├─ Stored for 90+ days
└─ Forwarded to Log Analytics

Diagnostic Logs (Resource details)
├─ Storage, Database, Network, VM logs
├─ Stored for 90+ days
└─ Forwarded to Log Analytics

Log Analytics Workspace
├─ Centralized log storage
├─ 90-day retention policy
├─ Query capabilities for investigation
└─ Integration with security monitoring

Compliance Policies
├─ All data must be encrypted
├─ All backups enabled
├─ US regions only (data residency)
└─ Enforce via Azure Policy

Auditor Access
├─ Auditors: Reader (view logs, cannot modify)
├─ Auditors: Log Analytics Reader (query logs)
└─ Auditors: CANNOT delete or modify logs

RESULT: SOC 2 compliant audit trail ✓
```

---

## Prerequisites

**Required Knowledge:**
- [Lab 01: Entra ID - Users & Groups](lab01-entra-users-groups.md)
- [Lab 02: RBAC & Azure Policy](lab02-rbac-azure-policy.md)
- [Lab 03: Management Groups & Subscriptions](lab03-management-groups-subscriptions.md)
- [Lab 07: Identity Security Hardening](lab07-identity-security-hardening.md) (optional but helpful)

**Required Permissions:**
- Owner role on at least one subscription
- Global Administrator or User Administrator in Entra ID
- Access to Log Analytics and monitoring features

**Cost Note:** Log Analytics charges per GB ingested ($2.50/GB typically). This lab uses free tier initially but may incur costs at scale.

---

## Estimated Time

**Total: 80 minutes**
- Part 1: Enable activity logging & diagnostic settings (20 min)
- Part 2: Set up Log Analytics Workspace (15 min)
- Part 3: Configure retention policies (15 min)
- Part 4: Create auditor access controls (15 min)
- Part 5: Set up compliance policies & evidence (15 min)

**Difficulty: Intermediate**

---

## Part 1 – Enable Activity Logging & Diagnostic Settings

### The Challenge

Logs don't exist by default. You must explicitly enable logging to create audit trails.

### What You'll Learn

- How to enable activity logging
- How to configure diagnostic settings
- How to route logs to storage
- How audit trails are created

### Step-by-Step Tasks

**Step 1: Understand Logging in Azure**

Two types of logs exist:

```
ACTIVITY LOGS (Subscription-level):
├─ What: Who did what at subscription/resource group level
├─ Examples:
│   ├─ User created VM
│   ├─ Admin deleted storage account
│   ├─ Policy denied resource creation
│   └─ Role assignment changed
├─ Captured: Automatically (no setup needed)
├─ Retention: 90 days by default
└─ Purpose: Subscription-level audit trail

DIAGNOSTIC LOGS (Resource-level):
├─ What: Detailed logs from individual resources
├─ Examples:
│   ├─ SQL query executed
│   ├─ File accessed in storage
│   ├─ Network security group rule blocked traffic
│   └─ Key vault accessed
├─ Captured: Must be enabled per resource
├─ Retention: Unlimited (if forwarded to storage/workspace)
└─ Purpose: Detailed compliance evidence
```

**Step 2: Create Storage Account for Log Archival**

Activity logs can be archived to storage for long-term retention:

1. Go to **Storage accounts** > **Create**
2. Create account:
```
Name: logsarchive[randomnumber]
Redundancy: LRS (acceptable for logs)
Tier: Cool (logs rarely accessed)
Purpose: Archive audit logs for 7+ years
```

3. Once created, note the **Storage account ID** (full resource path)

**Step 3: Enable Activity Log to Storage**

1. Go to **Activity log** (at subscription level)
2. Click **Export Activity Log**
3. Configure:
```
Destination: Storage account
Storage account: [logsarchive account from Step 2]
Retention: 365 days (1 year minimum for compliance)
Events to export: All
```

4. Click **Save**

**Step 4: Enable Activity Log to Event Hub (Optional - for real-time monitoring)**

For SOC 2, you might want real-time alerts on suspicious activity:

1. Go to **Activity log** > **Export Activity Log**
2. Add destination: **Event Hub**
3. Creates capability to trigger alerts on suspicious events
4. Example: Alert when user is deleted, role changed, etc.

**Step 5: Enable Diagnostic Settings for Resources**

For detailed compliance evidence, enable diagnostics on key resources:

1. Go to **Subscriptions** > **Diagnostic settings**
2. Create new setting:
```
Name: Send-All-Logs-To-Workspace
Logs: Check all log categories
Destination: Log Analytics Workspace (create in Part 2)
Retention: 90 days minimum
```

Or for individual resources:

1. Go to **Storage Account** > **Diagnostic settings**
2. Click **+ Add diagnostic setting**
3. Configure:
```
Name: Storage-Diagnostic-Logs
Logs: 
├─ StorageRead: ✓
├─ StorageWrite: ✓
└─ StorageDelete: ✓
Destinations: Log Analytics + Storage account
Retention: 90+ days
```

Repeat for:
- SQL Databases (query logs, connection logs)
- Key Vaults (access logs)
- Network Security Groups (traffic logs)

**Step 6: Document Logging Setup**

```
ACTIVITY & DIAGNOSTIC LOGGING CONFIGURATION
════════════════════════════════════════════════════════════

ACTIVITY LOG:
├─ Destination: Storage account (logsarchive...)
├─ Retention: 365 days
├─ Status: ✓ Enabled
└─ Purpose: Long-term archive

DIAGNOSTIC LOGS (Resources):
├─ Log Analytics Destination: [workspace name] (created in Part 2)
├─ Storage Destination: [archive account]
├─ Retention: 90 days minimum
└─ Resources with diagnostics enabled:
   ├─ Storage accounts: ✓
   ├─ SQL databases: ✓
   ├─ Key vaults: ✓
   └─ Other critical resources: ✓

LOGGING STATUS: ✓ ENABLED
```

### Validation Checklist

- [ ] Created storage account for log archival
- [ ] Enabled Activity log to Storage (365-day retention)
- [ ] Enabled Activity log to Event Hub (optional)
- [ ] Enabled diagnostic settings at subscription level
- [ ] Enabled diagnostics on key resources (Storage, SQL, Key Vault)
- [ ] Retention policies set to 90+ days
- [ ] Logging setup documented

### Success Criteria

✅ Complete: Activity logging enabled  
✅ Diagnostic logging configured on key resources  
✅ Long-term retention configured  
✅ Logs flowing to storage for archival  

---

## Part 2 – Set Up Log Analytics Workspace

### The Challenge

Logs need somewhere to be stored, queried, and analyzed. Log Analytics provides this.

### What You'll Learn

- How to create Log Analytics Workspace
- How to route logs to workspace
- How to query logs for compliance evidence
- How to set up alerting

### Step-by-Step Tasks

**Step 1: Create Log Analytics Workspace**

1. Go to **Log Analytics workspaces** > **Create**

2. Configure:
```
Name: compliance-logs-workspace
Resource Group: [create new or use existing]
Location: [same region as your resources, e.g., East US]
Pricing: Pay-as-you-go (or Standard if volume predictable)
Purpose: Centralized compliance log storage
```

3. Click **Review + Create** > **Create**

4. Once created, note the **Workspace ID** and **Workspace Key**

**Step 2: Route Subscription Activity Logs to Workspace**

1. Go to **Activity log** at subscription level
2. Click **Export Activity Log**
3. Add destination: **Log Analytics Workspace**
4. Select workspace created in Step 1
5. Click **Save**

Now all subscription activities flow into the workspace.

**Step 3: Route Diagnostic Logs from Resources to Workspace**

For each resource type:

1. Go to **Storage Account** > **Diagnostic settings**
2. Click **+ Add diagnostic setting**
3. Configure:
```
Name: Route-To-Compliance-Workspace
Logs: Check all relevant categories
Destination: Log Analytics Workspace
Select workspace: [compliance-logs-workspace]
Retention: 90 days
```

4. Click **Save**

Repeat for:
- SQL Databases
- Key Vaults
- Network Security Groups
- App Services (if applicable)

**Step 4: Test Logs Are Flowing**

1. Go to **Log Analytics Workspace** > **Logs**
2. Click **Write a new query** or use template: **Activity Log**
3. Click **Run** to see if logs are appearing

Expected:
```
Sample Activity Log Query Result:
TimeGenerated: 2024-06-19T14:23:45Z
OperationName: Microsoft.Storage/storageAccounts/write
Caller: admin@company.com
ResourceGroup: rg-compliance-test
OperationResult: Succeeded
```

If logs don't appear, wait a few minutes (propagation delay) and try again.

**Step 5: Create Useful Compliance Queries**

Save common compliance queries for later use:

1. Go to **Log Analytics Workspace** > **Logs** > **Saved Queries**

2. Create Query 1: "Who modified roles?"
```KQL
AzureActivity
| where OperationName contains "role" and OperationResult == "Succeeded"
| project TimeGenerated, Caller, OperationName, ResourceGroup
| sort by TimeGenerated desc
```

3. Create Query 2: "When were resources deleted?"
```KQL
AzureActivity
| where OperationName contains "Delete" and OperationResult == "Succeeded"
| project TimeGenerated, Caller, ResourceType, ResourceGroup
| sort by TimeGenerated desc
```

4. Create Query 3: "Failed access attempts"
```KQL
AzureActivity
| where OperationResult == "Failed"
| project TimeGenerated, Caller, OperationName, StatusMessage
| sort by TimeGenerated desc
```

5. Save each query for future use

**Step 6: Document Workspace Setup**

```
LOG ANALYTICS WORKSPACE CONFIGURATION
════════════════════════════════════════════════════════════

Workspace Details:
├─ Name: compliance-logs-workspace
├─ Workspace ID: [ID shown in Portal]
├─ Location: [region]
├─ Pricing: Pay-as-you-go
└─ Status: ✓ Created

Connected Data Sources:
├─ Activity Logs: ✓ Enabled
├─ Diagnostic Logs:
│   ├─ Storage Accounts: ✓
│   ├─ SQL Databases: ✓
│   ├─ Key Vaults: ✓
│   └─ Other resources: ✓
└─ Status: ✓ All Connected

Saved Queries:
├─ Role change detection ✓
├─ Resource deletion tracking ✓
├─ Failed access attempts ✓
└─ Total saved queries: 3

WORKSPACE STATUS: ✓ FULLY CONFIGURED
```

### Validation Checklist

- [ ] Log Analytics Workspace created
- [ ] Activity logs routed to workspace
- [ ] Diagnostic logs from resources routed to workspace
- [ ] Logs verified flowing into workspace
- [ ] Compliance queries saved (3 minimum)
- [ ] Workspace documented
- [ ] Ready for retention policies

### Success Criteria

✅ Complete: Workspace created and configured  
✅ All logs flowing into workspace  
✅ Compliance queries available  
✅ Ready for analysis  

---

## Part 3 – Configure Retention Policies

### The Challenge

Logs must be retained for compliance. Set up long-term retention.

### What You'll Learn

- How to configure log retention policies
- How to understand retention costs
- How to balance compliance with storage costs

### Step-by-Step Tasks

**Step 1: Set Activity Log Retention (Already done in Part 1)**

You already configured:
- Activity Log to Storage: 365 days
- Activity Log to Workspace: Can be configured here

1. Go to **Log Analytics Workspace** > **Usage and Estimated Costs** > **Data Retention**
2. Set retention to **90 days minimum** (for compliance)
3. Document:
```
Activity Log Retention: 365 days (in storage account)
Workspace Retention: 90 days (in Log Analytics)
```

**Step 2: Archive Old Logs to Cheap Storage**

For long-term compliance (7+ years), move old logs to cold storage:

1. Go to **Storage Account** > **Lifecycle management**
2. Create policy:
```
Rule: Archive logs older than 90 days
Action: Move blobs older than 90 days to Archive tier
Effect: After 90 days in cool storage, move to archive (cheaper)
Cost: Archive = $0.01/GB/month vs Cool = $0.01/GB/month
Savings: Significant for 7-year retention
```

**Step 3: Verify Retention Policies**

1. Go to **Log Analytics Workspace** > **Properties**
2. Verify data retention shown:
```
Workspace Data Retention: 90 days
├─ Free Tier: 90 days maximum (unless you pay)
├─ Paid Tier: 30-730 days configurable
└─ Current setting: 90 days
```

3. Go to **Storage Account** > **Lifecycle Management**
4. Verify archive rules are configured:
```
Lifecycle Rules: ✓ Enabled
├─ Archive logs >90 days old
├─ Delete archived logs >2555 days (7 years)
└─ Status: ✓ Active
```

**Step 4: Document Retention Configuration**

```
LOG RETENTION POLICY SUMMARY
════════════════════════════════════════════════════════════

RETENTION TIMELINE:

Days 0-90: Hot Storage (fast access)
├─ Location: Log Analytics Workspace
├─ Access time: Immediate
├─ Cost: Standard ($0.05/GB)
└─ Use case: Active investigation, SOC 2 audit

Days 90-365: Cool Storage (archive)
├─ Location: Storage Account (Cool tier)
├─ Access time: Minutes
├─ Cost: Archive ($0.01/GB)
└─ Use case: Compliance archive, rare access

Years 2-7: Archive Storage (long-term)
├─ Location: Storage Account (Archive tier)
├─ Access time: Hours
├─ Cost: Ultra-cheap ($0.0001/GB)
└─ Use case: Regulatory requirement, legal hold

After 7 years: Delete
├─ Deleted from all storage
├─ Justification: No business/legal requirement beyond 7 years
└─ Cost: Eliminated

RETENTION COMPLIANCE:
├─ SOC 2 requirement: 90 days minimum ✓
├─ Tax requirement: 7 years ✓
├─ GDPR requirement: As long as needed ✓
└─ All requirements met: ✓ YES

COST PROJECTION:
├─ 100 GB/month typical (100 subscriptions)
├─ Year 1: Hot + Cool = $60/month
├─ Year 2-7: Archive only = $1/month
├─ 7-year total: ~$500 (very reasonable)
└─ Status: ✓ COST-EFFECTIVE
```

### Validation Checklist

- [ ] Activity log retention set to 365+ days
- [ ] Workspace retention set to 90+ days
- [ ] Lifecycle policy configured (move to archive after 90 days)
- [ ] Lifecycle policy configured (delete after 7 years)
- [ ] Retention policy documented
- [ ] Cost projections calculated
- [ ] All retention policies verified

### Success Criteria

✅ Complete: Retention policies configured  
✅ 90-day minimum met for SOC 2  
✅ 7-year retention for tax/legal  
✅ Cost-effective tiering in place  

---

## Part 4 – Create Auditor Access Controls

### The Challenge

Auditors need to view logs for investigation, but CANNOT modify or delete them (immutability).

### What You'll Learn

- How to create read-only auditor roles
- How to grant Log Analytics access
- How to verify immutability

### Step-by-Step Tasks

**Step 1: Create Auditor Entra Group**

1. Go to **Entra ID** > **Groups** > **New group**
2. Create:
```
Name: grp-auditors
Type: Security
Description: Auditors and compliance team (can view all logs, cannot modify)
Members: Add internal auditors, compliance officers, external audit firms
```

**Step 2: Assign Reader Role (Subscription Level)**

Allows auditors to view all resources and activity logs:

1. Go to **Subscriptions** > **Access control (IAM)**
2. Click **+ Add** > **Add role assignment**
3. Configure:
```
Role: Reader
Scope: Subscription
Members: grp-auditors
Effect: Can view everything, cannot modify
```

**Step 3: Assign Log Analytics Reader Role**

Allows auditors to query logs in Log Analytics:

1. Go to **Log Analytics Workspace** > **Access control (IAM)**
2. Click **+ Add** > **Add role assignment**
3. Configure:
```
Role: Log Analytics Reader
Scope: Workspace
Members: grp-auditors
Effect: Can query/view logs, cannot modify workspace
```

**Step 4: Assign Storage Blob Reader (For log archival access)**

Auditors might need to access archived logs in storage:

1. Go to **Storage Account** > **Access control (IAM)**
2. Click **+ Add** > **Add role assignment**
3. Configure:
```
Role: Storage Blob Data Reader
Scope: Storage Account
Members: grp-auditors
Effect: Can read archived logs, cannot delete
```

**Step 5: Verify Immutability**

Confirm auditors cannot delete logs even if they wanted to:

1. Go to **Storage Account** > **Data protection** > **Blob immutability**
2. Enable:
```
Immutable storage: ✓ Enabled
Lock type: Time-based retention (7 years)
Effect: Blobs cannot be deleted/overwritten until retention expires
Purpose: Ensures log immutability (cannot tamper with evidence)
```

This is critical for compliance - proves logs were never altered.

**Step 6: Test Auditor Access**

1. Sign in as auditor (or use "Check access")
2. Verify:
```
Can Do:
├─ [ ] View subscriptions
├─ [ ] View all resources
├─ [ ] Query Log Analytics logs
├─ [ ] Access archived logs in storage
└─ [ ] Download logs for investigation

Cannot Do:
├─ [ ] Create resources
├─ [ ] Delete resources
├─ [ ] Modify policies
├─ [ ] Delete logs
├─ [ ] Export logs to personal account
└─ [ ] Change Log Analytics workspace
```

**Step 7: Document Auditor Access**

```
AUDITOR ACCESS CONTROL CONFIGURATION
════════════════════════════════════════════════════════════

Auditor Group: grp-auditors

Role Assignments:
├─ Subscription Reader
│  └─ Can view all resources and activity logs
├─ Log Analytics Reader (on workspace)
│  └─ Can query logs for investigation
├─ Storage Blob Data Reader (on archive storage)
│  └─ Can read archived logs
└─ Status: ✓ ALL ASSIGNED

Immutability Controls:
├─ Blob immutability: ✓ Enabled
├─ Retention lock: 7 years
├─ Effect: Logs cannot be deleted during retention
└─ Compliance: ✓ IMMUTABLE

Auditor Capabilities:
✓ Can: View all logs
✓ Can: Query for suspicious activity
✓ Can: Export logs for audit reports
✗ Cannot: Delete logs
✗ Cannot: Modify logs
✗ Cannot: Create/modify resources
✗ Cannot: Change policies

AUDITOR ACCESS STATUS: ✓ SECURE & COMPLIANT
```

### Validation Checklist

- [ ] Created grp-auditors group
- [ ] Assigned Reader role at subscription level
- [ ] Assigned Log Analytics Reader role
- [ ] Assigned Storage Blob Data Reader role
- [ ] Enabled blob immutability (7-year lock)
- [ ] Tested auditor access (can view, cannot modify)
- [ ] Auditor access documented

### Success Criteria

✅ Complete: Auditor access controls configured  
✅ Auditors can view all logs  
✅ Auditors cannot delete/modify logs  
✅ Immutability enforced (7-year retention)  

---

## Part 5 – Set Up Compliance Policies & Evidence

### The Challenge

For compliance audits, you need to prove your infrastructure meets standards (encryption, backups, regions, etc.)

### What You'll Learn

- How to create compliance policies
- How to generate compliance reports
- How to prepare for audits

### Step-by-Step Tasks

**Step 1: Create Encryption Policy**

All data must be encrypted:

1. Go to **Policy** > **Definitions** > **Create Policy**
2. Create:
```
Name: Require-Encryption-All-Resources
Description: All storage and databases must be encrypted
Effect: Modify (auto-enable encryption if missing)

Rules:
├─ Storage: Enable encryption at rest ✓
├─ Databases: Enable encryption at rest ✓
├─ Disks: Enable encryption ✓
└─ Result: All data encrypted by default
```

**Step 2: Create Backup Policy**

All critical resources must have backups:

```
Name: Require-Backup-Enabled
Effect: Deny (prevent creation without backup)

Rules:
├─ SQL Databases: DENY without backup enabled
├─ Storage Accounts: DENY without versioning/snapshots
├─ VMs: DENY without backup policy attached
└─ Result: Backups mandatory
```

**Step 3: Create Data Residency Policy**

Data must stay in US (for compliance):

```
Name: US-Region-Only
Effect: Deny (non-US regions denied)

Allowed Regions:
├─ East US
├─ East US 2
├─ West US
├─ Central US
└─ Result: Data never leaves US
```

**Step 4: Create Logging Policy**

All resources must have logging enabled:

```
Name: Require-Diagnostic-Logging
Effect: Deny (without diagnostic logs)

Rules:
├─ Storage: DENY without diagnostic logs
├─ SQL: DENY without audit logs
├─ Key Vault: DENY without logging
└─ Result: Audit trail for all resources
```

**Step 5: Assign All Compliance Policies**

1. Go to **Policy** > **Assignments** > **Assign Policy**
2. For each policy created:
   - Select policy
   - Scope: Root Management Group (affects all)
   - Effect: Deny (enforce)
   - Click Assign

**Step 6: Generate Compliance Evidence Report**

1. Go to **Policy** > **Compliance**
2. Review compliance status:

```
POLICY COMPLIANCE REPORT
════════════════════════════════════════════════════════════

Generated: [Date]
Organization: FinServe Solutions
Audit Purpose: SOC 2 Type II Compliance

COMPLIANCE SUMMARY:

Policy: Encryption Required
├─ Status: ✓ Compliant (100%)
├─ Compliant resources: 95/95
└─ Non-compliant: 0

Policy: Backup Required
├─ Status: ✓ Compliant (100%)
├─ Compliant resources: 42/42
└─ Non-compliant: 0

Policy: US Region Only
├─ Status: ✓ Compliant (100%)
├─ All resources in US
└─ Non-compliant: 0

Policy: Diagnostic Logging
├─ Status: ✓ Compliant (100%)
├─ All resources logging
└─ Non-compliant: 0

OVERALL COMPLIANCE: ✓ 100% COMPLIANT

AUDIT TRAIL EVIDENCE:
├─ Activity logs: 365 days retained ✓
├─ Diagnostic logs: 90+ days retained ✓
├─ Immutability: 7-year lock enabled ✓
├─ Auditor access: Read-only configured ✓
└─ Evidence: Complete ✓

CONCLUSION:
✓ Infrastructure meets SOC 2 requirements
✓ Audit trail is complete and immutable
✓ All resources encrypted and backed up
✓ Data residency requirement met
✓ Ready for external audit
```

**Step 7: Create Monthly Compliance Report**

Document what you did this month:

```
MONTHLY COMPLIANCE ATTESTATION - JUNE 2024
════════════════════════════════════════════════════════════

Prepared by: Compliance Team
Date: June 30, 2024
For: External Auditors (SOC 2 audit)

CONTROLS VERIFIED THIS MONTH:

Activity Logs:
├─ Logs collected: ✓
├─ Retention maintained: ✓ (365 days)
├─ Immutability verified: ✓
└─ No deletions detected: ✓

Encryption Status:
├─ Storage accounts: 100% encrypted ✓
├─ Databases: 100% encrypted ✓
├─ Disks: 100% encrypted ✓
└─ Policy enforced: ✓

Backups:
├─ Databases backed up: ✓
├─ VMs in backup plan: ✓
├─ Recovery tested: ✓
└─ No backup failures: ✓

Access Controls:
├─ Role assignments reviewed: ✓
├─ Auditors have read-only: ✓
├─ Least privilege enforced: ✓
└─ No inappropriate access: ✓

Incidents This Month:
├─ Unauthorized access attempts: 0
├─ Data loss incidents: 0
├─ Compliance violations: 0
└─ Status: ✓ CLEAN

SIGNED BY: [Compliance Officer Name]
DATE: June 30, 2024
```

### Validation Checklist

- [ ] Created encryption policy
- [ ] Created backup policy
- [ ] Created data residency (US-only) policy
- [ ] Created logging policy
- [ ] Assigned all policies (Root scope)
- [ ] Verified policies enforced (100% compliant)
- [ ] Generated compliance report
- [ ] Created monthly attestation
- [ ] Evidence documented

### Success Criteria

✅ Complete: All compliance policies configured  
✅ 100% policy compliance verified  
✅ Evidence documentation created  
✅ Ready for SOC 2 audit  

---

## Final Assessment: Compliance & Audit Checklist

After completing all 5 parts, verify everything is in place:

```
COMPLIANCE & AUDIT SETUP FINAL CHECKLIST
════════════════════════════════════════════════════════════

ACTIVITY & DIAGNOSTIC LOGGING
├─ [ ] Activity logs enabled
├─ [ ] Forwarded to storage (365-day retention)
├─ [ ] Diagnostic settings configured
├─ [ ] Logs flowing to Log Analytics
└─ [ ] Status: ✓ COMPLETE

LOG ANALYTICS WORKSPACE
├─ [ ] Workspace created
├─ [ ] All logs routed to workspace
├─ [ ] Compliance queries saved (3+)
├─ [ ] Logs verified flowing
└─ [ ] Status: ✓ COMPLETE

RETENTION POLICIES
├─ [ ] Activity logs: 365 days
├─ [ ] Workspace: 90+ days
├─ [ ] Lifecycle policy: Archive after 90 days
├─ [ ] Immutability: 7-year lock enabled
└─ [ ] Status: ✓ COMPLETE

AUDITOR ACCESS CONTROLS
├─ [ ] Auditor group created
├─ [ ] Reader role assigned (subscription)
├─ [ ] Log Analytics Reader assigned
├─ [ ] Storage Blob Reader assigned
├─ [ ] Immutability enforced
└─ [ ] Status: ✓ COMPLETE

COMPLIANCE POLICIES
├─ [ ] Encryption policy: Enforced ✓
├─ [ ] Backup policy: Enforced ✓
├─ [ ] Data residency: US-only ✓
├─ [ ] Logging policy: Enforced ✓
├─ [ ] All policies: 100% compliant ✓
└─ [ ] Status: ✓ COMPLETE

COMPLIANCE EVIDENCE
├─ [ ] Policy compliance report: Generated ✓
├─ [ ] Audit trail documented: ✓
├─ [ ] Monthly attestation: Created ✓
├─ [ ] Evidence ready for audit: ✓
└─ [ ] Status: ✓ COMPLETE

OVERALL COMPLETION: ___ 100% ___ Partial (identify gaps)

SOC 2 AUDIT READINESS: ✓ READY
```

---

## Key Takeaways

✅ **Activity logging creates accountability** - Proves who did what when  
✅ **Immutable logs prevent tampering** - Logs cannot be deleted (compliance requirement)  
✅ **Auditor access must be read-only** - Auditors view evidence, cannot alter it  
✅ **Retention tiers are cost-effective** - Hot/Cool/Archive for compliance + budget  
✅ **Policies enforce compliance automatically** - Don't rely on humans to remember  
✅ **Monthly attestation proves compliance** - Document what you did for auditors  

---

## Real-World Application

You've now implemented patterns used by:
- **Financial services companies**: SOC 2, PCI-DSS compliance
- **Healthcare providers**: HIPAA audit trail requirements
- **Large enterprises**: Regulatory compliance (SOX, GDPR)
- **SaaS companies**: Customer trust and compliance evidence

---

## Next Steps

1. **Monthly compliance review** - Run queries, generate reports
2. **Quarterly audits** - Full access review + policy compliance check
3. **Annual SOC 2 audit** - Provide all evidence to external auditors
4. **Incident investigation** - Use logs for root cause analysis
5. **Retention management** - Archive old logs, delete after 7 years
6. **Team training** - Ensure everyone understands compliance requirements

