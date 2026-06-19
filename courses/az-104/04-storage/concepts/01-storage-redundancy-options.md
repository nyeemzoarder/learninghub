# Storage Redundancy Options

> Module: [02 – Storage](../README.md)

## Why this matters

Every storage account creation wizard (Lab 04) asks you to pick a
**redundancy** option, and exam questions frequently describe a durability
or availability requirement and ask which option satisfies it at the lowest
cost. Picking the right one comes down to understanding what failure each
option protects against.

## Core idea

Azure Storage automatically replicates your data to protect against
hardware failures, network/power outages, and natural disasters. The options
trade off **cost** against the **scope of failure** they protect against:
a single datacenter, a region (multiple datacenters), or an entire
geography (paired regions).

## How it works

| Option | Copies | Protects against | Read access to secondary? |
|--------|--------|-------------------|----------------------------|
| **LRS** (Locally-redundant storage) | 3 copies, 1 datacenter | Disk/node/rack failure within a datacenter | No |
| **ZRS** (Zone-redundant storage) | 3 copies, 3 availability zones in the region | Datacenter-level failure (power/cooling) | No |
| **GRS** (Geo-redundant storage) | LRS in primary region + LRS copy in paired region | Regional disaster | No (unless you fail over) |
| **GZRS** (Geo-zone-redundant storage) | ZRS in primary region + LRS copy in paired region | Datacenter failure *and* regional disaster | No (unless you fail over) |
| **RA-GRS / RA-GZRS** | Same as GRS/GZRS | Same as GRS/GZRS | **Yes** — read-only endpoint to secondary region |

This builds on [region pairs and availability zones](../../00-prerequisites/concepts/01-cloud-computing-fundamentals.md#regions-region-pairs-and-availability-zones)
from the prerequisites module: ZRS uses AZs *within* a region; GRS/GZRS
replicate *across* a region pair.

## Example

A company stores customer invoices (must survive a regional disaster, and
the business wants to be able to read invoices even during a regional
outage) but doesn't need write access to the secondary copy.

- **LRS** is insufficient — a regional disaster destroys all copies.
- **GRS** protects against the regional disaster, but during an outage the
  data in the secondary region isn't *readable* until Microsoft (or the
  customer) initiates a failover.
- **RA-GRS** (or **RA-GZRS** for extra zone protection in the primary region)
  is the correct choice — it adds a read-only endpoint
  (`<account>-secondary.blob.core.windows.net`) that's available even if the
  primary region is down.

## Related diagram

See [storage-redundancy-options.drawio](../diagrams/storage-redundancy-options.drawio)
for a visual comparison of LRS/ZRS/GRS/GZRS replication scopes.

## Common pitfalls / exam traps

- **ZRS protects against datacenter failure, not regional disaster** — it
  doesn't replicate to another region.
- Switching between LRS ↔ GRS is straightforward in the Portal; converting
  to/from ZRS-based options may require a support request or account
  migration depending on region/tier.
- **RA-** prefixed options add a *read-only* secondary endpoint — they don't
  let you write to the secondary, and your application must explicitly use
  the `-secondary` endpoint to read from it.
- Redundancy choice is independent of performance tier (Standard/Premium) and
  access tier (Hot/Cool/Archive) — these are separate decisions made in the
  same wizard.

## See also

- [Lab 04 – Storage Accounts](../labs/lab04-storage-accounts.md)
- [Cloud Computing Fundamentals](../../00-prerequisites/concepts/01-cloud-computing-fundamentals.md)
- [Glossary](../../resources/glossary.md)
