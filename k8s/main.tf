locals {
  env = yamldecode(file("${path.module}/../config.yaml"))
}

##### MetalLB #####

resource "kubernetes_namespace" "metallb" {
  metadata {
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
    name = "metallb-system"
  }
}

resource "helm_release" "metallb" {
  depends_on = [kubernetes_namespace.metallb]
  name       = "metallb"
  namespace  = "metallb-system"
  #repository = "https://metallb.github.io/metallb"
  chart         = "charts/metallb"
  version       = "0.13.11"
  wait_for_jobs = true
  values = [
    templatefile("${path.module}/values-metallb.yaml", {
      registry_quay = local.env.registry_quay
    })
  ]
}

resource "helm_release" "ipaddresspool" {
  depends_on = [helm_release.metallb]
  name       = "ipaddresspool"
  namespace  = "metallb-system"
  chart      = "charts/ipaddress"
  version    = "0.1.0"
  set {
    name  = "lbaddress"
    value = local.env.lbaddress
  }
}

##### Nginx Ingress #####

resource "helm_release" "ingress" {
  depends_on       = [helm_release.ipaddresspool]
  name             = "ingress"
  namespace        = "ingress-nginx"
  create_namespace = true
  #helm pull oci://ghcr.io/nginxinc/charts/nginx-ingress --untar --version 0.18.1
  #repository  = "oci://ghcr.io/nginxinc/charts/nginx-ingress"
  chart   = "charts/nginx-ingress"
  version = "0.18.1"

  set {
    name  = "service.annotations"
    value = "metallb.universe.tf/address-pool: default"
  }

  set {
    name  = "controller.setAsDefaultIngress"
    value = true
  }

  set {
    name  = "controller.image.repository"
    value = "${local.env.registry_docker}/nginx/nginx-ingress"
  }
}

##### OpenEBS Jiva #####

resource "kubernetes_namespace" "openebs" {
  metadata {
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
    name = "openebs"
  }
}

resource "helm_release" "openebs-jiva" {
  depends_on       = [helm_release.ingress, kubernetes_namespace.openebs]
  name             = "openebs"
  namespace        = "openebs"
  create_namespace = true
  chart            = "charts/jiva"
  #repository = "https://openebs.github.io/jiva-operator"
  version = "3.5.1"

  values = [
    templatefile("${path.module}/values-openebs.yaml", {
      registry_docker = local.env.registry_docker
      registry_k8s    = local.env.registry_k8s
    })
  ]
}

##### MinIO #####

resource "kubernetes_namespace" "minio-tenant" {
  metadata {
    name = "minio-tenant"
  }
}

resource "helm_release" "minio-operator" {
  depends_on       = [helm_release.ingress]
  name             = "operator"
  namespace        = "minio-operator"
  create_namespace = true
  chart            = "charts/operator"
  #repository = "https://operator.min.io/"
  version = "5.0.9"

  values = [
    templatefile("${path.module}/values-minio-operator.yaml", {
      registry_quay = local.env.registry_quay
      domain        = local.env["domain"]
    })
  ]
}

resource "helm_release" "minio-tenant" {
  depends_on       = [helm_release.minio-operator, kubernetes_namespace.minio-tenant]
  name             = "tenant"
  namespace        = "minio-tenant"
  create_namespace = true
  chart            = "charts/tenant"
  #repository = "https://operator.min.io/"
  version = "5.0.9"

  values = [
    templatefile("${path.module}/values-minio-tenant.yaml", {
      registry_quay = local.env.registry_quay
      domain        = local.env["domain"]
    })
  ]
}

resource "kubernetes_secret_v1" "pmp-tls" {
  depends_on = [kubernetes_namespace.minio-tenant]
  metadata {
    name      = "pmp-tls"
    namespace = "minio-tenant"
  }
  data = {
    "tls.crt" = "${file("${path.module}/../cert/pmp-cert.pem")}",
    "tls.key" = "${file("${path.module}/../cert/pmp-key.pem")}"
  }
  type = "kubernetes.io/tls"
}

##### PostgreSQL #####

resource "helm_release" "cnpg" {
  depends_on       = [helm_release.ingress]
  name             = "cnpg"
  namespace        = "cnpg-system"
  create_namespace = true
  chart            = "charts/cloudnative-pg"
  #repository = "https://cloudnative-pg.github.io/charts"
  version       = "0.18.2"
  wait_for_jobs = true

  values = [
    templatefile("${path.module}/values-cnpg.yaml", {
      registry_ghcr = local.env.registry_ghcr
    })
  ]
}

resource "helm_release" "postgres" {
  depends_on = [helm_release.cnpg]
  name       = "postgres"
  namespace  = "cnpg-system"
  chart      = "charts/pgcluster"
  version    = "0.1.0"
}
