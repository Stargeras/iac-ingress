resource "tls_private_key" "key" {
  algorithm   = "RSA"
  rsa_bits    = "4096"
}

resource "tls_self_signed_cert" "certificate" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.key.private_key_pem}"
  dns_names  = "${var.tls_altnames}"
  # is_ca_certificate = true
  subject {
    common_name  = "${var.tls_cname}"
    organization = "${var.tls_organization}"
  }

  validity_period_hours = 8760
  depends_on = [tls_private_key.key]

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "local_file" "tls_crt" {
  filename = "tls.crt"
  content = "${tls_self_signed_cert.certificate.cert_pem}"
  depends_on = [tls_self_signed_cert.certificate]
}

resource "local_file" "tls_key" {
  filename = "tls.key"
  content = "${tls_private_key.key.private_key_pem}"
  depends_on = [tls_self_signed_cert.certificate]
}

resource "kubernetes_secret" "tls-secret" {
  type = "kubernetes.io/tls"

  metadata {
    name = "ingress-tls"
    namespace = "kube-public"
  }
  data = {
    "tls.crt" = "${tls_self_signed_cert.certificate.cert_pem}"
    "tls.key" = "${tls_private_key.key.private_key_pem}"
  }
  depends_on = [tls_self_signed_cert.certificate]
}

#resource "kubernetes_manifest" "tls_store" {
#  manifest = {
#    "apiVersion" = "traefik.containo.us/v1alpha1"
#    "kind" = "TLSStore"
#    "metadata" = {
#      "name" = "default"
#      "namespace" = "kube-public"
#    }
#    "spec" = {
#      "defaultCertificate" = {
#        "secretName" = "ingress-tls"
#      }
#    }
#  }
#  depends_on = [kubernetes_secret.tls-secret]
#}