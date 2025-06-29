
### helm-values:

```yaml
  extraSecretEnvironmentVars:
  - envName: AZURE_TENANT_ID
    secretName: azure-vault-secret
    secretKey: AZURE_TENANT_ID

  - envName: AZURE_CLIENT_ID
    secretName: azure-vault-secret
    secretKey: AZURE_CLIENT_ID

  - envName: AZURE_CLIENT_SECRET
    secretName: azure-vault-secret
    secretKey: AZURE_CLIENT_SECRET

  - envName: VAULT_AZUREKEYVAULT_VAULT_NAME
    secretName: azure-vault-secret
    secretKey: VAULT_AZUREKEYVAULT_VAULT_NAME

  - envName: VAULT_AZUREKEYVAULT_KEY_NAME
    secretName: azure-vault-secret
    secretKey: VAULT_AZUREKEYVAULT_KEY_NAME

  - envName: AZURE_TENANT_ID_secondary
    secretName: azure-vault-secret
    secretKey: AZURE_TENANT_ID_secondary

  - envName: AZURE_CLIENT_ID_secondary
    secretName: azure-vault-secret
    secretKey: AZURE_CLIENT_ID_secondary

  - envName: AZURE_CLIENT_SECRET_secondary
    secretName: azure-vault-secret
    secretKey: AZURE_CLIENT_SECRET_secondary

  - envName: VAULT_AZUREKEYVAULT_VAULT_NAME_secondary
    secretName: azure-vault-secret
    secretKey: VAULT_AZUREKEYVAULT_VAULT_NAME_secondary

  - envName: VAULT_AZUREKEYVAULT_KEY_NAME_secondary
    secretName: azure-vault-secret
    secretKey: VAULT_AZUREKEYVAULT_KEY_NAME_secondary
```

### 1. Create secret in OpenShift that contain Azure credentials for both keyvaults

```bash
oc create secret generic azure-vault-secret
--from-literal=AZURE_TENANT_ID="<AZURE_TENANT_ID_FOR_KEYVAULT_1>"
--from-literal=AZURE_CLIENT_ID="<AZURE_CLIENT_ID_FOR_KEYVAULT_1>"
--from-literal=AZURE_CLIENT_SECRET="<AZURE_CLIENT_SECRET_FOR_KEYVAULT_1>"
--from-literal=VAULT_AZUREKEYVAULT_VAULT_NAME="<VAULT_AZUREKEYVAULT_VAULT_NAME_FOR_KEYVAULT_1>"
--from-literal=VAULT_AZUREKEYVAULT_KEY_NAME="<VAULT_AZUREKEYVAULT_KEY_NAME_FOR_KEYVAULT_1>"
--from-literal=AZURE_TENANT_ID_secondary="<AZURE_TENANT_ID_FOR_KEYVAULT_secondary>"
--from-literal=AZURE_CLIENT_ID_secondary="<AZURE_CLIENT_ID_FOR_KEYVAULT_secondary>"
--from-literal=AZURE_CLIENT_SECRET_secondary="<AZURE_CLIENT_SECRET_FOR_KEYVAULT_secondary>"
--from-literal=VAULT_AZUREKEYVAULT_VAULT_NAME_secondary="<VAULT_AZUREKEYVAULT_VAULT_NAME_FOR_KEYVAULT_secondary>"
--from-literal=VAULT_AZUREKEYVAULT_KEY_NAME_secondary="<VAULT_AZUREKEYVAULT_KEY_NAME_FOR_KEYVAULT_secondary>"
```


### 2. Install vault with single autounseal:

```bash
  ha:
        ...
        # enable_multiseal = true
        ...
        seal "azurekeyvault" {
          name = "primary"
          priority = "1"
        }

        # seal "azurekeyvault" {
        #   name = "secondary"
        #   priority = "2"
        # }
        ...
```


### 3. Init vault 

```bash
oc exec -it -n <VAULT_NAMESPACE> vault-0 -- vault operator init 
```

### 4. Enable multi-seal - edit configmap

```bash
oc edit cm -n <VAULT_NAMESPACE> vault-config

  ha:
        ...
        enable_multiseal = true
        ...
        seal "azurekeyvault" {
          name = "primary"
          priority = "1"
        }

        # seal "azurekeyvault" {
        #   name = "secondary"
        #   priority = "2"
        # }
        ...
```

### 5. Restart vault

```bash
oc delete po -n <VAULT_NAMESPACE> --all
```

### 6. Add secondary unseal

```bash
```bash
oc edit cm -n <VAULT_NAMESPACE> vault-config

  ha:
        ...
        enable_multiseal = true
        ...
        seal "azurekeyvault" {
          name = "primary"
          priority = "1"
        }

        seal "azurekeyvault" {
          name = "secondary"
          priority = "2"
        }
        ...
```

### 7. Restart vault

```bash
oc delete po -n <VAULT_NAMESPACE> --all
```


### Test

```bash
oc get po -n <VAULT_NAMESPACE>

# Check Current SealWrap Status (Initial GET Request)
# This command retrieves the current status of SealWrap within Vault by making a GET request to the sys/sealwrap/rewrap endpoint.
# This step is useful for checking if there are any keys that require rewrapping.
oc exec -it -n <VAULT_NAMESPACE> vault-0 -- curl --header "X-Vault-Token: <VAULT_ROOT_TOKEN>" --request GET https://127.0.0.1:8200/v1/sys/sealwrap/rewrap -k

# Trigger SealWrap Rewrap Operation (POST Request)
# This command triggers a rewrap operation for keys protected by SealWrap.
# This is necessary when changing encryption keys or rotating them as part of a security policy.
oc exec -it -n <VAULT_NAMESPACE> vault-0 -- curl --header "X-Vault-Token: <VAULT_ROOT_TOKEN>" --request POST https://127.0.0.1:8200/v1/sys/sealwrap/rewrap -k

# Check SealWrap Status After Rewrap (GET Request)
# This command checks the status of SealWrap again after the rewrap operation to confirm that all keys have been successfully rewrapped.
# Ideally, there should be no keys left requiring rewrap if the operation was successful.
oc exec -it -n <VAULT_NAMESPACE> vault-0 -- curl --header "X-Vault-Token: <VAULT_ROOT_TOKEN>" --request GET https://127.0.0.1:8200/v1/sys/sealwrap/rewrap -k

# Check Vault Pod Logs
# This command retrieves the logs from the vault-0 pod.
# Reviewing logs can help detect any issues or errors encountered during the rewrap process.
# Useful for debugging or confirming the success of the rewrap operation.
oc logs -n <VAULT_NAMESPACE> vault-0

# Monitor the re-wrap process - wait until "fully_wrapped"s: true:
vault read sys/seal-backend-status -format=json

```

# Change azure secret id ( before exparation)
1. Edit the secret with new variables (secret_id, key_name, etc.).   
```bash
oc edit secret -n <VAULT_NAMESPACE> azure-vault-secret
```

2. Delete all pods again:
```bash
 oc delete po vault-0 vault-1 vault-2
```

3. To verify that the vault is unseal successful, run:
```bash
vault status
```

4. Monitor the re-wrap process - wait until "fully_wrapped"s: true:
```bash
  vault read sys/seal-backend-status -format=json
```


# Troubleshooting: Changing Secret Values

There can be scenarios where secret values cannot be changed, for example:

- The secret ID on Azure has expired.
- The Azure Key Vault has been accidentally deleted.

In both cases, you might be unable to modify the Vault configuration due to the following error:

"cannot make seal config changes while seal re-wrap is in progress, please revert any seal configuration changes."

This message means that Vault is in the middle of a re-wrap operation. When you change the seal configuration, Vault starts a re-wrap process to re-encrypt its master key with the new seal parameters. If one of the seal backends becomes unreachable or misconfigured (for example, due to an expired secret ID or a deleted Key Vault), the re-wrap operation can't complete. As a safety measure, Vault won't allow further seal configuration changes until the re-wrap process finishes.
Workaround for Stuck Re-wrap Operations
To resolve this issue, you can temporarily disable the re-wrap safety check:

1. Always take a backup of the secret before making changes:
```bash
 oc get secret azure-vault-secret -o yaml > azure-vault-secret.yaml.bkp
```

2. Edit the StatefulSet and add the environment variable:
```yaml
spec:
  # ...
  template:
    spec:
      containers:
      - name: vault
        # ...
        env:
        - name: VAULT_SEAL_REWRAP_SAFETY
          value: "disable"
```

3. Delete all pods to apply the changes:
```bash
 oc delete po vault-0 vault-1 vault-2
```

4. Edit the secret with new variables (secret_id, key_name, etc.).   
```bash
oc edit secret -n <VAULT_NAMESPACE> azure-vault-secret
```

5. Delete all pods again:
```bash
 oc delete po vault-0 vault-1 vault-2
```

## **Validation**
To verify that the vault is unseal successful, run:

```bash
vault status
```

6. Monitor the re-wrap process - wait until "fully_wrapped"s: true:
```bash
  vault read sys/seal-backend-status -format=json
```

7. Edit the StatefulSet to remove the VAULT_SEAL_REWRAP_SAFETY environment variable.   
8. Delete all pods one final time:
```bash
 oc delete po vault-0 vault-1 vault-2
```