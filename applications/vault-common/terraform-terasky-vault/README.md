# **Terraform Vault Module Documentation**  

This Terraform module is used to **manage HashiCorp Vault**, including the creation and configuration of various Vault resources.  

Currently, the module:  
1. **Manages Vault Policies** – It provides predefined policies for **admin, operator, and developer** roles. To create additional policies, simply add new policy files under the `policies` directory.  
2. **Configures OIDC Authentication** – This module sets up **OIDC authentication** in Vault using **Ping Identity** as the identity provider.  

---

### **Module Breakdown:**

### **Requirements**  
Defines the **Terraform provider version** required to manage Vault.  
- Uses **Vault provider version 4.6.0**.  

### **Providers**  
Specifies the Vault provider version, ensuring compatibility with Vault API.  

### **Modules**  
- `vault_oidc` – Configures Vault OIDC authentication using Ping Identity.

### **Resources**  
- `vault_policy.policy` – Manages Vault policies, allowing role-based access control.

### **Inputs**
This module takes multiple inputs, including:  
- **OIDC Configuration:** Client ID, Client Secret, Discovery URL, Bound Audiences, and Mount Path.  
- **Vault Configuration:** Vault Address, Role ID, and Secret ID.  
- **Audit Devices:** Defines audit logging settings for Vault, storing logs in a specified location.  
- **OIDC Roles:** Maps Vault role names to groups and associated token policies.  

### **Outputs**  
Currently, no outputs are defined in this module.  

---

This module **simplifies Vault management** by automating policy creation and OIDC authentication configuration.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | 4.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vault"></a> [vault](#provider\_vault) | 4.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vault_oidc"></a> [vault\_oidc](#module\_vault\_oidc) | ./modules/vault_oidc | n/a |

## Resources

| Name | Type |
|------|------|
| [vault_policy.policy](https://registry.terraform.io/providers/hashicorp/vault/4.6.0/docs/resources/policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_audit_devices"></a> [audit\_devices](#input\_audit\_devices) | A list of audit devices. | <pre>list(object({<br>    type = string<br>    # local = bool<br>    options = map(any)<br>  }))</pre> | <pre>[<br>  {<br>    "local": true,<br>    "options": {<br>      "file_path": "/var/log/vault_audit.log"<br>    },<br>    "type": "file"<br>  }<br>]</pre> | no |
| <a name="input_oidc_bound_audiences"></a> [oidc\_bound\_audiences](#input\_oidc\_bound\_audiences) | A list of allowed token audiences | `list(any)` | n/a | yes |
| <a name="input_oidc_client_id"></a> [oidc\_client\_id](#input\_oidc\_client\_id) | Ping Identity Vault app client ID | `string` | n/a | yes |
| <a name="input_oidc_client_secret"></a> [oidc\_client\_secret](#input\_oidc\_client\_secret) | Ping Identity Vault app client secret | `string` | n/a | yes |
| <a name="input_oidc_discovery_url"></a> [oidc\_discovery\_url](#input\_oidc\_discovery\_url) | Ping Identity Authz server Issuer URI: i.e. https://auth.pingone.asia/<env\_id>/as | `string` | n/a | yes |
| <a name="input_oidc_mount_path"></a> [oidc\_mount\_path](#input\_oidc\_mount\_path) | Mount path for ping auth | `string` | `"ping"` | no |
| <a name="input_oidc_roles"></a> [oidc\_roles](#input\_oidc\_roles) | Map of Vault role names to their bound groups and token policies. Structure looks like this:<pre>roles = {<br>  admin = {<br>    token_policies = ["admin"]<br>    bound_groups = ["vault_admins"]<br>  },<br>  devs  = {<br>    token_policies = ["devs"]<br>    bound_groups = ["vault_devs"]<br>  }<br>}</pre> | `map(any)` | `{}` | no |
| <a name="input_vault_addr"></a> [vault\_addr](#input\_vault\_addr) | Vault address | `string` | `"http://127.0.0.1:8200"` | no |
| <a name="input_vault_role_id"></a> [vault\_role\_id](#input\_vault\_role\_id) | n/a | `string` | n/a | yes |
| <a name="input_vault_secret_id"></a> [vault\_secret\_id](#input\_vault\_secret\_id) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->