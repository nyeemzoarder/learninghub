# Lab 06 – Cost Management & Chargeback by Department

## Real-Life Scenario

**Company: TechCorp Financial Services**

TechCorp's Azure bill grew from $5K/month to $47K/month in 6 months. The CFO is asking:

**"Who's spending what? Why is it so high? Can we control it?"**

**The Problem:**
- No visibility into spending by department
- No way to charge back costs to project owners
- Expensive resources running idle (forgotten test VMs)
- No budget controls (surprised by end-of-month bills)
- No cost forecasting
- Result: **Uncontrolled cloud spend + no accountability**

**Your Challenge:** Implement cost allocation, budgets, and controls

**The Solution You'll Build:**
```
COST ALLOCATION BY DEPARTMENT:
├─ Finance Department: $15K/month
│  ├─ Production databases: $10K
│  ├─ Development environment: $3K
│  └─ Disaster recovery: $2K
│
├─ Engineering Department: $28K/month
│  ├─ Microservices (Prod): $18K
│  ├─ Kubernetes cluster: $7K
│  └─ Development/Testing: $3K
│
└─ Operations: $4K/month
   ├─ Infrastructure: $3K
   └─ Monitoring & Backup: $1K

TOTAL: $47K/month with full visibility ✓
```

**Budget Controls:**
```
Department Budgets:
├─ Finance: Budget $16K/month → Alert at $14.4K (90%)
├─ Engineering: Budget $30K/month → Alert at $27K (90%)
├─ Operations: Budget $5K/month → Alert at $4.5K (90%)
└─ Each department owns their costs
```

**Cost Optimization:**
```
Policies Prevent Expensive Mistakes:
├─ Only allow Standard_B and Standard_D VMs (block Premium)
├─ Only allow LRS/ZRS storage (block expensive GRS)
├─ Limit resources to cost-optimized regions
└─ Require resource owners to tag everything
```

---

## Prerequisites

**Required Knowledge:**
- [Lab 01: Entra ID - Users & Groups](lab01-entra-users-groups.md)
- [Lab 02: RBAC & Azure Policy](lab02-rbac-azure-policy.md)
- [Lab 03: Management Groups & Subscriptions](lab03-management-groups-subscriptions.md)

**Required Permissions:**
- Owner role on at least one subscription
- Access to Azure Cost Management + Billing
- Ability to create policies
- Ability to create budget alerts

**Cost Note:** This lab uses existing resources (creates no new costs). Uses free Cost Management features.

---

## Estimated Time

**Total: 90 minutes**
- Part 1: Design tagging strategy (15 min)
- Part 2: Enforce tags with policies (20 min)
- Part 3: Set up budgets & alerts (20 min)
- Part 4: Analyze costs by department (20 min)
- Part 5: Prevent expensive mistakes (15 min)

**Difficulty: Intermediate**

---

## Part 1 – Design Cost Allocation Tagging Strategy

### The Challenge

Before you can track costs, you need a consistent tagging strategy. Every resource must be tagged the same way.

### What You'll Learn

- How to design a tagging strategy
- Why tag names/values matter for cost allocation
- How to document tagging standards

### Step-by-Step Tasks

**Step 1: Define Tagging Standards**

Create a company-wide tagging standard that covers:

```
REQUIRED TAGS FOR ALL RESOURCES:
════════════════════════════════════════════════════════════

Tag 1: CostCenter
├─ Purpose: Chargeback to department
├─ Values: Finance, Engineering, Operations, Training
├─ Example: CostCenter = Engineering
└─ Why: Bills can be grouped by cost center

Tag 2: Environment
├─ Purpose: Separate prod/dev costs
├─ Values: Production, Staging, Development
├─ Example: Environment = Production
└─ Why: Production usually costs 5x more than Dev

Tag 3: Owner
├─ Purpose: Know who to ask about resource
├─ Values: Email addresses of resource owners
├─ Example: Owner = john.smith@techcorp.com
└─ Why: Accountability for resource decisions

Tag 4: Project
├─ Purpose: Track costs per application/project
├─ Values: ProjectName (e.g., CustomerPortal, DataPipeline)
├─ Example: Project = CustomerPortal
└─ Why: Know which projects are expensive

Tag 5: LifeCycle
├─ Purpose: Know if resource is temporary or permanent
├─ Values: Permanent, Temporary, Trial
├─ Example: LifeCycle = Temporary
└─ Why: Clean up temporary test resources
```

**Step 2: Create Tagging Documentation**

Document your tagging standard so everyone uses it consistently:

```
TAGGING STANDARD - TECHCORP
════════════════════════════════════════════════════════════

All resources MUST have these tags (5 required tags):

Resource Template:
├─ Name: [resource-type]-[environment]-[project]
├─ CostCenter: [Finance|Engineering|Operations|Training]
├─ Environment: [Production|Staging|Development]
├─ Owner: your.email@techcorp.com
├─ Project: ProjectName
└─ LifeCycle: [Permanent|Temporary|Trial]

Example - Production Database:
├─ Name: sql-prod-customerdb
├─ CostCenter: Finance
├─ Environment: Production
├─ Owner: data-team@techcorp.com
├─ Project: CustomerPortal
└─ LifeCycle: Permanent

Example - Development VM:
├─ Name: vm-dev-testing
├─ CostCenter: Engineering
├─ Environment: Development
├─ Owner: dev-team@techcorp.com
├─ Project: DataPipeline
└─ LifeCycle: Temporary (delete after 30 days)

FAILURE TO TAG = Resource cannot be created (policy will deny)
```

**Step 3: Review Current Resources (Audit)**

Check what resources exist and how they're currently tagged:

1. Go to **Subscriptions** > **Resources**
2. Filter by resource type (e.g., Virtual Machines, Storage accounts)
3. Check which ones have tags and which don't
4. Document findings:

```
CURRENT TAGGING AUDIT
═════════════════════════════════════════════════════════════

Resource Type: Virtual Machines
├─ Total: 12 VMs
├─ Properly tagged: 3 (25%)
├─ Missing tags: 9 (75%)
└─ Action: Need to retroactively tag

Resource Type: Storage Accounts
├─ Total: 8 accounts
├─ Properly tagged: 2 (25%)
├─ Missing tags: 6 (75%)
└─ Action: Need to retroactively tag

Resource Type: SQL Databases
├─ Total: 4 databases
├─ Properly tagged: 0 (0%)
├─ Missing tags: 4 (100%)
└─ Action: Tag immediately

SUMMARY:
├─ Total resources: 24
├─ Properly tagged: 5 (21%)
├─ Need tagging: 19 (79%)
└─ Priority: HIGH - most resources untagged
```

**Step 4: Tag Existing Resources**

Update existing resources with proper tags:

For each resource without tags:
1. Go to **Resource** > **Tags**
2. Add the 5 required tags:
   - CostCenter
   - Environment
   - Owner
   - Project
   - LifeCycle
3. Click **Save**

Example PowerShell script to tag resources in bulk:

```powershell
# Tag all resources in a resource group
$rg = Get-AzResourceGroup -Name "rg-production"
$tags = @{
    "CostCenter" = "Engineering"
    "Environment" = "Production"
    "Owner" = "engineering-team@techcorp.com"
    "Project" = "CustomerPortal"
    "LifeCycle" = "Permanent"
}

$resources = Get-AzResource -ResourceGroupName $rg.ResourceGroupName
foreach ($resource in $resources) {
    Update-AzTag -ResourceId $resource.ResourceId -Tag $tags -Operation Merge
}
```

**Step 5: Document Tagging Completion**

```
TAGGING COMPLETION SUMMARY
═════════════════════════════════════════════════════════════

Resource Type: VMs
├─ Total: 12
├─ Tagged: 12 (100%)
└─ Status: ✓ Complete

Resource Type: Storage
├─ Total: 8
├─ Tagged: 8 (100%)
└─ Status: ✓ Complete

Resource Type: SQL Databases
├─ Total: 4
├─ Tagged: 4 (100%)
└─ Status: ✓ Complete

OVERALL: 24/24 resources properly tagged (100%) ✓
```

### Validation Checklist

- [ ] Tagging standard documented (5 tags defined)
- [ ] Tag values documented for each tag
- [ ] Current resources audited for tagging
- [ ] Untagged resources retroactively tagged
- [ ] 100% of resources now have required tags
- [ ] Tagging documentation shared with team

### Success Criteria

✅ Complete: All resources tagged consistently  
✅ Tagging standard documented  
✅ 100% resource coverage  
✅ Ready for cost allocation  

---

## Part 2 – Enforce Tags with Policies

### The Challenge

You can document tagging standards, but humans forget. Use policies to enforce tagging automatically.

### What You'll Learn

- How to create policies that enforce tags
- How to prevent untagged resources from being created
- How to auto-tag resources

### Step-by-Step Tasks

**Step 1: Create Policy - Require CostCenter Tag**

This policy denies creation of resources without a CostCenter tag:

1. Go to **Policy** > **Definitions** > **Create Policy Definition**

2. Configure:
```
Name: Require-CostCenter-Tag
Description: All resources must have CostCenter tag (Finance, Engineering, Operations, Training)
Policy Type: Built-in

Effect: Deny (prevent creation without tag)

Condition:
├─ Field: tags['CostCenter']
├─ Operator: exists
└─ Value: false → DENY (no tag) → ALLOW (tag exists)

Result: Cannot create resources without CostCenter tag
```

**Step 2: Create Policy - Require Environment Tag**

Similar to Step 1:

```
Name: Require-Environment-Tag
Description: All resources must have Environment tag (Production, Staging, Development)
Effect: Deny
Result: Cannot create without Environment tag
```

**Step 3: Create Policy - Require Owner Tag**

```
Name: Require-Owner-Tag
Description: All resources must have Owner tag (email of resource owner)
Effect: Deny
Result: Cannot create without Owner tag
```

**Step 4: Create Policy - Prevent Expensive VM Types**

This prevents developers from accidentally creating expensive VMs:

```
Name: Deny-Premium-VM-Types
Description: Only allow Standard_B and Standard_D VM types (cost optimization)
Effect: Deny

Condition:
├─ Resource type: Microsoft.Compute/virtualMachines
├─ Field: sku.name
├─ Values: Block Premium*, Deluxe*, etc.
├─ Allowed: Standard_B1s, Standard_B2s, Standard_D2s_v3, etc.

Result:
├─ Engineer tries to create Premium_D64s_v3
├─ Policy blocks it
├─ Must request exception through proper channels
└─ Forces cost-conscious decisions
```

**Step 5: Create Policy - Prevent Expensive Storage**

```
Name: Deny-Expensive-Storage-Replication
Description: Only allow LRS/ZRS, deny GRS/RA-GRS (cost control)
Effect: Deny

Condition:
├─ Resource type: Microsoft.Storage/storageAccounts
├─ Field: sku.name
├─ Blocked: Premium_GRS, Standard_GZRS, Standard_RA-GZRS
├─ Allowed: Standard_LRS, Standard_ZRS

Result:
├─ LRS: 1 datacenter (cheapest, acceptable for dev)
├─ ZRS: 3 zones (good for staging)
├─ GRS: 2 regions (expensive, requires exception)
└─ Prevents unintended expensive replication
```

**Step 6: Assign Policies to Subscription**

For each policy created:

1. Go to **Policy** > **Assignments** > **Assign Policy**
2. Select policy name
3. Choose scope: **Your subscription**
4. Set effect: **Deny** (enforce)
5. Click **Assign**

**Step 7: Test Policies Are Working**

Attempt to create a resource without tags:

1. Try to create a VM in the portal
2. Omit the CostCenter tag
3. Attempt to create:
   - Expected: Policy blocks creation with message
   - Message: "Required tag 'CostCenter' not found"

Document result:
```
POLICY ENFORCEMENT TEST
═════════════════════════════════════════════════════════════

Test 1: Create VM without CostCenter tag
├─ Attempted: Create VM without tag
├─ Expected: Denied
├─ Actual: ___ Denied ✓ ___ Allowed ✗
└─ Result: PASS ✓ / FAIL ✗

Test 2: Create Premium VM
├─ Attempted: Create Premium_D64s_v3 VM
├─ Expected: Denied
├─ Actual: ___ Denied ✓ ___ Allowed ✗
└─ Result: PASS ✓ / FAIL ✗

Test 3: Create resource WITH proper tags
├─ Attempted: Create Standard_D2s_v3 VM with all tags
├─ Expected: Success
├─ Actual: ___ Success ✓ ___ Denied ✗
└─ Result: PASS ✓ / FAIL ✗
```

### Validation Checklist

- [ ] Created 3 tag-requirement policies
- [ ] Created 2 cost-prevention policies
- [ ] All 5 policies assigned to subscription
- [ ] Tested policy enforcement (resource without tags denied)
- [ ] Tested compliant creation (proper tags allowed)
- [ ] Tested VM type policy (Premium denied)

### Success Criteria

✅ Complete: All policies enforced  
✅ Untagged resources cannot be created  
✅ Expensive VMs/storage blocked  
✅ Cost-conscious defaults enforced  

---

## Part 3 – Set Up Budgets & Cost Anomaly Alerts

### The Challenge

Budgets tell you how much you can spend. Alerts tell you when you're going over budget.

### What You'll Learn

- How to set up budget alerts
- How to configure anomaly detection
- How to establish cost accountability

### Step-by-Step Tasks

**Step 1: Create Budget for Engineering Department**

Engineering usually spends the most. Set a reasonable budget:

1. Go to **Cost Management + Billing** > **Budgets** > **Create budget**

2. Configure:
```
Budget Name: Engineering-Team-Monthly-Budget
Scope: Select subscription used by Engineering
Budget Amount: $30,000 (monthly)
Time Period: Monthly (resets each month)
Reset Date: 1st of each month
```

3. Configure **Alerts**:
```
Alert 1: 90% of budget
├─ Threshold: $27,000
├─ Recipients: engineering-manager@techcorp.com
└─ Triggers when spending hits $27K

Alert 2: 100% of budget
├─ Threshold: $30,000
├─ Recipients: engineering-manager@techcorp.com, cfo@techcorp.com
└─ Triggers at limit (alerts executives)

Alert 3: 110% of budget (overrun)
├─ Threshold: $33,000
├─ Recipients: cfo@techcorp.com, finance@techcorp.com
└─ Triggers if over budget (escalation)
```

4. Click **Create**

**Step 2: Create Budget for Finance Department**

Finance department manages customer data (lower cost than Engineering):

```
Budget Name: Finance-Team-Monthly-Budget
Budget Amount: $16,000
Alerts:
├─ 90%: $14,400 → engineering-manager
├─ 100%: $16,000 → manager + CFO
└─ 110%: $17,600 → CFO + Finance
```

**Step 3: Create Budget for Operations**

Operations manages infrastructure (lowest cost):

```
Budget Name: Operations-Monthly-Budget
Budget Amount: $5,000
Alerts:
├─ 90%: $4,500 → ops-manager
├─ 100%: $5,000 → ops-manager + CFO
└─ 110%: $5,500 → CFO
```

**Step 4: Create Organization-Wide Budget**

Total budget for entire company:

```
Budget Name: TechCorp-Total-Azure-Budget
Budget Amount: $51,000 (Total: Finance $16K + Engineering $30K + Ops $5K)
Alerts:
├─ 80%: $40,800 → CFO (early warning)
├─ 90%: $45,900 → CFO
├─ 100%: $51,000 → CFO + CEO
└─ 110%: $56,100 → CFO + CEO (escalation)

Purpose: Company-level cost control
```

**Step 5: Set Up Cost Anomaly Alert**

Azure can automatically detect unusual spending:

1. Go to **Cost Management** > **Alerts** > **Cost anomaly**

2. Configure:
```
Alert Name: Unusual-Spending-Detection
Scope: All subscriptions
Sensitivity: Medium (balance false positives vs real anomalies)
Frequency: Daily checks

Triggers when:
├─ Spending deviates significantly from historical average
├─ Example: Usually $1,500/day, suddenly $5,000/day
└─ Indicates: Resource leak, forgotten test environment, attack

Recipients:
├─ cfo@techcorp.com
├─ ops-manager@techcorp.com
└─ All team leads
```

**Step 6: Document Budget Configuration**

```
BUDGET & ALERT CONFIGURATION SUMMARY
════════════════════════════════════════════════════════════

DEPARTMENT BUDGETS:

Engineering Department:
├─ Budget: $30,000/month
├─ Alert 1 (90%): $27,000
├─ Alert 2 (100%): $30,000
├─ Alert 3 (110%): $33,000
└─ Recipients: engineering-manager, CFO, Finance

Finance Department:
├─ Budget: $16,000/month
├─ Alert 1 (90%): $14,400
├─ Alert 2 (100%): $16,000
├─ Alert 3 (110%): $17,600
└─ Recipients: finance-manager, CFO

Operations:
├─ Budget: $5,000/month
├─ Alert 1 (90%): $4,500
├─ Alert 2 (100%): $5,000
├─ Alert 3 (110%): $5,500
└─ Recipients: ops-manager, CFO

ORGANIZATION TOTAL:
├─ Budget: $51,000/month
├─ Alert 1 (80%): $40,800 (early warning)
├─ Alert 2 (90%): $45,900
├─ Alert 3 (100%): $51,000 (limit reached)
└─ Recipients: CFO, CEO

ANOMALY DETECTION:
├─ Status: Enabled
├─ Sensitivity: Medium
├─ Frequency: Daily
└─ Recipients: CFO, Ops Manager, Team Leads

All budgets and alerts configured: ✓
```

### Validation Checklist

- [ ] Created 3 department budgets
- [ ] Created 1 organization-wide budget
- [ ] Configured 3-tier alerts per budget (90%, 100%, 110%)
- [ ] Set appropriate recipients for each alert level
- [ ] Enabled cost anomaly detection
- [ ] All budgets configured and active

### Success Criteria

✅ Complete: All budgets and alerts in place  
✅ Departments have spending limits  
✅ Escalation path defined (90%→100%→110%)  
✅ Anomaly detection enabled  

---

## Part 4 – Analyze Costs by Department

### The Challenge

Now that budgets are in place, analyze actual spending to understand patterns.

### What You'll Learn

- How to use Azure Cost Analysis tools
- How to break down costs by tag/dimension
- How to identify expensive resources
- How to forecast future spending

### Step-by-Step Tasks

**Step 1: Analyze Costs by Cost Center**

1. Go to **Cost Management + Billing** > **Cost Analysis**

2. Configure view:
```
Group by: Tag (CostCenter)
Time range: Last 30 days
View: Pie chart or bar chart
```

3. Expected results:
```
Cost Breakdown by Department:
├─ Engineering: $28,000 (60%)
├─ Finance: $15,000 (32%)
├─ Operations: $4,000 (8%)
└─ Total: $47,000

This tells you:
├─ Engineering spends most (expected - many microservices)
├─ Finance next (critical databases)
├─ Operations least (shared infrastructure)
```

**Step 2: Analyze Costs by Environment**

```
Group by: Tag (Environment)
Time range: Last 30 days

Expected results:
├─ Production: $38,000 (81%)
├─ Staging: $6,000 (13%)
├─ Development: $3,000 (6%)
└─ Total: $47,000

This tells you:
├─ Prod costs ~6-7x more than Dev (normal)
├─ Staging costs are reasonable
├─ Dev costs seem high - investigate unused resources?
```

**Step 3: Analyze Costs by Resource Type**

```
Group by: Resource type
Time range: Last 30 days

Expected results:
├─ Virtual Machines: $20,000 (43%)
├─ SQL Databases: $12,000 (26%)
├─ Storage: $8,000 (17%)
├─ Bandwidth: $5,000 (11%)
├─ Other: $2,000 (3%)
└─ Total: $47,000

This tells you:
├─ VMs are biggest cost (scale-down opportunities?)
├─ Databases next (query optimization?)
├─ Storage acceptable
├─ Bandwidth could be reduced with CDN
```

**Step 4: Identify Expensive Resources**

1. Go to **Cost Management** > **Actual costs** > **Resources**
2. Sort by cost (highest first)
3. Look for:
   - Idle resources (Dev VMs running 24/7?)
   - Oversized resources (do we really need Premium VMs?)
   - Untagged resources (why weren't they tagged?)

Example findings:
```
Top 10 Most Expensive Resources:
1. sql-prod-main DB: $6,500/month
   └─ Tagged: ✓ Needed: ✓ Status: OK

2. vm-prod-api-1 (Premium_D64): $3,200/month
   └─ Tagged: ✓ But: Why Premium? Could use Standard_D4?
   └─ Potential saving: $1,000/month (if downsize)

3. storage-prod-backups: $2,800/month
   └─ Tagged: ✓ Status: Correct (GRS for disaster recovery)

4. vm-dev-testing-01: $1,500/month
   └─ Tagged: ✗ (UNTAGGED - violation!)
   └─ Owner: Unknown
   └─ Action: Tag and investigate if still needed

5. appService-prod-api: $1,200/month
   └─ Tagged: ✓ Needed: ✓ Status: OK
```

**Step 5: Forecast Future Spending**

1. Go to **Cost Management** > **Forecast**
2. View 12-month projection

Expected:
```
12-Month Cost Forecast:
├─ Current (Jun): $47K
├─ Projected (Jul-Dec): ~$50K/month (5% growth)
├─ Projected (Next year): ~$52K/month
└─ Annual cost: ~$600K

This tells you:
├─ Costs are growing at ~5%/month
├─ Without action, will hit $60K+/month in 1 year
├─ Need to optimize or budget will be exceeded
├─ Identify cost-saving opportunities NOW
```

**Step 6: Create Cost Analysis Report**

```
MONTHLY COST ANALYSIS REPORT
════════════════════════════════════════════════════════════

PERIOD: Last 30 days
TOTAL SPEND: $47,000

BY DEPARTMENT:
├─ Engineering: $28,000 (60%)
├─ Finance: $15,000 (32%)
└─ Operations: $4,000 (8%)

BY ENVIRONMENT:
├─ Production: $38,000 (81%)
├─ Staging: $6,000 (13%)
└─ Development: $3,000 (6%)

BY RESOURCE TYPE:
├─ Virtual Machines: $20,000 (43%)
├─ SQL Databases: $12,000 (26%)
├─ Storage: $8,000 (17%)
└─ Other: $7,000 (15%)

TOP COST DRIVERS:
1. sql-prod-main: $6,500 ✓ Justified
2. vm-prod-api-1: $3,200 ⚠ Review sizing
3. storage-backups: $2,800 ✓ Justified
4. vm-dev-testing: $1,500 ⚠ Untagged, investigate
5. appService-api: $1,200 ✓ Justified

COST ANOMALIES:
└─ vm-dev-testing-01: Untagged VM costing $1,500/month
   └─ Owner: Unknown
   └─ Action: Tag or shutdown if not needed
   └─ Potential saving: $1,500/month if deleted

FORECAST:
├─ Current trend: +5%/month growth
├─ 12-month projection: $600K+ annually
└─ Recommendation: Implement cost optimization initiatives

BUDGET STATUS:
├─ Total budget: $51,000
├─ Actual: $47,000
├─ Remaining: $4,000 (8% buffer)
└─ Status: On track (but tight)
```

### Validation Checklist

- [ ] Analyzed costs by CostCenter tag
- [ ] Analyzed costs by Environment tag
- [ ] Analyzed costs by resource type
- [ ] Identified top 5 most expensive resources
- [ ] Identified anomalies (untagged, idle resources)
- [ ] Generated cost forecast for 12 months
- [ ] Created cost analysis report

### Success Criteria

✅ Complete: Full cost visibility by department  
✅ Anomalies identified  
✅ Forecast generated  
✅ Cost optimization opportunities found  

---

## Part 5 – Prevent Expensive Mistakes with Policies

### The Challenge

Besides budgets, use policies to make cost-smart defaults.

### What You'll Learn

- How policies prevent expensive mistakes
- How to enforce cost optimization
- How to give developers guardrails

### Step-by-Step Tasks

**Step 1: Limit VM Sizes to Cost-Optimized Options**

Create a policy that only allows certain VM types:

```
Policy Name: Approved-VM-Sizes-Only
Description: Only allow Standard_B and Standard_D series (cost optimization)
Effect: Deny

Allowed VM Types:
├─ Standard_B1s, Standard_B2s, Standard_B4ms (burstable, cheap)
├─ Standard_D2s_v3, Standard_D4s_v3, Standard_D8s_v3 (balanced)
└─ Standard_E2s_v3 (for databases needing memory)

Denied VM Types:
├─ Premium_D64s_v3 (too expensive)
├─ Premium_E64s_v3 (extremely expensive)
├─ Any AMD-based SKUs (test the need first)
└─ Isolated sizes (reserved for special cases)

Result:
├─ Developer tries to create Premium VM
├─ Policy blocks: "Not in approved list"
├─ Developer must request exception (creates approval process)
└─ Forces cost-conscious decisions
```

**Step 2: Limit Storage Redundancy**

```
Policy Name: Limit-Storage-Redundancy-LRS
Description: Default to LRS, require justification for GRS
Effect: Deny

Rules:
├─ LRS: Always allowed (1 datacenter, cheapest)
├─ ZRS: Allowed in Staging/Prod (3 zones, moderate cost)
├─ GRS: Deny by default (must request exception)
├─ RA-GRS: Deny (very expensive, rare need)

Result:
├─ Default to cheapest option (LRS)
├─ Force business justification for expensive options
├─ No accidental GRS creation
└─ Potential savings: $500/month/storage account
```

**Step 3: Enforce Resource Deletion Timeouts for Temporary Resources**

```
Policy Name: Auto-Shutdown-Temporary-Resources
Description: Resources tagged LifeCycle=Temporary shutdown after 30 days
Effect: Audit + Modify

Result:
├─ Tag resource: LifeCycle = Temporary
├─ Policy tracks creation date
├─ After 30 days: Automatically deallocates/stops
├─ Prevents forgotten test resources
└─ Typical savings: $2-5K/month (forgotten test VMs)
```

**Step 4: Test Cost-Prevention Policies**

Attempt to create an expensive resource (should be denied):

1. Try to create Premium_D64s_v3 VM:
   ```
   Action: Attempt VM creation
   VM Type: Premium_D64s_v3
   Expected: Policy blocks
   Message: "VM type not in approved list"
   Result: PASS ✓
   ```

2. Try to create GRS storage:
   ```
   Action: Attempt storage account
   Redundancy: GRS (Geo-Redundant)
   Expected: Policy blocks
   Message: "Storage redundancy not approved"
   Result: PASS ✓
   ```

3. Create compliant resource (should succeed):
   ```
   Action: Create Standard_D4s_v3 VM with all tags
   Expected: Success ✓
   Message: "VM created successfully"
   Result: PASS ✓
   ```

**Step 5: Document Cost Prevention**

```
COST-PREVENTION POLICY SUMMARY
════════════════════════════════════════════════════════════

POLICIES IMPLEMENTED:

1. Approved VM Sizes
   ├─ Enforces: Only Standard_B/D series
   ├─ Prevents: Premium/expensive SKUs
   ├─ Potential savings: $100-1,000/month per violation

2. Storage Redundancy
   ├─ Enforces: LRS default, GRS requires exception
   ├─ Prevents: Accidental expensive replication
   ├─ Potential savings: $500/month per account

3. Temporary Resource Shutdown
   ├─ Enforces: Auto-shutdown after 30 days
   ├─ Prevents: Forgotten test resources
   ├─ Potential savings: $2,000-5,000/month

MONTHLY IMPACT:
├─ VM cost reduction: ~$500/month
├─ Storage cost reduction: ~$1,000/month
├─ Shutdown forgotten resources: ~$2,000/month
└─ Total potential savings: ~$3,500/month

ANNUAL IMPACT:
└─ Annual savings: ~$42,000/year
```

### Validation Checklist

- [ ] Created VM size approval policy
- [ ] Created storage redundancy policy
- [ ] Created temporary resource shutdown policy
- [ ] Tested VM policy (expensive VM denied)
- [ ] Tested storage policy (GRS denied)
- [ ] Tested compliant creation (success)
- [ ] Documented all policies and savings

### Success Criteria

✅ Complete: Cost-prevention policies enforced  
✅ Expensive mistakes prevented automatically  
✅ Developers have cost-smart guardrails  
✅ Annual savings estimated  

---

## Final Assessment: Cost Management Checklist

After completing all 5 parts, verify everything is in place:

```
COST MANAGEMENT & CHARGEBACK FINAL CHECKLIST
════════════════════════════════════════════════════════════

TAGGING STRATEGY
├─ [ ] 5 required tags defined (CostCenter, Environment, Owner, Project, LifeCycle)
├─ [ ] Tagging standard documented
├─ [ ] All existing resources tagged (100%)
└─ [ ] Tagging status: ✓ COMPLETE

POLICY ENFORCEMENT
├─ [ ] 3 tag-requirement policies created and assigned
├─ [ ] 2 cost-prevention policies created (VM sizes, storage)
├─ [ ] Temporary resource shutdown policy created
├─ [ ] All policies tested and working
└─ [ ] Policy status: ✓ COMPLETE

BUDGETS & ALERTS
├─ [ ] Engineering budget: $30,000/month with 3 alerts
├─ [ ] Finance budget: $16,000/month with 3 alerts
├─ [ ] Operations budget: $5,000/month with 3 alerts
├─ [ ] Organization budget: $51,000/month with 4 alerts
├─ [ ] Anomaly detection enabled
└─ [ ] Budget status: ✓ COMPLETE

COST ANALYSIS
├─ [ ] Analyzed costs by department (CostCenter tag)
├─ [ ] Analyzed costs by environment
├─ [ ] Analyzed costs by resource type
├─ [ ] Identified top expensive resources
├─ [ ] Identified anomalies and optimization opportunities
├─ [ ] Generated 12-month forecast
└─ [ ] Analysis status: ✓ COMPLETE

DOCUMENTATION
├─ [ ] Tagging standard documented
├─ [ ] Budget configuration summarized
├─ [ ] Cost analysis report created
├─ [ ] Policy summary with savings calculated
└─ [ ] Documentation status: ✓ COMPLETE

COST MANAGEMENT MATURITY:
├─ Month 1: No visibility ($47K, no tracking)
└─ Post-Lab: Full visibility, budgets, policies ($42K+ annual savings)

OVERALL COMPLETION: ___ 100% ___ Partial (identify gaps)
```

---

## Key Takeaways

✅ **Tags enable cost allocation** - CostCenter tags let you charge back costs to departments  
✅ **Policies enforce standards** - Cost-prevention policies prevent expensive mistakes  
✅ **Budgets create accountability** - Teams own their budgets and manage to them  
✅ **Visibility prevents surprises** - Monthly cost analysis prevents "sticker shock"  
✅ **Forecasting enables planning** - Know future costs so you can prepare  
✅ **Automation saves money** - Temporary resource shutdown prevents waste  

---

## Real-World Application

You've now implemented cost management patterns used by:
- **Google, Amazon, Microsoft**: Tag-based cost allocation
- **FinOps teams everywhere**: Budget-driven cost control
- **Enterprise cloud centers**: Department chargeback
- **Fast-growing startups**: Cost discipline from day 1

---

## Next Steps

1. **Monitor budgets** - Review actual spending vs. budget weekly
2. **Act on anomalies** - Investigate unexpected cost spikes
3. **Optimize continuously** - Look for resources to downsize/shutdown
4. **Review quarterly** - Full cost analysis with leadership
5. **Adjust forecasts** - Use actual data to refine spending projections
6. **Share findings** - Help teams understand their costs

