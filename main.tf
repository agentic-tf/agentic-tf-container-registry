locals {
  private_dns_zone_ids = var.create_private_dns_zones ? {
    registry = azurerm_private_dns_zone.acr[0].id
  } : var.private_dns_zone_ids
}

resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  # ── Security hardening ────────────────────────────────────────────────
  # I.AZR.0257 / I.AZR.0033 — no public access
  public_network_access_enabled = false

  # I.AZR.0137 — disable admin account; use Entra ID RBAC instead
  admin_enabled = false

  # Allow trusted Azure services to bypass network rules
  network_rule_bypass_option = "AzureServices"

  # I.AZR.0019 — Managed Identity
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# ── Private Endpoint ──────────────────────────────────────────────────
resource "azurerm_private_endpoint" "acr" {
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = azurerm_container_registry.this.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = contains(keys(local.private_dns_zone_ids), "registry") ? [1] : []
    content {
      name                 = "acr-dns-group"
      private_dns_zone_ids = [local.private_dns_zone_ids["registry"]]
    }
  }

  tags = var.tags
}

# ── Private DNS Zone ──────────────────────────────────────────────────
resource "azurerm_private_dns_zone" "acr" {
  count               = var.create_private_dns_zones ? 1 : 0
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  count                 = var.create_private_dns_zones ? 1 : 0
  name                  = "${var.name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.acr[0].name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false
  tags                  = var.tags
}

# ── Diagnostic Settings (I.AZR.0013) ─────────────────────────────────
resource "azurerm_monitor_diagnostic_setting" "acr" {
  count = var.log_analytics_workspace_id != "" ? 1 : 0

  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_container_registry.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ContainerRegistryRepositoryEvents"
  }

  enabled_log {
    category = "ContainerRegistryLoginEvents"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
