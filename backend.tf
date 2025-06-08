terraform {
  backend "s3" {
    bucket         = "cloudfence-tfstate-org"
    key            = "organization/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "tfstate-lock-org"
    encrypt        = true
  }
}
