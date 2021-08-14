terraform {
  required_version = ">= 1.0.4"
  backend "s3" {
    bucket         = var.bucket
    key            = var.key
    dynamodb_table = "tf_lock_pixlaunch"
    region         = var.region
    encrypt        = "true"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  region = var.region
}
