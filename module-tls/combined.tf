resource "local_file" "combined_pem" {
  filename   = "${path.module}/certs/combined.pem"
  content    = <<-EOF
  ${tls_self_signed_cert.ca_crt.cert_pem}
  ${tls_locally_signed_cert.tls_crt.cert_pem}
  EOF

  depends_on = [tls_self_signed_cert.ca_crt, tls_locally_signed_cert.tls_crt]
}