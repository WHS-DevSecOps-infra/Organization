terraform {
  backend "s3" {
    bucket         = "cloudfence-prod-bucket"
    key            = "vpc/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "cloudfence-prod-lock"
  }
}
