# Private Endpoints & Service Endpoints: Secure PaaS Access

## Opening Hook

**Why this matters:** You've locked down your VNets with NSGs and routing. But what about Azure services like Azure Storage or SQL Database? By default, they have public endpoints accessible from anywhere. Private Endpoints and Service Endpoints let you access Azure services securely from your VNet without exposing them to the internet.

---

## Before You Start

- **Prerequisites:** [VNets & Subnets](01-vnets-and-subnets.md), [Network Security Groups](02-network-security-groups.md)
- **Time to understand:** 15 minutes
- **Difficulty:** 🟡 **Intermediate** (builds on VNets and NSGs)
- **What you'll learn:** Private Endpoints vs. Service Endpoints, when to use each, how they work

---

## The Simple Idea

### The Problem

**By default, Azure PaaS services are public:**

```
Your VNet (10.0.0.0/16)
└── VM-A (10.0.1.5) wants to use Azure SQL Database
    └─ Default: SQL has public endpoint (database.database.windows.net)
    └─ Traffic: 10.0.1.5 → Internet → SQL public endpoint ✗
       └─ Traffic visible on internet (bad for security)
       └─ Potential for man-in-the-middle attacks

Goal: Access SQL from VM without exposing it to internet
```

### Two Solutions

| Solution | How | Security | Cost |
|----------|-----|----------|------|
| **Service Endpoint** | Direct route to service (remains public) | Good (routes through Azure backbone) | Free |
| **Private Endpoint** | Private IP in your VNet | Excellent (no internet exposure) | Paid (~$1/month) |

---

## Solution 1: Service Endpoints

### What Is a Service Endpoint?

**Service Endpoint** = Direct route from your VNet to an Azure service, using Azure's internal backbone (not the internet).

### Real-World Analogy: Private Warehouse Door

```
Azure SQL Database (Public building with multiple doors)

├── Main entrance (public endpoint)
│   └─ Anyone from internet can reach
│   └─ Insecure ✗
│
└── Special warehouse door (service endpoint)
   └─ Only accessible from authorized VNets
   └─ Direct route through Azure internal network
   └─ More secure ✓
```

### How Service Endpoints Work

```
Step 1: Create Service Endpoint in Subnet
  Subnet → Service Endpoints → Select "Microsoft.Storage"
  └─ Azure configures automatic route

Step 2: System Route Created
  Subnet's routing table now has:
  Destination: Storage endpoint
  Next Hop: Service Endpoint (Microsoft backbone)

Step 3: Traffic Flows Securely
  VM-A (10.0.1.5) → Storage service
  └─ Routing: Service Endpoint route selected
  └─ Path: Direct through Azure backbone (not internet)
  └─ Still travels through public internet for other traffic
```

### Service Endpoint Configuration

```
Step 1: Enable Service Endpoint in VNet/Subnet
  Azure Portal → VNet → Subnet → Service endpoints
  └─ Select: Microsoft.Storage, Microsoft.Sql, etc.

Step 2: Add Firewall Rule to Storage
  Storage Account → Firewall & Virtual Networks
  └─ Add VNet and subnet
  └─ Result: Only traffic from this VNet allowed

Step 3: Test
  VM in subnet → Storage account (now works securely) ✓
```

### Service Endpoint Limitations

```
Service Endpoint:
├─ ✓ Free (no extra cost)
├─ ✓ Quick to set up (minutes)
├─ ✗ Service still has public endpoint (accessible from internet if allowed)
├─ ✗ Only works with some Azure services
│  ├─ Supported: Storage, SQL Database, Cosmos DB, Key Vault, App Service
│  └─ Not supported: Some older services
└─ ✗ No private IP (routes to service's public IP, but via Azure backbone)
```

---

## Solution 2: Private Endpoints

### What Is a Private Endpoint?

**Private Endpoint** = A private IP address in your VNet that connects to an Azure service (service gets a private IP from your VNet's address space).

### Real-World Analogy: Private Branch Location

```
Azure SQL Database (Headquarters)

├── Main office (public endpoint)
│   └─ Anyone can visit
│   └─ Insecure ✗
│
└── Private branch office inside your building (private endpoint)
   └─ Only your employees can visit (same building)
   └─ No one from outside can reach it
   └─ Maximum security ✓
```

### How Private Endpoints Work

```
Step 1: Create Private Endpoint
  Subnet → Private Endpoints → Add
  └─ Resource: Azure SQL Database
  └─ VNet/Subnet: Which subnet gets the private IP?

Step 2: Private IP Created
  Subnet's address space: 10.0.2.0/24
  └─ Azure assigns private IP from this range
  └─ Example: 10.0.2.10 becomes the SQL Database endpoint
  └─ This IP is NOT publicly accessible

Step 3: Private DNS Zone
  Azure creates private DNS record:
  └─ database.database.windows.net → 10.0.2.10 (private IP)
  └─ VM in VNet resolves this automatically
  └─ VM connects to 10.0.2.10 (private connection)

Step 4: Traffic Flows Privately
  VM-A (10.0.1.5) → Private endpoint (10.0.2.10)
  └─ Routing: Matches local VNet route
  └─ Path: Internal VNet connection (never leaves your network) ✓
```

### Private Endpoint Configuration

```
Step 1: Create Private Endpoint
  Resource Group → Private Endpoints → Create
  ├─ Resource: Azure SQL Database
  ├─ VNet: Your-VNet
  ├─ Subnet: Your subnet (private IP will come from here)
  └─ DNS: Auto-register in private DNS zone ✓

Step 2: Firewall Configuration
  Storage Account → Firewall & Virtual Networks
  ├─ Default action: Deny (block all public access)
  └─ Private Endpoints: Auto-allowed (doesn't need rule)

Step 3: Test
  VM in VNet → Can reach storage via private endpoint
  Internet → Cannot reach storage (completely private) ✓
```

---

## Comparison: Service Endpoint vs. Private Endpoint

| Aspect | Service Endpoint | Private Endpoint |
|--------|------------------|------------------|
| **Private IP in VNet** | ❌ No (routes to service's public IP) | ✅ Yes (service gets IP from your subnet) |
| **Accessible from internet** | ⚠️ Yes (if firewall allows) | ❌ No (completely private) |
| **Cost** | Free | ~$1/month per endpoint |
| **Setup time** | Fast (minutes) | Moderate (10-15 min) |
| **Supported services** | Limited set | Broader support |
| **DNS** | Public DNS (service.region.azure.com) | Private DNS zone |
| **Bandwidth cost** | No extra charge | No extra charge |
| **Best for** | Quick, low-risk internal access | Production, high-security |

### Decision Tree

```
Need to access Azure PaaS service securely?
│
├─ VPN/ExpressRoute connected?
│  │
│  ├─ NO → Use Service Endpoint (simplest, free)
│  │   └─ "Secure enough" for most non-critical workloads
│  │
│  └─ YES → Can you route to service's IP via VPN?
│      ├─ NO (service doesn't support routing) → Service Endpoint
│      └─ YES → Choose:
│         ├─ Quick/Free: Service Endpoint ✓
│         ├─ Secure: Private Endpoint ✓
│         └─ Both: Set up Private Endpoint for production
│
└─ Need maximum security?
   └─ YES → Use Private Endpoint ✓
       └─ Service completely hidden from internet
```

---

## Worked Example: Real Scenario

### The Scenario

**TechCorp has:**
- Azure VNet: 10.0.0.0/16
- Dev Subnet: 10.0.1.0/24 (development VMs)
- Production Subnet: 10.0.2.0/24 (production VMs)
- Azure Storage Account for application data
- Azure SQL Database for app data

**Goal:** Access both securely from VMs without exposing to internet.

### Phase 1: Service Endpoints for Development

```
Dev environment (not critical):
  ├─ Create Service Endpoints on Dev Subnet
  │  ├─ Microsoft.Storage
  │  ├─ Microsoft.Sql
  │  └─ Configuration time: 5 minutes
  │
  ├─ Storage Account Firewall
  │  └─ Add Dev VNet/Subnet as allowed
  │
  ├─ SQL Database Firewall
  │  └─ Add Dev VNet/Subnet as allowed
  │
  └─ Result:
     ├─ Dev VMs can access Storage and SQL
     ├─ Traffic routes through Azure backbone
     ├─ Cost: $0 (free)
     └─ Security: Good (internal routing) ✓
```

### Phase 2: Private Endpoints for Production

```
Production environment (critical):
  ├─ Create Private Endpoint 1 (Storage)
  │  ├─ Resource: Storage Account
  │  ├─ VNet: Your-VNet
  │  ├─ Subnet: Prod Subnet (10.0.2.0/24)
  │  ├─ Private DNS zone: Auto-created
  │  └─ Result: Storage has private IP in subnet
  │
  ├─ Create Private Endpoint 2 (SQL)
  │  ├─ Resource: SQL Database
  │  ├─ VNet: Your-VNet
  │  ├─ Subnet: Prod Subnet (10.0.2.0/24)
  │  ├─ Private DNS zone: Auto-created
  │  └─ Result: SQL has private IP in subnet
  │
  ├─ Firewall Configuration
  │  ├─ Storage: Default deny (public), private endpoint allowed
  │  ├─ SQL: Default deny (public), private endpoint allowed
  │  └─ Result: No internet access possible
  │
  └─ Result:
     ├─ Prod VMs can access Storage and SQL via private IPs
     ├─ Traffic never leaves VNet (maximum security) ✓
     ├─ Internet cannot reach these services
     ├─ Cost: ~$2/month for 2 endpoints
     └─ Security: Excellent (completely private) ✓
```

### Step 3: Traffic Isolation

```
DNS Resolution:
├─ Dev VM DNS: storage.azure.com → 40.88.100.5 (public)
│  └─ Resolution: Public IP (resolves through internet DNS)
│
└─ Prod VM DNS: storage.azure.com → 10.0.2.10 (private)
   └─ Resolution: Private IP (resolves through private DNS zone)

Traffic paths:
├─ Dev VM → Storage: 10.0.1.5 → 40.88.100.5 (internet path)
│  ├─ Service Endpoint: Route directly through Azure backbone
│  └─ Firewall allows only from VNet
│
└─ Prod VM → Storage: 10.0.2.5 → 10.0.2.10 (VNet path)
   ├─ Private Endpoint: Routes locally within VNet
   └─ Never reaches internet ✓
```

---

## Common Mistakes (What NOT to Do)

### ❌ Mistake 1: Relying on Service Endpoint Alone for Sensitive Data

**Wrong:**
```
Service Endpoint created for SQL Database:
├─ Routes through Azure backbone ✓
├─ But SQL is still publicly accessible
├─ Competitor discovers public IP address
├─ Competitor uses their own VNet with Service Endpoint
├─ Competitor can access the database ✗
```

**Why it fails:** Service Endpoint doesn't hide the public endpoint.

**Fix:**
```
For sensitive data:
├─ Use Private Endpoint instead
├─ Disable public endpoint completely
├─ Result: Only your VNet can access it ✓
```

---

### ❌ Mistake 2: Private Endpoint Without Proper DNS

**Wrong:**
```
Private Endpoint created for SQL (10.0.2.10):
├─ Application code: "Connect to database.database.windows.net"
├─ DNS resolution: Resolves to 40.88.100.5 (public IP)
├─ Firewall: Allows only private endpoint
├─ Result: Connection fails ✗
```

**Why it fails:** DNS resolves to public IP, but firewall blocks it.

**Fix:**
```
Create private DNS zone:
├─ database.database.windows.net → 10.0.2.10
├─ VNet linked to private DNS zone
├─ Now: DNS resolves to 10.0.2.10 (private IP)
├─ Connection uses private endpoint ✓
```

---

### ❌ Mistake 3: Creating Private Endpoint in Wrong Subnet

**Wrong:**
```
Prod Subnet: 10.0.2.0/24 (prod workloads)
Dev Subnet: 10.0.1.0/24 (dev workloads)

Create Private Endpoint in Subnet 10.0.1.0/24:
├─ Prod workloads in 10.0.2.0/24 try to access database
├─ DNS: Resolves to private endpoint IP (10.0.1.10)
├─ Routing: 10.0.2.5 → 10.0.1.10 (different subnet)
├─ Works but not optimal ⚠️
└─ Better: Private endpoint in same subnet as clients
```

**Why it fails:** Not a complete failure, but adds latency and complexity.

**Fix:**
```
Create Private Endpoint in prod subnet:
├─ Private Endpoint IP: 10.0.2.10 (same subnet as clients)
├─ Prod workload (10.0.2.5) → 10.0.2.10 (local)
└─ Lower latency, cleaner routing ✓
```

---

## Service Endpoint vs. Private Endpoint Checklist

```
Choosing between them:

□ For development/non-critical:
  ├─ Service Endpoint usually sufficient
  ├─ Lower cost (free)
  ├─ Quick to set up
  └─ Good balance of security and simplicity

□ For production/sensitive data:
  ├─ Use Private Endpoint
  ├─ Highest security (private IP)
  ├─ Public endpoint can be completely disabled
  └─ Worth the small monthly cost

□ Hybrid approach:
  ├─ Service Endpoints: External/non-critical services
  ├─ Private Endpoints: Internal/sensitive services
  └─ Both: Some organizations use both for defense-in-depth

□ If using Private Endpoint:
  ├─ Create private DNS zone (auto-done)
  ├─ Link DNS zone to VNet
  ├─ Disable public endpoint on storage
  └─ Test: Confirm private endpoint works, public fails ✓

□ If using Service Endpoint:
  ├─ Enable on subnet(s) where workloads exist
  ├─ Add VNet/subnet to storage firewall
  ├─ Storage still has public endpoint
  └─ Consider: Is this sufficient for security requirements? ✓
```

---

## How This Connects to Other Topics

### Related to Module 01 (Identity & Governance)
- **RBAC:** Only admins can create/manage Private Endpoints

### Related to Module 02 (Storage)
- **Storage Security:** Private Endpoints secure storage access
- **Storage Firewall:** Works with both Service and Private Endpoints

### Related to Module 03 (Compute)
- **VM Access to Services:** VMs use Private/Service Endpoints to reach PaaS

### Related to Module 05 (Monitor)
- **Monitor Endpoint:** Track Private Endpoint connections

---

## See It In Action

**Associated labs:**
- [Lab 17: Configure Service Endpoints](../labs/lab17-service-endpoints.md)
- [Lab 18: Configure Private Endpoints](../labs/lab18-private-endpoints.md)

**Suggested learning sequence:**
1. ✅ Read [VNets & Subnets](01-vnets-and-subnets.md)
2. ✅ Read [Network Security Groups](02-network-security-groups.md)
3. ✅ Read [VPN & ExpressRoute](05-vpn-and-expressroute.md)
4. ✅ Read this doc (Private Endpoints & Service Endpoints)
5. ✅ Work through Lab 17 (Service Endpoints hands-on)
6. ✅ Work through Lab 18 (Private Endpoints hands-on)

---

## Key Takeaways

- **Service Endpoint = free route to service** (good, not perfect)
- **Private Endpoint = private IP in your VNet** (best security)
- **Service Endpoint:** Suitable for non-critical, internal-only traffic
- **Private Endpoint:** For sensitive data, production workloads
- **Private DNS zone:** Required for Private Endpoints to work seamlessly
- **Firewall integration:** Both work with storage/service firewalls
- **Public endpoint:** Can be disabled entirely with Private Endpoints
- **Cost:** Service Endpoint free, Private Endpoint ~$1/month

---

## Next Steps

1. **Learn:** Read this doc (you're here)
2. **Understand:** When to use each (decision tree above)
3. **Practice:** [Lab 17: Service Endpoints](../labs/lab17-service-endpoints.md)
4. **Practice:** [Lab 18: Private Endpoints](../labs/lab18-private-endpoints.md)
5. **Secure:** Disable public endpoints for sensitive services
6. **Monitor:** Track endpoint usage and security
