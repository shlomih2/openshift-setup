# Performance Replication

Based on this [article](https://developer.hashicorp.com/vault/tutorials/enterprise/performance-replication)

## Steps:

## On Primary site:

### Create super user

1. Login on leader node:
```bash
vault login
```

2. Create policy for superuser
```bash
vault policy write superpolicy -<<EOF
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF
```

3. Enable userpass auth
```bash
vault auth enable  userpass
```

4. Create superuser user and test login
```bash
vault write  auth/userpass/users/superuser password='<PASSWORD>' policies="superpolicy"
vault login -method=userpass username=superuser
```

### Edit svc vault-active - set type to LoadBalancer

1. Change service type
```bash
oc patch svc vault-active --type='merge' -p '{
  "metadata": {
    "annotations": {
      "service.beta.kubernetes.io/azure-load-balancer-internal": "true",
      "service.beta.kubernetes.io/azure-load-balancer-internal-subnet": "apps-subnet"
    }
  }
}'


oc patch svc vault-active -p '{"spec": {"type": "LoadBalancer"}}'
```

2. View the IP
```bash
oc get svc vault-active
```

3. Copy the IP and use it in the next step

### Add LoadBalancer IP to statefulset

1. Edit statefulset
```bash
oc edit sts vault
```

2. Change VAULT_CLUSTER_ADDR env
```yaml
    spec:
      containers:
      - args:
        env:
        - name: VAULT_CLUSTER_ADDR
          value: https://<LoadBalancer_IP>:8201
```

### Setup replication

1. enable replication
```bash
vault write -f sys/replication/performance/primary/enable
```

2. Generate token for secondary 

```bash
vault write sys/replication/performance/primary/secondary-token id=secondary
```

3. Copy the token - use it on next step in secondary site

## On Secondary site:

1. Enable replication

```bash
vault write -f sys/replication/performance/secondary/enable \
 primary_api_addr="https://<OPENSHIFT_ROUTE_FQDN>:443" \
 ca_file=/vault/userconfig/vault-ha-tls/vault.ca \
 token="<TOKEN>"
```

2. Check replication status

```bash
vault read -format=json sys/replication/status
```

3. Login with the user we created on the primary site

```bash
vault login -method=userpass username=superuser
```


# Disable replication

To disable performance replication between the primary and secondary sites, you need to perform the following steps:

### On Secondary Site:
Disable Replication for the Secondary Site:
```bash 
vault write -f sys/replication/performance/secondary/disable
```
Verify Replication is Disabled:
```bash 
vault read -format=json sys/replication/status
```
The output should show that replication is no longer enabled.


### On Primary Site:
Disable Replication for the Primary Site:
```bash
vault write -f sys/replication/performance/primary/disable
```
Verify Replication is Disabled:
```bash 
vault read -format=json sys/replication/status
```
The output should show that replication is no longer enabled.


