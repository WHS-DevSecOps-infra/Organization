terraform {
  backend "s3" {
    bucket         = "cloudfence-operation-state"
    key            = "state/dynamodb.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "dynamodb-operation-lock"
  }
}
