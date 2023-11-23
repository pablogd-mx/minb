output "ca_key" {
  value     = tls_private_key.ca_key.private_key_pem
  sensitive = true
}

output "ca_cert" {
  value = tls_self_signed_cert.ca.cert_pem
}

output "pmp_key" {
  value     = tls_private_key.pmp_key.private_key_pem
  sensitive = true
}

output "pmp_cert" {
  value = tls_locally_signed_cert.pmp_cert.cert_pem
}

resource "local_file" "ca_cert" {
  content  = tls_self_signed_cert.ca.cert_pem
  filename = "${path.module}/ca-cert.pem"
}

resource "local_file" "pmp_key" {
  content  = tls_private_key.pmp_key.private_key_pem
  filename = "${path.module}/pmp-key.pem"
}

resource "local_file" "pmp_cert" {
  content  = tls_locally_signed_cert.pmp_cert.cert_pem
  filename = "${path.module}/pmp-cert.pem"
}
