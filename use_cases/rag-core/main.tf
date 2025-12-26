module "network" {
  source = "../../modules/network"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = var.tags
}

module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
}

module "storage" {
  source = "../../modules/storage"

  project_name   = var.project_name
  environment    = var.environment
  force_destroy  = var.force_destroy
  tags           = var.tags
}

module "compute" {
  source = "../../modules/compute"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  public_subnet_ids  = module.network.public_subnet_ids
  ecs_task_sg_id     = module.network.ecs_task_sg_id
  alb_sg_id          = module.network.alb_sg_id
  tags               = var.tags
}

module "auth" {
  source = "../../modules/auth"

  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
}

module "database" {
  source = "../../modules/database"

  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.network.vpc_id
  subnet_ids     = module.network.private_subnet_ids # Databases in private subnets
  allowed_cidrs  = var.allowed_cidrs
  db_username    = var.db_username
  db_password    = var.db_password
  tags           = var.tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_name          = var.project_name
  environment           = var.environment
  # Update monitoring to use ECS service name instead of Lambda
  lambda_function_names = [module.compute.service_name] 
  tags                  = var.tags
}
