variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "lambda_package_dir" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
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
