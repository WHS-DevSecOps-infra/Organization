# AWS 제공자 설정
provider "aws" {
  region = "ap-northeast-2"  # 리전 설정
}

# S3 버킷 생성
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name-terraformmm"  # 고유한 이름을 사용해야 합니다.
}

