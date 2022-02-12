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

provider "kubectl" {
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

  set {
    name = "ingressRoute.dashboard.enabled"
    value = "false"
  }
}

resource "kubectl_manifest" "tls_store" {
  count = var.use_traefik ? 1 : 0
  yaml_body = <<YAML
apiVersion: traefik.containo.us/v1alpha1
kind: TLSStore
metadata:
  name: default
  namespace: kube-public
spec:
  defaultCertificate:
    secretName: ingress-tls
YAML
  depends_on = [helm_release.traefik]
}

resource "kubectl_manifest" "traefik-dashboard" {
  count = var.use_traefik ? 1 : 0
  yaml_body = <<YAML
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: traefik-dashboard
  namespace: traefik
spec:
  entryPoints:
  - websecure
  routes:
  - kind: Rule
    match: PathPrefix(`/dashboard`) || PathPrefix(`/api`)
    services:
    - kind: TraefikService
      name: api@internal
  tls:
    store:
      name: default
YAML
  depends_on = [kubectl_manifest.tls_store]
}
