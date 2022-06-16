resource "kubernetes_secret" "tls-secret" {
  type = "kubernetes.io/tls"

  metadata {
    name      = "ingress-tls"
    namespace = "default"
  }
  data = {
    "tls.crt" = "${tls_locally_signed_cert.tls_crt.cert_pem}"
    "tls.key" = "${tls_private_key.tls_key.private_key_pem}"
  }
  depends_on = [tls_locally_signed_cert.tls_crt]
}