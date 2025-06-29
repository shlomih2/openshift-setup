##################
# Vault Global
##################

variable "vault_addr" {
  type        = string
  description = "Vault address"
  default     = "http://127.0.0.1:8200"
}

##################
# Vault Audit
##################

variable "audit_devices" {
  description = "A list of audit devices."
  type = list(object({
    type = string
    # local = bool
    options = map(any)
  }))
  default = [{
    type  = "file"
    local = true
    options = {
      file_path = "/var/log/vault_audit.log"
    }
  }]
}

##################
# Vault OIDC
##################

variable "oidc_discovery_url" {
  type        = string
  description = "OIDC Identity Authz server Issuer URI"
}

variable "oidc_mount_path" {
  type        = string
  description = "Mount path for OIDC auth"
  default     = "oidc"
}

variable "oidc_client_id" {
  type        = string
  description = "OIDC Identity Vault app client ID"
}

variable "oidc_client_secret" {
  type        = string
  description = "OIDC Identity Vault app client secret"
}

variable "oidc_bound_audiences" {
  type        = list(any)
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

variable "oidc_roles" {
  type        = map(any)
  default     = {}
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

variable "enabled_roles" {
  description = "List of roles for which policies should be created."
  type        = list(string)
  default     = []
}