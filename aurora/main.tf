resource "aws_secretsmanager_secret" "db_credentials" {
  name = local.secretsmanager_secret_name

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = local.db_username,
    password = local.db_password
  })
}

resource "random_id" "id" {
  byte_length = 4
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_parameter_group" {
  name        = local.cluster_parameter_group_name
  family      = local.cluster_parameter_group_family

  dynamic "parameter" {
    for_each = local.db_parameters

    content {
      name  = parameter.value["name"]
      value = parameter.value["value"]
    }
  }

  tags = local.tags
}

resource "aws_security_group" "aurora_db_sg" {
  name        = local.cluster_security_group_name
  description = "Security group for Aurora PostgreSQL Serverless DB"

  dynamic "ingress" {
    for_each = local.vpc_security_group_ids

    content {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      security_groups = [ingress.value]
    }
  }
  vpc_id = local.vpc_id
  tags = local.tags
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier              = local.cluster_identifier
  engine_mode                     = local.engine_mode
  engine                          = local.engine
  engine_version                  = local.engine_version
  db_subnet_group_name            = aws_db_subnet_group.db_subnet_group.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster_parameter_group.name
  master_username                 = local.db_username
  master_password                 = local.db_password
  skip_final_snapshot             = true
  vpc_security_group_ids          = [ aws_security_group.aurora_db_sg.id ]

  scaling_configuration {
    auto_pause               = true
    max_capacity             = local.cluster_max_capacity
    min_capacity             = local.cluster_min_capacity
    seconds_until_auto_pause = local.seconds_until_auto_pause
  }

  tags                            = local.tags
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = local.db_subnet_group_name
  subnet_ids = local.vpc_subnet_ids

  tags = local.tags
}
