terraform {
  backend "s3" {
    bucket         = "cloudfence-identity-bucket"
    key            = "iam/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "iam-identity-lock"
  }
}
