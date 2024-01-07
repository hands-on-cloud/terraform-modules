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

## Contributing

This module is maintained by [https://hands-on.cloud](https://hands-on.cloud).

Contributions to this module are welcome. Please ensure that your changes are tested and documented.

## License

This Terraform module is released under the MIT License. See the LICENSE file for more details.

