# Terraform backend
# Replace to your own configuration:
# https://github.com/hands-on-cloud/cloudformation-templates/tree/master/terraform-remote-state-infrastructure
terraform {
  backend "s3" {
    bucket  = "hands-on-cloud-terraform-remote-state-s3"
    key     = "budget-lambda-trigger-demo.tfstate"
    region  = "us-west-2"
    encrypt = "true"
    dynamodb_table = "hands-on-cloud-terraform-remote-state-dynamodb"
  }
}


provider "aws" {
  region = "us-east-1"
}

locals {
  prefix = "budget-lambda-trigger-demo"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "budget_alert_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${local.prefix}-lambda"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.11"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${local.prefix}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_sns_topic" "budget_alert_topic" {
  name = "${local.prefix}-budget-alert-topic"
}

resource "aws_sns_topic_subscription" "budget_alert_subscription" {
  topic_arn = aws_sns_topic.budget_alert_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.budget_alert_lambda.arn
}

resource "aws_lambda_permission" "allow_sns_to_call_lambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.budget_alert_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.budget_alert_topic.arn
}

resource "aws_budgets_budget" "account" {
  name              = "${local.prefix}-budget-aws-monthly"
  budget_type       = "COST"
  limit_amount      = "10"
  limit_unit        = "USD"
  time_period_end   = "2087-06-15_00:00"
  time_period_start = "2024-01-01_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_sns_topic_arns = [ aws_sns_topic.budget_alert_topic.arn ]
  }
}
