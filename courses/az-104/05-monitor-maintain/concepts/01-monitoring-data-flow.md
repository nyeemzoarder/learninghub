# Monitoring Data Flow

> Module: [05 – Monitor & Maintain](../README.md)

## Why this matters

Lab 17 touches diagnostic settings, Log Analytics, KQL, action groups, and
two kinds of alerts in one session — it's easy to lose track of how these
pieces connect. This doc lays out the pipeline so each lab step makes sense
in context.

## Core idea

Azure Monitor is the umbrella for collecting, analyzing, and acting on
telemetry (metrics and logs) from your resources. Data flows from a
**resource** → through a **collection mechanism** → into a **store** → and
can trigger an **alert** → which notifies via an **action group**.

## How it works

1. **Source data**: every resource emits **platform metrics** (e.g., CPU %,
   disk IOPS — numeric, time-series) automatically. Some also emit
   **resource logs** (e.g., storage `StorageRead`/`StorageWrite` events) —
   these require explicit configuration.
2. **Diagnostic settings**: route resource logs/metrics to one or more
   destinations:
   - **Log Analytics workspace** — queryable with KQL
   - **Storage account** — cheap, long-term archival
   - **Event Hub** — streaming to external systems
3. **VM-specific data** requires the **Azure Monitor Agent (AMA)**, installed
   via **VM Insights**, plus a **Data Collection Rule (DCR)** that defines
   what performance counters/logs to collect and where to send them.
4. **Log Analytics workspace**: stores logs as tables (e.g., `AzureActivity`,
   `Perf`) queryable with **KQL** (Kusto Query Language).
5. **Alert rules** evaluate either:
   - **Metric signals** — near-real-time, e.g., "CPU % > 80 for 5 minutes"
   - **Log signals** (scheduled query) — KQL query run on a schedule, e.g.,
     "count of failed operations > 5 in 15 minutes"
6. **Action groups**: reusable notification/automation targets (email, SMS,
   webhook, Logic App, etc.) attached to one or more alert rules.

## Example

Tracing Lab 17's setup through this pipeline:

```
vm-monitor01 (CPU metric)
   │ (built-in, no config needed)
   ▼
Metric alert "alert-high-cpu" (CPU > 80% for 5 min)
   │
   ▼
Action group "ag-az104lab17" → email notification

stoaz104lab17<unique> (StorageRead/Write logs)
   │ diagnostic setting "diag-storage17"
   ▼
Log Analytics workspace "law-az104lab17"
   │ KQL: AzureActivity | where ActivityStatusValue == "Failed" | summarize count() ...
   ▼
Log alert "alert-failed-ops" (count > 5 in 15 min)
   │
   ▼
Action group "ag-az104lab17" → email notification
```

Two different alert *types* (metric vs. log), two different *data paths*
(built-in metric vs. diagnostic-settings-routed logs), one shared
**action group**.

## Related diagram

See [monitoring-data-flow.drawio](../diagrams/monitoring-data-flow.drawio)
for a visual of this pipeline.

## Common pitfalls / exam traps

- **Metric alerts evaluate faster and don't require Log Analytics**; **log
  alerts** are more flexible (any KQL query) but run on a schedule (minimum
  ~5 minute evaluation frequency) — higher latency.
- Diagnostic settings must be configured **per resource** — enabling them on
  one storage account doesn't enable them for others.
- VM Insights/AMA + DCR is the **current** mechanism; older docs may reference
  the legacy Log Analytics (MMA) agent, which is being retired.
- An action group is reusable across **many** alert rules and resource
  types — you don't need a new one per alert.

## See also

- [Lab 17 – Azure Monitor & Alerts](../labs/lab17-azure-monitor-alerts.md)
- [Lab 18 – Backup & Recovery](../labs/lab18-backup-recovery.md)
- [Lab 19 – Network Monitoring Tools](../labs/lab19-network-monitoring.md)
- [Glossary](../../resources/glossary.md)
