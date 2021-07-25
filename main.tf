# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

data "aws_vpc" "main" {
  id = "${var.vpc_id}"
}

data "aws_subnet_ids" "main" {
  vpc_id = "${data.aws_vpc.main.id}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.aws_ami_name}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = "${var.aws_ami_owners}"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "${data.aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_spot_instance_request" "dev_instance" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  availability_zone = "us-east-2c"

  key_name = "${var.ec2_keyname}"
  security_groups = ["${aws_security_group.allow_ssh.name}"]

  user_data = "${file("scripts/user_data.sh")}"

  wait_for_fulfillment = true

  root_block_device {
    volume_size = "16"
  }
}

resource "aws_ebs_volume" "workspace" {
  availability_zone = "us-east-2c"
  size              = 20
}

resource "aws_volume_attachment" "workspace" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.workspace.id
  instance_id = aws_spot_instance_request.dev_instance.spot_instance_id
}

resource "aws_ssm_parameter" "ssh-default-private-key" {
  name        = "/dev-env/ssh/default-private-key"
  description = "The parameter description"
  type        = "SecureString"
  value       = file("${var.default_private_key_path}")
}

resource "aws_ssm_parameter" "ssh-default-public-key" {
  name        = "/dev-env/ssh/default-public-key"
  description = "The parameter description"
  type        = "String"
  value       = file("${var.default_public_key_path}")
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid = "BasicServices"
    actions = [
      "sts:AssumeRole",
      "s3:*"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }

  statement {
    sid = "SSM"
    actions = [
      "ssm:GetParameter",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:ssm:*:*:parameter/dev-env/ssh/default-public-key",
      "arn:aws:ssm:*:*:parameter/dev-env/ssh/default-private-key",
    ]
  }
}

resource "aws_iam_policy" "assume_role" {
  provider = aws
  name     = "assume_role"
  policy   = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role" "assume_role" {
  name = "assume-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "assume_role" {
  provider = aws
  role = "${aws_iam_role.assume_role.name}"
  policy_arn = "${aws_iam_policy.assume_role.arn}"
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "${aws_iam_role.assume_role.name}"
}
