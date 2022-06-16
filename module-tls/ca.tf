resource "tls_private_key" "ca_key" {
  algorithm   = "RSA"
  rsa_bits    = "4096"
}

resource "tls_self_signed_cert" "ca_crt" {
  private_key_pem = "${tls_private_key.ca_key.private_key_pem}"
  is_ca_certificate = true
  subject {
    common_name  = var.ca_cname
    organization = var.ca_organization
  }

  validity_period_hours = 87600
  depends_on = [tls_private_key.ca_key]

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "server_auth",
    "client_auth",
  ]
}

resource "local_file" "ca_crt" {
  filename   = "${path.module}/certs/ca.crt"
  content    = tls_self_signed_cert.ca_crt.cert_pem
  depends_on = [tls_self_signed_cert.ca_crt]
}

resource "local_file" "ca_key" {
  filename   = "${path.module}/certs/ca.key"
  content    = tls_private_key.ca_key.private_key_pem
  depends_on = [tls_self_signed_cert.ca_crt]
}