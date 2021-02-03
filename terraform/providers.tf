terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.9.4"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}