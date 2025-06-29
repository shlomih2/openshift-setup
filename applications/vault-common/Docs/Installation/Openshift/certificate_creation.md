# **Certificate Creation Guidelines**

### **Required SANs**
```
DNS: vault-0
DNS: vault-1
DNS: vault-2
DNS: *.vault
DNS: *.vault-internal
DNS: *.vault-internal.<VAULT_NAMESPACE>.svc.cluster.local
DNS: Openshift Route URL
DNS: Load Balancer URL
IP Address: 127.0.0.1

```

After setting up the SANs, Generate signed certificate. you should have the following **TLS certificate files**:  
- **Private Key:** `vault.key`  
- **Certificate:** `vault.crt`  
- **CA Certificate:** `vault.ca`  

---

## **Certificate Setup on OpenShift (Site A)**

**All commands should be executed in the `<VAULT_NAMESPACE>` namespace.**

### **1️. First-time Certificate Setup**
To create the TLS secret for the first time, run:

```bash
oc create secret generic vault-ha-tls -n $VAULT_K8S_NAMESPACE \
   --from-file=vault.key=${WORKDIR}/vault.key \
   --from-file=vault.crt=${WORKDIR}/vault.crt \
   --from-file=vault.ca=${WORKDIR}/vault.ca
```

---

### **2️. Certificate Rotation**
If the certificate needs to be updated (due to expiration or changes), follow these steps:

1. **Backup the existing secret:**
   ```bash
   oc get secret vault-ha-tls -o yaml > vault-ha-tls-secret.yaml.bkp
   ```

2. **Delete the existing secret:**
   ```bash
   oc delete secret vault-ha-tls
   ```

3. **Recreate the secret with the new certificate:**
   ```bash
   oc create secret generic vault-ha-tls \
      -n $VAULT_K8S_NAMESPACE \
      --from-file=vault.key=${WORKDIR}/vault.key \
      --from-file=vault.crt=${WORKDIR}/vault.crt \
      --from-file=vault.ca=${WORKDIR}/vault.ca
   ```

---

### **3️. Apply the New Certificate**
To ensure Vault loads the updated certificate, restart the Vault pods:

```bash
oc delete pod vault-0 
oc delete pod vault-1
oc delete pod vault-2 
```

---

## **Validation**
To verify that the certificate update was successful, run:

```bash
vault status
```
✅ **If the command succeeds, the certificate update is applied.**  

🚨 **If the command fails, check:**
1. The **SANs** in the certificate are correct.
2. The **secret was recreated correctly**.
3. The **Vault pods were restarted**.

---
