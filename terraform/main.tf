provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks1"
  location            = "North Europe"
  resource_group_name = "rg-azure-githubactions"
  dns_prefix          = "exampleaks1"
  default_node_pool {
    name                 = "default"
    node_count           = 1
    vm_size              = "Standard_B2S"
    orchestrator_version = "1.18.14"
  }
  kubernetes_version = "1.18.14"
  identity {
    type = "SystemAssigned"
  }
  tags = {
    Environment = var.environment
  }
}

provider "helm" {
  kubernetes {
    host  = azurerm_kubernetes_cluster.example.kube_config.0.host
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)
    client_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)
    client_key = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_key)
  }
}

resource "helm_release" "argocd" {
  name = "argocd"
  namespace = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  create_namespace = true
  values = [
    file("terraform/values/argocd.yaml")
  ]
}

resource "helm_release" "rootapp" {
  name = "rootapp"
  depends_on = [ helm_release.argocd ]
  namespace = "argocd"
  chart = "chart/argocd/"
  create_namespace = true
  values = [
    file("chart/argocd/values.yaml")
  ]
}