variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "engine_mode" {
  description = "The database engine mode"
  type        = string
  default     = "serverless"
}

variable "engine" {
  description = "The database engine"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version" {
  description = "The database engine version"
  type        = string
  default     = "13.12"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_subnet_ids" {
  description = "List of VPC subnet IDs"
  type        = list(string)
}

variable "cluster_parameter_group_family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = "aurora-postgresql13"
}

variable "vpc_security_group_ids" {
  description = "When provided, the module will allow traffic from provided security groups to the cluster"
  type        = list(string)
  default     = []
}

variable "db_parameters" {
  description = "List of custom DB parameters"
  type        = list(map(string))
  default     = []
}

variable "username" {
  description = "Username for the database"
  type        = string
  default     = "postgres"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    Terraform   = "true"
    Environment = "dev"
  }
}

variable "cluster_min_capacity" {
  description = "The minimum capacity for the cluster"
  type        = number
  default     = 2
}

variable "cluster_max_capacity" {
  description = "The maximum capacity for the cluster"
  type        = number
  default     = 8
}

variable "seconds_until_auto_pause" {
  description = "The number of seconds before the cluster is paused"
  type        = number
  default     = 300
}
