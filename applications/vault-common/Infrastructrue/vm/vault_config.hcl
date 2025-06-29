api_addr      = "https://<DNS_OF_VM>:8200"
cluster_addr  = "https://<DNS_OF_VM>:8201"
license_path  = "/opt/vault/config/license.hclic"
disable_mlock = true
ui            = true
 
enable_multiseal = true
 
storage "raft" {
  node_id = "vault-node-1"
  path    = "/opt/vault/data/"
}
 
listener "tcp" {
  tls_disable     = 0
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"

  tls_cert_file      = "/opt/vault/tls/vault.crt"
  tls_key_file       = "/opt/vault/tls/vault.key"
  tls_client_ca_file = "/opt/vault/tls/vault.ca"

  # Enable unauthenticated metrics access (necessary for Prometheus Operator)
  telemetry {
    unauthenticated_metrics_access = "true"
  }
}
 
log_level = "info"
log_format = "standard"

# For Auto unseal with AWS KMS
# seal "awskms" {
#   region = "<REGION_OF_KMS>"
# }

# For Auto unseal with Azure Key Vault
# seal "azurekeyvault" {}


telemetry {
  prometheus_retention_time = "0h"
  disable_hostname = true
  dogstatsd_addr = "telegraf.monitoring.svc.cluster.local:8125"
  enable_hostname_label = true
}