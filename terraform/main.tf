module "networking" {
  source = "./modules/vpc"

  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
}

module "security-groups" {
  source = "./modules/security-groups"

  vpc_id       = module.networking.vpc_id
  project_name = var.project_name
  app_port     = var.app_port
}

module "ec2" {
  source = "./modules/ec2"

  instance_type         = var.instance_type
  private_subnet_id     = module.networking.private_subnet_id
  app_security_group_id = module.security.app_security_group_id
  project_name          = var.project_name
}

module "rds" {
  source = "./modules/rds"

  project_name          = var.project_name
  private_subnet_ids    = module.networking.private_subnet_ids
  rds_security_group_id = module.security.rds_security_group_id
  db_password           = var.db_password
}

module "alb" {
  source = "./modules/alb"

  project_name          = var.project_name
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  vpc_id                = module.networking.vpc_id
  app_port              = var.app_port
  instance_id           = module.compute.instance_id
}
