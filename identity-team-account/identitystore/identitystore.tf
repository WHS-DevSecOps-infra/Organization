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

data "aws_ssoadmin_instances" "this" {}


# 인스턴스 만들기
resource "aws_identitystore_user" "sh1220_instance" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  user_name         = "sh1220"
  display_name      = "Park SungHyun"
  emails {
    value   = "jiu0009@naver.com"
    primary = true
  }
  name {
    given_name  = "SungHyun"
    family_name = "Park"
  }
}


resource "aws_identitystore_user" "dain_choi_instance" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  user_name         = "dain_choi"
  display_name      = "Choi dain"
  emails {
    value   = "ekdlslove1231@gmail.com"
    primary = true
  }
  name {
    given_name  = "dain"
    family_name = "Choi"
  }
}

resource "aws_identitystore_user" "luujaiyn_instance" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  user_name         = "luujaiyn"
  display_name      = "Son Jueun"
  emails {
    value   = "luujaiyn@gmail.com"
    primary = true
  }
  name {
    given_name  = "Jueun"
    family_name = "Son"
  }
}


resource "aws_identitystore_user" "hyeinNa_instance" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  user_name         = "hyeinNa"
  display_name      = "Na hyein"
  emails {
    value   = "nhi3373@gmail.com"
    primary = true
  }
  name {
    given_name  = "hyein"
    family_name = "Na"
  }
}


resource "aws_identitystore_user" "yunho_choi_instance" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  user_name         = "yunho_choi"
  display_name      = "Choi Yunho"
  emails {
    value   = "cyunho62100@gmail.com"
    primary = true
  }
  name {
    given_name  = "Yunho"
    family_name = "Choi"
  }
}


resource "aws_identitystore_user" "yujin_kwon_instance" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  user_name         = "yujin_kwon"
  display_name      = "Kwon Yujin"
  emails {
    value   = "rnjsdbwls0530@gmail.com"
    primary = true
  }
  name {
    given_name  = "Yujin"
    family_name = "Kwon"
  }
}


resource "aws_identitystore_user" "chaeyeonKim_instance" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  user_name         = "chaeyeonKim"
  display_name      = "Kim Chaeyeon"
  emails {
    value   = "amazin9sparky@gmail.com"
    primary = true
  }
  name {
    given_name  = "Chaeyeon"
    family_name = "Kim"
  }
}

resource "aws_identitystore_user" "subin_kim_instance" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  user_name         = "subin_kim"
  display_name      = "Kim Subin"
  emails {
    value   = "20221083@sungshin.ac.kr"
    primary = true
  }
  name {
    given_name  = "Subin"
    family_name = "Kim"
  }
}

output "sh1220_user_id" {
  value = aws_identitystore_user.sh1220_instance.user_id
}

output "dain_choi_user_id" {
  value = aws_identitystore_user.dain_choi_instance.user_id
}

output "luujaiyn_user_id" {
  value = aws_identitystore_user.luujaiyn_instance.user_id
}

output "hyeinNa_user_id" {
  value = aws_identitystore_user.hyeinNa_instance.user_id
}

output "yunho_choi_user_id" {
  value = aws_identitystore_user.yunho_choi_instance.user_id
}

output "yujin_kwon_user_id" {
  value = aws_identitystore_user.yujin_kwon_instance.user_id
}

output "chaeyeonKim_user_id" {
  value = aws_identitystore_user.chaeyeonKim_instance.user_id
}

output "subin_kim_user_id" {
  value = aws_identitystore_user.subin_kim_instance.user_id
}
