# **Installing HashiCorp Vault on a VM (Best Practices & Hardening)**  

This guide details the **best-practice** installation of **HashiCorp Vault** on a VM, using a **dedicated user** with **minimal permissions**. It follows **HashiCorp's security hardening recommendations**, ensuring Vault runs in a **secure, isolated environment** with a **systemd service** for proper process management.  

### **Operating System Requirement**  

The installation scripts have been tested on **Red Hat Enterprise Linux (RHEL)**. Ensure your VM is running a compatible version of RHEL before proceeding.  

---

### **Prerequisites**  

Before starting the installation, ensure the following requirements are met:  

1. **Vault Binary** – The Vault installation package (`vault.zip`) **must be available** in `/tmp/vault.zip`.  
2. **System Path Configuration** – Ensure `/usr/local/bin` is included in your **`PATH`** so Vault can be executed globally.  
3. **Root Privileges** – All installation commands **must be run as `root`** to ensure proper permission setup.  
4. **Vault License** – If using **Vault Enterprise**, have the **license file** ready.  
5. **TLS Certificates** – Generate or obtain the necessary **TLS certificates** for secure communication:  
   - **Private Key** (`vault.key`)  
   - **Certificate** (`vault.crt`)  
   - **CA Certificate** (`vault.ca`)  
6. **Multi Auto-Unseal Setup** – Read the [Multi Auto-Unseal documentation](../../docs/multi_auto_unseal.md) before proceeding to understand the installation process.  
7. **Required Packages** – Ensure the following packages are installed and available in your local repo environment:
   ```sh
   sudo yum install -y -q curl unzip jq wget unzip bind-utils ruby rubygems
   ``` 

✅ **Once these prerequisites are met, you can proceed with the installation.**

---

## **Installation Steps**  

### **Step 0: Review and Update the `.env` [File](../../../Infrastructrue/vm/scripts/.env)**  

Before proceeding, review the `.env` file to ensure the scripts are configured according to your requirements. This file allows you to customize the following settings:  

- **Vault User**: Specify the user under which Vault will run.  
- **Installation Location**: Define the directory where Vault will be installed.  
- **Vault Installation Folder**: Set the folder for Vault's configuration and data.  
- **Log Level**: Adjust the log level for debugging or production use.  

If necessary, update these values in the `.env` file to align with your deployment intentions.  

### **Step 1: Run the Vault Installation [Script](../../../Infrastructrue/vm/scripts/install_vault)**  

```sh
bash install_vault.sh
```

This script:  
✔️ **Creates a dedicated Vault user & group** with minimal privileges.  
✔️ **Sets up the necessary directories** (`/opt/vault`, `/opt/vault/config`, `/opt/vault/data`, `/opt/vault/tls`).  
✔️ **Applies correct permissions** to ensure Vault runs securely.  
✔️ **Installs the Vault binary** from `/tmp/vault.zip` to `/usr/local/bin/`.  

---

### **Step 2: Configure Vault Files**  

After running the installation script, configure the necessary **Vault configuration files**:  

1. **`vault_config.hcl` (Main Vault Configuration File)**  
   - Defines the **storage backend, listener, telemetry, and auto-unseal**.  
   - Includes **TLS encryption, audit logging, and security best practices**.  

2. **`vault.env` (Environment Variables File)**  
   - Stores **Azure auto-unseal credentials** securely instead of hardcoding them in `vault_config.hcl`.  
   - Variables include `AZURE_TENANT_ID`, `AZURE_CLIENT_ID`, and `AZURE_CLIENT_SECRET` for auto unseal with Azure Key Vault and more.  
   - Variables include `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `VAULT_AWSKMS_SEAL_KEY_ID` for auto unseal with AWS KMS and more.  

3. **`vault.hclic` (Vault License File)**  
   - Must be placed in `/opt/vault/config/license.hclic`.  
   - Set correct permissions:  
    ```sh
        chown vault:vault /opt/vault/config/license.hclic
    ```

4. **TLS Certificates (`vault.key`, `vault.crt`, `vault.ca`)**  
   - Must be placed in `/opt/vault/tls/`.  
   - Set correct permissions:  
    ```sh
        chown vault:vault /opt/vault/tls/*
    ```

   **Note**: For documantation about replacing a certificate look [here](../../docs/certificate_creation.md#certificate-update-on-site-b-vm-based-deployment).
---

### **Step 3: Start Vault Using the Run [Script](../../../Infrastructrue/vm/scripts/run_vault)**  

```sh
sudo bash run_vault.sh --path-to-config ./vault_config.hcl --path-to-env-file ./vault.env
```

This script:  
✔️ **Moves `vault_config.hcl` and `vault.env` to the correct location** (`/opt/vault/config/`).  
✔️ **Creates a systemd service** with best-practice settings.  
✔️ **Starts Vault securely**, ensuring it runs as a background service.  


🔁 **Re-running the Script for Configuration Updates**  
- This script can be **run multiple times** whenever there are updates to `vault_config.hcl` or `vault.env`.  
- To **apply changes easily**, simply **re-run the script** with the updated configuration files.  

**Importent Note**: This is **especially necessary** when making changes related to **Multi auto-unseal configuration** read [here](../../docs/multi_auto_unseal.md).  

✅ **Whenever you modify Vault’s configuration, re-run the script to apply the changes seamlessly.**


---

## **Vault Hardening Steps**  

After Vault is installed and running, apply additional **hardening measures** to further **secure the system and prevent leaks**.  

🔹 **Refer to HashiCorp’s official hardening guide:**  
For [Documentation](https://developer.hashicorp.com/vault/docs/concepts/production-hardening?productSlug=vault&tutorialSlug=operations&tutorialSlug=)  

---

### **1. Disable Swap**  

Vault should never use **disk swap**, as it may lead to **sensitive data exposure**.  

#### **Check if swap is enabled:**  
```sh
cat /proc/swaps   # List active swap devices
vmstat            # Check swap usage
sudo swapon --show  # Show detailed swap info
```

#### **Disable swap permanently:**  
```sh
sudo swapoff -a  # Disable swap immediately
```

**Note**: Make sure to **remove swap permanantly** to prevent it from re-enabling after reboot!

---

### **2. Disable Bash History**  

Vault should never store command history, as it might contain **sensitive tokens or unseal keys**.  

#### **Disable history logging:**  
Add the following lines to **`/etc/profile`** and **`/etc/bashrc`**:  

```sh
unset HISTFILE
set +o history
export HISTSIZE=0
export HISTFILESIZE=0
```

#### **Apply changes immediately:**  
```sh
source /etc/bashrc
source /etc/profile
```

---

## **First-Time Vault Initialization**  

After installation and hardening, Vault must be **initialized**. This process generates the **root key and recovery keys**, which must be securely stored.  

### **1. Set the Vault Server Address and Vault CA path**  

Before initializing, define the **Vault API address** and **Vault CA** as a permenent environment variables:  

```sh
echo 'VAULT_ADDR="https://<YOUR_VAULT_SERVER_NAME>:8200"' | sudo tee -a /etc/environment
echo 'VAULT_CA="/opt/vault/tls/vault.ca"' | sudo tee -a /etc/environment
```

Apply changes immediately without rebooting:

```sh
source /etc/environment
```

---

### **2. Initialize Vault**  

```sh
vault operator init
```

This command will generate:  
✔️ **Unseal Keys (or Recovery Keys if using Auto-Unseal)**  
✔️ **Root Token**  

These credentials must be **securely stored** in a **trusted password manager or offline storage**. If lost, recovery will be difficult.  

---

### **3. Log in as Root**  

Use the generated **root token** to log in:  

```sh
vault login <ROOT_TOKEN>
```

This grants full administrative access to Vault.  

---

## **Final Notes**  

🔹 **Vault is now installed, hardened, and initialized!**  
🔹 **Store the unseal keys and root token securely!**  
🔹 **Enable authentication methods (e.g., AppRole, LDAP) for secure access control.**  

**Your Vault server is now production-ready!** 


**Note**: For validations that everything worked as expected look [here](./validations.md).