# Virtual Networks & Subnets: Building Your Private Network

## Opening Hook

**Why this matters:** Before you can deploy any Azure resource (VM, database, app service), it needs a network to live in. Virtual Networks are like creating your own private network inside Azure—like a gated community where only authorized traffic can enter. Understanding VNets and subnets is foundational to everything else in Azure networking.

---

## Before You Start

- **Prerequisites:** [00-Prerequisites: Networking Basics](../../../00-prerequisites/concepts/02-networking-basics.md) (CIDR, IP addresses, subnets)
- **Time to understand:** 15 minutes
- **Difficulty:** 🟢 **Beginner** (foundational, no prior network knowledge needed)
- **What you'll learn:** What VNets are, how to create subnets, why they matter

---

## The Simple Idea

### What Is a Virtual Network (VNet)?

A **VNet** is your own **private network inside Azure**. It's a walled-off space where your resources live, talk to each other, and stay isolated from the internet (unless you explicitly allow internet access).

### Real-World Analogy: Your Office Network

**Without a VNet (insecure):**
```
Your computers sitting on public internet
↓
Anyone can see them and try to connect
↓
No privacy, high risk
```

**With a VNet (secure):**
```
Your office building (VNet)
├── Reception area (public IP - can access internet)
├── Employee cubicles (private IPs - internal only)
├── Server room (no public IP - completely isolated)
└── Conference room (VPN access only - external partners)

Locked doors (Network Security Groups) control who goes where
```

### What Is a Subnet?

A **subnet** is a **smaller network inside a VNet**. You divide your VNet into subnets to organize resources and apply security rules.

**Example VNet structure:**
```
VNet: 10.0.0.0/16 (my company network)
├── Subnet 1: 10.0.1.0/24 (Web tier - public)
├── Subnet 2: 10.0.2.0/24 (App tier - private)
└── Subnet 3: 10.0.3.0/24 (Database tier - completely private)
```

Each subnet has different security rules (Network Security Groups).

---

## How It Actually Works

### Step 1: Create a VNet

You define an address space (like your company's IP range):

```
VNet Name: my-company-network
Address Space: 10.0.0.0/16
(This gives you 65,536 possible IP addresses)
```

### Step 2: Divide Into Subnets

You create smaller subnets within the VNet:

```
Subnet 1 (Web): 10.0.1.0/24 (256 addresses)
Subnet 2 (App): 10.0.2.0/24 (256 addresses)
Subnet 3 (DB):  10.0.3.0/24 (256 addresses)
```

### Step 3: Deploy Resources Into Subnets

```
Subnet 1 (Web): VM with public IP (accessible from internet)
Subnet 2 (App): VM with private IP (internal only)
Subnet 3 (DB):  SQL Database (no public IP)
```

### Step 4: Apply Security Rules (NSGs)

```
Subnet 1: "Allow port 80 from internet"
Subnet 2: "Allow port 5000 from Subnet 1 only"
Subnet 3: "Allow port 1433 from Subnet 2 only"
```

**Result:** Traffic flows securely through your network tiers.

---

## Key Components: Understanding VNet Structure

| Component | What It Is | Example | Why It Matters |
|-----------|-----------|---------|---|
| **VNet** | Your private network | 10.0.0.0/16 | Creates isolated space for resources |
| **Address Space** | Range of IP addresses | 10.0.0.0/16 (65k IPs) | Defines what IPs you can assign |
| **Subnet** | Smaller network within VNet | 10.0.1.0/24 (256 IPs) | Organize resources by tier/function |
| **Public IP** | Internet-accessible address | 52.123.45.67 | Allows VM to receive traffic from internet |
| **Private IP** | Internal-only address | 10.0.2.5 | Resources talk to each other internally |
| **Network Security Group (NSG)** | Firewall rules | "Allow port 80 inbound" | Controls traffic in/out of subnet |

---

## Mental Model: VNet as a Building

Think of your VNet like a **building with security**:

```
                    ┌─────────────────────────────┐
                    │   Azure VNet (10.0.0.0/16) │ (Your private building)
                    │     (65,536 IP addresses)  │
                    │                             │
    ┌───────────────┼─────────────┬───────────────┼──────────────────┐
    │               │             │               │                  │
┌─────────────┐  ┌────────────┐ ┌────────────┐ ┌────────────┐
│   Subnet 1  │  │  Subnet 2  │ │  Subnet 3  │ │ Subnet 4   │
│   Web Tier  │  │  App Tier  │ │  DB Tier   │ │ Backup     │
│             │  │            │ │            │ │            │
│10.0.1.0/24 │  │10.0.2.0/24 │ │10.0.3.0/24 │ │10.0.4.0/24 │
│             │  │            │ │            │ │            │
│ VM1 (public)│  │ VM2        │ │  SQL DB    │ │ Backup VM  │
│ IP: .5     │  │ (private)  │ │ (private)  │ │ (private)  │
│             │  │ IP: .10    │ │ IP: .10    │ │ IP: .20    │
└─────────────┘  └────────────┘ └────────────┘ └────────────┘
     ↑                                          
     │ Public IP: 52.123.45.67                 
     │ (accessible from internet)              
```

Each subnet has security rules (like locked doors):
- **Subnet 1 (Web):** Door open to internet (port 80)
- **Subnet 2 (App):** Door locked except from Subnet 1
- **Subnet 3 (DB):** Door locked except from Subnet 2
- **Subnet 4 (Backup):** Door locked—internal only

---

## Worked Example: Real Scenario

### The Scenario

**TechCorp is building a 3-tier web application:**
- **Web Tier:** User-facing web servers (needs internet access)
- **App Tier:** API servers (talks to web tier and database)
- **Database Tier:** SQL databases (talks to app tier only)

**Goal:** Deploy this securely with separate tiers, each with appropriate access.

### Step 1: Plan the VNet

```
VNet Address: 10.0.0.0/16

Web Subnet:  10.0.1.0/24   (256 IPs for web servers)
App Subnet:  10.0.2.0/24   (256 IPs for app servers)
DB Subnet:   10.0.3.0/24   (256 IPs for databases)
```

### Step 2: Create Subnets & Deploy Resources

```
Web Subnet (10.0.1.0/24)
└── VM: WebServer1
    ├── Private IP: 10.0.1.5
    ├── Public IP: 52.123.45.67 ← Internet can reach here
    └── Purpose: Accept web traffic from internet

App Subnet (10.0.2.0/24)
└── VM: AppServer1
    ├── Private IP: 10.0.2.10
    ├── No public IP ← Internet CANNOT reach here
    └── Purpose: Talk to web tier and database only

DB Subnet (10.0.3.0/24)
└── Database: SQL Server
    ├── Private IP: 10.0.3.20
    ├── No public IP ← Internet CANNOT reach here
    └── Purpose: Accept queries from app tier only
```

### Step 3: Apply Security Rules (Network Security Groups)

```
┌──────────────────────────────────────────┐
│     Web Subnet Security Rules (NSG)      │
├──────────────────────────────────────────┤
│ ✓ ALLOW: Port 80 (HTTP) from internet    │
│ ✓ ALLOW: Port 443 (HTTPS) from internet  │
│ ✗ DENY: Everything else from internet    │
│ ✓ ALLOW: App tier to reach web tier      │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│     App Subnet Security Rules (NSG)      │
├──────────────────────────────────────────┤
│ ✓ ALLOW: Port 5000 from web tier         │
│ ✓ ALLOW: Database tier to reach app tier │
│ ✗ DENY: Internet access (no public IP)   │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│     DB Subnet Security Rules (NSG)       │
├──────────────────────────────────────────┤
│ ✓ ALLOW: Port 1433 (SQL) from app tier   │
│ ✗ DENY: Everything else                  │
│ ✗ DENY: Internet access (no public IP)   │
└──────────────────────────────────────────┘
```

### Step 4: Traffic Flow

**User requests web page:**
```
1. User on internet → WebServer1 (52.123.45.67)
   ✓ Allowed (public IP, port 80 open)

2. WebServer1 → AppServer1 (10.0.2.10)
   ✓ Allowed (internal subnet communication)

3. AppServer1 → SQL Server (10.0.3.20)
   ✓ Allowed (port 1433 from app tier)

4. SQL Server → Internet
   ✗ Blocked (no public IP, NSG denies)
```

**Security achieved:** Database is unreachable from internet, even if someone compromises the web server.

---

## Important Concept: Azure Reserved IPs

⚠️ **Important:** Azure reserves 5 IPs in every subnet:

| IP | Purpose |
|----|---------|
| .0 | Network address (reserved) |
| .1 | Default gateway (reserved) |
| .2 | Azure DNS (reserved) |
| .3 | Azure future use (reserved) |
| .255 | Broadcast address (reserved) |

**Example for subnet 10.0.1.0/24 (256 IPs):**
```
Total IPs: 256
Reserved: 5 (listed above)
Usable: 256 - 5 = 251 IPs for your resources
```

**Formula:**
```
Usable IPs = Total IPs - 5
Total IPs = 2^(32 - subnet_mask)

Example: /24 subnet
Total = 2^(32-24) = 2^8 = 256
Usable = 256 - 5 = 251
```

---

## Common Mistakes (What NOT to Do)

### ❌ Mistake 1: Overlapping Address Spaces

**Wrong:**
```
VNet 1: 10.0.0.0/16
VNet 2: 10.0.0.0/16 (same range!)

If you peer these VNets:
↓
Network conflict—traffic routing fails
↓
Applications can't communicate
```

**Why it fails:** Azure can't route traffic to same IP range in two places.

**Fix:**
```
Plan address spaces before creating VNets:
VNet 1: 10.0.0.0/16
VNet 2: 10.1.0.0/16 (different range)
VNet 3: 10.2.0.0/16 (different range)

Document them:
├── Finance VNet: 10.0.0.0/16
├── Engineering VNet: 10.1.0.0/16
└── Operations VNet: 10.2.0.0/16
```

---

### ❌ Mistake 2: Subnet Too Large

**Wrong:**
```
VNet: 10.0.0.0/16
Single subnet: 10.0.0.0/16 (all 65k IPs in one subnet)

Result:
├── No tier separation
├── All resources see all traffic
├── Hard to apply targeted security
└── Scaling becomes difficult
```

**Why it fails:** Can't separate concerns (web vs. app vs. database).

**Fix:**
```
Divide into multiple smaller subnets:
VNet: 10.0.0.0/16
├── Web:  10.0.1.0/24 (256 IPs)
├── App:  10.0.2.0/24 (256 IPs)
├── DB:   10.0.3.0/24 (256 IPs)
└── Extra: 10.0.4.0-10.0.254.0/24 (for growth)
```

---

### ❌ Mistake 3: Forget About Reserved IPs

**Wrong:**
```
Subnet: 10.0.1.0/24
Admin thinks: "I have 256 IPs, let me assign 256 VMs"
↓
Creates VMs with IPs: 10.0.1.0, 10.0.1.1, ..., 10.0.1.255
↓
Fails: IPs .0, .1, .2, .3, .255 are reserved
↓
Only 251 VMs can be created, not 256
```

**Why it fails:** Reserved IPs aren't available for resources.

**Fix:**
```
Calculate usable IPs:
/24 subnet = 256 total - 5 reserved = 251 usable
/25 subnet = 128 total - 5 reserved = 123 usable
/26 subnet = 64 total - 5 reserved = 59 usable

Plan accordingly for expected scale.
```

---

## How This Connects to Other Topics

### Related to Module 01 (Identity & Governance)
- **RBAC + VNets:** Use RBAC to control who can create/modify VNets
- **Policy + VNets:** Enforce policies like "all VNets must have NSGs"

### Related to Module 02 (Storage)
- **Service Endpoints:** Connect storage accounts to VNet without public IP
- **Private Endpoints:** Access storage securely from VNet
- **Firewall rules:** Restrict storage access to specific VNets

### Related to Module 03 (Compute)
- **VM Deployment:** VMs must be in a subnet (the network they live in)
- **Load Balancers:** Distribute traffic to VMs across subnets

### Related to Module 05 (Monitor)
- **Network Watcher:** Monitor traffic between subnets
- **Flow Logs:** See which resources are communicating with each other

---

## See It In Action

**Associated lab:** [Lab 12: Create & Configure VNets](../labs/lab12-vnet-creation.md)

**Suggested learning sequence:**
1. ✅ Read this doc (VNets & Subnets - foundation)
2. ✅ Read [Network Security Groups](02-network-security-groups.md) (how to secure them)
3. ✅ Read [Routing Fundamentals](03-routing-fundamentals.md) (how traffic flows)
4. ✅ Work through Lab 12 (hands-on VNet creation)
5. ✅ Read [VNet Peering](04-vnet-peering.md) (connect multiple VNets)

---

## Key Takeaways

- **VNet = Your private network in Azure** (like an office network)
- **Subnet = Division within VNet** (like separate departments)
- **Each resource needs a VNet and subnet** (fundamental requirement)
- **Plan address spaces ahead** (avoid overlaps and conflicts)
- **Reserve 5 IPs per subnet** (don't count them in usable IPs)
- **Multiple subnets = better security** (separate tiers, different rules)
- **Public IP = Internet accessible** (VMs with public IPs can reach internet)
- **Private IP = Internal only** (VMs without public IPs stay private)

---

## Summary: VNet vs. Subnet vs. Resource Group

| Aspect | VNet | Subnet | Resource Group |
|--------|------|--------|-----------------|
| **Purpose** | Create private network | Organize within VNet | Organize any resources |
| **Contains** | Subnets, resources | Resources (VMs, etc.) | Any Azure resources |
| **Region** | Region-specific | Within VNet (same region) | Can span regions |
| **Required** | Yes (for networking) | Yes (to deploy resources) | Yes (to organize resources) |
| **IP space** | Address space you define | Divided from VNet | N/A (no IP concept) |

---

## Next Steps

1. **Learn:** Read this doc (you're here)
2. **Secure:** Read [Network Security Groups](02-network-security-groups.md) (how to add firewall rules)
3. **Understand:** Read [Routing Fundamentals](03-routing-fundamentals.md) (how traffic flows)
4. **Practice:** [Lab 12: Create & Configure VNets](../labs/lab12-vnet-creation.md)
5. **Connect:** Read [VNet Peering](04-vnet-peering.md) (connect multiple VNets)
