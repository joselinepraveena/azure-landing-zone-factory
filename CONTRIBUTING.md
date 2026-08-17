# Contributing

1. Create a focused branch and avoid including real tenant data.
2. Run `make check`.
3. Include plan evidence and cost, policy, RBAC, and rollback impact in the pull
   request.
4. Obtain CODEOWNERS review for sensitive paths.

Terraform should remain declarative and idempotent. Add a contract test for each
new request rule and an architecture decision record for material trade-offs.
Policy enforcement must progress through audit and a representative canary.
