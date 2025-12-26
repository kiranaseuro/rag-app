variable "project_name" {
  type = string
  default = "sample-rag"
}

variable "environment" {
  type = string
}

variable "use_case" {
  type = string
  default = "rag-core"
}

variable "aws_region" {
  type = string
}

variable "db_username" {
  type = string
  default = "raguser"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "change-me"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "allowed_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/8"]
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
