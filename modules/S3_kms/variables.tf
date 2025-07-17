variable "description" {
  type    = string
  default = "KMS key for S3 encryption"
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket that will use this KMS key"
}