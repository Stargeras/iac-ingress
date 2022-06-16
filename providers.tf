terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig
  }
}
provider "kubernetes" {
  config_paths = [
    "${var.kubeconfig}"
  ]
}

provider "kubectl" {
  config_paths = [
    "${var.kubeconfig}"
  ]
}