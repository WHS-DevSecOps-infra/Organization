# security-team-account의 main.tf
# modules/github_oidc를 불러와 해당account별 OIDC역할을 자동으로 생성하는 구조

module "github_oidc" {
  source = "../../../modules/iam_OIDC"

  role_name = "security-role"

  add_root_trust = false
  # GitHub Actions에서 이 role을 사용할 수 있도록 허용하는 sub조건
  sub_condition = ["repo:WHS-DevSecOps-infra/Organization:*",
  "repo:WHS-DevSecOps-infra/CI-CD_Examples:*"]

  thumbprint_list = ["2b18947a6a9fc7764fd8b5fb18a863b0c6dac24f"]
  # 이 role에 연결할 정책들(IAM 정책 ARN)
  policy_arns = []
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "custom_inline_policy" {
  name = "security"
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
          "kms:*",
          "iam:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}