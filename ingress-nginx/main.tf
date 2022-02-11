resource "helm_release" "ingress" {
  count      = var.use_nginx ? 1 : 0
  name       = "ingress"
  namespace  = "ingress"
  create_namespace = "true"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name = "controller.defaultTLS.secret"
    value = "kube-public/ingress-tls"
  }

  set {
    name = "controller.wildcardTLS.secret"
    value = "kube-public/ingress-tls"
  }

  set {
    name = "controller.kind"
    value = "deployment"
  }
}

