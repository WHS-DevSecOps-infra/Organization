terraform {
  backend "s3" {
    bucket         = "cloudfence-management-state"
    key            = "guardduty-detector/guardduty.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "guardduty-management-lock"
  }
}