output "security_group_id" {
  value = aws_rds_cluster.aurora_cluster.vpc_security_group_ids
}

output "db_endpoint" {
  value = aws_rds_cluster.aurora_cluster.endpoint
}

output "db_reader_endpoint" {
  value = aws_rds_cluster.aurora_cluster.reader_endpoint
}

output "secret_name" {
  value = aws_secretsmanager_secret.db_credentials.name
}
