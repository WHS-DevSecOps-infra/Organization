data "terraform_remote_state" "org" {
  backend = "s3"
  config = {
    bucket = "cloudfence-management-state"
    key    = "organization/organizations.tfstate"
    region = "ap-northeast-2"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "this" {
  description         = var.description
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowRootAccountFullAccess",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "AllowS3ServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceArn"     = var.s3_bucket_arn,
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid : "AllowRootAccountToUseKey",
        Effect : "Allow",
        Principal : {
          AWS : [
            "arn:aws:iam::${data.terraform_remote_state.org.outputs.operation_account_id}:root",
            "arn:aws:iam::${data.terraform_remote_state.org.outputs.management_account_id}:root"
          ]
        },
        Action : [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource : "*"
      }
    ]
  })
}