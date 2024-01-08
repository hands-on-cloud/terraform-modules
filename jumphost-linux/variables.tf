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

variable "ec2_instance_type" {
  type        = string
  description = "EC2 Instance Type"
  default     = "m5.large"
}

variable "ec2_volume_size" {
  type        = number
  description = "EC2 Volume Size"
  default     = 50
}

variable "ec2_enhanced_monitoring" {
  type        = bool
  description = "Enable enhanced monitoring"
  default     = false
}

variable "ec2_associate_public_ip_address" {
  type        = bool
  description = "Associate public IP address"
  default     = false
}
