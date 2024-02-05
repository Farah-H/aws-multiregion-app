terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "farah-previse-tf-state-prod"
    key    = "eu-west-2/terraform.tfstate"

    region = "eu-west-1"
  }

  required_version = "1.5.6"
}

provider "aws" {
  region = "eu-west-2"

  # I like this because in practice sometimes resources will be created manually, esp in lower environments, makes future env cleanup much easier. 
  default_tags {
    tags = {
      Owner     = "Platform"
      Terraform = true
    }
  }
}

# I use this to parametise, for example, IAM policies so code can be deployed to multiple accounts if necessary 
data "aws_caller_identity" "current" {}