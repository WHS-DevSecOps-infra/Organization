# prod-team-account의 main.tf
# modules/github_oidc를 불러와 해당account별 OIDC역할을 자동으로 생성하는 구조

module "github_oidc" {
  source = "../../../modules/github_oidc"

  role_name      = "Application-Deployment-role2"
  add_root_trust = false
  # GitHub Actions에서 이 role을 사용할 수 있도록 허용하는 sub조건
  sub_condition = ["repo:WHS-DevSecOps-infra/Organization:*",
  "repo:WHS-DevSecOps-infra/Application-Deployment:*"]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
  # 이 role에 연결할 정책들(IAM 정책 ARN)
  policy_arns = []
}

data "aws_caller_identity" "current" {}


#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "custom_inline_policy" {
  name = "prod-role"
  role = module.github_oidc.oidc_role_name # 모듈에서 출력된 role이름 참조

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "rds:*",
          "s3:*",
          "ec2:*",
          "dynamodb:*",
          "kms:*"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "TerraformBackendProdState",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::cloudfence-prod-state",
          "arn:aws:s3:::cloudfence-prod-state/*"
        ]
      },
      {
        "Sid" : "TerraformBackendOperationState",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::cloudfence-operation-state",
          "arn:aws:s3:::cloudfence-operation-state/*"
        ]
      },
      {
        "Sid" : "TerraformDynamoDBLock",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        "Resource" : "arn:aws:dynamodb:*:*:table/s3-operation-lock"
      },
      {
        "Sid" : "KMSDecryptForStateFiles",
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ],
        "Resource" : "arn:aws:kms:ap-northeast-2:243359234795:key/c2c5da76-b55b-4bcc-a240-10cc6d6e9940"
      },
      {
        "Sid" : "AllProdResourceManagement",
        "Effect" : "Allow",
        "Action" : [
          "ec2:*",
          "ecs:*",
          "iam:*",
          "elasticloadbalancing:*",
          "codedeploy:*",
          "autoscaling:*",
          "cloudwatch:*",
          "wafv2:*"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowACMCertificateManagement",
        "Effect" : "Allow",
        "Action" : [
          "acm:RequestCertificate",
          "acm:DescribeCertificate",
          "acm:DeleteCertificate",
          "acm:ListTagsForCertificate",
          "acm:AddTagsToCertificate",
          "acm:RemoveTagsFromCertificate"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowRoute53DNSValidation",
        "Effect" : "Allow",
        "Action" : [
          "route53:GetChange",
          "route53:ChangeResourceRecordSets",
          "route53:ListHostedZonesByName",
          "route53:GetHostedZone",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : "arn:aws:route53:::hostedzone/*"
      },
      {
        "Sid" : "AllowRoute53GetChange",
        "Effect" : "Allow",
        "Action" : "route53:GetChange",
        "Resource" : "arn:aws:route53:::change/*"
      }
    ]
  })
}