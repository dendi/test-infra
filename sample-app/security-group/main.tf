# Configure the AWS provider
provider "aws" {
  region = "ap-southeast-1"
}

# Initialize the backend configuration
terraform {
  backend "s3" {
    bucket = "dendi-bucket-test"
    key    = "test-infra/sample-app/security-group/state.tfstate"
    region = "ap-southeast-1"
  }
}

data "aws_vpc" "vpc" {
  state      = "available"
  cidr_block = "10.0.0.0/16"

  filter {
    name   = "tag:Name"
    values = ["dendi-vpc"]
  }
}

module "security_group_ec2" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>4.17"
  name    = "Allow Http from ALB"
  vpc_id  = data.aws_vpc.vpc.id

  description     = "Allow HTTP Access"
  use_name_prefix = false

  egress_rules = ["all-all"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 80,
      to_port     = 80,
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow SSH Access For Periscope"
    }
  ]


}
