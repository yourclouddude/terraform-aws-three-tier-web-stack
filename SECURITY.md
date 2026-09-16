# Security Policy

## Reporting a vulnerability

Please do **not** open a public GitHub issue for a suspected security vulnerability.

If GitHub private vulnerability reporting is available for this repository, use **Security → Report a vulnerability**. Otherwise, contact YourCloudDude through https://yourclouddude.com/ with enough detail to reproduce and assess the issue safely.

Please include:

- the affected module, resource, or file
- a clear description of the vulnerability or unsafe configuration
- steps to reproduce it
- the potential impact
- any suggested mitigation, if you have one

Do not include real AWS credentials, Terraform state, access tokens, customer data, or other secrets in a report.

## Scope

This repository is a learning project, not a managed production platform. Reports about public exposure, IAM, network boundaries, secret handling, Terraform state, encryption, or unsafe defaults are useful when they identify a concrete issue in the repository.

## Supported versions

Security fixes are applied to the current `main` branch. Older commits and forks are not maintained as separately supported releases.
