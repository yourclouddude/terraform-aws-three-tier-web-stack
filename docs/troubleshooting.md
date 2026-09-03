# Troubleshooting

## Terraform says there are not enough Availability Zones

The root configuration selects two available zones from the chosen Region. Use an AWS Region with at least two available zones for your account.

## The ALB returns 503

A 503 from the ALB usually means there are no healthy targets.

Check these in order:

1. EC2 instances exist in the Auto Scaling group.
2. target health shows why instances are unhealthy.
3. the application security group allows port 8080 from the ALB security group.
4. the ALB security group allows egress to the application security group on port 8080.
5. the launch-template user data completed and the `yourclouddude-demo` systemd service started.

The private instances have no SSH rule by design. Do not add `0.0.0.0/0` SSH as a debugging shortcut.

## The page loads but says the database is not reachable

That means the web process is healthy but its TCP check to PostgreSQL failed.

Check:

- RDS is in the `available` state.
- the RDS endpoint can be resolved through VPC DNS.
- application egress allows TCP 5432 to the database security group.
- database ingress allows TCP 5432 from the application security group.

This symptom is intentionally different from an unhealthy ALB target.

## The EC2 instances cannot download packages

That is expected. The application subnets have no NAT gateway or other default internet route.

The base application does not need package installation. If your extension needs outbound access, add the smallest egress design that meets the requirement: a relevant VPC endpoint, NAT, or another deliberate path. Document the cost and security impact.

## I cannot SSH to an instance

Also expected. The base architecture has no port 22 ingress and the instances have no public IP addresses.

A better extension is to design private management access with Systems Manager and the required VPC endpoints or controlled egress, then grant only the IAM permissions that path needs.

## RDS creation takes a long time

RDS is usually the slowest resource in this stack. Terraform may wait several minutes while the database is created or deleted. Do not interrupt the run only because EC2 and the ALB completed first.

## Terraform wants a database password

It should not. The database module uses RDS-managed master credentials with Secrets Manager.

If you changed the module to accept a plaintext `password` argument, reconsider that design before committing the change.

## Destroy fails because resources are still referenced

Wait for Auto Scaling and load-balancer dependencies to detach. Then run:

```bash
terraform destroy
```

again and read the exact dependency error before manually deleting resources.

Avoid mixing manual deletions with Terraform unless you understand how the state will be reconciled.

## I want remote state

Copy the pattern from `backend.tf.example`, create the backend resources separately, and replace the placeholders. Do not commit local `.tfstate` files or backend credentials.

## CI fails on formatting

Run:

```bash
terraform fmt -recursive
```

Review the diff, then rerun:

```bash
terraform fmt -check -recursive
terraform validate
bash scripts/security_guardrails.sh
```
