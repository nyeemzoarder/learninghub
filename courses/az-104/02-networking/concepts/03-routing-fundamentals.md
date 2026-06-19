# Routing Fundamentals: How Traffic Finds Its Way

## Opening Hook

**Why this matters:** You've created a VNet with subnets and locked them down with NSGs. But how does traffic actually find its way from your web server to your database? Routing is the "GPS" of your network—it decides which path traffic takes. Understand routing, and you'll understand how your entire network communicates.

---

## Before You Start

- **Prerequisites:** [VNets & Subnets](01-vnets-and-subnets.md) and [Network Security Groups](02-network-security-groups.md)
- **Time to understand:** 15 minutes
- **Difficulty:** 🟢 **Beginner** (builds on NSGs, no advanced networking needed)
- **What you'll learn:** How Azure routes traffic, system vs. custom routes, common routing patterns

---

## The Simple Idea

### What Is Routing?

**Routing** = Deciding the path that network traffic takes from source to destination.

Think of it like **GPS for data packets:**

```
Your data packet: "I need to go from 10.0.1.5 to 10.0.3.20"
                           ↓
                   Azure routing table
                           ↓
         "I know a route to 10.0.3.0/24
          Go through subnet 10.0.3.0/24"
                           ↓
            Data arrives at destination ✓
```

### How Azure Decides Routes

Azure has a **routing table** (like a GPS navigation database) that says:
- "To reach 10.0.1.0/24, use local VNet"
- "To reach 10.0.2.0/24, use local VNet"
- "To reach 192.168.0.0/16, use VPN Gateway"
- "To reach anything else, use internet"

### Two Types of Routes

| Route Type | What It Does | Examples |
|-----------|------------|----------|
| **System Routes** | Built-in, automatic, managed by Azure | Internal VNet traffic, internet |
| **Custom Routes (UDR)** | You create them for special cases | Send traffic through firewall, VPN |

---

## How It Actually Works

### Step 1: Traffic Arrives at Your Subnet

```
Data packet arrives:
From: 10.0.1.5 (WebServer)
To: 10.0.3.20 (Database)
```

### Step 2: Subnet Looks at Its Routing Table

Azure automatically created these **system routes** for your subnet:

```
Destination          Next Hop         Purpose
────────────────────────────────────────────
10.0.0.0/16         Local VNet       Traffic within VNet stays local
10.0.1.0/24         Local Subnet     Traffic to this subnet is direct
10.0.2.0/24         Local Subnet     Traffic to app subnet is direct
10.0.3.0/24         Local Subnet     Traffic to DB subnet is direct
0.0.0.0/0           Internet         Everything else goes to internet
```

### Step 3: Routing Lookup

```
Packet destination: 10.0.3.20
Azure checks routing table:
  └─ Does it match 10.0.0.0/16? YES ✓
  └─ Next hop: "Local VNet"
  └─ Route: Send directly to destination within VNet

Result: Packet goes from 10.0.1.5 → 10.0.3.20 (direct path)
```

### Step 4: NSG Check

```
Packet arrives at DB subnet:
  └─ NSG checks inbound rule
     "Is source 10.0.2.0/24 on port 1433?" 
     → YES ✓
  └─ NSG allows traffic
Result: Database receives the packet ✓
```

---

## Mental Model: Routing as GPS Navigation

```
You're driving from point A to point B.

Your GPS (routing table):
├─ Route 1: "If destination is nearby, drive directly" (system route)
├─ Route 2: "If destination is far, take the highway" (system route)
├─ Route 3: "If you need to go through a checkpoint, use Route 66" (custom route)
└─ Route 4: "If no route exists, go to the main road" (default route)

Your data packet follows the same logic:
├─ System routes handle normal traffic (within VNet, to internet)
└─ Custom routes handle special cases (through firewall, VPN, etc.)
```

---

## System Routes vs. Custom Routes

### System Routes (Created Automatically)

**Every VNet automatically gets these routes:**

```
Destination        Next Hop         Created Automatically?
──────────────────────────────────────────────────────
10.0.0.0/16        Local VNet       ✓ Yes (VNet address space)
0.0.0.0/0          Internet         ✓ Yes (default internet route)
```

**Examples of what each means:**

| Route | Destination | Next Hop | When Used |
|-------|------------|----------|----------|
| Local VNet | 10.0.0.0/16 | Local | Traffic within your entire VNet |
| Internet | 0.0.0.0/0 | Internet | Traffic to anywhere not in your VNet |

### Custom Routes (UDRs - User-Defined Routes)

**You create these for special cases:**

```
Example UDR:
Destination:  192.168.0.0/16 (on-premises)
Next Hop:     VPN Gateway
Purpose:      Send traffic to on-premises through VPN
```

**Why you'd create custom routes:**

| Use Case | Custom Route | Benefit |
|----------|-------------|---------|
| **Send traffic through firewall** | Destination: 0.0.0.0/0 → Next Hop: Firewall IP | All internet-bound traffic passes through firewall |
| **Connect to on-premises** | Destination: 192.168.0.0/16 → Next Hop: VPN Gateway | Corporate network access |
| **Send to security appliance** | Destination: 10.0.0.0/16 → Next Hop: NVA (network appliance) | All internal traffic inspected |

---

## Worked Example: Real Scenario

### The Scenario

**TechCorp's network:**
- 3 subnets within VNet: Web (10.0.1.0/24), App (10.0.2.0/24), DB (10.0.3.0/24)
- Azure Firewall in hub VNet protecting everything
- VPN connection to on-premises network (192.168.0.0/16)

**Goal:** Route traffic correctly through firewall and VPN.

### Step 1: Default System Routes (Automatic)

```
App Subnet (10.0.2.0/24) Routing Table (Default):
─────────────────────────────────────────────────

Destination      Next Hop        Priority
───────────────────────────────────────
10.0.0.0/16      Local VNet        1  (All internal VNet traffic)
0.0.0.0/0        Internet          2  (Everything else to internet)

AppServer (10.0.2.10) wants to send data:

Case 1: To Database (10.0.3.20)
  └─ Destination: 10.0.3.20
  └─ Match: 10.0.0.0/16? YES ✓
  └─ Route: Local VNet (direct path)
  └─ Result: 10.0.2.10 → 10.0.3.20 directly ✓

Case 2: To Internet
  └─ Destination: 8.8.8.8 (Google)
  └─ Match: 10.0.0.0/16? NO
  └─ Match: 0.0.0.0/0? YES ✓
  └─ Route: Internet (default route)
  └─ Result: 10.0.2.10 → Internet directly ✓ (No firewall!)
```

**Problem:** Traffic to internet bypasses firewall. We need custom routes.

### Step 2: Add Custom Routes (Force Through Firewall)

```
Admin creates custom route:
Destination:  0.0.0.0/0 (all internet traffic)
Next Hop:     Azure Firewall (10.0.0.4)
Priority:     Higher than default

App Subnet (10.0.2.0/24) Routing Table (Updated):
──────────────────────────────────────────────────

Destination      Next Hop        Priority
───────────────────────────────────────
0.0.0.0/0        Firewall IP       1  (Custom route - checked first!)
10.0.0.0/16      Local VNet        2
0.0.0.0/0        Internet          3  (Default - not used now)

AppServer (10.0.2.10) wants to send data:

Case 1: To Database (10.0.3.20)
  └─ Destination: 10.0.3.20
  └─ Match: 0.0.0.0/0? YES, but next hop is 10.0.0.0/16
  └─ No wait, check priority 2 first
  └─ Match: 10.0.0.0/16? YES ✓
  └─ Route: Local VNet (direct, bypass firewall—OK for internal)
  └─ Result: 10.0.2.10 → 10.0.3.20 directly ✓

Case 2: To Internet
  └─ Destination: 8.8.8.8 (Google)
  └─ Match: 0.0.0.0/0? YES ✓ (custom route, high priority)
  └─ Route: Firewall IP (10.0.0.4)
  └─ Result: 10.0.2.10 → Firewall → Internet ✓ (Firewall inspects!)
```

**Result:** Custom route forces internet-bound traffic through firewall.

### Step 3: Add VPN Route (For On-Premises Access)

```
Admin creates another custom route:
Destination:  192.168.0.0/16 (on-premises)
Next Hop:     VPN Gateway
Priority:     1

App Subnet (10.0.2.0/24) Routing Table (Final):
────────────────────────────────────────────────

Destination        Next Hop        Priority
──────────────────────────────────
192.168.0.0/16     VPN Gateway       1  (On-prem traffic via VPN)
0.0.0.0/0          Firewall IP       2  (Internet via firewall)
10.0.0.0/16        Local VNet        3  (Internal via VNet)
0.0.0.0/0          Internet          4  (Default - not reached)

AppServer (10.0.2.10) wants to send data:

Case 1: To Database (10.0.3.20)
  └─ Match: 192.168.0.0/16? NO
  └─ Match: 0.0.0.0/0? YES, but check next priority
  └─ Match: 10.0.0.0/16? YES ✓
  └─ Route: Local VNet
  └─ Result: Direct to database ✓

Case 2: To On-Premises Server (192.168.1.50)
  └─ Match: 192.168.0.0/16? YES ✓
  └─ Route: VPN Gateway
  └─ Result: 10.0.2.10 → VPN Gateway → VPN Tunnel → On-premises ✓

Case 3: To Internet (8.8.8.8)
  └─ Match: 192.168.0.0/16? NO
  └─ Match: 0.0.0.0/0? YES ✓
  └─ Route: Firewall IP
  └─ Result: 10.0.2.10 → Firewall → Internet ✓
```

---

## Common Mistakes (What NOT to Do)

### ❌ Mistake 1: Unexpected Default Route

**Wrong:**
```
Admin creates custom route:
  Destination: 0.0.0.0/0 → VPN Gateway

All traffic goes to VPN, including:
  ├─ Internal traffic (should stay local) ✗
  ├─ Internet traffic (should go to internet or firewall) ✗
  └─ Database traffic (should be direct) ✗

Result: Everything bottlenecks through VPN
```

**Why it fails:** Too broad a route causes unnecessary traffic redirection.

**Fix:**
```
Be more specific:
  └─ 192.168.0.0/16 → VPN Gateway (only on-prem traffic)
  └─ 10.0.0.0/16 → Local VNet (internal traffic)
  └─ 0.0.0.0/0 → Internet or Firewall (external traffic)

Each traffic type follows the correct path ✓
```

---

### ❌ Mistake 2: Routing Loop

**Wrong:**
```
Custom route 1: 0.0.0.0/0 → Firewall (10.0.0.4)
Custom route 2: 0.0.0.4/32 → Internet

Packet goes: App → Firewall → Internet
But what if firewall tries to reach internet?
  └─ Matches 0.0.0.0/0 → Firewall again
  └─ Infinite loop! ✗
```

**Why it fails:** Packet gets stuck in a loop.

**Fix:**
```
Firewall routes to internet directly (exclude from custom route):
  └─ Custom route: 0.0.0.0/0 → Firewall
  └─ Except: Firewall's NIC route: 0.0.0.0/0 → Internet (direct)

Packet goes: App → Firewall → Internet (no loop) ✓
```

---

### ❌ Mistake 3: Too Many Custom Routes

**Wrong:**
```
Create 100 custom routes for every possible destination
├─ 8.8.8.8/32 → Internet
├─ 1.1.1.1/32 → Internet
├─ ... (95 more individual IPs)
└─ 192.168.0.0/16 → VPN

Result:
  ├─ Difficult to maintain
  ├─ Error-prone
  ├─ Confusing for other admins
  └─ Harder to troubleshoot
```

**Why it fails:** Complexity = mistakes and maintenance headaches.

**Fix:**
```
Use aggregate routes (CIDR notation):
  └─ 0.0.0.0/0 → Firewall (one route handles everything)
  └─ 192.168.0.0/16 → VPN (one route for all on-prem)

Much simpler and easier to manage ✓
```

---

## Routing Decision Order (Route Priority)

**When traffic arrives, Azure checks routes in this order:**

1. **Most specific match** (longest prefix match)
   ```
   Destination: 10.0.2.5
   Routes available:
   ├─ 10.0.2.0/25 (specific)
   ├─ 10.0.2.0/24 (less specific)
   └─ 10.0.0.0/16 (even less specific)
   
   Azure picks: 10.0.2.0/25 (most specific) ✓
   ```

2. **Custom routes before system routes**
   ```
   If both custom and system routes exist for same destination:
   └─ Custom route wins
   ```

3. **Default deny if no match**
   ```
   If no route matches:
   └─ Traffic is dropped (denied) ✗
   ```

---

## How This Connects to Other Topics

### Related to Module 01 (Identity & Governance)
- **RBAC + Routing:** Use RBAC to control who can modify routing tables
- **Policy + Routing:** Enforce routing policies (e.g., all traffic must go through firewall)

### Related to Module 02 (Storage)
- **Storage Firewall Routes:** Combined with routing, restrict storage access to specific networks
- **Service Endpoints:** Routes direct traffic to storage without public internet

### Related to Module 03 (Compute)
- **VM to VM Communication:** VMs in same VNet route directly (system route)
- **VM to Database:** Routing determines path through NSG and firewall

### Related to Module 05 (Monitor)
- **Route Metrics:** Monitor traffic flow through different routes
- **Network Watcher:** Trace routing paths to diagnose connectivity issues

---

## See It In Action

**Associated lab:** [Lab 14: Configure Routing & UDRs](../labs/lab14-routing.md)

**Suggested learning sequence:**
1. ✅ Read [VNets & Subnets](01-vnets-and-subnets.md)
2. ✅ Read [Network Security Groups](02-network-security-groups.md)
3. ✅ Read this doc (Routing Fundamentals)
4. ✅ Work through Lab 14 (hands-on routing configuration)
5. ✅ Read [VNet Peering](04-vnet-peering.md) (routing between peered VNets)

---

## Key Takeaways

- **Routing = GPS for data packets** (decides which path traffic takes)
- **System routes are automatic** (internal traffic, internet access)
- **Custom routes (UDRs) are for special cases** (firewall, VPN, appliances)
- **More specific route wins** (longer CIDR prefix = higher priority)
- **Custom routes override system routes** (same destination priority)
- **Traffic flows based on routing table** then **checked by NSG rules**
- **Routing + NSG = complete traffic control** (routing decides path, NSG decides permission)

---

## Routing Decision Flowchart

```
Packet arrives at subnet
         ↓
   Check routing table
         ↓
   ┌─────┴──────┐
   │            │
Custom route? | System route?
   │            │
   v            v
Found match? → Yes → Next hop identified
   │                      ↓
   └─→ No → Check next route / Default (drop)
                      ↓
           NSG checks permission
                      ↓
         ┌─────┴──────┐
         │            │
      ALLOW       DENY
         │            │
   Forward    Drop
   packet    packet
```

---

## Summary: Three Layers of Network Control

| Layer | Tool | Controls | Example |
|-------|------|----------|---------|
| **1. Routing** | Routing Tables (System + UDR) | Which path traffic takes | Route all internet traffic through firewall |
| **2. Security** | Network Security Groups (NSG) | Which traffic is allowed | Allow port 443 from web subnet to app subnet |
| **3. Access** | RBAC | Who can change routing/NSGs | Only network admins can modify routing tables |

All three together provide complete network control.

---

## Next Steps

1. **Learn:** Read this doc (you're here)
2. **Practice:** [Lab 14: Configure Routing & UDRs](../labs/lab14-routing.md)
3. **Connect:** Read [VNet Peering](04-vnet-peering.md) (routing between peered VNets)
4. **Advance:** Read [VPN & ExpressRoute](05-vpn-and-expressroute.md) (routing to on-premises)
5. **Secure:** Advanced—Azure Firewall with routing rules
