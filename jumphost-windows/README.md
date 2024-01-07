<!-- BEGIN_TF_DOCS -->

# Useful Hands-On.Cloud Terraform modules - Jumphost (Windows EC2 Instance)

This Terraform module provisions a Windows EC2 instance, commonly used as a jumpbox in AWS environments.
It also includes a KMS key for EBS volume encryption and user data to install Chocolatey and Google Chrome,
with optional components such as pgAdmin4 and Anaconda.

## Features

- Provisions a Windows Server EC2 instance.
- Sets up IAM roles and policies for EC2 and KMS access.
- Configures a security group for the instance.
- Installs Chocolatey and Google Chrome through user data.
- Optional installation of pgAdmin4 and Anaconda.
- Uses a KMS key for EBS volume encryption.

## Usage

To use this module in your Terraform configuration, refer to the following example:

```hcl
module "jumphost" {
  source = "../../jumphost-windows"

  prefix = "my-ec2-name-prefix"

  vpc_id          = module.vpc.vpc_id
  vpc_subnet_id   = module.vpc.private_subnets[0]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## Documentation

To update module documentation:

```shell
terraform-docs -c .terraform-docs.yml .
```

## Security

```shell
checkov -d . --download-external-modules kms
```

## Contributing

This module is maintained by [https://hands-on.cloud](https://hands-on.cloud).

Contributions to this module are welcome. Please ensure that your changes are tested and documented.

## License

This Terraform module is released under the MIT License. See the LICENSE file for more details.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.ssm_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.kms_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ssm_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_kms_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.jumphost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.ec2_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.latest_amazon_linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.trust_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_jumphost_id"></a> [jumphost\_id](#output\_jumphost\_id) | n/a |
| <a name="output_rdp_jumphost_fqdn"></a> [rdp\_jumphost\_fqdn](#output\_rdp\_jumphost\_fqdn) | n/a |
| <a name="output_rdp_jumphost_user"></a> [rdp\_jumphost\_user](#output\_rdp\_jumphost\_user) | n/a |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | n/a |
| <a name="output_ssm_command_jumphost_port_forward"></a> [ssm\_command\_jumphost\_port\_forward](#output\_ssm\_command\_jumphost\_port\_forward) | n/a |
| <a name="output_ssm_command_jumphost_pwd_reset"></a> [ssm\_command\_jumphost\_pwd\_reset](#output\_ssm\_command\_jumphost\_pwd\_reset) | n/a |

<!-- END_TF_DOCS -->