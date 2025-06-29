# **Audit Device Configuration**  

Configure Vault to **send audit logs to a stdout:  

```sh
vault audit enable file file_path=stdout
```

Configure Vault to **send audit logs to a SIEM** via a TCP socket:  

```sh
vault audit enable socket address=10.41.173.137:10540 socket_type=tcp
```

Configure Vault to **send audit logs to a file:  

```sh
vault audit enable -path=file-disk file file_path=/vault/audit/vault_audit.log
```




To check the list of enabled audit devices, use:
```sh
vault audit list
```

## Note: 
This configuration will replicate via performance replication.
Ensure the folder exists on all sites, and the IP and port (for the socket) are reachable from all sites.