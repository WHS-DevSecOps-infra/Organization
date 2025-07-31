terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# KMS 모듈 호출
module "s3_kms" {
  source        = "../../../modules/S3_kms"
  description   = "KMS key for S3 encryption"
  s3_bucket_arn = "arn:aws:s3:::cloudfence-operation-state"
}

# S3 버킷 생성
resource "aws_s3_bucket" "state_org" {
  bucket = "cloudfence-operation-state"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "operation"
  }
}

# 버킷 버전 관리
resource "aws_s3_bucket_versioning" "state_org_versioning" {
  bucket = aws_s3_bucket.state_org.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 버킷 소유권 제어
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.state_org.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

# 퍼블릭 접근 차단
resource "aws_s3_bucket_public_access_block" "state_org_block" {
  bucket                  = aws_s3_bucket.state_org.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# management 계정에 대한 readonly 권한 추가
resource "aws_s3_bucket_policy" "allow_management_read" {
  bucket = aws_s3_bucket.state_org.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowManagementAccountReadAccess",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::433331841346:root"
        },
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::cloudfence-operation-state",
          "arn:aws:s3:::cloudfence-operation-state/*"
        ]
      }
    ]
  })
}

# S3 버킷 서버 측 암호화
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.state_org.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = module.s3_kms.kms_key_arn
    }
  }
}
