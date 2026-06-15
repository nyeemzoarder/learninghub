# Module 05 – Monitor & Maintain

> Part of the [AZ-104 course](../README.md).

## Before you start

- [Networking Basics](../00-prerequisites/02-networking-basics.md) — useful
  for Lab 19 (Network Watcher tools build on routing/IP concepts)
- [Module 04 – Networking](../04-networking/README.md) — Lab 19 reuses
  VNet/NSG concepts from this module

## Learning objectives

By the end of this module you should be able to:
- Configure diagnostic settings to route logs/metrics to Log Analytics
- Write basic KQL queries against activity logs and VM performance data
- Create metric-based and log-based alert rules with action groups
- Create a Recovery Services vault, run VM backups, and restore a VM/disk
- Describe Azure Site Recovery's failover/failback workflow and RPO/RTO
- Use Network Watcher tools (Connection Troubleshoot, IP flow verify, Next
  hop, Packet Capture, NSG flow logs/Traffic Analytics)

## Concepts

- [Monitoring Data Flow](concepts/01-monitoring-data-flow.md) — how
  diagnostic settings, Log Analytics, and alerts fit together
- Backup vs. Site Recovery — *TODO*
- Network Watcher Toolset — *TODO*

## Diagrams

- [Monitoring Data Flow](diagrams/monitoring-data-flow.drawio) — open in
  [diagrams.net](https://app.diagrams.net) (File > Open from > Device)

## Labs

Work through in order — later labs may reuse resources from earlier ones:

1. [Lab 17 – Azure Monitor & Alerts](labs/lab17-azure-monitor-alerts.md)
2. [Lab 18 – Backup & Recovery](labs/lab18-backup-recovery.md)
3. [Lab 19 – Network Monitoring Tools](labs/lab19-network-monitoring.md)

## Exam domain

Maps to **Monitor and maintain Azure resources (10–15%)** — see the
[exam blueprint](../resources/exam-blueprint.md) for the full breakdown.
