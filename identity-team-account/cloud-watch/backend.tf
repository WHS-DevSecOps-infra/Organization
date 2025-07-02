terraform {
  backend "s3" {
    bucket         = "cloudfence-identity-bucket"
<<<<<<<< HEAD:identity-team-account/cloud-watch/backend.tf
    key            = "cloudwatch/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "cloudwatch-identity-lock"
========
    key            = "firehose/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "firehose-identity-lock"
>>>>>>>> 27f8fb7 (identity 폴더 구조 리팩터링):identity-team-account/firehose/backend.tf
  }
}
