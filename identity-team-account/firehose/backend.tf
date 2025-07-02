terraform {
  backend "s3" {
    bucket         = "cloudfence-identity-bucket"
    key            = "firehose/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "firehose-identity-lock"
  }
}
