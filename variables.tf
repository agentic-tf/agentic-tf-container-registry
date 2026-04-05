variable "name" {
  type        = string
  description = "Name of the Azure Container Registry. Must be alphanumeric, 5-50 characters."

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "ACR name must be alphanumeric and between 5 and 50 characters."
  }
}

variable "location" {
  type        = string
  description = "Azure region where the Container Registry will be created."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the Container Registry."
}

variable "sku" {
  type        = string
  description = "SKU tier for the Container Registry. Must be Premium to support private endpoints."
  default     = "Premium"
}

# ── Networking ────────────────────────────────────────────────────────
variable "private_endpoint_subnet_id" {
  type        = string
  description = "Resource ID of the subnet where the private endpoint will be created."
}

variable "virtual_network_id" {
  type        = string
  description = "Resource ID of the virtual network to link with the private DNS zone."
}

variable "create_private_dns_zones" {
  type        = bool
  description = "Create private DNS zones for the registry private endpoint. Set false if centrally managed."
  default     = true
}

variable "private_dns_zone_ids" {
  type        = map(string)
  description = "Existing private DNS zone IDs keyed by subresource name when create_private_dns_zones = false."
  default     = {}
}

# ── Operational ───────────────────────────────────────────────────────
variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID for diagnostic logs. Empty string to skip."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources created by this module."
  default     = {}
}
