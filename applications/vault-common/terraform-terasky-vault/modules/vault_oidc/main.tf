resource "vault_jwt_auth_backend" "oidc" {

  description = "Identity OIDC"
  path        = var.mount_path

  type               = "oidc"
  oidc_discovery_url = var.discovery_url
  bound_issuer       = var.discovery_url
  oidc_client_id     = var.client_id
  oidc_client_secret = var.client_secret
  
  tune {
    listing_visibility = "unauth"
    default_lease_ttl  = var.default_lease_ttl
    max_lease_ttl      = var.max_lease_ttl
    token_type         = var.token_type
  }
}

resource "vault_jwt_auth_backend_role" "role" {
  
  for_each       = var.roles

  backend        = vault_jwt_auth_backend.oidc.path
  role_name      = each.key
  token_policies = each.value.token_policies

  allowed_redirect_uris = [
    "${replace(var.vault_addr, ":8200", ":8250")}/ui/vault/auth/${vault_jwt_auth_backend.oidc.path}/oidc/callback",
    "${replace(var.vault_addr, ":8200", ":8250")}/oidc/callback",
    "http://localhost:8250/oidc/callback"
  ]

  user_claim      = "sub"
  role_type       = "oidc"
  bound_audiences = var.bound_audiences
  oidc_scopes = [
    "openid",
    "profile",
    "email",
  ]
  bound_claims = {
    groups = join(",", each.value.bound_groups)
  }
}