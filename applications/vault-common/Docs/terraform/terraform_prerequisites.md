# Terraform Prerequisites - Connect Terraform Cloud to Vault

To enable Terraform Cloud to authenticate securely with HashiCorp Vault, we use the AppRole authentication method. 

1. Create a terraform-policy.

```bash
vault policy write terraform-policy /tmp/terraform-policy.hcl
```

**Note**: We used the admin policy as the [terraform policy](../terraform/terraform-policy.hcl).

2. Create approle 

Enable approle auth method:

```bash
vault auth enable approle
```

Configure the approle terraform-role.

```bash
vault write auth/approle/role/terraform-role \
  token_policies="terraform-policy" \
  secret_id_ttl=0 \
  token_ttl=3600 \
  token_max_ttl=7200 \
  token_num_uses=0
```

- Role Creation Breakdown:
* **Assigned Policy** - `terraform-policy`.  
* **Secret ID expiration** - Never (`secret_id_ttl=0`).  
* **Token TTL** - 1 hour (`token_ttl=3600`).
* **Max TTL:** 2 hours (`token_max_ttl=7200`).  
* **Token uses** - Unlimited (`token_num_uses=0`).  

To obtain the approle's terraform-role role id run:

```bash
vault read auth/approle/role/terraform-role/role-id
```

To obtain the approle's terraform-role secret id run:

```bash
vault write -f auth/approle/role/terraform-role/secret-id
```


3. Save the `role-id` and `secret-id` secrets in Terraform Cloud in the workspace.