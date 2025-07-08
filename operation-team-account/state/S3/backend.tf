terraform {
  backend "s3" {
    bucket         = "cloudfence-operation-state"
    key            = "state/s3.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "s3-operation-lock"
  }
}
