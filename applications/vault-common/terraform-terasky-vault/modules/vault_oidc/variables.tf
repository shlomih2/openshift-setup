variable "vault_addr" {
  type        = string
  description = "Vault address in the form of https://domain:8200"
}

variable "discovery_url" {
  type        = string
  description = "OIDC Identity Authz server Issuer URI"
}

variable "mount_path" {
  type        = string
  description = "Mount path for OIDC auth"
  default     = "oidc"
}

variable "client_id" {
  type        = string
  description = "OIDC Identity Vault app client ID"
}

variable "client_secret" {
  type        = string
  description = "OIDC Identity Vault app client secret"
}

variable "bound_audiences" {
  type        = list
  description = "A list of allowed token audiences"
}

variable "default_lease_ttl" {
  type        = string
  description = "Default lease TTL for Vault tokens"
  default     = "768h"
}

variable "max_lease_ttl" {
  type        = string
  description = "Maximum lease TTL for Vault tokens"
  default     = "768h"
}

variable "token_type" {
  type        = string
  description = "Token type for Vault tokens"
  default     = "default-service"
}

variable "roles" {
  type    = map
  default = {}
  description = <<EOF
Map of Vault role names to their bound groups and token policies. Structure looks like this:

```
roles = {
  admin = {
    token_policies = ["admin"]
    bound_groups = ["vault_admins"]
  },
  devs  = {
    token_policies = ["devs"]
    bound_groups = ["vault_devs"]
  }
}
```
EOF
}