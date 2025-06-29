# Auto Snapshot

HashiCorp Vault Auto Snapshot is a feature that enables automatic, scheduled backups of Vault’s data, ensuring business continuity and disaster recovery. By configuring auto snapshots, administrators can define snapshot intervals, retention policies, and storage locations, reducing manual intervention while maintaining data integrity. This feature is especially useful for Vault clusters running in HA mode, providing a seamless way to restore lost or corrupted data with minimal downtime.

Based on this [article](https://developer.hashicorp.com/vault/api-docs/v1.16.x/system/storage/raftautosnapshots).

## auto snapshot with **azure-blob**:
 
1. Create auto snapshot confiuration 
```bash
vault write sys/storage/raft/snapshot-auto/config/auto-snapshots \
    storage_type=azure-blob \
    file_prefix=vault-snapshot \
    interval=24h \
    retain=30 \
    azure_account_name=<your_storage_account_name> \
    azure_account_key=<your_storage_account_key> \
    azure_container_name=<your_container_name> \
    path_prefix=vault/backups/
```

**Parameters**:
* `name` (string: <required>) – Name of the configuration to modify.
* `interval` (integer or string: <required>) - Time between snapshots. This can be either an integer number of seconds, or a Go duration format string (e.g. 24h)
* `retain` (integer: 1) - How many snapshots are to be kept; when writing a snapshot, if there are more snapshots already stored than this number, the oldest ones will be deleted.
* `path_prefix` (string: <required>) - For cloud storage types, the bucket prefix to use. Type azure-blob require a trailing / (slash).
* `file_prefix` (string: "vault-snapshot") - Within the directory or bucket prefix given by path_prefix, the file or object name of snapshot files will start with this string.
* `storage_type` (string: <required>) - One of "local", "azure-blob", "aws-s3", or "google-gcs". The remaining parameters described below are all specific to the selected storage_type and prefixed accordingly.
* `azure_container_name` (string: <required>) - Azure container name to write snapshots to.
* `azure_account_name` (string) - Azure account name.
* `azure_account_key` (string) - Azure account key.


**Note**: If you are using the pod's terminal, make sure its the leader pod by running the following command: `vault operator raft list-peers`

2. Inspect auto snapshot configuration:
 
```bash
vault read sys/storage/raft/snapshot-auto/config/auto-snapshots
```

3. Get status of the snapshots:

```bash
vault read sys/storage/raft/snapshot-auto/status/auto-snapshots
```

**Note**: Here you will see if there are any errors with the snapshot, or information about the latest snapshot.


## auto **local** snapshot:

```bash
sudo mkdir -p /opt/data/raft/snapshots/local
sudo chown vault:vault /opt/data/raft/snapshots/local
sudo chmod 750 /opt/data/raft/snapshots/local


vault write sys/storage/raft/snapshot-auto/config/local \
    interval="24h" \
    retain=30 \
    path_prefix="/opt/data/raft/snapshots/local" \
    storage_type="local" \
    local_max_space=1073741824


# View configuration:
vault read sys/storage/raft/snapshot-auto/config/local


## Inspect backup file
vault operator raft snapshot inspect vault-snapshot.snap

```