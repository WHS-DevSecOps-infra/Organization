terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  alias  = "operation"
  region = "ap-northeast-2"
}

module "guardduty-detector" {
  source = "../../modules/guardduty-detector"
  enable = true
}
