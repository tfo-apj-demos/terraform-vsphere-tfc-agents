terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.49"
    }
    vsphere = {
      source = "hashicorp/vsphere"
      version = "~> 2.5"
    }
  }
}

provider "tfe" {
  organization = var.organization
}

provider "vsphere" {}