terraform {
  backend "s3" {
    bucket         = "cloudfence-identity-state"
    key            = "s3/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "s3-identity-lock"
  }
}
