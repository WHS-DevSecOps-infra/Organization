terraform {
  backend "s3" {
    bucket         = "cloudfence-identity-bucket"
    key            = "state/dynamodb.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "dynamodb-identity-lock"
  }
}
