# Configure the AWS provider
provider "aws" {
  region = "ap-southeast-1"
}

# Initialize the backend configuration
terraform {
  backend "s3" {
    bucket = "dendi-bucket-test"
    key    = "test-infra/sample-app/ecr/state.tfstate"
    region = "ap-southeast-1"
  }
}

module "ecr" {
  source = "terraform-aws-modules/ecr/aws"
  version = "~>1.6"
  repository_name = "sample-app"

#   repository_read_write_access_arns = ["arn:aws:iam::012345678901:role/terraform"]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = "staging"
  }
}
