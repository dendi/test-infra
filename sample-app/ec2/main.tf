# Configure the AWS provider
provider "aws" {
  region = "ap-southeast-1"
}

# Initialize the backend configuration
terraform {
  backend "s3" {
    bucket = "dendi-bucket-test"
    key    = "test-infra/sample-app/ec2/state.tfstate"
    region = "ap-southeast-1"
  }
}

# Use the AWS ALB module
