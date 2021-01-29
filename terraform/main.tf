provider "azurerm" {
  version = ">2.5.0"
  features {}
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks1"
  location            = "North Europe"
  resource_group_name = "rg-azure-githubactions"
  dns_prefix          = "exampleaks1"
    default_node_pool {
        name       = "default"
        node_count = 1
        vm_size    = "Standard_B2S"
        orchestrator_version = "1.18.14"
    }
  kubernetes_version    = "1.18.14"
  identity {
    type = "SystemAssigned"
  }
  tags = {
    Environment = var.environment
  }
}

resource "local_file" "kubeconfig" {
    content = azurerm_kubernetes_cluster.example.kube_config_raw
    filename = pathexpand("~/.kube/config")
}