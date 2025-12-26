locals {
  functions = {
    auth_handler = {
      filename    = "${var.lambda_package_dir}/auth_handler.zip"
      handler     = "app.handler"
      runtime     = "python3.11"
      memory_size = 256
      timeout     = 10
      environment = {
        STAGE = var.environment
      }
    }
    upload_handler = {
      filename    = "${var.lambda_package_dir}/upload_handler.zip"
      handler     = "app.handler"
      runtime     = "python3.11"
      memory_size = 512
      timeout     = 30
      environment = {
        STAGE = var.environment
      }
    }
    query_handler = {
      filename    = "${var.lambda_package_dir}/query_handler.zip"
      handler     = "app.handler"
      runtime     = "python3.11"
      memory_size = 512
      timeout     = 30
      environment = {
        STAGE = var.environment
      }
    }
    document_processor = {
      filename    = "${var.lambda_package_dir}/document_processor.zip"
      handler     = "app.handler"
      runtime     = "python3.11"
      memory_size = 512
      timeout     = 60
      environment = {
        STAGE = var.environment
      }
    }
    db_init = {
      filename    = "${var.lambda_package_dir}/db_init.zip"
      handler     = "app.handler"
      runtime     = "python3.11"
      memory_size = 256
      timeout     = 60
      environment = {
        STAGE = var.environment
      }
    }
    evaluation_handler = {
      filename    = "${var.lambda_package_dir}/evaluation_handler.zip"
      handler     = "app.handler"
      runtime     = "python3.11"
      memory_size = 256
      timeout     = 30
      environment = {
        STAGE = var.environment
      }
    }
  }

  routes = {
    auth = {
      method     = "POST"
      path       = "/auth"
      lambda_key = "auth_handler"
    }
    upload = {
      method     = "POST"
      path       = "/upload"
      lambda_key = "upload_handler"
    }
    query = {
      method     = "POST"
      path       = "/query"
      lambda_key = "query_handler"
    }
    evaluate = {
      method     = "POST"
      path       = "/evaluate"
      lambda_key = "evaluation_handler"
    }
  }
}

module "network" {
  source = "../../modules/network"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  tags                 = var.tags
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

  project_name = var.project_name
  environment  = var.environment
  functions    = local.functions
  tags         = var.tags
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
  subnet_ids     = module.network.public_subnet_ids
  allowed_cidrs  = var.allowed_cidrs
  db_username    = var.db_username
  db_password    = var.db_password
  tags           = var.tags
}

module "api" {
  source = "../../modules/api"

  project_name           = var.project_name
  environment            = var.environment
  lambda_invoke_arns      = module.compute.lambda_invoke_arns
  lambda_function_names   = module.compute.lambda_function_names
  routes                 = local.routes
  tags                   = var.tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_name          = var.project_name
  environment           = var.environment
  lambda_function_names = module.compute.lambda_function_names
  tags                  = var.tags
}
