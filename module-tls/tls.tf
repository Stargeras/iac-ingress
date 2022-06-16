resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}


resource "tls_cert_request" "tls_request" {
  private_key_pem = "${tls_private_key.tls_key.private_key_pem}"
  dns_names       = var.tls_altnames

  subject {
    common_name  = var.tls_cname
    organization = var.tls_organization
  }
  depends_on = [tls_self_signed_cert.ca_crt, tls_private_key.tls_key]
}

resource "tls_locally_signed_cert" "tls_crt" {
  cert_request_pem   = "${tls_cert_request.tls_request.cert_request_pem}"
  ca_private_key_pem = "${tls_private_key.ca_key.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca_crt.cert_pem}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
  depends_on = [tls_cert_request.tls_request]
}

resource "local_file" "tls_crt" {
  filename   = "${path.module}/certs/tls.crt"
  content    = tls_locally_signed_cert.tls_crt.cert_pem
  depends_on = [tls_locally_signed_cert.tls_crt]
}

resource "local_file" "tls_key" {
  filename   = "${path.module}/certs/tls.key"
  content    = tls_private_key.tls_key.private_key_pem
  depends_on = [tls_locally_signed_cert.tls_crt]
}
