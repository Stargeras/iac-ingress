provider "kubernetes" {
  config_paths = [
    "${var.kubeconfig}"
  ]
}

resource "kubernetes_namespace" "webapp" {
  count = var.webapp_namespace != "default" ? 1 : 0
  metadata {
    name = "${var.webapp_namespace}"
  }
}

resource "kubernetes_deployment" "webapp" {
  metadata {
    name = "webapp"
    namespace = "${var.webapp_namespace}"
    labels = {
      app = "webapp"
    }
  }
  spec {
    replicas = "${var.webapp_replicas}"
    selector {
      match_labels = {
        app = "webapp"
      }
    }
    template {
      metadata {
        labels = {
          app = "webapp"
        }
      }
      spec {
        container {
          image = "${var.webapp_image}"
          name  = "webapp"
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.webapp]
}

resource "kubernetes_service" "webapp" {
  metadata {
    name = "webapp"
    namespace = "${var.webapp_namespace}"
  }
  spec {
    selector = {
      app = "webapp"
    }
    port {
      port        = "${var.webapp_port}"
      target_port = "${var.webapp_port}"
    }
    type = "ClusterIP"
  }
  depends_on = [kubernetes_namespace.webapp]
}

resource "kubernetes_ingress_v1" "webapp" {
  count = var.use_nginx ? 1 : 0
  metadata {
    name = "webapp"
    namespace = "${var.webapp_namespace}"
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "${var.webapp_hostname}"
      http {
        path {
          backend {
            service {
              name = "webapp"
              port {
                number = "${var.webapp_port}"
              }
            }
          }
          path = "/"
        }
      }
    }
    tls {
      hosts = [
        "${var.webapp_hostname}"
      ]
    }
  }
  depends_on = [kubernetes_namespace.webapp]
}

resource "kubernetes_manifest" "webapp" {
  count = var.use_traefik ? 1 : 0
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = "webapp"
      "namespace" = "${var.webapp_namespace}"
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [{
        "match" = "Host(`${var.webapp_hostname}`) && PathPrefix(`/`)"
        "kind" = "Rule"
        "services" = [{
          "name" = "webapp"
          "port" = "${var.webapp_port}"
        }]
      }]
      "tls" = {
        "store" = {
          "name" = "default"
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.webapp]
}
