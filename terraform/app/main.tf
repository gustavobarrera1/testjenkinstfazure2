provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = "rg-gbarrera"
}

data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_user_assigned_identity" "app_identity" {
  name                = var.app_identity
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_user_assigned_identity.app_identity.principal_id
  role_definition_name = "AcrPull"
  scope                = data.azurerm_container_registry.acr.id
}

resource "azurerm_container_app" "app" {
  name                         = var.container_app
  container_app_environment_id = "/subscriptions/${var.subscription_id}/resourceGroups/${data.azurerm_resource_group.rg.name}/providers/Microsoft.App/managedEnvironments/my-containerapp-env"
  resource_group_name          = data.azurerm_resource_group.rg.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_identity.id]
  }

  template {
    container {
      name   = "mycontainer"
      image  = "${data.azurerm_container_registry.acr.login_server}/myapp:latest"
      cpu    = 0.5
      memory = "1.0Gi"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  registry {
    server   = data.azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.app_identity.id
  }

  # scale {
  #   min_replicas = 1
  #   max_replicas = 2
  # }

  depends_on = [azurerm_role_assignment.acr_pull]
}