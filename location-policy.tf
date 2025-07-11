resource "azurerm_policy_definition" "deny_location" {
  name         = "deny-unsupported-locations"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny Unsupported Locations"
  description  = "This policy denies resource creation in unsupported regions."

  policy_rule = jsonencode({
    "if": {
      "field": "location",
      "notIn": ["eastus", "westus"]
    },
    "then": {
      "effect": "deny"
    }
  })

  metadata = jsonencode({
    "category": "Custom"
  })
}
