terraform {
  backend "s3" {
    bucket         = "cloudfence-security-state"
    key            = "guardduty-detector/guardduty.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "guardduty-security-lock"
  }
}