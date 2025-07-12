terraform {
  backend "s3" {
    bucket         = "cloudfence-dev-state"
    key            = "state/dynamodb.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "dynamodb-dev-lock"
  }
}
