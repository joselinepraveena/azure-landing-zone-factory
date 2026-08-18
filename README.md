# Azure Landing Zone Factory

Production-oriented Terraform for deploying an Azure Landing Zone foundation
and vending a governed profile onto an existing application subscription.

## What it deploys

- The current Azure Verified Pattern Module for ALZ, pinned to `0.21.0`
- Microsoft's ALZ hierarchy and policy library, pinned to `2026.04.2`
- Existing platform-subscription placement for management, connectivity,
  identity, and security
- Request-driven workload enrollment with management-group placement, mandatory
  tags, monthly budget, baseline RBAC, Activity Log diagnostics, expiry, and a
  network integration contract
- Secure, recoverable Azure Storage state bootstrap
- GitHub Actions validation, security scanning, plan, and gated apply workflows
  using Azure workload identity federation (OIDC)

Subscription creation depends on the organization's billing agreement, so the
portable implementation enrolls an existing subscription ID. Workload resources
remain owned by application teams.

## Prerequisites

- Terraform 1.12 or newer
- An Azure tenant and a deployment identity with:
  - Management Group Contributor at the chosen parent management group
  - Resource Policy Contributor at the chosen parent management group
  - permission to move each subscription supplied to the factory
  - Budget Contributor, Monitoring Contributor, Tag Contributor, and the narrow
    role-assignment permission required by approved workload profiles
- An existing Azure Storage backend for remote state

The included state bootstrap denies network access by default. Supply trusted
runner egress CIDRs or subnets, or use a private runner. A GitHub-hosted runner
cannot reach a private backend unless its network path is explicitly designed.

The deploying identity must be able to read the tenant root management group.
By default, the hierarchy is created directly below the tenant root. Set
`parent_management_group_id` to place it below another existing management
group.

## Quick start

```bash
cp environments/lab/platform.tfvars.example environments/lab/platform.tfvars
# Edit all placeholder values.

terraform -chdir=platform/alz init \
  -backend-config="resource_group_name=<state-rg>" \
  -backend-config="storage_account_name=<state-account>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=platform/lab.tfstate" \
  -backend-config="use_azuread_auth=true"

terraform -chdir=platform/alz plan \
  -var-file=../../environments/lab/platform.tfvars
```

Review the plan before applying. For a local syntax check, use `make check`;
`-backend=false` must not be used for shared deployments.

## Vend a workload subscription

Copy and edit `config/vending-requests/sample-sandbox.json`, then:

```bash
python3 scripts/validate-request.py config/vending-requests/my-app.json
terraform -chdir=platform/vending init \
  -backend-config="resource_group_name=<state-rg>" \
  -backend-config="storage_account_name=<state-account>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=vending/<subscription-id>.tfstate" \
  -backend-config="use_azuread_auth=true"
terraform -chdir=platform/vending plan \
  -var="request_file=../../config/vending-requests/my-app.json"
```

Valid destinations are `corp`, `online`, `local`, and `sandbox`. A move changes
inherited policy and access and therefore requires explicit plan review.

## GitHub configuration

Create `lab-plan` and reviewer-protected `lab-apply` environments. Configure:

### Repository variables

- `AZURE_PLAN_CLIENT_ID`
- `AZURE_APPLY_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_DEFAULT_LOCATION`
- `PLATFORM_SUBSCRIPTION_IDS_JSON`
- `TFSTATE_RESOURCE_GROUP`
- `TFSTATE_STORAGE_ACCOUNT`
- `TFSTATE_CONTAINER`

Federated credentials must match each environment and workflow subject. The plan
identity is read-only; the apply identity receives only the roles listed in the
prerequisites at its deployment scopes. No client secret is required.

Pull requests run formatting, validation, and static security checks. A
manually dispatched plan uploads a saved plan, and the apply job only runs
after approval in the selected GitHub environment.

## Design notes

Start with the [step-by-step repository guide](docs/repository-guide.md) for a
simple folder-by-folder explanation, usage instructions, and data flows. Then
review [the architecture walkthrough](docs/architecture/overview.md),
[ADR 0001](docs/decisions/0001-use-avm-alz.md), and the
[operations runbook](docs/runbooks/operations.md).

## Safety

- Start in a non-production tenant or below a dedicated parent management group.
- Never commit state, plan files, credentials, or populated local `.tfvars`.
- Commit generated provider lock files after initialization.
- Treat management-group moves and policy changes as privileged operations.
- ALZ policy starts from the upstream baseline; test changes in audit/canary
  before enabling deny effects.
