project_name = "sample-rag"
use_case     = "rag-core"
db_username  = "raguser"
db_password  = "change-me"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

tags = {
  owner       = "platform-team"
  cost_center = "rag"
}
