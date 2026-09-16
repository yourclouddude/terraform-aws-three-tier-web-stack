## What changed?

Describe the infrastructure or documentation change and the problem it solves.

## Why this approach?

Explain any VPC, routing, security-group, EC2, ALB, RDS, secret-management, state, or cost trade-offs introduced by the change.

## Validation

- [ ] `terraform fmt -check -recursive`
- [ ] `terraform init -backend=false`
- [ ] `terraform validate`
- [ ] `bash scripts/security_guardrails.sh`
- [ ] No credentials, state files, plan files, or secrets were committed

## Risk / rollback

Describe resources that may be replaced, destroyed, exposed, or made unreachable and how the change can be reverted safely.

## Documentation

- [ ] README/docs updated when architecture or operational behavior changed
- [ ] No documentation change needed
