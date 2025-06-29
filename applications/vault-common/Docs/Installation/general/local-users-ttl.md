# Changing TTL for Existing Users in Vault Userpass Auth

This guide explains how to update the Time-To-Live (TTL) settings for an existing user in Vault's userpass authentication method.

## Prerequisites

- Vault CLI installed and configured
- Appropriate permissions to modify users in the userpass auth method
- Vault server running and accessible

## Understanding TTL and Max TTL

- **TTL (Time-To-Live)**: The default lease duration for tokens issued to this user
- **Max TTL**: The maximum allowed lifetime for tokens issued to this user

## Steps to Update TTL Settings

1. First, ensure you're authenticated to Vault with appropriate permissions:

```bash
vault login
```

2. Use the `vault write` command to update the TTL settings for the user:

```bash
vault write auth/userpass/users/<user_name> \
  ttl=15m \
  max_ttl=1h
```

This command:
- Updates the user `<user_name>` in the `userpass` auth method
- Sets the default TTL to 15 mins
- Sets the maximum TTL to 1 hours

3. Verify the changes (optional):

```bash
vault read auth/userpass/users/<user_name>
```

## Important Notes

- This change will not affect existing tokens, only new tokens issued after the change
- The user will need to log out and log back in for the new TTL settings to take effect
- The `max_ttl` cannot be greater than the auth method's configured max TTL
- If you omit either `ttl` or `max_ttl`, the existing value will be preserved

## Troubleshooting

If you encounter "permission denied" errors:
- Ensure you have the necessary capabilities (`update`) on the path `auth/userpass/users/<user_name>`
- Check your token's policy with `vault token lookup`

## Example Policy

A policy that allows updating user TTL settings might look like:

```hcl
path "auth/userpass/users/*" {
  capabilities = ["update", "read"]
}
```