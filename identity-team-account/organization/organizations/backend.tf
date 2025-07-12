terraform {
  backend "s3" {
<<<<<<< HEAD
    bucket         = "cloudfence-identity-state"
=======
    bucket         = "cloudfence-identity-bucket"
>>>>>>> 6db8d39553654901d25bda9b3c66010b60c829b9
    key            = "organization/organizations.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "organizations-identity-lock"
  }
}
