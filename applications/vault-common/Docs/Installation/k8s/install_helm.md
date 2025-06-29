# **Installing and Upgrading Vault on k8s with Helm**

This guide outlines the best practices for deploying **HashiCorp Vault** on **k8s**, including security hardening recommendations.

---

## **Prerequisites**

### **1. Create the Vault Namespace**
Ensure the `vault` namespace exists before proceeding:

```bash
kubectl create ns <VAULT_NAMESPACE>
```

### **2. Create a Secret for Vault Enterprise License**
Store your Vault license as a Kubernetes secret:

```bash
kubectl create secret generic vault-enterprise-license --from-file=license=./path/to/your/vault.hclic --namespace <VAULT_NAMESPACE>
```

### **3. Create a Secret for Azure Auto-Unseal/ AWS KMS**
For Vault auto-unseal using **Azure Key Vault**/**AWS KMS**, create the required secrets. More details can be found [here](../../docs/multi_auto_unseal.md).

For auto unseal with Azure Auto-Unseal
```bash
kubectl create secret generic azure-vault-secret --namespace <VAULT_NAMESPACE> \
--from-literal=AZURE_TENANT_ID="<AZURE_TENANT_ID_FOR_KEYVAULT>" \
--from-literal=AZURE_CLIENT_ID="<AZURE_CLIENT_ID_FOR_KEYVAULT>" \
--from-literal=AZURE_CLIENT_SECRET="<AZURE_CLIENT_SECRET_FOR_KEYVAULT>" \
--from-literal=VAULT_AZUREKEYVAULT_VAULT_NAME="<VAULT_AZUREKEYVAULT_VAULT_NAME_FOR_KEYVAULT>" \
--from-literal=VAULT_AZUREKEYVAULT_KEY_NAME="<VAULT_AZUREKEYVAULT_KEY_NAME_FOR_KEYVAULT>" 
```

For auto unseal with AWS KMS
```bash
kubectl create secret generic aws-vault-secret \
--from-literal=AWS_ACCESS_KEY_ID="<AWS_ACCESS_KEY_ID>" \
--from-literal=AWS_SECRET_ACCESS_KEY="<AWS_SECRET_ACCESS_KEY>" \
--from-literal=VAULT_AWSKMS_SEAL_KEY_ID="<VAULT_AWSKMS_SEAL_KEY_ID>"
```

### **4. Create a Secret for TLS Certificates**
Ensure that the required **TLS certificates** are created and stored in a secret. See [certificate creation](./../../docs/certificate_creation.md) for details.

### **5. Create a Secret for Registry**
To pull images from a private JFrog registry, create a secret for the registry credentials:

```bash
kubectl create secret docker-registry jfrog-pull-secret \
  --docker-server=<ARTIFACTORY_URL> \
  --docker-username=<USERNAME> \
  --docker-password=<PASSWORD_OR_API_KEY> \
  --docker-email=your-email@example.com

```

Ensure this secret is referenced in the `values.yaml` file:

```yaml
global:
    ...
    imagePullSecrets:
        - name: jfrog-pull-secret
```

---

## **Installing Vault on K8S**

Follow these steps to install Vault using **Helm**.

### **1. Review the Helm Values**
Before installation, review the **[values.yaml](./values.yaml)** file to align the configuration with your requirements.

Key parameters to verify:
- **Ingress settings**
- **Vault configurations** (storage, HA setup, security settings)

### **2. Install Vault Using Helm**
```
Run the Jenkins pipeline to deploy the updated configuration.
```

It is recommended to use the Jenkins pipeline to deploy the updated configuration, as it ensures consistency and automation in the deployment process.   
Alternatively, you can use helm in order to install/upgrade the new configuration
```bash
helm upgrade -i vault path_to_helm_chart -f your-values-file.yaml --namespace <VAULT_NAMESPACE>
```

Notice that the current values file is applicable for version 0.29.0.

### **3. Initialize Vault (First-Time Setup)**

* **For azure key vault unseal**:

For first-time installations, initialize Vault:

```bash
kubectl exec vault-0 -- vault operator init
```
⚠ **Important:** Store the **root token** and **recovery keys** securely.

* **For multi unseal**:

In order to configure multi unseal HA, read this [article](../../docs/multi_auto_unseal.md).


### **4. Verify the Vault Cluster**
Check if Vault is running and unsealed:

```bash
kubectl exec vault-0 -- vault status
```

Since **auto-unseal** is enabled, Vault should already be unsealed. You can also verify access by logging in:

```bash
kubectl -n <VAULT_NAMESPACE> exec vault-0 -- vault login <root_token>
```

---

## **Updating Vault**

### **1. Modify the Values File**
Before updating, **update** the `values.yaml` file with the required changes. Ensure the settings align with the desired configuration.

### **2. Upgrade the Vault Helm Deployment**
Apply the new configuration:

```
Run the Jenkins pipeline to deploy the updated configuration.
```

It is recommended to use the Jenkins pipeline to deploy the updated configuration, as it ensures consistency and automation in the deployment process.   
Alternatively, you can use helm in order to install/upgrade the new configuration

```bash
helm upgrade -i vault path_to_helm_chart -f your-values-file.yaml --namespace <VAULT_NAMESPACE>
```

Notice that the current values file is applicable for version 0.29.0.

### **3. Restart Vault Pods to Apply Changes**
```bash
kubectl delete pod vault-0
kubectl delete pod vault-1
kubectl delete pod vault-2
```

---

## **Validating the Installation or Update**

### **1. Ensure All Pods Are Running**
```bash
kubectl get pods -n <VAULT_NAMESPACE>
```

### **2. Check Vault Status**
```bash
kubectl exec vault-0 -- vault status
```

### **3. Verify Auto-Unseal**
Ensure that Vault **automatically unseals** by restarting a pod and checking its status:

```bash
kubectl delete pod vault-0
kubectl get pods -n <VAULT_NAMESPACE>
kubectl exec vault-0 -- vault status
```
If auto-unseal is working, the pod should start **unsealed**.

### **4. Validate Vault Cluster Membership**
Ensure all Vault pods are part of the same cluster:

```bash
kubectl exec vault-0 -- vault login <token>
kubectl exec vault-0 -- vault operator raft list-peers
```
All Vault pods should be listed in the **Raft peer list**.

### output:
```bash
Node       Address                        State       Voter
----       -------                        -----       -----
vault-0    vault-0.vault-internal:8201    leader      true
vault-1    vault-1.vault-internal:8201    follower    true
vault-2    vault-2.vault-internal:8201    follower    true
```
---

This guide ensures a **secure and production-ready Vault deployment** on k8s with best practices in place.