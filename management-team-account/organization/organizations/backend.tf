terraform {
  backend "s3" {
    bucket         = "cloudfence-management-state"
    key            = "organization/organizations.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "s3-management-lock"
  }
}
