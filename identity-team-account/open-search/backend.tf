terraform {
  backend "s3" {
    bucket         = "cloudfence-identity-bucket"
    key            = "opensearch/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "opensearch-identity-lock"
  }
}
