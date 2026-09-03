#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "security guardrail failed: $1" >&2
  exit 1
}

if grep -R -E 'associate_public_ip_address[[:space:]]*=[[:space:]]*true' --include='*.tf' .; then
  fail "EC2 public IP assignment must stay disabled"
fi

if grep -R -E 'publicly_accessible[[:space:]]*=[[:space:]]*true' --include='*.tf' .; then
  fail "RDS must not be publicly accessible"
fi

if grep -R -E '(from_port|to_port)[[:space:]]*=[[:space:]]*22' --include='*.tf' .; then
  fail "SSH ingress is not part of the base architecture"
fi

world_cidr_rules=$( (grep -R -E 'cidr_ipv4[[:space:]]*=[[:space:]]*"0\.0\.0\.0/0"' --include='*.tf' . || true) | wc -l | tr -d ' ' )
if [[ "${world_cidr_rules}" != "1" ]]; then
  fail "expected exactly one internet-wide security-group rule for ALB HTTP ingress"
fi

if ! grep -q 'http_tokens[[:space:]]*=[[:space:]]*"required"' modules/web/main.tf; then
  fail "launch template must require IMDSv2"
fi

if ! grep -q 'storage_encrypted[[:space:]]*=[[:space:]]*true' modules/database/main.tf; then
  fail "RDS storage encryption must remain enabled"
fi

if ! grep -q 'manage_master_user_password[[:space:]]*=[[:space:]]*true' modules/database/main.tf; then
  fail "RDS must manage the master password instead of storing one in Terraform variables"
fi

if grep -R -E '^[[:space:]]*password[[:space:]]*=' --include='*.tf' .; then
  fail "do not place database passwords directly in Terraform resources"
fi

echo "Repository-specific security guardrails passed."
