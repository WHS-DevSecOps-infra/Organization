terraform {
  backend "s3" {
    bucket         = "cloudfence-identity-s3" 
    key            = "vpc/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "tfstate-identity-lock"  
  }
}

