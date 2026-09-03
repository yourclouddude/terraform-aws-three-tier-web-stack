resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name_prefix}-db"
  }
}

resource "aws_db_instance" "this" {
  identifier = substr("${var.name_prefix}-postgres", 0, 63)

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  engine         = "postgres"
  engine_version = "16"
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.db_username
  port     = 5432

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 1
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot       = true

  deletion_protection = false
  skip_final_snapshot  = true
  apply_immediately    = true

  performance_insights_enabled = false

  tags = {
    Name = "${var.name_prefix}-postgres"
    Tier = "database"
  }
}
