terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc9"
    }

    sops = {
      source = "carlpett/sops"
      version = "1.2.0"
    }
  }
}

provider "sops" {}

data "sops_file" "secrets" {
  source_file = "secrets.sops.yml"
}

locals {
  variables = yamldecode(file("variables.yml"))
  secrets = data.sops_file.secrets.data
}

provider "proxmox" {
  pm_api_url          = local.secrets.prox_api_url
  pm_api_token_id     = local.secrets.prox_api_token_id
  pm_api_token_secret = local.secrets.prox_api_token_secret
  pm_tls_insecure     = local.secrets.prox_tls_insecure
}
