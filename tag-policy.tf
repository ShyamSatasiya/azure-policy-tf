



resource "azurerm_policy_definition" "enforce_tags" {
  name         = "enforce-required-tags"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce Required Tags"
  description  = "This policy requires the 'Environment' tag on all resources."

  policy_rule = jsonencode({
    "if": {
      "not": {
        "field": "[concat('tags[', 'Environment', ']')]",
        "exists": "true"
      }
    },
    "then": {
      "effect": "deny"
    }
  })

  metadata = jsonencode({
    "category": "Custom"
  })
}
