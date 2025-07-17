
# billing을 담을 bucket 생성
resource "aws_s3_bucket" "billing" {
  bucket        = "billing-report-bucket"
  force_destroy = true
}

# billing에서 bucket에 putobject를 하는 것을 허용
resource "aws_s3_bucket_policy" "allow_billing_upload" {
  bucket = aws_s3_bucket.billing.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "billingreports.amazonaws.com" },
      Action    = "s3:PutObject",
      Resource  = "${aws_s3_bucket.billing.arn}/*"
    }]
  })
}
