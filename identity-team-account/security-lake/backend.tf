terraform {
  backend "s3" {
    bucket         = "cloudfence-identity-bucket"
    key            = "securitylake/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "securitylake-identity-lock"
  }
}
