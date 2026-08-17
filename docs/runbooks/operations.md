# Operations runbook

## Failed vending

1. Preserve the failed workflow and Terraform plan logs.
2. Determine whether failure occurred before or after subscription placement.
3. Correct the versioned request or identity permissions; do not patch resources
   manually unless incident response requires it.
4. Re-run plan against the same subscription state key and verify no unexpected
   replacement or deletion before applying.

## Subscription move

Management-group moves change inherited policy and access. Plan from both the
source and destination control perspectives, validate policy impact with Azure
Policy Insights, notify the owner, and perform the move through a reviewed
request. Do not move a subscription with active remediation without accounting
for the remediation identity.

## Policy impact or rollback

Keep new controls in audit mode until canary evidence is reviewed. For an
incident caused by enforcement, disable or change the assignment through the
same ALZ configuration and protected workflow. Record any emergency portal
change, then import or reconcile it immediately to remove drift.

## State recovery

1. Stop applies for the affected root.
2. Inspect blob versions and leases; never copy state into an issue or chat.
3. Restore the last known-good blob version under change control.
4. Run `terraform plan -refresh-only`, then a normal plan.
5. Resume applies only when the plan matches the known Azure inventory.

## Exemption

This repository does not silently bypass policy. Record owner, business reason,
scope, compensating control, approval, and expiration in the governance
repository. Review expiring exemptions before extending them.

## Decommission

1. Confirm owner approval, retention obligations, locks, backups, and billing.
2. Remove network attachments and workload data through workload-owned code.
3. Move the empty subscription to `decommissioned`.
4. Preserve required logs and state, then cancel the subscription through the
   billing process. Removing a request alone does not cancel a subscription.
