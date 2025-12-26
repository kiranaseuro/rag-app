output "api_endpoint" {
  value = "http://${module.compute.alb_dns_name}"
}

output "documents_bucket_name" {
  value = module.storage.documents_bucket_name
}

output "user_pool_id" {
  value = module.auth.user_pool_id
}

output "user_pool_client_id" {
  value = module.auth.user_pool_client_id
}

output "db_endpoint" {
  value = module.database.db_endpoint
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}
