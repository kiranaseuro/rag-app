variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "lambda_invoke_arns" {
  type = map(string)
}

variable "lambda_function_names" {
  type = map(string)
}

variable "routes" {
  type = map(object({
    method     = string
    path       = string
    lambda_key = string
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
