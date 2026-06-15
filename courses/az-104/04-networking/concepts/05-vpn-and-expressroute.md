# VPN & ExpressRoute: Hybrid Connectivity

## Opening Hook

**Why this matters:** You have Azure VNets in the cloud, but your company still has an on-premises data center. You need to connect them securely. You have two choices: VPN (cheaper, over the internet) or ExpressRoute (dedicated, more expensive, better performance). This doc explains both, when to use each, and how they work.

---

## Before You Start

- **Prerequisites:** [VNets & Subnets](01-vnets-and-subnets.md), [Routing Fundamentals](03-routing-fundamentals.md), [VNet Peering](04-vnet-peering.md)
- **Time to understand:** 20 minutes
- **Difficulty:** 🟡 **Intermediate** (builds on routing)
- **What you'll learn:** How VPN and ExpressRoute work, comparison, when to use each

---

## The Simple Idea

### What Is Hybrid Connectivity?

**Hybrid** = Connecting on-premises infrastructure to Azure cloud.

You need this when:
- Your company has servers in the data center (on-premises)
- You also have resources in Azure (VMs, databases, apps)
- They need to communicate securely

### Two Solutions

| Solution | Connection | Bandwidth | Latency | Cost | Security |
|----------|-----------|-----------|---------|------|----------|
| **VPN** | Over internet (encrypted) | Up to 1.25 Gbps | High (~100ms) | Low | Good (encryption) |
| **ExpressRoute** | Dedicated circuit from provider | Up to 100 Gbps | Low (~5ms) | High | Excellent (isolated) |

---

## Option 1: VPN Gateway

### What Is a VPN?

**VPN (Virtual Private Network)** = Secure tunnel over the public internet that encrypts all traffic.

### Real-World Analogy: Armored Truck Through Public Roads

```
On-Premises Office
│
├── Secret documents
│
└── Send via: Armored Truck (encrypted)
    └─ Drives through public roads
    └─ Attackers can see the truck, but can't access contents ✓

    ↓ (Internet)

    Azure VNet
    │
    ├── Documents received and decrypted
    │
    └── Safely used in cloud services ✓
```

### How VPN Works

```
Step 1: On-premises router has VPN client
  └─ Initiates secure tunnel to Azure VPN Gateway

Step 2: Encryption happens automatically
  └─ All traffic encrypted before leaving on-premises
  └─ Travels over internet
  └─ Decrypted by Azure VPN Gateway

Step 3: Azure VPN Gateway decrypts and forwards
  └─ Forwards to VNets connected to it
  └─ Return traffic encrypted again

Result:
  On-premises ═══(Encrypted Tunnel)═══ Azure
  │                   (Over Internet)      │
  └─ Secure but slower (encryption overhead)
  └─ Good for moderate bandwidth needs
```

### VPN Configuration

```
On-Premises:
├─ VPN Gateway (on router)
├─ Pre-shared key or certificate
└─ Routes: "To reach 10.0.0.0/16 (Azure), use VPN tunnel"

Azure:
├─ VPN Gateway in VNet
├─ Connection resource linking on-prem gateway to Azure gateway
└─ Routes: "To reach 192.168.0.0/16 (on-prem), use VPN tunnel"

Handshake:
  On-prem: "Can I reach 10.0.0.0/16?"
  Azure VPN: "Yes, authenticate with pre-shared key"
  Tunnel established ✓
```

### VPN Use Cases

```
Use VPN when:
├─ Need to connect quickly (days, not weeks)
├─ Low-to-medium bandwidth (< 1 Gbps)
├─ Budget-conscious (cheaper than ExpressRoute)
├─ Can tolerate higher latency (100ms+)
├─ Example: Backup a database nightly to Azure
│         (doesn't need constant, low-latency connection)

Don't use VPN if:
├─ Need very high bandwidth (> 1 Gbps)
├─ Need consistent low latency (< 10ms)
├─ Transmitting HD video or real-time data
└─ Example: Don't run production SQL server queries over VPN
```

---

## Option 2: ExpressRoute

### What Is ExpressRoute?

**ExpressRoute** = Dedicated, private network circuit from your on-premises to Azure (not over the internet).

### Real-World Analogy: Private Highway Just For You

```
On-Premises Office
│
├── Secret documents
│
└── Send via: Private highway (dedicated, isolated)
    └─ Only you can use this highway
    └─ No encryption needed (already isolated)
    └─ Much faster and more reliable ✓

    ↓ (Dedicated Circuit - not internet)

    Azure VNet
    │
    ├── Documents received immediately
    │
    └── Safely used in cloud services ✓
```

### How ExpressRoute Works

```
Step 1: Order dedicated circuit from provider
  └─ Provider creates private circuit: On-prem → Azure DC
  └─ Takes 2-4 weeks to provision

Step 2: Circuit arrives (dedicated link)
  └─ Not encrypted (no need—it's isolated)
  └─ High bandwidth available (1.25, 10, 100 Gbps options)

Step 3: BGP routing configured
  └─ "Routes to 10.0.0.0/16 (Azure) go through this circuit"
  └─ "Routes to 192.168.0.0/16 (on-prem) come from this circuit"

Result:
  On-premises ═══(Dedicated Circuit)═══ Azure
  │               (Private, No Internet)     │
  └─ Secure (isolated by nature)
  └─ Fast (low latency, high bandwidth)
  └─ Predictable (dedicated resource)
```

### ExpressRoute Peering Models

Azure supports multiple connections over one ExpressRoute circuit:

```
ExpressRoute Circuit
├─ Private Peering (Azure VNets)
│  └─ Connect to your Azure VNets (10.0.0.0/16, etc.)
│  └─ Private IP addresses used
│  └─ Lowest latency
│
├─ Microsoft Peering (Microsoft Services)
│  └─ Connect to Office 365, Dynamics, Azure Services
│  └─ Public IP addresses used
│  └─ Can reach Microsoft services without internet
│
└─ Azure Public Peering (Deprecated, avoid)
   └─ Older model, being phased out
```

### ExpressRoute Pricing Models

```
Unlimited Data (Most common):
├─ Monthly fee + Fixed amount of bandwidth
├─ Example: $100/month for 1 Gbps circuit
├─ All data transfers included ✓

Metered Data (Cheaper if low usage):
├─ Monthly fee + Per-GB charges for outbound
├─ Example: $50/month + $0.02/GB outbound
├─ Good if only occasional transfers
└─ Note: Inbound is always free ✓
```

---

## Comparison: VPN vs. ExpressRoute

| Aspect | VPN | ExpressRoute |
|--------|-----|--------------|
| **Cost** | Low ($10-50/month) | High ($100-1000+/month) |
| **Setup Time** | Fast (days) | Slow (weeks) |
| **Bandwidth** | Up to 1.25 Gbps | Up to 100 Gbps |
| **Latency** | High (~100ms) | Low (~5ms) |
| **Reliability** | Medium (shared internet) | High (dedicated) |
| **Encryption** | Built-in | Not needed (isolated) |
| **Security** | Good (encryption) | Excellent (isolation) |
| **Best For** | Quick, temporary, low bandwidth | Production, high throughput |

### Decision Tree

```
Need to connect on-premises to Azure?
│
├─ YES → Have dedicated budget?
│        │
│        ├─ NO → Use VPN Gateway ✓
│        │   └─ Good for: backup, development, non-critical workloads
│        │
│        └─ YES → Need high bandwidth or low latency?
│                 │
│                 ├─ NO → Use VPN Gateway ✓
│                 │   └─ Cheaper, fast to set up
│                 │
│                 └─ YES → Use ExpressRoute ✓
│                     └─ Production, mission-critical, real-time data
│
└─ NO → Don't connect on-prem ✓
    └─ Cloud-only architecture (simpler)
```

---

## Worked Example: Real Scenario

### The Scenario

**TechCorp has:**
- On-premises: Data center with SQL servers (192.168.0.0/16)
- Azure: Production VNet (10.0.0.0/16) and Dev VNet (10.1.0.0/16)

**Requirement:** Migrate workloads incrementally (dual-run for weeks).

### Solution 1: VPN for Initial Migration

```
Phase 1 (Weeks 1-4): Use VPN for testing
  └─ On-premises → VPN Gateway → Azure Prod VNet
  └─ Test applications in Azure while old systems still running
  └─ Cost: ~$30/month VPN + internet bandwidth
  └─ Latency: ~100ms (acceptable for testing) ✓

Configuration:
├─ On-prem VPN Gateway: Configured for site-to-site VPN
├─ Azure VPN Gateway in Prod VNet
├─ Pre-shared key or certificates
├─ Routes:
│  ├─ On-prem: 192.168.0.0/16 local, 10.0.0.0/16 via VPN
│  └─ Azure: 10.0.0.0/16 local, 192.168.0.0/16 via VPN

Testing:
  ├─ App server in Azure (10.0.1.5) queries on-prem SQL (192.168.1.50)
  ├─ Latency: ~100ms (acceptable for testing) ✓
  └─ VPN encrypts all traffic ✓

Cost: Low (good for temporary connection)
```

### Solution 2: Migrate to ExpressRoute (Phase 2)

```
Phase 2 (Weeks 5+): Switch to ExpressRoute for production
  └─ Order dedicated circuit: Takes 3 weeks to provision
  └─ While waiting, continue testing over VPN

Configuration:
├─ ExpressRoute Circuit provisioned
│  ├─ Provider: Equinix (or other partner)
│  ├─ Bandwidth: 10 Gbps
│  ├─ Location: Same city as data center
│  └─ Monthly cost: ~$500
│
├─ Azure side: Create ExpressRoute gateway
│  ├─ Private Peering for VNets
│  └─ Routes updated to use ExpressRoute for all on-prem traffic
│
└─ On-premises side: BGP configured for routing

Result:
  ├─ High bandwidth available (10 Gbps vs. VPN's 1.25 Gbps)
  ├─ Low latency (~5ms vs. VPN's 100ms)
  ├─ Production workloads move to Azure with good performance ✓
  └─ Cost higher but worth it for mission-critical apps
```

### Phase 3: Dual Connectivity (Redundancy)

```
For production reliability: Use BOTH VPN and ExpressRoute

VPN + ExpressRoute together:
├─ ExpressRoute: Primary (low latency, high bandwidth)
│  └─ BGP priority: 100 (preferred)
│
└─ VPN: Failover (takes over if ExpressRoute fails)
   └─ BGP priority: 200 (backup only)

Result:
  ├─ Normal: All traffic goes through ExpressRoute
  ├─ If ExpressRoute circuit fails: Automatically uses VPN ✓
  ├─ Keeps services running during maintenance/outages ✓
  └─ High availability achieved (minimal downtime)

Configuration:
  BGP Local Preference / Priority settings on-prem
  └─ Advertise 10.0.0.0/16 via ExpressRoute with lower metric
  └─ Advertise 10.0.0.0/16 via VPN with higher metric
  └─ On-prem routers prefer lower metric (ExpressRoute)
  └─ If ExpressRoute fails, use VPN (higher metric wins)
```

---

## Common Mistakes (What NOT to Do)

### ❌ Mistake 1: Choosing VPN for Production High-Traffic

**Wrong:**
```
Production database (500 GB/month traffic):
├─ Manager says: "VPN is cheaper, let's use that"
├─ VPN bandwidth: 1.25 Gbps
├─ Actual usage: 500 GB/month = 1.5 Gbps sustained
├─ Result: Bottleneck, slow queries, timeouts ✗
```

**Why it fails:** VPN has bandwidth limits, not suitable for heavy production.

**Fix:**
```
Use ExpressRoute for production:
├─ Bandwidth: 10+ Gbps available
├─ Latency: Consistent (~5ms)
├─ Throughput: Can handle 500 GB/month easily ✓
└─ Worth the extra cost for reliability ✓
```

---

### ❌ Mistake 2: Not Planning Failover

**Wrong:**
```
ExpressRoute circuit fails (provider maintenance):
├─ No VPN backup configured
├─ On-premises can't reach Azure ✗
├─ Production services down ✗
├─ SLA breach, customers affected ✗
```

**Why it fails:** Single point of failure.

**Fix:**
```
Configure redundancy:
├─ Primary: ExpressRoute (low latency)
├─ Secondary: VPN (backup)
├─ BGP preference: ExpressRoute preferred
└─ On circuit failure: BGP switches to VPN automatically ✓
```

---

### ❌ Mistake 3: Poor Routing Configuration

**Wrong:**
```
On-premises routes:
  └─ Default route (0.0.0.0/0) → VPN to Azure
  
  Result: ALL traffic to internet goes through Azure VPN ✗
  ├─ Accessing external websites slow
  ├─ Azure gateway becomes bottleneck
  └─ Expensive bandwidth usage

Solution: Be specific
  ├─ Route 10.0.0.0/16 → VPN (only Azure)
  ├─ Route 0.0.0.0/0 → Local internet (for web, email, etc.)
  └─ Result: Only Azure traffic uses VPN, internet traffic local ✓
```

---

## Connectivity Checklist

```
□ Choose technology (VPN vs. ExpressRoute)
  └─ VPN: Quick setup, lower cost
  └─ ExpressRoute: Higher bandwidth, production-grade

□ For VPN:
  ├─ VPN Gateway created in Azure VNet
  ├─ VPN Gateway configured on on-premises router
  ├─ Pre-shared key configured on both sides
  ├─ Routes configured (what traffic goes through VPN)
  └─ Connection tested (ping on-prem from Azure) ✓

□ For ExpressRoute:
  ├─ Order circuit from provider
  ├─ Wait for provisioning (2-4 weeks)
  ├─ Provider key received
  ├─ ExpressRoute gateway created in Azure
  ├─ BGP peers configured on both sides
  └─ Routes converged (on-prem routes visible in Azure) ✓

□ For both:
  ├─ Routing configured on both sides
  ├─ NSG rules allow traffic (security groups still apply)
  ├─ Firewall rules allow traffic (if firewalls present)
  └─ Performance tested (latency, bandwidth acceptable) ✓

□ For redundancy:
  ├─ Both VPN and ExpressRoute configured
  ├─ BGP priorities set (prefer one, failover to other)
  ├─ Failover tested (disconnect primary, verify backup works)
  └─ Alerts configured (notify when primary fails) ✓
```

---

## How This Connects to Other Topics

### Related to Module 01 (Identity & Governance)
- **RBAC:** Only network admins can configure VPN/ExpressRoute gateways

### Related to Module 02 (Storage)
- **Storage Access:** On-prem servers reach Azure Storage via VPN/ExpressRoute

### Related to Module 04 (Networking)
- **VNet Peering:** Hub VNet with gateway can serve multiple spokes

### Related to Module 05 (Monitor)
- **Monitor Hybrid Connectivity:** Monitor VPN/ExpressRoute metrics

---

## See It In Action

**Associated labs:**
- [Lab 16: Configure VPN Gateway](../labs/lab16-vpn-gateway.md)

**Suggested learning sequence:**
1. ✅ Read [VNets & Subnets](01-vnets-and-subnets.md)
2. ✅ Read [Routing Fundamentals](03-routing-fundamentals.md)
3. ✅ Read [VNet Peering](04-vnet-peering.md)
4. ✅ Read this doc (VPN & ExpressRoute)
5. ✅ Work through Lab 16 (hands-on VPN setup)
6. ➡️ Read [Private Endpoints & Service Endpoints](07-private-endpoints-service-endpoints.md)

---

## Key Takeaways

- **VPN = encrypted tunnel over internet** (quick, cheaper, limited bandwidth)
- **ExpressRoute = dedicated private circuit** (better performance, higher cost)
- **VPN best for:** Non-critical, temporary, low-bandwidth connections
- **ExpressRoute best for:** Production, high-throughput, mission-critical
- **Failover:** Configure both VPN and ExpressRoute for redundancy
- **BGP routing:** Automatic failover when primary fails
- **Routing specificity:** Route only Azure traffic through VPN/ExpressRoute
- **NSG/Firewall rules still apply** on both sides of the connection

---

## Next Steps

1. **Learn:** Read this doc (you're here)
2. **Decide:** Which fits your scenario—VPN or ExpressRoute?
3. **Plan:** Document on-premises IP ranges and Azure VNet ranges
4. **Practice:** [Lab 16: Configure VPN Gateway](../labs/lab16-vpn-gateway.md)
5. **Advance:** Set up dual connectivity with VPN + ExpressRoute
6. **Secure:** Read [Private Endpoints & Service Endpoints](07-private-endpoints-service-endpoints.md)
