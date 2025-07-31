terraform {
  backend "s3" {
    bucket         = "cloudfence-prod-state"
    key            = "guardduty-detector/guardduty.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "guardduty-prod-lock"
  }
}