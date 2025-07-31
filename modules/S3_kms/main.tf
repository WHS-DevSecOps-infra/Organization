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
        Sid: "AllowRootAccountToUseKey",
        Effect: "Allow",
        Principal: {
          AWS: [
            "arn:aws:iam::502676416967:root",           # operation 계정
            "arn:aws:iam::433331841346:root"            # management 계정
          ]
        },
        Action: [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:DescribeKey"
        ],
        Resource: "*"
      }
    ]
  })
}