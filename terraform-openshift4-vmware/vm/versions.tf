terraform {
  required_providers {
    template = {
      source = "hashicorp/template"
    }
    vsphere = {
      source = "vmware/vsphere"
    }
    ignition = {
      source = "community-terraform-providers/ignition"
    }
  }
  required_version = ">= 0.13"
}
