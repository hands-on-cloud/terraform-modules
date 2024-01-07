locals {
  prefix      = "${var.prefix}-windows-jumphost"

  ec2_policy_arn = "arn:aws:iam::aws:policy/${var.ec2_policy_name}"

  tags        = var.tags

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

resource "aws_iam_role" "ssm_role" {
  name = "${local.prefix}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = local.ec2_policy_arn
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "${local.prefix}-instance-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_security_group" "ec2_sg" {
  name        = "${local.prefix}-sg"
  description = "Security group for EC2 instance"
  vpc_id      = local.vpc_id

  egress {
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

  iam_instance_profile      = aws_iam_instance_profile.ssm_instance_profile.name

  subnet_id                 = local.vpc_subnet_id

  vpc_security_group_ids    = [aws_security_group.ec2_sg.id]

  root_block_device {
    volume_size = 100
    encrypted = true
    kms_key_id = aws_kms_key.ssm_key.arn
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

# KMS for SSM
resource "aws_kms_key" "ssm_key" {
  description             = "KMS key for SSM"
  enable_key_rotation     = true
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "ssm_key_alias" {
  name          = "alias/${local.prefix}-kms-key"
  target_key_id = aws_kms_key.ssm_key.key_id
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
          aws_kms_key.ssm_key.arn
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
