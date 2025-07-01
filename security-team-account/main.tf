# S3 버킷 생성
resource "aws_s3_bucket" "state_org" {
  bucket = "cloudfence-security-bucket"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "security"
  }
}

# S3 버킷 버전 관리 설정
resource "aws_s3_bucket_versioning" "state_org_versioning" {
  bucket = aws_s3_bucket.state_org.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 버킷 소유권 제어 설정
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.state_org.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

# S3 버킷의 공용 접근 차단 설정
resource "aws_s3_bucket_public_access_block" "state_org_block" {
  bucket                  = aws_s3_bucket.state_org.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 암호화를 위한 고객 관리형 KMS 키
resource "aws_kms_key" "s3_key" {
  description         = "KMS key for S3 encryption"
  enable_key_rotation = true
}

# S3 버킷 서버 측 암호화 설정
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.state_org.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}

# DynamoDB 테이블 생성 (상태 파일 잠금 관리)
resource "aws_dynamodb_table" "lock_org" {
  name         = "cloudfence-security-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID" # 고유한 LockID로 상태 잠금 관리

  attribute {
    name = "LockID"
    type = "S"
  }

  # 서버 측 암호화 설정
  server_side_encryption {
    enabled = true # 서버 측 암호화 활성화
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "security"
  }
}