# Security policy

## Reporting

Do not open a public issue for a vulnerability or exposed credential. Use the
repository owner's private security-reporting channel.

## Repository expectations

- Never commit Azure credentials, client secrets, certificates, tokens, state,
  saved plans, private tenant inventory, or real incident data.
- Use GitHub OIDC federation with separate narrowly scoped plan and apply
  identities.
- Require review for workflows, bootstrap, ALZ, policy, and RBAC changes.
- Treat subscription moves, policy enforcement, and role assignments as
  privileged operations.
- Pin dependencies and review upstream release notes before upgrades.

Only the latest release on `main` is supported. Security fixes are delivered by
pull request and a new repository release.
