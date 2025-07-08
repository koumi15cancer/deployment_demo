variable "aws_region" {
  default = "ap-southeast-1"
}

variable "vpc_id" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "alb_security_group_id" {}
variable "ecs_service_sg_id" {}