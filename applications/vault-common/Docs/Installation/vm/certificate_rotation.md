## **Certificate Rotation (VM-Based Deployment)**

### **1. Remove Old Certificates**
**Backup** and delete the existing certificates:

```bash
rm -f /opt/vault/tls/*
```

### **2️. Copy the New Certificates**
Place the updated TLS certificates in `/opt/vault/tls/`.

### **3️. Set Correct Ownership**
Ensure Vault has the correct permissions:

```bash
chown vault:vault /opt/vault/tls/*
```

### **4️. Restart Vault Service**
Apply the new certificates by restarting Vault:

```bash
sudo systemctl restart vault
```

---

## **Validation**
To verify the service is running correctly:

```bash
systemctl status vault
```

```bash
vault status
```

✅ **If both commands succeed, the update is applied.**  

🚨 **If the service fails:**
- Restore the old certificates and restart the service.
- Troubleshoot using logs:

  ```bash
  journalctl -u vault -xe
  ```
