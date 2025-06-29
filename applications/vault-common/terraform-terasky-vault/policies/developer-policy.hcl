################################
### Vault Policy - Developer ###
################################

# Read and write access to secrets in the KV secrets engine
path "secrets/data/*" {
  capabilities = ["create", "read", "update"]
}

# List secrets in the KV secrets engine
path "secrets/metadata/*" {
  capabilities = ["read", "list"]
}

# Renew leases for secrets used by their applications
path "sys/leases/renew" {
  capabilities = ["update"]
}

# Access to the PKI secrets engine for certificate issuance
path "pki/issue/*" {
  capabilities = ["create", "update"]
}

# Access to the Transit secrets engine for encryption/decryption
path "transit/encrypt/*" {
  capabilities = ["create", "update"]
}

path "transit/decrypt/*" {
  capabilities = ["create", "update"]
}

# Access to the Transit secrets engine for key derivation
path "transit/datakey/*" {
  capabilities = ["create", "update"]
}

# Access to the Transit secrets engine for key rotation
path "transit/keys/*" {
  capabilities = ["read", "update"]
}

# Allow developers to look up their own token information
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow developers to renew their own token
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Allow developers to revoke their own token
path "auth/token/revoke-self" {
  capabilities = ["update"]
}

# Allow developers to access the capabilities-self endpoint to check their own permissions
path "sys/capabilities-self" {
  capabilities = ["read"]
}
