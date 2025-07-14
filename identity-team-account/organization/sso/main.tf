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
    bucket         = "cloudfence-identity-state"
    key            = "organization/organizations.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "organizations-identity-lock"
    profile        = "cloudfence-identity"
  }
}

data "terraform_remote_state" "identitystore" {
  backend = "s3"
  config = {
    bucket         = "cloudfence-identity-state"
    key            = "organization/identitystore.tfstate"
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


# aws_ssoadmin_* 계열 리소스를 사용하는데, 이건 기본적으로 다음 조건이 필요:
# SSO 인스턴스가 미리 수동으로 활성화되어 있어야 함
# 루트 계정으로도 일부 API 호출은 거부될 수 있음 (특히 IAM Identity Center/SSO 관련)
# 권한 및 신뢰 정책 구성까지 필요한 경우가 있음
resource "aws_ssoadmin_account_assignment" "sh1220_admin_assignments" {
  for_each = local.identity_team_admin_accounts

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_pset.arn
  principal_id       = data.terraform_remote_state.identitystore.outputs.user_ids["sh1220"]
  principal_type     = "USER"
  target_id          = each.value
  target_type        = "AWS_ACCOUNT"
  depends_on         = [] # 사용자 리소스가 먼저 생성되어야 함

}
resource "aws_ssoadmin_account_assignment" "sh1220_readonly_assignments" {
  for_each = local.identity_team_readonly_accounts

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.readonly_pset.arn
  principal_id       = data.terraform_remote_state.identitystore.outputs.user_ids["sh1220"]
  principal_type     = "USER"
  target_id          = each.value
  target_type        = "AWS_ACCOUNT"
  depends_on         = [] # 사용자 리소스가 먼저 생성되어야 함

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

# application_admin_user_account_pairs를 사용하여 application 팀의 AdminAccess 권한을 부여하는 리소스
resource "aws_ssoadmin_account_assignment" "application_admin_assignments" {
  for_each = {
    for pair in local.application_admin_user_account_pairs : pair.key => pair
  }

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_pset.arn
  principal_id       = each.value.user_id
  principal_type     = "USER"
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}

# application_readonly_user_account_pairs를 사용하여 application 팀의 ReadOnlyAccess 권한을 부여하는 리소스
resource "aws_ssoadmin_account_assignment" "application_readonly_assignments" {
  for_each = {
    for pair in local.application_readonly_user_account_pairs : pair.key => pair
  }

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.readonly_pset.arn
  principal_id       = each.value.user_id
  principal_type     = "USER"
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}

