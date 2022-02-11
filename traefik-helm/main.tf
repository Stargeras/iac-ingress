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

resource "helm_release" "traefik" {
  count      = var.use_traefik ? 1 : 0
  name       = "traefik"
  namespace  = "traefik"
  create_namespace = "true"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name = "ports.websecure.tls.enabled"
    value = "true"
  }

  set {
    name = "deployment.kind"
    value = "Deployment"
  }
}

resource "kubernetes_manifest" "tls_store" {
  count = var.use_traefik ? 1 : 0
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "TLSStore"
    "metadata" = {
      "name" = "default"
      "namespace" = "kube-public"
    }
    "spec" = {
      "defaultCertificate" = {
        "secretName" = "ingress-tls"
      }
    }
  }
  depends_on = [helm_release.traefik]
}

resource "kubernetes_manifest" "dashboard" {
  count = var.use_traefik ? 1 : 0
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = "dashboard"
      "namespace" = "traefik"
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [{
        "match" = "((PathPrefix(`dashboard`) || PathPrefix(`/api`))"
        "kind" = "Rule"
        "services" = [{
          "name" = "api@internal"
          "kind" = "TraefikService"
        }]
      }]
      "tls" = {
        "store" = {
          "name" = "default"
        }
      }
    }
  }
  depends_on = [helm_release.traefik]
}
