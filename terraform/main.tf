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

provider "kubectl" {
  host  = azurerm_kubernetes_cluster.example.kube_config.0.host
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)
  client_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)
  client_key = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_key)
  load_config_file = false
}
          
provider "kubernetes" {
  host  = azurerm_kubernetes_cluster.example.kube_config.0.host
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)
  client_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)
  client_key = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_key)
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

locals {
  resources = split("\n---\n", file("manifests/install.yaml"))
}

resource "kubectl_manifest" "test" {

  count     = length(local.resources)
  yaml_body = local.resources[count.index]
  override_namespace = "argocd"
  wait =  true
  depends_on = [ kubernetes_namespace.argocd ]
}

provider "helm" {
  kubernetes {
    host  = azurerm_kubernetes_cluster.example.kube_config.0.host
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)
    client_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)
    client_key = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_key)
  }
}

resource "helm_release" "argocd-bootstrap" {
  name = "argocd-bootstrap"
  namespace = "argocd"
  chart = "chart/argocd"
  create_namespace = "true"
}