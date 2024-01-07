variable "prefix" {
  type        = string
  description = "Prefix for resources created by this module"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    Terraform   = "true"
    Environment = "dev"
  }
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "vpc_subnet_id" {
  type        = string
  description = "VPC Subnet ID"
}

variable "ec2_policy_name" {
  type        = string
  description = "EC2 Policy Name"
  default     = "AdministratorAccess"
}
