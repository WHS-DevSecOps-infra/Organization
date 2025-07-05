terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # optional
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "ap-northeast-2"
}


# 새로운 organization 생성
resource "aws_organizations_organization" "org" {
  aws_service_access_principals = [ #조직 전체 수준에서 접근을 허용하고, Delegated Administrator(위임 관리자)로 계정에 등록할 수 있게 해줌.
    "cloudtrail.amazonaws.com",     # AWS CloudTrail이 전체 조직의 로그를 수집할 수 있게 함
    "config.amazonaws.com",         # AWS Config가 전체 조직의 리소스를 추적·관리할 수 있게 함
    "guardduty.amazonaws.com",      # guardduty / 위협탐지
    "securityhub.amazonaws.com",    #security hub / 조직 보안 표준
    "inspector2.amazonaws.com",
    "detective.amazonaws.com",
    "sso.amazonaws.com"
  ]

  feature_set          = "ALL"                      # 모든 기능 사용 가능 (OU, SCP, consolidated billing 등)
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"] # 실제로 어떤 정책(SCP, TAG_POLICY 등)을 켤지 지정
  # SERVICE_CONTROL_POLICY : SCP
}

# Delegated Administrator 등록
resource "aws_organizations_delegated_administrator" "sso_delegate" {
  account_id        = aws_organizations_account.identity_account.id
  service_principal = "sso.amazonaws.com"
}
# Delegate GuardDuty, SecurityHub, Inspector, Detective
locals {
  security_services = [
    "guardduty.amazonaws.com",
    "securityhub.amazonaws.com",
    "inspector2.amazonaws.com",
    "detective.amazonaws.com"
  ]
}

resource "aws_organizations_delegated_administrator" "security_delegates" {
  for_each          = toset(local.security_services)
  account_id        = aws_organizations_account.security_account.id
  service_principal = each.value
}

# account 설정
resource "aws_organizations_account" "identity_account" {
  name      = "identity-team-account"
  email     = "whs-cloudfence+identity-team@googlegroups.com" # 반드시 고유해야 함
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_account" "operation_account" {
  name      = "operation-team-account"
  email     = "whs-cloudfence+operation-team@googlegroups.com" # 반드시 고유해야 함
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_account" "security_account" {
  name      = "security-team-account"
  email     = "whs-cloudfence+security-team@googlegroups.com" # 반드시 고유해야 함
  parent_id = aws_organizations_organization.org.roots[0].id
}


resource "aws_organizations_account" "dev_account" {
  name      = "dev-team-account"
  email     = "whs-cloudfence+dev-team@googlegroups.com" # 반드시 고유해야 함
  parent_id = aws_organizations_organization.org.roots[0].id
}


resource "aws_organizations_account" "stage_account" {
  name      = "stage-team-account"
  email     = "whs-cloudfence+stage-team@googlegroups.com" # 반드시 고유해야 함
  parent_id = aws_organizations_organization.org.roots[0].id
}


resource "aws_organizations_account" "prod_account" {
  name      = "prod-team-account"
  email     = "whs-cloudfence+prod-team@googlegroups.com" # 반드시 고유해야 함
  parent_id = aws_organizations_organization.org.roots[0].id
}

output "identity_account_id" {
  value = aws_organizations_account.identity_account.id
}

output "operation_account_id" {
  value = aws_organizations_account.operation_account.id
}

output "security_account_id" {
  value = aws_organizations_account.security_account.id
}

output "dev_account_id" {
  value = aws_organizations_account.dev_account.id
}

output "stage_account_id" {
  value = aws_organizations_account.stage_account.id
}

output "prod_account_id" {
  value = aws_organizations_account.prod_account.id
}


output "management_account_id" {
  value = aws_organizations_organization.org.master_account_id
}