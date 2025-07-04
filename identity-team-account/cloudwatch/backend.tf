terraform {
  backend "s3" {
    bucket         = "cloudfence-identity-bucket"
    key            = "cloudwatch/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "cloudwatch-identity-lock"
  }
}