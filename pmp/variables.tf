variable "namespace" {
  description = ""
  type        = string
  default     = "pmp"
}

variable "mxpcPath" {
  description = ""
  type        = string
  default     = "https://cdn.mendix.com/mendix-for-private-cloud/mxpc-cli"
}

variable "mendixOperatorVersion" {
  description = ""
  type        = string
  default     = "2.13.0"
}

variable "db_host" {
  description = ""
  type        = string
  default     = "pmp-rw.cnpg-system"
}

variable "storage_endpoint" {
  description = ""
  type        = string
  default     = "http://minio.minio-tenant.svc.cluster.local"
}

variable "storage_accesskey" {
  description = ""
  type        = string
  default     = "minio"
}

variable "storage_secretkey" {
  description = ""
  type        = string
}

variable "ingress_domain" {
  description = ""
  type        = string
}

variable "registry_url" {
  description = ""
  type        = string
}

variable "registry_name" {
  description = ""
  type        = string
}

variable "registry_user" {
  description = ""
  type        = string
}

variable "registry_password" {
  description = ""
  type        = string
}

variable "mxAdminPassword" {
  description = ""
  type        = string
}

variable "sourceURL" {
  description = ""
  type        = string
  default     = "oci-image://public.ecr.aws/p2w4x6l6/mendix-private-platform:1.4.2.a741c7ab"
}

// variable "kubeconfig_path" {
//   type    = string~ZSDXFG5H6UJKOP]
//   default = "../talos/kubeconfig"
// }