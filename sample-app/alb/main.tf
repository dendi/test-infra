# Configure the AWS provider
provider "aws" {
  region = "ap-southeast-1"
}

# Initialize the backend configuration
terraform {
  backend "s3" {
    bucket = "dendi-bucket-test"
    key    = "test-infra/sample-app/alb/state.tfstate"
    region = "ap-southeast-1"
  }
}

# Get subnet and VPC resources
data "aws_vpc" "dendi_vpc" {
  id = "vpc-01ab90cde884409a1"
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dendi_vpc.id]
  }
  tags = {
    Tier = "Public"
  }
}

# Get SG resources
data "aws_security_groups" "allow_http_alb" {
  filter {
    name   = "group-name"
    values = ["Allow Http from ALB"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dendi_vpc.id]
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "dendi-alb"

  load_balancer_type = "application"

  vpc_id          = data.aws_vpc.dendi_vpc.id
  subnets         = [data.aws_subnets.public.id]
  security_groups = [data.aws_security_groups.allow_http_alb.id]

  access_logs = {
    bucket = "dendi-alb-logs"
  }

  target_groups = [
    {
      name_prefix      = "tg-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      targets = {
        my_target = {
          target_id = "i-07e0280a60263df92"
          port      = 80
        }
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}
