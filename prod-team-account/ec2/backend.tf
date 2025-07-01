terraform {
  backend "s3" {
    bucket         = "cloudfence-prod-bucket"
    key            = "ec2/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "cloudfence-prod-lock"
  }
}