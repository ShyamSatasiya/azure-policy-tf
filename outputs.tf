output "deny_location_policy_id" {
  value = azurerm_policy_definition.deny_location.id
}

output "enforce_tags_policy_id" {
  value = azurerm_policy_definition.enforce_tags.id
}