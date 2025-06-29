# mizrahi-vault

https://github.com/hashicorp/vault-secrets-operator/blob/main/chart/values.yaml

https://developer.hashicorp.com/vault/docs/platform/k8s/vso/openshift

https://github.com/TeraSky-OSS/vault-workshop/blob/main/Demo/demos/vault_secret_operator.sh


helm upgrade --install --create-namespace --namespace vault-secrets-operator vault-secrets-operator hashicorp/vault-secrets-operato


vault auth enable kubernetes

kubectl apply -f $VSO_YAML_PATH/secret.yaml

TOKEN_REVIEW_JWT=$(kubectl get secret default -n vault-secrets-operator -o go-template='{{ .data.token }}' | base64 --decode)
KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 --decode)
KUBE_HOST=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.server}')

vault write auth/kubernetes/config token_reviewer_jwt="$TOKEN_REVIEW_JWT" kubernetes_host="$KUBE_HOST" kubernetes_ca_cert="$KUBE_CA_CERT"


kubectl apply -f $VSO_YAML_PATH/VaultConnection.yaml

kubectl apply -f $VSO_YAML_PATH/VaultAuth.yaml

vault policy write app-read-policy - <<EOF
path "secret/*" {
  capabilities = ["read"]
}
EOF

vault write auth/kubernetes/role/example \
    bound_service_account_names=default \
    bound_service_account_namespaces=default \
    policies=app-read-policy \
    ttl=24h


kubectl apply -f $VSO_YAML_PATH/VaultStaticSecret.yaml

kubectl get secrets -n default

kubectl apply -f $VSO_YAML_PATH/basic_secret_pod.yaml

kubectl exec -n default $DEMO_POD_VSO -- printenv | grep ENV_ ; echo