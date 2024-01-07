# Useful Hands-On.Cloud Terraform modules - Aurora Serverless Access Demo

This module deploys:

* VPC
* Aurora Serverless
* Windows Jumphost 

## Usage

To deploy example:

```shell
terraform init
terraform apply -auto-approve
```

Use module output to get AWS CLI commands for:

* Reset Windows Jumphost password
* Set up SSM port forwarding for RDP session 

Connect to `localhost:53389` as soon as RDP port is forwarded.

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

