terraform {
  backend "s3" {
    bucket         = "cloudfence-identity-s3" 
    key            = "ec2/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "tfstate-identity-lock"  
  }
}