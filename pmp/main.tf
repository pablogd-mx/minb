locals {
  env = yamldecode(file("${path.module}/../config.yaml"))
}

data "kubernetes_secret" "db_secret" {
  metadata {
    name      = "pmp-superuser"
    namespace = "cnpg-system"
  }
}

resource "helm_release" "mendix_installer" {
  name             = "mendixinstaller"
  chart            = "./charts/mendix-installer"
  namespace        = local.env["namespace"]
  create_namespace = true
  wait_for_jobs    = true
  values = [
    templatefile("${path.module}/values-mendix-installer.yaml",
      {
        namespace             = local.env["namespace"],
        mxpcPath              = local.env["mxpcPath"],
        mendixOperatorVersion = local.env["mendixOperatorVersion"],
        db_host               = var.db_host,
        db_user               = data.kubernetes_secret.db_secret.data["username"],
        db_password           = data.kubernetes_secret.db_secret.data["password"],
        storage_endpoint      = var.storage_endpoint,
        storage_accesskey     = var.storage_accesskey,
        storage_secretkey     = local.env["storage_secretkey"],
        ingress_domain        = local.env["domain"],
        registry_url          = local.env["registry_url"],
        registry_name         = local.env["registry_name"],
        registry_user         = local.env["registry_user"],
        registry_password     = local.env["registry_password"]
    })
  ]
}

resource "kubernetes_secret_v1" "pmp-tls" {
  depends_on = [helm_release.mendix_installer]
  metadata {
    name      = "pmp-tls"
    namespace = local.env["namespace"]
  }
  data = {
    "tls.crt" = "${file("${path.module}/../cert/pmp-cert.pem")}",
    "tls.key" = "${file("${path.module}/../cert/pmp-key.pem")}"
  }
  type = "kubernetes.io/tls"
}

resource "helm_release" "mendix_pmp" {
  depends_on       = [helm_release.mendix_installer, kubernetes_secret_v1.pmp-tls]
  name             = "pmp"
  chart            = "./charts/mendixapp"
  namespace        = local.env["namespace"]
  create_namespace = true
  values = [
    templatefile("${path.module}/values-pmp.yaml",
      {
        mxAdminPassword = local.env["mxAdminPassword"],
        sourceURL       = local.env["sourceURL"]
    })
  ]
}

