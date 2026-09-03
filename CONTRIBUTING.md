# Contributing

This repository is a focused learning architecture, so changes should make a real engineering idea clearer rather than simply add more AWS services.

Before opening a pull request:

```bash
terraform fmt -recursive
terraform init -backend=false
terraform validate
bash scripts/security_guardrails.sh
```

Keep these boundaries intact unless your change is explicitly about redesigning them:

- only the ALB is internet-facing
- EC2 instances stay private and have no SSH ingress
- RDS stays private
- application-to-database access uses security-group references
- secrets do not belong in Terraform files, user data, examples, or Git history
- new services need a documented reason, cost, permission boundary, and failure mode

Documentation should explain the decision being made, not just restate Terraform arguments. Avoid fake production claims, invented benchmarks, or generic architecture boilerplate.
