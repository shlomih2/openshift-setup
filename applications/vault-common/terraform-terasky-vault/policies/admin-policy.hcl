#############################
### Vault Policy - Admin ####
#############################
# Explicitly deny all operations on the "master" user in userpass auth method
path "auth/userpass/users/master" {
  capabilities = ["deny"]
}

# Explicitly deny all operations on the "master-backup" user in userpass auth method
path "auth/userpass/users/master-backup" {
  capabilities = ["deny"]
}


# permit access to all sys backend configurations to administer Vault itself
path "sys/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage audit devices (enable, disable, and configure)
path "sys/audit" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# List existing policies
path "sys/policy" {
  capabilities = ["read"]
}

# Create and manage ACL policies broadly across Vault
path "sys/policy/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage namespaces
path "sys/namespaces/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List Namespaces
path "sys/namespaces" {
  capabilities = ["list"]
}

# Manage leases for secrets (renew, revoke, and view)
path "sys/leases/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Access system health and diagnostics information
path "sys/health" {
  capabilities = ["read", "sudo"]
}

# Manage and manage secret backends broadly across Vault.
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Enable advanced debugging features if needed
path "sys/debug/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# manage Vault auth methods
path "auth/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# permit access to administer secrets KV secrets engine - admin cannot read secrets
path "secrets/*" {
  capabilities = ["create", "update", "delete"]
}

# permit access to list secrets KV v2 secrets engine
path "secrets/metadata/*" {
  capabilities = ["read", "list"]
}

# Manage Vault identities
path "identity/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Full access to the PKI secrets engine (certificate management)
path "pki/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Full access to the Transit secrets engine (encryption-as-a-service)
path "transit/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

############## View all Secrets Engines ##################
# Allow listing secrets in all KV secret engines
path "+/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow listing secrets in all KV version 2 secret engines
path "+/metadata/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Generic catch-all for other secret engines
path "+/*" {
  capabilities = ["create", "read", "list"]
}
