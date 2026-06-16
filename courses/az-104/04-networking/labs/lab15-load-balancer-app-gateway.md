# Lab 15 – Load Balancer & Application Gateway

## Objectives
- Deploy an Azure Load Balancer (Layer 4) with a backend pool and health probe
- Deploy an Application Gateway (Layer 7) with path-based routing
- Compare LB SKUs (Basic vs Standard) and understand when to use each service

## Prerequisites
- None
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time
45 minutes

---

## Part 1 – Setup: VNet and two web VMs

1. Search for **Resource groups** > **Create**. Name: `rg-az104-lab15`,
   region: `East US`. **Create**.
2. **Virtual networks** > **Create**. **Name**: `vnet-lab15`, **Address space**:
   `10.80.0.0/16`, **Subnets**: `subnet-backend` with `10.80.1.0/24`. **Create**.
3. Create two VMs:
   - **vm-web01** and **vm-web02**: both **Ubuntu 22.04 LTS**, **Standard_B1s**,
     `vnet-lab15`/`subnet-backend` with **public IPs** (so you can manage them
     individually). **Create**.
4. On each VM, install nginx with distinct content:
   - SSH into `vm-web01` and run:
     ```bash
     sudo apt-get update && sudo apt-get install -y nginx
     echo "Server 1" | sudo tee /var/www/html/index.html
     ```
   - SSH into `vm-web02` and repeat (changing "Server 1" to "Server 2").

## Part 2 – Standard Load Balancer

1. Search for **Load balancers** > **Create**.
2. **Basics**:
   - **Name**: `lb-lab15`
   - **Type**: **Public**
   - **SKU**: **Standard**
   - **Region**: `East US`
   - **Public IP**: **Create new** (e.g., `pip-lb15`)
3. **Frontend IP configuration**:
   - **Frontend IP name**: `feLB`
   - (Public IP already selected above)
4. **Backend pools**: **Create new**
   - **Name**: `beLB`
   - **Subnet**: select `vnet-lab15`/`subnet-backend`
5. **Inbound rules** (configure after creation).
6. **Review + create** > **Create**.

### Add VMs to backend pool
1. Go to **lb-lab15** > **Backend pools** > select `beLB` > **+ Add**.
2. Select `vm-web01` and `vm-web02` > **Add**.

### Configure health probe & load-balancing rule

> Tip: Health probes determine if backend instances are healthy. If a probe fails, the load balancer removes that instance from the rotation until it recovers.

1. **lb-lab15** > **Health probes** > **+ Add**:
   - **Name**: `probe-http`
   - **Protocol**: **TCP**
   - **Port**: 80
   - **Interval**: 5
   - **Add**.

2. **lb-lab15** > **Load balancing rules** > **+ Add**:
   - **Name**: `rule-http`
   - **Protocol**: **TCP**
   - **Frontend port**: 80
   - **Backend port**: 80
   - **Backend pool**: `beLB`
   - **Health probe**: `probe-http`
   - **Session persistence**: **None**
   - **Add**.

### Test load balancing
1. Go to **lb-lab15** > **Overview** > copy the **Public IP address**.
2. Open `http://<lb-ip>` in a browser multiple times — should see alternating
   "Server 1" / "Server 2" responses.

## Part 3 – Application Gateway with path-based routing

1. Search for **Application gateways** > **Create**.
2. **Basics**:
   - **Name**: `appgw-lab15`
   - **Tier**: **Standard v2**
   - **Capacity**: 1 instance
   - **Virtual network**: `vnet-lab15`
   - **Subnet**: **Create new** `subnet-appgw` with `10.80.2.0/24`
   - **Public IP**: **Create new** (e.g., `pip-appgw15`)
3. **Backends**:
   - **Backend pools**: select **Create new**
   - **Name**: `backendPool1`
   - **Target type**: **IP addresses or FQDN**
   - **Targets**: add `vm-web01`'s private IP (e.g., `10.80.1.4`) and
     `vm-web02`'s private IP (e.g., `10.80.1.5`)
4. **Configuration** (after creation): **Rules** > configure path-based rules
   (see Part 4).
5. **Review + create** > **Create**.

### Configure path-based routing
1. Go to **appgw-lab15** > **Rules** (under **Settings**) > **+ Add rule**.
2. **Rule name**: `rule-path`
3. **Listener** tab:
   - **Listener name**: `listener-http`
   - **Frontend IP**: select public IP
   - **Port**: 80
   - **Protocol**: **HTTP**
4. **Backend targets** tab:
   - **Path-based routing**: **Checked**
   - **Path rules**:
     - Path: `/api/*` → backend pool `backendPool1`
     - Path: `/images/*` → backend pool `backendPool1` (or create separate pools)
     - Default path: `/` → backend pool `backendPool1`
5. **Review + create** > **Create**.

## Part 4 – Compare LB SKUs

| Aspect | Basic LB | Standard LB |
|--------|----------|-------------|
| Backend pool | Up to 300 instances, single AVS | Up to 1000, VMs/VMSS across zones |
| SLA | None | 99.99% |
| NSG required on backend | No (open by default) | Yes (secure by default) |
| Availability Zones | No | Yes (zone-redundant) |
| Outbound rules | No | Yes (explicit SNAT config) |

## Validation
- [ ] Load Balancer distributes traffic across both VMs (alternating responses)
- [ ] Health probe configured on port 80
- [ ] Application Gateway deployed with backend pool pointing at both VM IPs
- [ ] Can articulate Basic vs Standard LB differences and L4 vs L7 use cases

## Cleanup
1. **Resource groups** > select `rg-az104-lab15` > **Delete resource group**.

## Exam Tips
- **Load Balancer** = Layer 4 (TCP/UDP), regional or global (cross-region) tier available in Standard SKU.
- **Application Gateway** = Layer 7 (HTTP/HTTPS), supports path-based routing, SSL offload/termination, cookie-based session affinity, and integrates with WAF (Web Application Firewall) — WAF_v2 SKU.
- Standard LB requires explicit NSG rules to allow traffic (including `AzureLoadBalancer` tag for health probes); Basic LB does not.
- Public vs Internal LB: Internal (ILB) has a private frontend IP only, used for internal-facing tiers.
