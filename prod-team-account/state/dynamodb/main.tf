terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# 리소스 단위 Lock Table

locals {
  resources = [
    "acm",
    "iam",
    "ecs",
    "alb",
    "vpc",
    "codedeploy",
    "deploy",
    "dynamodb",
    "s3",
    "guardduty"
  ]
}

resource "aws_dynamodb_table" "resource_locks" {
  for_each     = toset(local.resources)
  name         = "${each.key}-prod-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # 서버 측 암호화 설정
  server_side_encryption {
    enabled = true # 서버 측 암호화 활성화
  }

  tags = {
    Name        = "${each.key} Lock Table"
    Environment = "prod"
  }
}
