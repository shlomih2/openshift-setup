# Vault OIDC

In order to add more roles to oidc you would need to add the following in the tfvars [file](../terraform.tfvars).

```tml
oidc_roles = {
  admin = {
    token_policies = ["admin-policy"]
    bound_groups   = ["AMAT-APP-MySM-Administrators"]
  },
  operator = {
    token_policies = ["operator-policy"]
    bound_groups   = ["AMAT-APP-MySM-Operators"]
  },
  developer = {
    token_policies = ["developer-policy"]
    bound_groups   = ["AMAT-APP-MySM-Developers"]
  }
  # Add here more roles...
  # <name_of_role> = {
  #   token_policies = ["your-policy"]
  #   bound_groups   = ["name-of-group-in-ping"]
  # }
}
```

