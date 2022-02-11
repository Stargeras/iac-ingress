provider "helm" {
  kubernetes {
      config_path = "${var.kubeconfig}"
  }
}

provider "kubernetes" {
  config_paths = [
    "${var.kubeconfig}"
  ]
}

resource "kubernetes_namespace" "metallb" {
  metadata {
    name = "metallb"
  }
}

resource "kubernetes_config_map" "metallb" {
  metadata {
    name = "config"
    namespace = "metallb"
  }
  data = {
    config = <<-EOT
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - ${var.metallb_ip}
    EOT
  }
  depends_on = [kubernetes_namespace.metallb]
}

resource "helm_release" "metallb" {
  name       = "metallb"
  namespace  = "metallb"
  create_namespace = "true"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metallb"

  set {
      name = "existingConfigMap"
      value = "config"
  }
  depends_on = [kubernetes_config_map.metallb]
}