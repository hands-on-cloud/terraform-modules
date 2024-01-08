locals {
  ami_filter = ["amzn2-ami-hvm-*-x86_64-gp2"]
  aws_account_id  = data.aws_caller_identity.current.account_id
  current_identity = data.aws_caller_identity.current.arn
  ec2_associate_public_ip_address = var.ec2_associate_public_ip_address
  ec2_enhanced_monitoring = var.ec2_enhanced_monitoring
  ec2_policy_arn = "arn:aws:iam::aws:policy/${var.ec2_policy_name}"
  ec2_instance_type = var.ec2_instance_type
  ec2_volume_size = var.ec2_volume_size
  prefix      = "${var.prefix}-windows-jump-host"
  tags        = merge(
    var.tags,
    {
      Name = local.prefix
    }
  )
  vpc_id      = var.vpc_id
  vpc_subnet_id = var.vpc_subnet_id
}

data "aws_ami" "latest" {
  most_recent = true

  filter {
    name   = "name"
    values = local.ami_filter
  }

  owners = ["amazon"]
}

data "aws_caller_identity" "current" {}

resource "aws_security_group" "ec2_sg" {
  name        = "${local.prefix}-sg"
  description = "Security group for EC2 instance"
  vpc_id      = local.vpc_id

  egress {
    description = "Allow outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_instance" "jump_host" {
  ami           = data.aws_ami.latest.id
  instance_type = local.ec2_instance_type

  iam_instance_profile      = aws_iam_instance_profile.this.name

  subnet_id                 = local.vpc_subnet_id

  vpc_security_group_ids    = [aws_security_group.ec2_sg.id]

  ebs_optimized = true

  root_block_device {
    volume_size = local.ec2_volume_size
    encrypted = true
    kms_key_id = module.kms.key_arn
  }

  monitoring = local.ec2_enhanced_monitoring

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install -y epel firefox
    sudo yum install -y xrdp xfce4
    sudo systemctl start xrdp
    sudo systemctl enable xrdp
    sudo yum groupinstall -y "Xfce"
    echo "xfce4-session" > ~ec2-user/.Xclients
    sudo chown ec2-user:ec2-user ~ec2-user/.Xclients
    sudo chmod a+x ~ec2-user/.Xclients
    sudo service xrdp restart
    sudo yum -y install chromium
  EOF

  associate_public_ip_address = local.ec2_associate_public_ip_address

  tags = merge(
    local.tags,
    {
      Name = local.prefix
    }
  )
}

module "kms" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-kms.git?ref=5508c9cdd6fdb0ed4dcf399f54ba02fb8c31bd4b"  # commit hash of version 2.1.0

  description = "EC2 AutoScaling key usage"
  key_usage   = "ENCRYPT_DECRYPT"

  # Policy
  key_owners                              = [local.current_identity]
  key_administrators                      = [local.current_identity]
  key_service_users                       = [aws_iam_role.this.arn]

  # Aliases
  aliases = ["${local.prefix}/ebs"]

  tags = local.tags
}

resource "aws_iam_policy" "kms_policy" {
  name        = "${local.prefix}-kms-policy"
  description = "Policy for KMS key"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = [
          module.kms.key_arn
        ],
        Effect = "Allow"
      }
    ]
  })
}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name = "${local.prefix}-role"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

resource "aws_iam_role_policy_attachment" "ssm_kms_policy_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.kms_policy.arn
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  # This jump host is used for demo dev projects, allowing Administrator permissions for flexibility
  # checkov:skip=CKV_AWS_274: "Disallow IAM roles, users, and groups from using the AWS AdministratorAccess policy"
  role       = aws_iam_role.this.name
  policy_arn = local.ec2_policy_arn
}

resource "aws_iam_instance_profile" "this" {
  name = "${local.prefix}-instance-profile"
  role = aws_iam_role.this.name
}
