# VNet Peering: Connecting Networks Directly

## Opening Hook

**Why this matters:** So far you've created isolated VNets with internal routing. But what if you need to connect two separate VNets—maybe one for dev, one for prod? You could route through the internet (slow, insecure), or you could peer them directly (fast, private). VNet peering lets two VNets communicate as if they were one network, without going through a gateway.

---

## Before You Start

- **Prerequisites:** [VNets & Subnets](01-vnets-and-subnets.md), [Routing Fundamentals](03-routing-fundamentals.md)
- **Time to understand:** 15 minutes
- **Difficulty:** 🟡 **Intermediate** (builds on routing)
- **What you'll learn:** How peering works, regional vs. global, routing considerations, gateway transit

---

## The Simple Idea

### What Is VNet Peering?

**VNet Peering** = A direct, private connection between two Azure Virtual Networks that lets them communicate as if they're part of the same network.

### Real-World Analogy: Two Office Buildings Connected by a Bridge

```
Building A (VNet-A: 10.0.0.0/16)
│
├── Employees: 10.0.1.0/24
│   └── Internal phone system
│
└── Connection: Direct bridge to Building B
                (VNet Peering)

Building B (VNet-B: 172.16.0.0/16)
│
├── Employees: 172.16.1.0/24
│   └── Internal phone system
│
└── Connection: Direct bridge to Building A

Result: Employees in Building A can call Building B directly ✓
        No need for a gateway or external connection ✓
```

### Two Types of Peering

| Type | Distance | Bandwidth | Latency | Cost |
|------|----------|-----------|---------|------|
| **Regional Peering** | Same region (e.g., East US to East US) | Unlimited | Low | Charged but minimal |
| **Global Peering** | Different regions (e.g., East US to West Europe) | Unlimited | Medium | Charged, slightly more |

---

## How VNet Peering Works

### Step 1: Create Two VNets

```
VNet-A: 10.0.0.0/16
├── Subnet A1: 10.0.1.0/24
└── Subnet A2: 10.0.2.0/24

VNet-B: 172.16.0.0/16
├── Subnet B1: 172.16.1.0/24
└── Subnet B2: 172.16.2.0/24

Requirement: Address spaces must NOT overlap ✓
```

### Step 2: Create Peering Connection (Bidirectional)

```
In Azure Portal:
├─ Go to VNet-A
├─ Select "Peerings"
├─ Add Peering to VNet-B
├─ Wait for status: "Connected" ✓

Behind the scenes:
├─ Azure creates routes in both VNets
├─ Route to 172.16.0.0/16 → Peered Network (in VNet-A)
├─ Route to 10.0.0.0/16 → Peered Network (in VNet-B)
└─ Connection is bidirectional (both directions work automatically) ✓
```

### Step 3: Subnet Routing After Peering

```
VNet-A Subnet A1 (10.0.1.0/24) Routing Table:

Destination        Next Hop         Source
────────────────────────────────────────────
10.0.0.0/16        Local VNet-A     System Route
172.16.0.0/16      Peered VNet-B    System Route (AUTO!)
0.0.0.0/0          Internet         System Route

VM in Subnet A1 wants to reach 172.16.1.5:
  └─ Checks routing table
  └─ Matches: 172.16.0.0/16 → Peered Network
  └─ Sends traffic directly to peered VNet ✓
```

### Step 4: NSG Rules Apply

```
Traffic flows: 10.0.1.5 (VM-A) → 172.16.1.10 (VM-B)

Checks:
├─ Routing: Does 172.16.0.0/16 have a route? YES (peering) ✓
├─ NSG on Subnet A1: Allow outbound? YES (default) ✓
├─ NSG on Subnet B1: Allow inbound from 10.0.1.0/24? Must be YES
│  └─ If NO, connection fails even though peering exists ✗
└─ Result: Traffic delivered ✓

Lesson: Peering allows the route, NSGs still control traffic ✓
```

---

## Mental Model: Peering as a Tunnel

```
Before Peering:
VNet-A ═══════ Internet ═══════ VNet-B
        (slow, public, insecure)

After Peering:
VNet-A ════════════════════════════ VNet-B
        (direct, private, fast)

Inside: Automatic routes direct traffic through the tunnel ✓
Outside: No internet routing needed ✓
```

---

## Regional vs. Global Peering

### Regional Peering (Same Region)

**Scenario:** East US 1 VNet ↔ East US 2 VNet

```
Configuration:
├─ Peering Name: vnet-a-to-vnet-b
├─ Peering Type: Regional (same Azure region)
├─ Network access: Enabled
├─ Traffic forwarding: Can be enabled
├─ Virtual network gateway: Optional

Performance:
├─ Latency: <2ms (very fast) ✓
├─ Bandwidth: Unlimited ✓
└─ Cost: Charged per GB (ingress only) ✓

Use case: Dev/Staging/Prod in same region, need to share services
```

### Global Peering (Different Regions)

**Scenario:** East US VNet ↔ West Europe VNet

```
Configuration:
├─ Peering Name: vnet-a-to-vnet-b-global
├─ Peering Type: Global (different regions)
├─ Network access: Enabled
├─ Traffic forwarding: Can be enabled
├─ Virtual network gateway: Optional

Performance:
├─ Latency: ~100ms (depends on distance) ⚠
├─ Bandwidth: Unlimited ✓
└─ Cost: Charged per GB (ingress only) ✓

Use case: Multi-region deployment (US HQ + EU office), replicated services
```

---

## Worked Example: Real Scenario

### The Scenario

**TechCorp has:**
- Dev VNet in East US: 10.0.0.0/16
  - Dev App Server: 10.0.1.0/24
  - Dev Database: 10.0.2.0/24
- Prod VNet in East US: 172.16.0.0/16
  - Prod App Server: 172.16.1.0/24
  - Prod Database: 172.16.2.0/24

**Goal:** Let Dev and Prod communicate (e.g., backup dev data to prod storage).

### Step 1: Create Peering

```
Azure Portal → VNet-Dev → Peerings → Add
  Peering name: dev-to-prod
  VNet: VNet-Prod
  Wait for status: Connected ✓

Result:
├─ VNet-Dev has new route: 172.16.0.0/16 → Peered Network
├─ VNet-Prod has new route: 10.0.0.0/16 → Peered Network
└─ Both VNets can reach each other's subnets ✓
```

### Step 2: Verify NSG Rules

```
Dev App Server (10.0.1.10) tries to backup to Prod Storage (172.16.2.20):

NSG on Prod Subnet (172.16.2.0/24):
  Rule: Allow inbound from 10.0.1.0/24 (Dev App subnet)
  Port: 443 (HTTPS for backup)
  Action: ALLOW ✓

Traffic flow:
  Dev App → Routing: 172.16.0.0/16 matches peering → Forward ✓
          → NSG: Allow from 10.0.1.0/24 on 443 → Allow ✓
          → Reaches Prod Storage ✓
```

### Step 3: Bidirectional Traffic

```
Prod App Server (172.16.1.10) wants to query Dev Database (10.0.2.5):

NSG on Dev Subnet (10.0.2.0/24):
  Rule: Allow inbound from 172.16.1.0/24 (Prod App subnet)
  Port: 5432 (PostgreSQL)
  Action: ALLOW ✓

Traffic flow:
  Prod App → Routing: 10.0.0.0/16 matches peering → Forward ✓
           → NSG: Allow from 172.16.1.0/24 on 5432 → Allow ✓
           → Reaches Dev Database ✓

Key: Peering is bidirectional (both directions work automatically) ✓
```

---

## Gateway Transit (Advanced)

### What Is Gateway Transit?

**Gateway Transit** = Allow peered VNets to use one VNet's VPN/ExpressRoute gateway.

### Use Case: Hub-and-Spoke with Gateway

```
Hub VNet (10.0.0.0/16)
├── Has VPN Gateway
├── On-premises connection: 192.168.0.0/16
│
├─ Spoke A (10.1.0.0/16) — Peered
│  └── Needs on-premises access
│  └── Enable gateway transit ✓
│
└─ Spoke B (10.2.0.0/16) — Peered
   └── Needs on-premises access
   └── Enable gateway transit ✓

Result:
  Spoke A traffic to on-prem: Spoke A → Hub Gateway → VPN → On-prem ✓
  Spoke B traffic to on-prem: Spoke B → Hub Gateway → VPN → On-prem ✓
  No need for separate gateways in each spoke (cost savings) ✓
```

### Configuration

```
When creating peering:
├─ Source VNet (Hub): Enable "Allow gateway transit"
├─ Target VNet (Spoke): Enable "Use remote gateway"
└─ Result: Spoke can reach on-premises through Hub's gateway ✓

Cost benefit:
├─ One gateway for entire organization
├─ Spokes don't need their own gateways
└─ Saves money (gateways are expensive) ✓
```

---

## Common Mistakes (What NOT to Do)

### ❌ Mistake 1: Overlapping Address Spaces

**Wrong:**
```
VNet-A: 10.0.0.0/16
VNet-B: 10.0.0.0/16 (same address space!)

Try to create peering:
  └─ Azure rejects peering ✗
  └─ Error: "Address space overlaps"
```

**Why it fails:** Overlapping addresses cause routing confusion.

**Fix:**
```
Make address spaces non-overlapping:
├─ VNet-A: 10.0.0.0/16 ✓
├─ VNet-B: 172.16.0.0/16 ✓
└─ Peering works ✓
```

---

### ❌ Mistake 2: Forgetting NSG Rules

**Wrong:**
```
Peering created: VNet-A ↔ VNet-B
VM-A (10.0.1.5) tries to reach VM-B (172.16.1.10)

Routing works: 172.16.0.0/16 → Peered VNet ✓
NSG on VNet-B Subnet: All inbound DENIED ✗

Result: Traffic blocked even though peering exists ✗
```

**Why it fails:** Peering enables the route but doesn't override NSG rules.

**Fix:**
```
Add NSG rule on VNet-B:
  Source: 10.0.1.0/24 (VM-A's subnet)
  Port: 443 (whatever service needs)
  Action: ALLOW ✓

Now traffic flows ✓
```

---

### ❌ Mistake 3: Not Enabling Traffic Forwarding

**Wrong:**
```
Scenario: Three VNets, two connected via peering
  VNet-A ↔ VNet-B (peered)
  VNet-B ↔ VNet-C (peered)
  
VM in VNet-A tries to reach VNet-C:
  └─ Routing: Does 10.2.0.0/16 (VNet-C) exist in VNet-A? NO ✗
  └─ VNet-B should forward traffic, but routing not configured
  └─ Result: Connection fails ✗
```

**Why it fails:** Peering doesn't automatically forward between spokes.

**Fix:**
```
Use custom routing in VNet-A:
  Destination: 10.2.0.0/16 (VNet-C)
  Next Hop: VNet-B appliance IP
  └─ Requires VNet-B to enable "forwarded traffic" ✓

Or use a hub-and-spoke with gateway transit (cleaner) ✓
```

---

## Peering Checklist

```
□ VNets have non-overlapping address spaces
  └─ Check: Does 10.0.0.0/16 overlap with 172.16.0.0/16? NO ✓

□ Create peering from both sides (or wait for request)
  └─ VNet-A initiates → VNet-B accepts ✓
  └─ Connection status: Connected ✓

□ Check routing (automatic system routes created)
  └─ Can VNet-A reach 172.16.0.0/16? Route should exist ✓

□ Verify NSG rules allow traffic
  └─ NSG on peered VNet allows source/port ✓

□ Test connectivity
  └─ Ping, SSH, or RDP from VM-A to VM-B ✓

□ For gateway transit (if needed)
  └─ Hub VNet: "Allow gateway transit" enabled ✓
  └─ Spoke VNet: "Use remote gateway" enabled ✓
  └─ Routes configured to use hub gateway ✓
```

---

## How This Connects to Other Topics

### Related to Module 01 (Identity & Governance)
- **RBAC + Peering:** Only network admins can create/delete peering
- **Policy:** Require peering in hub-and-spoke topology

### Related to Module 02 (Storage)
- **Storage Access:** Use peering to reach storage in another VNet securely

### Related to Module 03 (Compute)
- **VM Communication:** VMs in peered VNets can communicate directly

### Related to Module 05 (Monitor)
- **Monitor Peering:** Check peering metrics (bytes in/out)

---

## See It In Action

**Associated labs:**
- [Lab 15: Configure VNet Peering](../labs/lab15-vnet-peering.md)

**Suggested learning sequence:**
1. ✅ Read [VNets & Subnets](01-vnets-and-subnets.md)
2. ✅ Read [Routing Fundamentals](03-routing-fundamentals.md)
3. ✅ Read this doc (VNet Peering)
4. ✅ Work through Lab 15 (hands-on peering setup)
5. ➡️ Read [VPN & ExpressRoute](05-vpn-and-expressroute.md) (hybrid connectivity)

---

## Key Takeaways

- **Peering = direct connection between VNets** (private, fast)
- **Regional peering** = same region (low latency, minimal cost)
- **Global peering** = different regions (higher latency, higher cost)
- **Peering is bidirectional** (both VNets automatically get routes)
- **Routing is automatic** (Azure creates system routes)
- **NSG rules still apply** (peering enables route, NSGs control traffic)
- **Non-overlapping address spaces required** (or peering fails)
- **Gateway transit** = spokes use hub's VPN/ExpressRoute gateway (cost savings)

---

## Next Steps

1. **Learn:** Read this doc (you're here)
2. **Practice:** [Lab 15: Configure VNet Peering](../labs/lab15-vnet-peering.md)
3. **Extend:** Read [VPN & ExpressRoute](05-vpn-and-expressroute.md) (connect on-premises)
4. **Design:** Hub-and-spoke topology using peering and gateway transit
