terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.79.0"
    }
  }
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "hcp_hvn" "main" {
  hvn_id         = "hvn1"
  cloud_provider = "aws"
  region         = "ap-northeast-1"
  cidr_block     = "172.25.16.0/20"
}

resource "hcp_vault_cluster" "main" {
  cluster_id      = "vault-cluster"
  hvn_id          = hcp_hvn.main.hvn_id
  tier            = "dev"
  public_endpoint = true
}

resource "hcp_vault_cluster_admin_token" "main" {
  cluster_id = hcp_vault_cluster.main.cluster_id
}
