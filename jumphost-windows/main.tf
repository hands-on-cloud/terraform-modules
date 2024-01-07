locals {
  aws_account_id  = data.aws_caller_identity.current.account_id
  current_identity = data.aws_caller_identity.current.arn
  ec2_policy_arn = "arn:aws:iam::aws:policy/${var.ec2_policy_name}"
  prefix      = "${var.prefix}-windows-jumphost"
  tags        = merge(
    var.tags,
    {
      Name = local.prefix
    }
  )
  vpc_id      = var.vpc_id
  vpc_subnet_id = var.vpc_subnet_id
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
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

resource "aws_instance" "jumphost" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "m5.large"

  iam_instance_profile      = aws_iam_instance_profile.this.name

  subnet_id                 = local.vpc_subnet_id

  vpc_security_group_ids    = [aws_security_group.ec2_sg.id]

  ebs_optimized = true

  root_block_device {
    volume_size = 100
    encrypted = true
    kms_key_id = module.kms.key_arn
  }

  monitoring = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = <<-EOF
    <powershell>
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
    choco install googlechrome -y --force --ignore-checksums -y;

    # pgAdmin4
    # choco install pgadmin4 -y;

    # Download and install Anaconda
    # ATTENTION: This action might take a while!
    # choco install anaconda3 -y;
    </powershell>
  EOF

  associate_public_ip_address = false

  tags = merge(
    local.tags,
    {
      Name = local.prefix
    }
  )
}

module "kms" {
  #source  = "terraform-aws-modules/kms/aws"
  #version = "2.1.0"
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-kms.git?ref=5508c9cdd6fdb0ed4dcf399f54ba02fb8c31bd4b"  # commit hash of version 2.1.0

  description = "EC2 AutoScaling key usage"
  key_usage   = "ENCRYPT_DECRYPT"

  # Policy
  key_owners                              = [local.current_identity]
  key_administrators                      = [local.current_identity]
  key_service_users                       = [aws_iam_role.this.arn]

  # Aliases
  aliases = ["${local.prefix}/ebs"]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
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
  # This Jumphost is used for demo dev projects, allowing Administrator permissions for flexibility
  # checkov:skip=CKV_AWS_274: "Disallow IAM roles, users, and groups from using the AWS AdministratorAccess policy"
  role       = aws_iam_role.this.name
  policy_arn = local.ec2_policy_arn
}

resource "aws_iam_instance_profile" "this" {
  name = "${local.prefix}-instance-profile"
  role = aws_iam_role.this.name
}
