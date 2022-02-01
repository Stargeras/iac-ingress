resource "kubernetes_deployment" "webapp" {
  metadata {
    name = "webapp"
    labels = {
      app = "webapp"
    }
  }
  spec {
    replicas = 3
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
          image = "nginx"
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
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "webapp" {
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
                number = 80
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
