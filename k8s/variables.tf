variable "lbaddress" {
  description = "load balancer ip"
  type        = string
}

variable "registry" {
  description = "air-gap registry for k8s images"
  type        = string
  default     = ""
}

variable "kubeconfig_path" {
  type    = string
  default = "../talos/kubeconfig"
}