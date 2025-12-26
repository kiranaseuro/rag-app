variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "ecs_task_sg_id" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "container_port" {
  type    = number
  default = 8000
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "container_image" {
  type    = string
  default = "nginx:latest" # Placeholder until user provides ZIP/Docker image
}

variable "tags" {
  type    = map(string)
  default = {}
}
