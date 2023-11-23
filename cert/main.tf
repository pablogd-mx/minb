locals {
  env = yamldecode(file("${path.module}/../config.yaml"))
}

resource "tls_private_key" "ca_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem       = tls_private_key.ca_key.private_key_pem
  validity_period_hours = local.env["certificate_validity_hours"]
  is_ca_certificate     = true
  subject {
    common_name         = "Private Mendix Platform"
    organization        = "Siemens"
    organizational_unit = "Mendix"
  }
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing"
  ]
}

resource "tls_private_key" "pmp_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "pmp_cert_request" {
  private_key_pem = tls_private_key.pmp_key.private_key_pem
  subject {
    common_name         = local.env["domain"]
    organization        = "Siemens"
    organizational_unit = "Mendix"
  }
  dns_names = [
    local.env["domain"],
    "*.${local.env["domain"]}"
  ]
}

resource "tls_locally_signed_cert" "pmp_cert" {
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  ca_private_key_pem    = tls_private_key.ca_key.private_key_pem
  cert_request_pem      = tls_cert_request.pmp_cert_request.cert_request_pem
  validity_period_hours = local.env["certificate_validity_hours"]

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
    "server_auth"
  ]
}

