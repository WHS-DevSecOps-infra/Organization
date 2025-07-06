terraform {
  backend "s3" {
    bucket         = "cloudfence-prod-state"
    key            = "dynamodb/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "dynamodb-prod-lock"
  }
}
