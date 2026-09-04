resource "aws_security_group" "alb" {
  name_prefix            = "${local.name_prefix}-alb-"
  description            = "Public ALB boundary"
  revoke_rules_on_delete = true
  vpc_id                 = module.network.vpc_id

  tags = {
    Name = "${local.name_prefix}-alb"
  }
}

resource "aws_security_group" "app" {
  name_prefix            = "${local.name_prefix}-app-"
  description            = "Private application tier boundary"
  revoke_rules_on_delete = true
  vpc_id                 = module.network.vpc_id

  tags = {
    Name = "${local.name_prefix}-app"
  }
}

resource "aws_security_group" "database" {
  name_prefix            = "${local.name_prefix}-db-"
  description            = "Private database tier boundary"
  revoke_rules_on_delete = true
  vpc_id                 = module.network.vpc_id

  tags = {
    Name = "${local.name_prefix}-db"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80

  description = "Public HTTP entry point"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080

  description = "ALB traffic to application tier"
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080

  description = "Application traffic from ALB only"
}

resource "aws_vpc_security_group_egress_rule" "app_to_database" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.database.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432

  description = "PostgreSQL traffic to database tier"
}

resource "aws_vpc_security_group_egress_rule" "app_dns_udp" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "${cidrhost(var.vpc_cidr, 2)}/32"
  from_port         = 53
  ip_protocol       = "udp"
  to_port           = 53

  description = "VPC resolver lookups over UDP"
}

resource "aws_vpc_security_group_egress_rule" "app_dns_tcp" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "${cidrhost(var.vpc_cidr, 2)}/32"
  from_port         = 53
  ip_protocol       = "tcp"
  to_port           = 53

  description = "VPC resolver lookups over TCP"
}

resource "aws_vpc_security_group_ingress_rule" "database_from_app" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432

  description = "PostgreSQL from application tier only"
}
