variable "aws_region" {
  description = "AWS Region used for the learning stack."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short project name used in AWS resource names and tags."
  type        = string
  default     = "ycd-three-tier"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment label used in names and tags."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type for the application tier."
  type        = string
  default     = "t3.micro"
}

variable "app_desired_capacity" {
  description = "Desired number of application instances."
  type        = number
  default     = 2

  validation {
    condition     = var.app_desired_capacity >= 1 && var.app_desired_capacity <= 4
    error_message = "app_desired_capacity must be between 1 and 4 for this learning stack."
  }
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Initial PostgreSQL database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "RDS master username. The password is managed by RDS in Secrets Manager."
  type        = string
  default     = "appadmin"
}
