# Useful Hands-On.Cloud Terraform modules - Jumphost (Amazon Linux EC2 Instance)

This Terraform module provisions an Amazon Linux EC2 Instance, commonly used as a jump-box in AWS environments.
EBS volume is encrypted using KMS key. User data installs xrdp, Xfce Desktop Environment, Firefox and Chromium.

## Features

- Provisions a Amazon Linux EC2 Instance.
- Sets up IAM roles and policies for EC2 and KMS access.
- Configures a security group for the instance.
- User data installs:
    - xrdp
    - Xfce Desktop Environment
    - Firefox
    - Chromium
- Uses a KMS key for EBS volume encryption.

## Usage

To use this module in your Terraform configuration, refer to the following example:

```hcl
module "jump_host" {
  source = "../../jumphost-linux"

  prefix = local.prefix

  vpc_id          = module.vpc.vpc_id
  vpc_subnet_id   = module.vpc.private_subnets[1]

  tags = local.tags
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