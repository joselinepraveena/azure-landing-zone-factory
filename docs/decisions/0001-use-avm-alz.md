# ADR 0001: Use the Azure Verified ALZ pattern

- Status: Accepted
- Date: 2026-08-17

## Context

A hand-built hierarchy is easy to demonstrate but shifts policy-library updates,
dependency ordering, and Azure API edge cases onto the local platform team.
Microsoft recommends the Azure Verified Pattern Module for new Terraform ALZ
implementations.

## Decision

Use `Azure/avm-ptn-alz/azurerm` pinned to `0.21.0` and the Microsoft ALZ library
pinned to `2026.04.2`. Keep tenant-specific subscription placement and workload
profiles in thin local composition roots.

## Consequences

The factory receives an upstream-reviewed hierarchy and policy baseline and can
upgrade deliberately. Module upgrades require release-note review and a tenant
canary plan. Standard management-group IDs can conflict with an existing ALZ;
brownfield tenants must inventory first and may need a custom architecture
library rather than applying this root unchanged.
