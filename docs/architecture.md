# Architecture Notes

This stack is intentionally small enough that every network rule can be explained without hiding behind a diagram.

## Traffic contracts

The public boundary is the Application Load Balancer. Its security group accepts HTTP on port 80 from the internet. Nothing else does.

The ALB can send traffic only to the application security group on port 8080. The EC2 instances sit in private application subnets and do not receive public IP addresses.

The application security group can reach PostgreSQL on port 5432 and can use DNS inside the VPC. It has no general internet egress rule.

RDS sits in separate database subnets and accepts PostgreSQL traffic only from the application security group. `publicly_accessible` is disabled.

That makes the useful mental model:

```text
Internet
   |
   v :80
  ALB
   |
   v :8080
 EC2 ASG
   |
   v :5432
  RDS
```

Security groups are used as identities between tiers instead of copying private CIDR ranges into every rule.

## Why three subnet groups?

The public, application, and database subnets make routing intent visible even though the base application and database route tables contain only the VPC-local route.

The public subnets have a default route to the Internet Gateway so the internet-facing ALB can operate there. The private tiers do not have a NAT route.

This is stricter than putting EC2 in a public subnet and relying only on security groups, and it makes accidental internet dependencies easier to notice.

## Why no NAT in the base version?

NAT is useful when private workloads genuinely need internet egress. It is not free architecture decoration.

The demo service uses the Python runtime available on the selected Amazon Linux 2023 AMI, so startup does not need package downloads. Leaving NAT out removes an hourly/data-processing cost and forces later features to make their outbound dependency explicit.

If you add Systems Manager, package repositories, third-party APIs, or telemetry exporters, choose between NAT and purpose-built VPC endpoints based on the traffic and operational requirement.

## Health checks are not dependency checks

`/health` returns success when the HTTP process is running. It does not fail merely because PostgreSQL is unavailable.

The main page performs a separate TCP connection attempt to the RDS endpoint. This lets a learner break the database path and see the difference between:

- a dead application instance
- a healthy application instance with an unavailable dependency

Production health strategy depends on how tightly a service should be coupled to its dependencies, but treating every dependency failure as an immediate instance failure can create avoidable cascading replacement.

## Database credentials

The RDS resource uses `manage_master_user_password = true`. AWS manages the master password in Secrets Manager instead of requiring a password value in source-controlled variables or EC2 user data.

The base web process does not consume that secret because it only demonstrates network reachability. A real SQL extension should add an instance role with access to one specific secret and fetch credentials at runtime. Do not solve the exercise by copying the password into Terraform variables, user data, or the repository.

## Availability and scaling

The VPC spans two Availability Zones. The ALB uses both public subnets and the Auto Scaling group can place instances across both application subnets.

The default desired application capacity is two. A target-tracking policy aims for 60% average CPU utilization and can scale the group up to four instances.

RDS is intentionally single-AZ in this learning configuration to keep the cost and failure model obvious. Turning on Multi-AZ changes cost, failover behavior, and recovery expectations and should be treated as an explicit architecture decision.

## Observability

The stack creates a CloudWatch alarm for unhealthy ALB targets. It has no notification action by default, because routing alarms to email, chat, or incident tooling is an environment-specific decision.

Useful next signals include target response time, target 5xx errors, ASG capacity, RDS CPU/storage, and database connections.

## Failure experiments

A few changes are especially useful because the failure is easy to reason about:

- remove ALB egress to the app tier and inspect target health
- remove app ingress from the ALB and compare the symptom
- remove app egress to PostgreSQL and watch the main page report the database path as unavailable while `/health` stays green
- reduce desired capacity to one and discuss the difference between a multi-AZ network and a multi-instance application
- enable Multi-AZ RDS and compare the Terraform plan and monthly cost drivers

## Cost boundaries

The most persistent costs in the default stack are the ALB, EC2 instances, and RDS instance/storage. CloudWatch alarms can also create a small recurring charge.

The repository does not publish a fixed monthly price because AWS Region, instance choice, runtime, data transfer, and pricing change the answer. Use the current AWS pricing pages or the AWS Pricing Calculator before applying a long-lived environment.
