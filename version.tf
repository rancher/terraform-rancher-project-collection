terraform {
  required_version = "~>1"
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.20.1"
    }
  }
}