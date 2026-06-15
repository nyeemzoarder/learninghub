# Lab 13 – Network Security Groups & Application Security Groups

## Objectives
- Create and associate NSGs at subnet and NIC level
- Understand rule priority, evaluation order, and default rules
- Use Application Security Groups (ASGs) to group VMs for rule targeting
- Use network diagnostics tools: effective security rules, IP flow verify

## Prerequisites
- A VNet with at least one subnet (reuse Lab 12's `vnet-hub`, or create new)
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time
35 minutes

---

## Part 1 – Setup

1. Search for **Resource groups** > **Create**. Name: `rg-az104-lab13`,
   region: `East US`. **Review + create** > **Create**.
2. Search for **Virtual networks** > **Create**. **Resource group**:
   `rg-az104-lab13`, **Name**: `vnet-lab13`, **Address space**: `10.60.0.0/16`.
   **Subnets**: `subnet-web` with `10.60.1.0/24`. **Create**.
3. Create two VMs:
   - **Virtual machines** > **Create** > `vm-web01`, **Ubuntu 22.04 LTS**,
     **Standard_B1s**, `vnet-lab13`/`subnet-web`. **Create**.
   - Repeat for `vm-web02`.

## Part 2 – Create an NSG and rules

1. Search for **Network security groups** > **Create**.
   - **Resource group**: `rg-az104-lab13`
   - **Name**: `nsg-web`
   - **Region**: `East US`
   - **Create**.

2. Go to **nsg-web** > **Inbound security rules** > **+ Add**.
3. Create rule 1: **Allow SSH from your IP only**
   - **Source**: **IP addresses**, enter your public IP (e.g., `203.0.113.0/32`)
   - **Source port ranges**: `*`
   - **Destination**: **Any**
   - **Service**: **SSH** (auto-fills port 22)
   - **Protocol**: **TCP**
   - **Action**: **Allow**
   - **Priority**: 100
   - **Name**: `Allow-SSH-MyIP`
   - **Add**.

4. Create rule 2: **Allow HTTP from anywhere**
   - **Source**: **Any**
   - **Service**: **HTTP** (port 80)
   - **Action**: **Allow**
   - **Priority**: 110
   - **Name**: `Allow-HTTP`
   - **Add**.

5. (Optional) Create rule 3: **Deny all (illustrative)**
   - **Source**: **Any**
   - **Destination**: **Any**
   - **Action**: **Deny**
   - **Priority**: 4096
   - **Name**: `Deny-All-Inbound`
   - **Add**

## Part 3 – Associate NSG to subnet

1. Go to **nsg-web** > **Subnets** > **+ Associate**.
2. Select `vnet-lab13` / `subnet-web` > **OK**.

The NSG is now applied at the subnet level, affecting all VMs in that subnet.

## Part 4 – Application Security Groups

1. Search for **Application security groups** > **Create**.
   - **Resource group**: `rg-az104-lab13`
   - **Name**: `asg-webservers`
   - **Region**: `East US`
   - **Create**.

2. Add VM NICs to the ASG:
   - Go to **vm-web01** > **Networking** > select the NIC (e.g.,
     `vm-web01***`) > **Application security groups** > **Configure
     application security group memberships** > add `asg-webservers` > **Save**.
   - Repeat for **vm-web02**.

3. Create an NSG rule targeting the ASG:
   - **nsg-web** > **Inbound security rules** > **+ Add**.
   - **Source**: **Application security group**: `asg-webservers`
   - **Destination**: **Application security group**: `asg-webservers`
   - **Service**: **HTTPS** (port 443)
   - **Action**: **Allow**
   - **Priority**: 120
   - **Name**: `Allow-HTTPS-To-WebASG`
   - **Add**.

This rule allows HTTPS traffic between members of the `asg-webservers` group
without needing to hardcode IP addresses.

## Part 5 – Effective security rules & IP flow verify

1. Go to **vm-web01** > **Networking** > select the NIC > **Network Watcher**
   (or search **Network Watcher**) > **Effective security rules** to see the
   merged subnet + NIC-level rules.

2. **Network Watcher** > **IP flow verify** (under **Network diagnostic tools**):
   - **VM**: `vm-web01`
   - **Direction**: **Inbound**
   - **Protocol**: **TCP**
   - **Local IP/port**: `10.60.1.4:80` (or the actual private IP)
   - **Remote IP/port**: `10.60.1.100:12345` (a test IP)
   - **Check** — should show **Allow** (matching the HTTP rule).

3. Repeat with port 22 from a non-allowed source IP — expect **Deny**.

## Part 6 – Rule priority & evaluation order

Discuss (no need to execute):
- Rules evaluated in **priority order** (100–4096, lower number = higher
  priority); first match wins.
- Default rules (priority 65000+): AllowVnetInBound, AllowAzureLoadBalancerInBound,
  DenyAllInBound (and outbound equivalents) — cannot be deleted, but can be
  overridden by lower-numbered custom rules.
- NSGs can apply at **subnet** and/or **NIC** level — traffic must pass both
  if both exist.

## Validation
- [ ] NSG `nsg-web` associated with `subnet-web`
- [ ] SSH allowed only from your IP; HTTP allowed from any source
- [ ] ASG `asg-webservers` contains both VM NICs and is referenced by an NSG rule
- [ ] **Effective security rules** shows merged subnet + NIC rules
- [ ] **IP flow verify** confirms expected allow/deny for sample traffic

## Cleanup
1. **Resource groups** > select `rg-az104-lab13` > **Delete resource group**.

## Exam Tips
- Lowest priority number wins (evaluated first); once a rule matches, evaluation stops.
- NSGs are stateful — an allowed inbound flow's response traffic is automatically allowed outbound (and vice versa).
- ASGs let you write NSG rules based on application roles (e.g., "WebServers") instead of hardcoded IPs — simplifies rule management as VMs scale.
- "Effective security rules" merges subnet-level + NIC-level NSGs — exam scenarios often ask which rule "wins" when both exist.
