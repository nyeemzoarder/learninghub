# Cheat Sheets

> Part of the [AZ-104 course](../../README.md).

Quick-reference tables for facts that are easy to mix up. Add more here as
you work through the modules.

## Storage redundancy (Module 02)

| Option | Datacenter failure | Zone failure | Regional disaster | Read access to secondary |
|--------|---------------------|--------------|--------------------|----------------------------|
| LRS | ✅ | ❌ | ❌ | — |
| ZRS | ✅ | ✅ | ❌ | — |
| GRS | ✅ | ❌ | ✅ | ❌ |
| GZRS | ✅ | ✅ | ✅ | ❌ |
| RA-GRS | ✅ | ❌ | ✅ | ✅ |
| RA-GZRS | ✅ | ✅ | ✅ | ✅ |

See [Storage Redundancy Options](../../02-storage/concepts/01-storage-redundancy-options.md).

## NSG default rules (Module 04)

| Direction | Priority | Source | Destination | Access |
|-----------|----------|--------|-------------|--------|
| Inbound | 65000 | VirtualNetwork | VirtualNetwork | Allow |
| Inbound | 65001 | AzureLoadBalancer | Any | Allow |
| Inbound | 65500 | Any | Any | Deny |
| Outbound | 65000 | VirtualNetwork | VirtualNetwork | Allow |
| Outbound | 65001 | Any | Internet | Allow |
| Outbound | 65500 | Any | Any | Deny |

Lower priority number = evaluated first. Custom rules (priority 100–4096)
are evaluated before these defaults. See
[Lab 13 – NSGs & ASGs](../../04-networking/labs/lab13-nsg-asg.md).

## Azure Monitor: metric vs. log alerts (Module 05)

| | Metric alert | Log alert (scheduled query) |
|---|---------------|-------------------------------|
| Data source | Platform metrics | Log Analytics (KQL) |
| Latency | Near real-time | Minutes (eval frequency) |
| Flexibility | Limited to available metrics | Any KQL query |

See [Monitoring Data Flow](../../05-monitor-maintain/concepts/01-monitoring-data-flow.md).
