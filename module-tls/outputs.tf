output "cert_pem" {
  value = tls_locally_signed_cert.tls_crt.cert_pem
}

output "private_key" {
  value     = tls_private_key.tls_key.private_key_pem
  sensitive = true
}

output "combined_pem" {
  value = <<-EOF
  ${tls_self_signed_cert.ca_crt.cert_pem}
  ${tls_locally_signed_cert.tls_crt.cert_pem}
  EOF
}