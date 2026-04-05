output "id" {
  description = "Resource ID of the Azure Container Registry."
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "Name of the Azure Container Registry."
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "The URL that can be used to log into the Container Registry."
  value       = azurerm_container_registry.this.login_server
}

output "identity_principal_id" {
  description = "Principal ID of the system-assigned managed identity."
  value       = azurerm_container_registry.this.identity[0].principal_id
}

output "private_endpoint_id" {
  description = "Resource ID of the private endpoint."
  value       = azurerm_private_endpoint.acr.id
}
