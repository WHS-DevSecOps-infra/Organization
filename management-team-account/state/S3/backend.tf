terraform {
  backend "s3" {
    bucket         = "cloudfence-management-state"
    key            = "state/s3.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "s3-management-lock"
  }
}
