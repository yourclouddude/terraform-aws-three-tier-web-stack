module "network" {
  source = "./modules/network"

  availability_zones = local.availability_zones
  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
}

module "database" {
  source = "./modules/database"

  db_name           = var.db_name
  db_username       = var.db_username
  instance_class    = var.db_instance_class
  name_prefix       = local.name_prefix
  security_group_id = aws_security_group.database.id
  subnet_ids        = module.network.database_subnet_ids
}

module "web" {
  source = "./modules/web"

  alb_security_group_id = aws_security_group.alb.id
  app_security_group_id = aws_security_group.app.id
  app_subnet_ids        = module.network.application_subnet_ids
  db_host               = module.database.address
  db_port               = module.database.port
  desired_capacity      = var.app_desired_capacity
  instance_type         = var.instance_type
  name_prefix           = local.name_prefix
  public_subnet_ids     = module.network.public_subnet_ids
  vpc_id                = module.network.vpc_id
}
