terraform {
  backend "s3" {
    bucket         = "cloudfence-identity-bucket"
<<<<<<<< HEAD:identity-team-account/firehose/backend.tf
    key            = "firehose/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "firehose-identity-lock"
========
    key            = "iam/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "iam-identity-lock"
>>>>>>>> 27f8fb7 (identity 폴더 구조 리팩터링):identity-team-account/iam/backend.tf
  }
}
