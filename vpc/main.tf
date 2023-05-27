# Configure the AWS provider
provider "aws" {
  region = "ap-southeast-1"
}

# Initialize the backend configuration
terraform {
  backend "s3" {
    bucket = "dendi-bucket-test"
    key    = "test-infra/sample-app/vpc/state.tfstate"
    region = "ap-southeast-1"
  }
}

# Use the AWS VPC module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>4.0"

  name                 = "dendi-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = ["ap-southeast-1a", "ap-southeast-1b"]
  public_subnets       = ["10.0.1.0/24"]
  private_subnets      = ["10.0.100.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  tags = {
    Terraform   = "true"
    Environment = "staging"
  }
}
