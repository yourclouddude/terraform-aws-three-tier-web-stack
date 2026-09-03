variable "alb_security_group_id" {
  type = string
}

variable "app_security_group_id" {
  type = string
}

variable "app_subnet_ids" {
  type = list(string)
}

variable "db_host" {
  type = string
}

variable "db_port" {
  type = number
}

variable "desired_capacity" {
  type = number
}

variable "instance_type" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}
