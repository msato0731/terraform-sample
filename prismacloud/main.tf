terraform {
  required_providers {
    prismacloud = {
      source  = "PaloAltoNetworks/prismacloud"
      version = "1.5.8"
    }
  }
}

provider "prismacloud" {
  json_config_file = ".prismacloud_auth.json"
}

resource "prismacloud_account_group" "example" {
  name        = "My new group"
  description = "Made by Terraform"
}
