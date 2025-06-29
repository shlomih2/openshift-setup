### **Telemetry with Vault and Splunk**  

**Vault telemetry** provides valuable insights into system performance, security events, and audit logs, which can be collected and analyzed using monitoring tools like **Splunk**. This guide focuses on configuring **Vault’s telemetry and audit logging**, ensuring that logs and metrics are forwarded correctly. While **Splunk setup is a prerequisite**, this guide will only cover the necessary **Vault-side configuration** to enable telemetry and auditing.  

---

## **Prerequisites**  

1. Ensure Splunk is configured to receive Vault telemetry and audit logs. Follow this [official guide](https://developer.hashicorp.com/vault/tutorials/monitoring/monitor-telemetry-audit-splunk).  
2. On both openshift and on VM based Vault cluster, verify that your **Vault configuration** includes the required **telemetry stanza**:

```tml
telemetry {
    prometheus_retention_time = "0h"
    disable_hostname = true
    dogstatsd_addr = "telegraf.monitoring.svc.cluster.local:8125"
    enable_hostname_label = true
}
```

On site A: in [`values.yaml`](../installation/openshift/values.yaml#L249-L254).
On site B: in [`vault_config.hcl`](../installation/Vault_Cluster/vault_config.hcl#L42-L47).


If update in the configuration is needed from any reason, do the following:

* For site A: Edit the cm with your new configuration with the following command:
```bash
oc edit cm vault-config
```

* For site B: Edit the `vault_config.hcl` and run the script `run_vault` like [so](../installation/Vault_Cluster/README.md#step-3-start-vault-using-the-run-script), to apply the changes.

---

## **Steps on the Vault Side**  

Enable **audit logging** in Vault and configure it to send audit logs to a file for Splunk auditing:  

```bash
vault audit enable file file_path=/vault/audit/vault-audit.log mode=744
```

### **Command Explanation:**  
- **`vault audit enable file`** → Enables Vault’s audit logging to a file.  
- **`file_path=/vault/audit/vault-audit.log`** → Specifies the path where audit logs will be stored.  
- **`mode=744`** → Sets file permissions (**read/write for owner, read for others**), ensuring logs are accessible but secured.  

This configuration allows **Observability tools like Splunk** to ingest Vault audit logs from the specified file for further analysis and monitoring.