resource "kubernetes_deployment" "webapp" {
  metadata {
    name = "webapp"
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
}

resource "kubernetes_service" "webapp" {
  metadata {
    name = "webapp"
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
}

resource "kubernetes_ingress_v1" "webapp" {
  count = var.use_nginx ? 1 : 0
  metadata {
    name = "webapp"
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
}
