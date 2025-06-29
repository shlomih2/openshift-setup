# **Validation: Ensuring Vault Installation Works as Intended**  

After completing the installation, follow these **validation steps** to confirm that Vault is correctly installed, configured, and running as expected.  

---

## **1. Validate `install_vault.sh` Execution**  

Check that the required **folders were created** and have the correct ownership:  

```sh
ls -ld /opt/vault/data /opt/vault/tls /opt/vault/config /opt/vault/bin
```
✅ **Expected Output:**  
- All directories should exist.  
- The owner and group should be **`vault:vault`**.  

Verify that the **Vault binary is installed** in the correct location:  

```sh
ls -l /usr/local/bin/vault
```
✅ **Expected Output:**  
- `/usr/local/bin/vault` should exist.  
- The file should be executable (`-rwxr-xr-x`).  

Additional validation:  
- Ensure Vault has **correct permissions** on its directories:  
  ```sh
  sudo -u vault ls -l /opt/vault
  ```
- Confirm that Vault is **executable** by running:  
  ```sh
  vault --version
  ```

---

## **2. Validate `run_vault.sh` Execution**  

Check that the **Vault service was created correctly**:  

```sh
systemctl list-unit-files | grep vault
```
✅ **Expected Output:**  
- A systemd service should be listed as **`vault.service`**.  

Verify the **service configuration**:  

```sh
systemctl cat vault
```
✅ **Expected Output:**  
- Shows the Vault systemd service file with the correct **ExecStart** command, **environment variables**, and **working directory**.  

Check the **service status** to ensure Vault is running:  

```sh
systemctl status vault
```
✅ **Expected Output:**  
- **Active:** `active (running)`  

If the service **fails**, check the logs for troubleshooting:  

```sh
journalctl -u vault
```

---

## **3. Validate Environment Variables**  

Ensure **`VAULT_ADDR`** and **`VAULT_CA`** are set:  

```sh
echo $VAULT_ADDR
echo $VAULT_CA
```
✅ **Expected Output:**  
- `VAULT_ADDR` should match your Vault server URL (`http://<YOUR_VAULT_SERVER_IP>:8200`).  
- `VAULT_CA` should point to `/opt/vault/tls/vault.ca`.  

If missing, **reload environment variables**:  

```sh
source /etc/environment
```

---

## **4. Validate Vault Initialization & Auto-Unseal**  

Run **Vault status** to check the initialization state:  

```sh
vault status
```
✅ **Expected Output:**  
- `Initialized: true` (Vault has been initialized).  
- `Sealed: false` (Vault is unsealed).  
- `Key Shares` and `Key Threshold` should be displayed.  
- **Auto-unseal mechanism should be listed** (e.g., `azurekeyvault` or `multiseal`).  

---

## **5. Test Auto-Unseal Mechanism**  

Restart the Vault service to confirm that auto-unseal works correctly:  

```sh
systemctl restart vault
```

Wait a few seconds, then **check Vault status again**:  

```sh
vault status
```
✅ **Expected Outcome:**  
- `Sealed: false` **(Vault should remain unsealed, confirming auto-unseal is working).**  
- If Vault is sealed, **auto-unseal is not configured correctly**—check `vault status` logs for errors.  

---

### **Final Verification**  
If all steps pass successfully:  
✔️ Vault **binaries and directories** are correctly set up.  
✔️ Vault **service is running** without issues.  
✔️ Vault **environment variables are loaded**.  
✔️ Vault **auto-unseals successfully after a restart**.  

🚀 **Vault is now fully operational and hardened for production use!**  

---

Let me know if you need additional troubleshooting steps! 🔍