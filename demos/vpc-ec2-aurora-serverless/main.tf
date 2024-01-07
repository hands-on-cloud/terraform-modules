locals {
  db_name = "${local.prefix}-db"

  prefix = "aurora-demo"

  vpc_azs   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_cidr = "10.0.0.0/16"
  vpc_enable_nat_gateway     = true
  vpc_name = "${local.prefix}-vpc"
  vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  vpc_public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  vpc_single_nat_gateway     = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = local.vpc_azs
  private_subnets = local.vpc_private_subnets
  public_subnets  = local.vpc_public_subnets

  enable_nat_gateway = local.vpc_enable_nat_gateway
  single_nat_gateway = local.vpc_single_nat_gateway

  tags = local.tags
}

module "aurora" {
  source = "../../aurora"

  db_name = local.db_name

  # aws rds describe-db-engine-versions --engine aurora-postgresql --filters Name=engine-mode,Values=serverless --output text --query "DBEngineVersions[].EngineVersion"
  engine_version = "13.12"
  engine_mode    = "serverless"
  engine         = "aurora-postgresql"
  cluster_parameter_group_family = "aurora-postgresql13"

  vpc_id          = module.vpc.vpc_id
  vpc_subnet_ids  = module.vpc.private_subnets

  vpc_security_group_ids = [module.jumphost.security_group_id]

  tags = local.tags
}

module "jumphost" {
  source = "../../jumphost-windows"

  prefix = local.prefix

  vpc_id          = module.vpc.vpc_id
  vpc_subnet_id   = module.vpc.private_subnets[1]

  tags = local.tags
}
