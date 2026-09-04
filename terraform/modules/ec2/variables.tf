variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet for the application EC2"
  type        = string
}

variable "app_security_group_id" {
  description = "Application security group ID"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}
