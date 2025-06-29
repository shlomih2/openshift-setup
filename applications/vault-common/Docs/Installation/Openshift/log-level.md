# Changing Log Level in HashiCorp Vault

## Overview
This guide explains how to change the log level in HashiCorp Vault by modifying the Vault ConfigMap and restarting the Vault pods. This process is applicable when Vault is deployed on Kubernetes.

## Prerequisites
- Kubernetes cluster with HashiCorp Vault installed.
- `oc` CLI configured to interact with the cluster.

---

## Step 1: Edit the Vault ConfigMap
Vault's log level is configured via its configuration file, typically managed through a Kubernetes `ConfigMap`.

1. **Identify the ConfigMap**:
   ```bash
   oc get configmap -n <vault-namespace>
   ```

2. **Edit the ConfigMap**:
   ```bash
   oc edit configmap <vault-configmap-name> -n <vault-namespace>
   ```

3. **Modify the Log Level**:
   Add or update the following line under the `logging` section of your ConfigMap:
   ```hcl
   log_level = "DEBUG"
   ```
   Available log levels: `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR` (Default: `INFO`)

---

## Step 2: Restart the Vault Pods
After updating the ConfigMap, the Vault pods need to be restarted for the changes to take effect.

1. **Delete the Vault pods** (they will automatically restart if managed by a `Deployment` or `StatefulSet`):
   ```bash
   oc delete pod vault-0 -n <vault-namespace>
   oc delete pod vault-1 -n <vault-namespace>
   oc delete pod vault-2 -n <vault-namespace>
   ```

2. **Verify the pods are restarted**:
   ```bash
   oc get pods -n <vault-namespace>
   ```

---

## Step 3: Confirm the New Log Level
You can confirm that the log level has been successfully changed by checking the logs of a running Vault pod:
```bash
oc logs <vault-pod-name> -n <vault-namespace>
```

Look for log messages that indicate the desired log level (e.g., `DEBUG`).

---

## Additional Tips
- To persist the changes, ensure the updated `ConfigMap` is not overwritten by Helm or other deployment mechanisms.
- Consider using a `Helm` values file if you are deploying Vault via Helm charts.

---

## References
- [HashiCorp Vault Documentation](https://developer.hashicorp.com/vault/docs)


