
locals {
  depends_on = []
  cicd_users = {
    "dain_choi"  = data.terraform_remote_state.identitystore.outputs.user_ids["dain_choi"]
    "yujin_kwon" = data.terraform_remote_state.identitystore.outputs.user_ids["yujin_kwon"]
    "subin_kim"  = data.terraform_remote_state.identitystore.outputs.user_ids["subin_kim"]
  }

  operation_users = {
    "hyeinNa"    = data.terraform_remote_state.identitystore.outputs.user_ids["hyeinNa"]
    "yunho_choi" = data.terraform_remote_state.identitystore.outputs.user_ids["yunho_choi"]
  }
  monitoring_users = {
    "chaeyeon_kim" = data.terraform_remote_state.identitystore.outputs.user_ids["chaeyeonKim"]
    "luujaiyn"     = data.terraform_remote_state.identitystore.outputs.user_ids["luujaiyn"]
  }

  application_users = {
    "soobin_kwon" = data.terraform_remote_state.identitystore.outputs.user_ids["Soobin_kwon"]
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

  application_admin_user_account_pairs = flatten([
    for user_name, user_id in local.application_users : [
      for acc_key, acc in local.application_team_admin_accounts : {
        key        = "${user_name}-${acc}"
        user_id    = user_id
        account_id = acc
      }
    ]
  ])

  application_readonly_user_account_pairs = flatten([
    for user_name, user_id in local.application_users : [
      for acc_key, acc in local.application_team_readonly_accounts : {
        key        = "${user_name}-${acc}"
        user_id    = user_id
        account_id = acc
      }
    ]
  ])
}