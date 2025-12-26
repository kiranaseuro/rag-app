locals {
  lambda_package_dir = "${path.root}/../../dist"
}

module "rag_core" {
  count  = var.use_case == "rag-core" ? 1 : 0
  source = "../../use_cases/rag-core"

  project_name        = var.project_name
  environment         = var.environment
  lambda_package_dir  = local.lambda_package_dir
  db_username         = var.db_username
  db_password         = var.db_password
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  allowed_cidrs       = var.allowed_cidrs
  force_destroy       = var.force_destroy
  tags                = var.tags
}

module "rag_with_eval" {
  count  = var.use_case == "rag-with-eval" ? 1 : 0
  source = "../../use_cases/rag-with-eval"

  project_name        = var.project_name
  environment         = var.environment
  lambda_package_dir  = local.lambda_package_dir
  db_username         = var.db_username
  db_password         = var.db_password
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  allowed_cidrs       = var.allowed_cidrs
  force_destroy       = var.force_destroy
  tags                = var.tags
}

locals {
  selected_api_endpoint = var.use_case == "rag-core" ? module.rag_core[0].api_endpoint : module.rag_with_eval[0].api_endpoint
  selected_documents_bucket = var.use_case == "rag-core" ? module.rag_core[0].documents_bucket_name : module.rag_with_eval[0].documents_bucket_name
  selected_user_pool_id = var.use_case == "rag-core" ? module.rag_core[0].user_pool_id : module.rag_with_eval[0].user_pool_id
  selected_user_pool_client_id = var.use_case == "rag-core" ? module.rag_core[0].user_pool_client_id : module.rag_with_eval[0].user_pool_client_id
  selected_db_endpoint = var.use_case == "rag-core" ? module.rag_core[0].db_endpoint : module.rag_with_eval[0].db_endpoint
  selected_alerts_topic = var.use_case == "rag-core" ? module.rag_core[0].alerts_topic_arn : module.rag_with_eval[0].alerts_topic_arn
}

output "api_endpoint" {
  value = local.selected_api_endpoint
}

output "documents_bucket_name" {
  value = local.selected_documents_bucket
}

output "user_pool_id" {
  value = local.selected_user_pool_id
}

output "user_pool_client_id" {
  value = local.selected_user_pool_client_id
}

output "db_endpoint" {
  value = local.selected_db_endpoint
}

output "alerts_topic_arn" {
  value = local.selected_alerts_topic
}
