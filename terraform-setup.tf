terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }

    tfe = {
      source  = "hashicorp/tfe"
    }
  }
}

provider "google" {
  project = var.terraform_admin_gcp_project_id
  region  = "global"
}

provider "tfe" {
  hostname = var.tfc_hostname
}
