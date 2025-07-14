# 각 팀에 대한 AdminAccess & ReadOnlyAccess 권한 pset 
locals {

  # identity_team_admin_accounts: IAM Identity Center의 관리자 권한을 부여할 계정 목록
  identity_team_admin_accounts = {
    identity_account   = data.terraform_remote_state.organization.outputs.identity_account_id,
    management_account = data.terraform_remote_state.organization.outputs.management_account_id,
    prod_account       = data.terraform_remote_state.organization.outputs.prod_account_id
  }
  identity_team_readonly_accounts = {
    operation_account = data.terraform_remote_state.organization.outputs.operation_account_id,
    security_account  = data.terraform_remote_state.organization.outputs.security_account_id,
    dev_account       = data.terraform_remote_state.organization.outputs.dev_account_id,
    stage_account     = data.terraform_remote_state.organization.outputs.stage_account_id
  }
  # cicd_team_admin_accounts: cicd의 관리자 권한을 부여할 계정 목록
  cicd_team_admin_accounts = {
    operation_account  = data.terraform_remote_state.organization.outputs.operation_account_id,
    management_account = data.terraform_remote_state.organization.outputs.management_account_id,
    identity_account   = data.terraform_remote_state.organization.outputs.identity_account_id,
    security_account   = data.terraform_remote_state.organization.outputs.security_account_id,
    dev_account        = data.terraform_remote_state.organization.outputs.dev_account_id,
    stage_account      = data.terraform_remote_state.organization.outputs.stage_account_id,
    prod_account       = data.terraform_remote_state.organization.outputs.prod_account_id
  }
  cicd_team_readonly_accounts = {}

  # operation_team_admin_accounts: operation의 관리자 권한을 부여할 계정 목록
  operation_team_admin_accounts = {
    operation_account = data.terraform_remote_state.organization.outputs.operation_account_id
    prod_account      = data.terraform_remote_state.organization.outputs.prod_account_id
  }
  operation_team_readonly_accounts = {
    identity_account = data.terraform_remote_state.organization.outputs.identity_account_id,
    security_account = data.terraform_remote_state.organization.outputs.security_account_id,
    dev_account      = data.terraform_remote_state.organization.outputs.dev_account_id,
    stage_account    = data.terraform_remote_state.organization.outputs.stage_account_id,
  }

  monitoring_team_admin_accounts = {
    operation_account  = data.terraform_remote_state.organization.outputs.operation_account_id
    prod_account       = data.terraform_remote_state.organization.outputs.prod_account_id
    management_account = data.terraform_remote_state.organization.outputs.management_account_id
    security_account   = data.terraform_remote_state.organization.outputs.security_account_id,

  }
  monitoring_team_readonly_accounts = {
    identity_account = data.terraform_remote_state.organization.outputs.identity_account_id,
    dev_account      = data.terraform_remote_state.organization.outputs.dev_account_id,
    stage_account    = data.terraform_remote_state.organization.outputs.stage_account_id,
  }


  # security_team_admin_accounts: security의 관리자 권한을 부여할 계정 목록
  security_team_admin_accounts = {
    security_account = data.terraform_remote_state.organization.outputs.security_account_id
  }
  security_team_readonly_accounts = {
    identity_account  = data.terraform_remote_state.organization.outputs.identity_account_id,
    operation_account = data.terraform_remote_state.organization.outputs.operation_account_id,
    dev_account       = data.terraform_remote_state.organization.outputs.dev_account_id,
    stage_account     = data.terraform_remote_state.organization.outputs.stage_account_id,
    prod_account      = data.terraform_remote_state.organization.outputs.prod_account_id
  }
  # dev_team_admin_accounts: dev의 관리자 권한을 부여할 계정 목록
  dev_team_admin_accounts = {
    dev_account = data.terraform_remote_state.organization.outputs.dev_account_id
  }
  dev_team_readonly_accounts = {
    identity_account  = data.terraform_remote_state.organization.outputs.identity_account_id,
    operation_account = data.terraform_remote_state.organization.outputs.operation_account_id,
    security_account  = data.terraform_remote_state.organization.outputs.security_account_id,
    stage_account     = data.terraform_remote_state.organization.outputs.stage_account_id,
    prod_account      = data.terraform_remote_state.organization.outputs.prod_account_id
  }

  # stage_team_admin_accounts: stage의 관리자 권한을 부여할 계정 목록
  stage_team_admin_accounts = {
    stage_account = data.terraform_remote_state.organization.outputs.stage_account_id
  }
  stage_team_readonly_accounts = {
    identity_account  = data.terraform_remote_state.organization.outputs.identity_account_id,
    operation_account = data.terraform_remote_state.organization.outputs.operation_account_id,
    security_account  = data.terraform_remote_state.organization.outputs.security_account_id,
    dev_account       = data.terraform_remote_state.organization.outputs.dev_account_id,
    prod_account      = data.terraform_remote_state.organization.outputs.prod_account_id
  }
  # prod_team_admin_accounts: prod의 관리자 권한을 부여할 계정 목록
  prod_team_admin_accounts = {
    prod_account = data.terraform_remote_state.organization.outputs.prod_account_id
  }
  prod_team_readonly_accounts = {
    identity_account  = data.terraform_remote_state.organization.outputs.identity_account_id,
    operation_account = data.terraform_remote_state.organization.outputs.operation_account_id,
    security_account  = data.terraform_remote_state.organization.outputs.security_account_id,
    dev_account       = data.terraform_remote_state.organization.outputs.dev_account_id,
    stage_account     = data.terraform_remote_state.organization.outputs.stage_account_id
  }


  application_team_admin_accounts = {}
  application_team_readonly_accounts = {
    identity_account  = data.terraform_remote_state.organization.outputs.identity_account_id,
    prod_account      = data.terraform_remote_state.organization.outputs.prod_account_id,
    operation_account = data.terraform_remote_state.organization.outputs.operation_account_id,
    security_account  = data.terraform_remote_state.organization.outputs.security_account_id,
    dev_account       = data.terraform_remote_state.organization.outputs.dev_account_id,
    stage_account     = data.terraform_remote_state.organization.outputs.stage_account_id
  }
}