terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}


provider "aws" {
  region = var.region
  access_key = "AKIARH3UUDQSF4T7TDEG"
  secret_key = "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"
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedBy   = var.username
      Project     = var.project
    }
 }
}
