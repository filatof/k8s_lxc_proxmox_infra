terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }
}


provider "proxmox" {
  pm_user = var.pm_user_prov
  pm_password = var.pm_password_prov
  pm_tls_insecure = true
  pm_api_url = var.pm_api_url_prov
}
