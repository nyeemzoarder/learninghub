# Module 04 – Networking

> Part of the [AZ-104 course](../README.md).

## Before you start

- [Networking Basics](../00-prerequisites/02-networking-basics.md) — IP
  addressing, CIDR notation, subnets, DNS, and routing. This module assumes
  you're comfortable with all of it.

## Learning objectives

By the end of this module you should be able to:
- Create a VNet with multiple subnets, configure service/private endpoints,
  and plan address spaces
- Create and associate NSGs/ASGs, understand rule priority and default rules,
  and use diagnostics tools to verify effective rules
- Peer VNets and configure a Site-to-Site VPN gateway
- Deploy a Load Balancer (Layer 4) and Application Gateway (Layer 7) and know
  when to use each
- Create public and private DNS zones, configure autoregistration, and
  understand Azure-provided DNS

## Concepts

- [Hub-Spoke Topology](concepts/01-hub-spoke-topology.md) — the standard
  Azure network architecture pattern
- NSG Rule Evaluation — *TODO*
- Load Balancer vs. Application Gateway — *TODO*

## Diagrams

- [Hub-Spoke Topology](diagrams/hub-spoke-topology.drawio) — open in
  [diagrams.net](https://app.diagrams.net) (File > Open from > Device)

## Labs

Work through in order — later labs may reuse resources from earlier ones:

1. [Lab 12 – VNets & Subnets](labs/lab12-vnet-subnets.md)
2. [Lab 13 – NSGs & ASGs](labs/lab13-nsg-asg.md)
3. [Lab 14 – VNet Peering & VPN Gateway](labs/lab14-vnet-peering-vpn.md)
4. [Lab 15 – Load Balancer & Application Gateway](labs/lab15-load-balancer-app-gateway.md)
5. [Lab 16 – DNS & Name Resolution](labs/lab16-dns-name-resolution.md)

## Exam domain

Maps to **Implement and manage virtual networking (15–20%)** — see the
[exam blueprint](../resources/exam-blueprint.md) for the full breakdown.
