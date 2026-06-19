# Lab 17 – Azure Monitor & Alerts

## Objectives
- Configure diagnostic settings to send logs/metrics to Log Analytics
- Write Kusto (KQL) queries against VM/activity logs
- Create metric and log-based alert rules with action groups
- Explore Azure Monitor Insights (VM insights)

## Prerequisites
- A VM (small size to minimize billing)
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time
40 minutes

---

## Part 1 – Setup: Log Analytics workspace

1. Search for **Log Analytics workspaces** > **Create**.
2. **Basics**:
   - **Resource group**: **Create new** `rg-az104-lab17`
   - **Name**: `law-az104lab17`
   - **Region**: `East US`
   - **Create**.

## Part 2 – Diagnostic settings

> Important: Diagnostic data is not retroactive. Enable diagnostic settings BEFORE you want to start collecting logs. Historical data cannot be recovered.

Send metrics/logs to the Log Analytics workspace:

1. Create a storage account (or reuse one):
   - **Storage accounts** > **Create**. **Resource group**: `rg-az104-lab17`,
     **Name**: `stoaz104lab17<unique>`. **Create**.

2. Go to **stoaz104lab17<unique>** > **Diagnostic settings** (under **Monitoring**) >
   **+ Add diagnostic setting**:
   - **Diagnostic setting name**: `diag-storage17`
   - **Logs**: check **StorageRead**, **StorageWrite**, **StorageDelete**
   - **Metrics**: check **Transaction**
   - **Send to Log Analytics workspace**: **Enabled**
   - **Log Analytics workspace**: `law-az104lab17`
   - **Save**.

Diagnostic data now flows from the storage account to Log Analytics.

## Part 3 – VM Insights (monitoring on a VM)

1. Create a VM:
   - **Virtual machines** > **Create** > `vm-monitor01`, **Ubuntu 22.04 LTS**,
     **Standard_B1s**, `rg-az104-lab17`. **Create**.

2. Go to **vm-monitor01** > **Insights** (under **Monitoring**) > **Enable** (or
   **Configure**).
   - **Log Analytics workspace**: `law-az104lab17`
   - **Configure** — the Portal automatically installs the Azure Monitor Agent
     (AMA) and sets up data collection rules (DCRs) for performance metrics.

After a few minutes, performance data (CPU, memory, disk) flows into Log Analytics.

## Part 4 – KQL queries

1. Go to **law-az104lab17** > **Logs** (under **General**).
2. Run a query:
   ```kql
   AzureActivity
   | where ResourceGroup == "rg-az104-lab17"
   | project TimeGenerated, OperationNameValue, Caller, ActivityStatusValue
   | order by TimeGenerated desc
   | take 20
   ```
   This shows recent activity log entries for the resource group.

3. Run another query (after VM insights sends data):
   ```kql
   Perf
   | where ObjectName == "Processor" and CounterName == "% Processor Time"
   | summarize avg(CounterValue) by bin(TimeGenerated, 5m), Computer
   | order by TimeGenerated desc
   ```
   This aggregates CPU usage by 5-minute bins.

## Part 5 – Action group

1. Search for **Action groups** > **Create**.
2. **Basics**:
   - **Resource group**: `rg-az104-lab17`
   - **Action group name**: `ag-az104lab17`
   - **Display name**: `AG Lab 17`
3. **Notifications** tab:
   - **Notification type**: **Email/SMS message/Push notification/Voice**
   - **Name**: `admin-email`
   - **Email address**: your email
   - **Add**.
4. **Review + create** > **Create**.

## Part 6 – Metric alert

> Tip: Set alert thresholds conservatively to avoid alert fatigue. A threshold too low will trigger false alarms; too high will miss real issues. Start with typical peak usage + 20%.

1. Search for **Alert rules** > **Create** > **Alert rule**.
2. **Condition**:
   - **Resource**: select `vm-monitor01`
   - **Signal name**: **Percentage CPU**
   - **Operator**: **Greater than**
   - **Threshold**: 80
   - **Aggregation period**: 5 minutes
   - **Frequency of evaluation**: 1 minute
3. **Actions**:
   - **Action group**: select `ag-az104lab17`
4. **Details**:
   - **Alert rule name**: `alert-high-cpu`
   - **Severity**: **2**
5. **Review + create** > **Create**.

Now, if the VM's CPU exceeds 80% for 5 minutes, an alert fires and sends an
email/notification via the action group.

## Part 7 – Log alert (scheduled query)

1. Search for **Alert rules** > **Create** > **Alert rule**.
2. **Condition**:
   - **Resource**: select `law-az104lab17` (Log Analytics workspace)
   - **Signal name**: **Custom log search**
   - **Search query**:
     ```kql
     AzureActivity
     | where ActivityStatusValue == "Failed"
     | summarize Count = count() by bin(TimeGenerated, 15m)
     ```
   - **Threshold**: Count > 5
   - **Evaluation frequency**: 5 minutes
   - **Lookback period**: 15 minutes
3. **Actions**:
   - **Action group**: `ag-az104lab17`
4. **Details**:
   - **Alert rule name**: `alert-failed-ops`
   - **Severity**: **3**
5. **Review + create** > **Create**.

This log alert fires if more than 5 failed operations occur in a 15-minute window.

## Validation
- [ ] Log Analytics workspace created and receiving diagnostic data
- [ ] AMA installed on `vm-monitor01` and sending performance metrics
- [ ] KQL query against `AzureActivity` returns results
- [ ] Action group `ag-az104lab17` created with email notification
- [ ] Metric alert on CPU > 80% and log-based alert both exist

## Cleanup
1. **Resource groups** > select `rg-az104-lab17` > **Delete resource group**.

## Exam Tips
- **Diagnostic settings** route platform logs/metrics to Log Analytics, Storage (archival), or Event Hubs (streaming).
- **Metric alerts** = near-real-time, based on platform metrics (CPU, disk, network). **Log alerts** = based on KQL queries against Log Analytics, evaluated on a schedule — more flexible but higher latency.
- Action groups are reusable across alerts and support email, SMS, voice, webhook, Azure Function, Logic App, ITSM, etc.
- VM insights requires the Azure Monitor Agent (AMA) + a Data Collection Rule (DCR) — replacing the older Log Analytics/MMA agent.
