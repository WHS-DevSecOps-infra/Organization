terraform {
  backend "s3" {
    bucket         = "cloudfence-stage-bucket"
    key            = "vpc/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "cloudfence-stage-lock"
  }
}
