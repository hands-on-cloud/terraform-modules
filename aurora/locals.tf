locals {
  aws_account_id                  = data.aws_caller_identity.current.account_id
  cluster_identifier              = "${local.prefix}-cluster"
  cluster_parameter_group_family  = var.cluster_parameter_group_family
  cluster_parameter_group_name    = replace("${local.prefix}-group", "[^a-z0-9.-]", "-")
  cluster_security_group_name     = local.prefix
  cluster_max_capacity            = var.cluster_max_capacity
  cluster_min_capacity            = var.cluster_min_capacity
  db_name                         = var.db_name
  db_username                     = var.username
  db_password                     = random_password.password.result
  db_subnet_group_name            = replace("${local.prefix}-group", "[^a-z0-9._-]", "-")
  db_parameters                   = var.db_parameters
  engine                          = var.engine
  engine_mode                     = var.engine_mode == "serverless" ? "serverless" : "provisioned"
  engine_version                  = var.engine_version
  prefix                          = replace("${local.engine}-${local.engine_mode}-${local.db_name}-${local.random_id}", "[^a-z0-9-]", "-")
  random_id                       = random_id.id.hex
  secretsmanager_secret_name      = local.prefix
  seconds_until_auto_pause        = var.seconds_until_auto_pause
  tags                            = var.tags
  vpc_security_group_ids          = var.vpc_security_group_ids
  vpc_id                          = var.vpc_id
  vpc_subnet_ids                  = var.vpc_subnet_ids
}