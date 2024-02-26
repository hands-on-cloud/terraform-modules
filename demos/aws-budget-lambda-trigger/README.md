<!-- BEGIN_TF_DOCS -->

# Useful Hands-On.Cloud Terraform modules - AWS Budget Lambda Trigger

<img alt="AWS Budget and Lambda Integration" src="./img/AWS Budget and Lambda Integration.png" width="50%"/>

This module configures monthly AWS Budget and triggers AWS Lambda on specific threshold.

AWS services:

* AWS Budget
* Amazon SNS
* AWS Lambda 

## Usage

To deploy example:

```shell
terraform init
terraform apply -auto-approve
```

## Documentation

To update module documentation:

```shell
terraform-docs -c .terraform-docs.yml .
```

## Contributing

This module is maintained by [https://hands-on.cloud](https://hands-on.cloud).

Contributions to this module are welcome. Please ensure that your changes are tested and documented.

## License

This Terraform module is released under the MIT License. See the LICENSE file for more details.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.4.2 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.38.0 |
## Resources

| Name | Type |
|------|------|
| [aws_budgets_budget.account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget) | resource |
| [aws_iam_role.lambda_exec_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_lambda_function.budget_alert_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allow_sns_to_call_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_sns_topic.budget_alert_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.budget_alert_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [archive_file.lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
## Outputs

No outputs.

<!-- END_TF_DOCS -->