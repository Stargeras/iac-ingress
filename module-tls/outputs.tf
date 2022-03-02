output "cert_pem" {
  value = tls_self_signed_cert.certificate.cert_pem
}

output "private_key" {
  value     = tls_private_key.key.private_key_pem
  sensitive = true
}