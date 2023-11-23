terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }
  }
}

provider "kubernetes" {
  # Configuration options
  config_path = var.kubeconfig_path
}

provider "helm" {
  # Configuration options
  kubernetes {
    config_path = var.kubeconfig_path
  }
}
