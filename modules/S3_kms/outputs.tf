output "kms_key_arn" {
  description = "The ARN of the KMS key used for S3 encryption"
  value       = aws_kms_key.this.arn
}