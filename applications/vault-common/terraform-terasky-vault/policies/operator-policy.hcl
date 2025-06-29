##############################
### Vault Policy - Operator ##
##############################

# Access to system health and diagnostics information
path "sys/health" {
  capabilities = ["read"]
}

# List existing policies
path "sys/policy" {
  capabilities = ["create", "read", "update"]
}

# Manage leases for secrets (renew, revoke, and view)
path "sys/leases/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage secret backends broadly across Vault.
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "list"]
}

# Manage audit devices (enable, disable, and configure)
path "sys/audit" {
  capabilities = ["read", "update", "list"]
}

# Manage Vault auth methods
path "auth/*" {
  capabilities = ["create", "read", "update", "list"]
}

# Manage Vault identities
path "identity/*" {
  capabilities = ["create", "read", "update", "list"]
}

# Access to list secrets KV v2 secrets engine
path "secrets/metadata/*" {
  capabilities = ["read", "list"]
}

# Full access to the PKI secrets engine (certificate management)
path "pki/*" {
  capabilities = ["create", "read", "update", "list"]
}

# Full access to the Transit secrets engine (encryption-as-a-service)
path "transit/*" {
  capabilities = ["create", "read", "update", "list"]
}

# Allow operators to look up their own token information
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow operators to renew their own token
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Allow operators to revoke their own token
path "auth/token/revoke-self" {
  capabilities = ["update"]
}

# Allow operators to create and manage tokens for others (if needed)
path "auth/token/create" {
  capabilities = ["create", "update"]
}

# Allow operators to lookup other tokens (if needed)
path "auth/token/lookup" {
  capabilities = ["update"]
}

# Allow operators to revoke other tokens (if needed)
path "auth/token/revoke" {
  capabilities = ["update"]
}

# Allow operators to access the capabilities endpoint to check permissions
path "sys/capabilities" {
  capabilities = ["read"]
}

# Allow operators to access the capabilities-self endpoint to check their own permissions
path "sys/capabilities-self" {
  capabilities = ["read"]
}
