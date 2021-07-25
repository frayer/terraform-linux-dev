variable "aws_region" {
  description = "AWS region to launch EC2 instance"
}

variable "vpc_id" {
  description = "VPC ID to run the EC2 instance in"
}

variable "instance_type" {
  description = "EC2 instance type"
  default = "c5a.2xlarge"
}

variable "ec2_keyname" {
  description = "EC2 Key Pair name to use for instance"
}

variable "default_private_key_path" {
  description = "Path to a SSH private key to install in the development environment.  Useful for migrating a Git SSH key to the environment for development purposes."
  default = "~/.ssh/id_rsa"
}

variable "default_public_key_path" {
  description = "Path to a SSH public key to install in the development environment.  Useful for migrating a Git SSH key to the environment for development purposes."
  default = "~/.ssh/id_rsa.pub"
}

variable "aws_ami_name" {
  description = "value"
  default = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "aws_ami_owners" {
  description = "value"
  type = list
  default = ["099720109477"] # Canonical
}
