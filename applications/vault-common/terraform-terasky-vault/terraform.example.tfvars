################################
# Global Variables
################################

vault_addr = "http://127.0.0.1:8200"


################################
# Policies Variables
################################

enabled_roles = ["admin", "developer", "operator"]


################################
# Audit Variables
################################

audit_devices = [
  {
    description = "A local audit device."
    type        = "file"
    options = {
      file_path = "/dev/null"
    }
  },
  {
    description = "A socket audit device."
    type        = "socket"
    path        = "app_socket"
    local       = false
    options = {
      address     = "socket:8000"
      socket_type = "tcp"
    }
  },
  {
    description = "A syslog audit device."
    type        = "syslog"
    local       = false
    options = {
      facility = "AUTH"
      tag      = "vault"
    }
  }
]


################################
# OIDC Variables
################################

oidc_client_id       = "oidc_client_id"
oidc_client_secret   = "oidc_client_secret"
oidc_bound_audiences = ["SAME_AS_IN_oidc_client_id"]
oidc_discovery_url   = "oidc_discovery_url"

max_lease_ttl     = "1h"
default_lease_ttl = "1h"

oidc_roles = {
  admin = {
    token_policies = ["admin-policy"]
    bound_groups   = ["Administrators"]
  },
  operator = {
    token_policies = ["operator-policy"]
    bound_groups   = ["Operators"]
  },
  developer = {
    token_policies = ["developer-policy"]
    bound_groups   = ["Developers"]
  }
}