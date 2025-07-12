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
  region = "ap-northeast-2"
}

# 현재 활성화된 IAM Identity Center 인스턴스에 연결된 디렉터리 정보를 불러오기
# 사용자(user), 그룹(group) 등을 생성할 때 필수적으로 사용됨.
# 일반적으로 하나의 디렉터리만 존재하기 때문에 파라미터 없이 조회 가능
# IAM Identity Center의 인스턴스 정보 조회
data "aws_ssoadmin_instances" "this" {}


data "terraform_remote_state" "organization" {
  backend = "s3"
  config = {
    bucket         = "cloudfence-identity-bucket"
    key            = "organizations/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "organizations-identity-lock"
    profile        = "cloudfence-identity"
  }
}

data "terraform_remote_state" "identitystore" {
  backend = "s3"
  config = {
    bucket         = "cloudfence-identity-bucket"
    key            = "identitystore/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "identitystore-identity-lock"
    profile        = "cloudfence-identity"
  }
}


# AdministratorAccess라는 이름의 Permission Set(권한 세트)을 생성.
# Permission Set은 일종의 SSO 역할(Role) 이며, IAM Policy의 집합.
# 여기선 8시간 세션을 지정 (PT8H → ISO 8601 포맷).
# 이 Permission Set에는 별도로 정책을 추가할 수 있음. (inline_policy, managed_policies 등).


# 1. admin_pset 생성
resource "aws_ssoadmin_permission_set" "admin_pset" {
  name             = "AdministratorAccess"
  description      = "Full admin access"
  instance_arn     = data.aws_ssoadmin_instances.this.arns[0]
  session_duration = "PT8H"
}


resource "aws_ssoadmin_managed_policy_attachment" "admin_attach" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_pset.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# 2. readonly_pset 생성
resource "aws_ssoadmin_permission_set" "readonly_pset" {
  name             = "ReadOnlyAccess"
  description      = "Read-only access"
  instance_arn     = data.aws_ssoadmin_instances.this.arns[0]
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "readonly_attach" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.readonly_pset.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}



# 앞서 생성한 SSO 사용자(admin@example.com)에게 앞서 생성한 Permission Set(AdministratorAccess)을 
# 특정 AWS 계정 (identity_account)에 할당.
# principal_id: 사용자 또는 그룹 ID (여기서는 사용자)
# principal_type: "USER" 또는 "GROUP" 지정
# target_id: 조직 내 계정의 ID
# target_type: 고정값 "AWS_ACCOUNT"
# resource "aws_ssoadmin_account_assignment" "admin_assignment" {
#   instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
#   permission_set_arn = aws_ssoadmin_permission_set.admin_pset.arn
#   principal_id       = aws_identitystore_user.admin_instance.user_id
#   principal_type     = "USER"
#   target_id          = aws_organizations_account.identity_account.id
#   target_type        = "AWS_ACCOUNT"
# }


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
}

# aws_ssoadmin_* 계열 리소스를 사용하는데, 이건 기본적으로 다음 조건이 필요:
# SSO 인스턴스가 미리 수동으로 활성화되어 있어야 함
# 루트 계정으로도 일부 API 호출은 거부될 수 있음 (특히 IAM Identity Center/SSO 관련)
# 권한 및 신뢰 정책 구성까지 필요한 경우가 있음
resource "aws_ssoadmin_account_assignment" "sh1220_admin_assignments" {
  for_each = local.identity_team_admin_accounts

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_pset.arn
  principal_id       = data.terraform_remote_state.identitystore.outputs.sh1220_user_id
  principal_type     = "USER"
  target_id          = each.value
  target_type        = "AWS_ACCOUNT"
  depends_on         = [] # 사용자 리소스가 먼저 생성되어야 함

}
resource "aws_ssoadmin_account_assignment" "sh1220_readonly_assignments" {
  for_each = local.identity_team_readonly_accounts

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.readonly_pset.arn
  principal_id       = data.terraform_remote_state.identitystore.outputs.sh1220_user_id
  principal_type     = "USER"
  target_id          = each.value
  target_type        = "AWS_ACCOUNT"
  depends_on         = [] # 사용자 리소스가 먼저 생성되어야 함

}


locals {
  depends_on = []
  cicd_users = {
    "dain_choi"  = data.terraform_remote_state.identitystore.outputs.dain_choi_user_id
    "yujin_kwon" = data.terraform_remote_state.identitystore.outputs.yujin_kwon_user_id
    "subin_kim"  = data.terraform_remote_state.identitystore.outputs.subin_kim_user_id
  }

  operation_users = {
    "hyeinNa"    = data.terraform_remote_state.identitystore.outputs.hyeinNa_user_id
    "yunho_choi" = data.terraform_remote_state.identitystore.outputs.yunho_choi_user_id
  }
  monitoring_users = {
    "chaeyeon_kim" = data.terraform_remote_state.identitystore.outputs.chaeyeonKim_user_id
    "luujaiyn"     = data.terraform_remote_state.identitystore.outputs.luujaiyn_user_id
  }
  cicd_admin_user_account_pairs = flatten([
    for user_name, user_id in local.cicd_users : [
      for acc_key, acc in local.cicd_team_admin_accounts : {
        key        = "${user_name}-${acc}"
        user_id    = user_id
        account_id = acc
      }
    ]
  ])

  cicd_readonly_user_account_pairs = flatten([
    for user_name, user_id in local.cicd_users : [
      for acc_key, acc in local.cicd_team_readonly_accounts : {
        key        = "${user_name}-${acc}"
        user_id    = user_id
        account_id = acc
      }
    ]
  ])

  operation_admin_user_account_pairs = flatten([
    for user_name, user_id in local.operation_users : [
      for acc_key, acc in local.operation_team_admin_accounts : {
        key        = "${user_name}-${acc}"
        user_id    = user_id
        account_id = acc
      }
    ]
  ])

  operation_readonly_user_account_pairs = flatten([
    for user_name, user_id in local.operation_users : [
      for acc_key, acc in local.operation_team_readonly_accounts : {
        key        = "${user_name}-${acc}"
        user_id    = user_id
        account_id = acc
      }
    ]
  ])


  monitoring_admin_user_account_pairs = flatten([
    for user_name, user_id in local.monitoring_users : [
      for acc_key, acc in local.monitoring_team_admin_accounts : {
        key        = "${user_name}-${acc}"
        user_id    = user_id
        account_id = acc
      }
    ]
  ])

  monitoring_readonly_user_account_pairs = flatten([
    for user_name, user_id in local.monitoring_users : [
      for acc_key, acc in local.monitoring_team_readonly_accounts : {
        key        = "${user_name}-${acc}"
        user_id    = user_id
        account_id = acc
      }
    ]
  ])
}
# cicd_admin_user_account_pairs를 사용하여 cicd 팀의 AdminAccess 권한을 부여하는 리소스
resource "aws_ssoadmin_account_assignment" "cicd_admin_assignments" {
  for_each = {
    for pair in local.cicd_admin_user_account_pairs : pair.key => pair # 리스트를 맵으로 변환
    #  Terraform의 for_each는 반드시 set 또는 map을 받아야 함.
    # 그래서 단순 리스트는 사용할 수 없고, 고유한 키를 가진 map으로 변환해야 함.
    # 이때 pair.key => pair를 사용하면 고유한 식별자(key)를 기준으로 사용할 수 있으므로, 이후 each.key, each.value를 통해 리소스를 안전하게 만들 수 있음.
  }

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_pset.arn
  principal_id       = each.value.user_id
  principal_type     = "USER"
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}

# cicd_readonly_user_account_pairs를 사용하여 cicd 팀의 ReadOnlyAccess 권한을 부여하는 리소스
resource "aws_ssoadmin_account_assignment" "cicd_readonly_assignments" {
  for_each = {
    for pair in local.cicd_readonly_user_account_pairs : pair.key => pair
  }

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.readonly_pset.arn
  principal_id       = each.value.user_id
  principal_type     = "USER"
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}

# operation_admin_user_account_pairs를 사용하여 operation 팀의 AdminAccess 권한을 부여하는 리소스
resource "aws_ssoadmin_account_assignment" "operation_admin_assignments" {
  for_each = {
    for pair in local.operation_admin_user_account_pairs : pair.key => pair
  }

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_pset.arn
  principal_id       = each.value.user_id
  principal_type     = "USER"
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}

# operation_readonly_user_account_pairs를 사용하여 operation 팀의 ReadOnlyAccess 권한을 부여하는 리소스
resource "aws_ssoadmin_account_assignment" "operation_readonly_assignments" {
  for_each = {
    for pair in local.operation_readonly_user_account_pairs : pair.key => pair
  }

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.readonly_pset.arn
  principal_id       = each.value.user_id
  principal_type     = "USER"
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}

# operation_admin_user_account_pairs를 사용하여 operation 팀의 AdminAccess 권한을 부여하는 리소스
resource "aws_ssoadmin_account_assignment" "monitoring_admin_assignments" {
  for_each = {
    for pair in local.monitoring_admin_user_account_pairs : pair.key => pair
  }

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_pset.arn
  principal_id       = each.value.user_id
  principal_type     = "USER"
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}

# operation_readonly_user_account_pairs를 사용하여 operation 팀의 ReadOnlyAccess 권한을 부여하는 리소스
resource "aws_ssoadmin_account_assignment" "monitoring_readonly_assignments" {
  for_each = {
    for pair in local.monitoring_readonly_user_account_pairs : pair.key => pair
  }

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.readonly_pset.arn
  principal_id       = each.value.user_id
  principal_type     = "USER"
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}
