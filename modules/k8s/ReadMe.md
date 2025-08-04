## Hashicorp Vault integration setup

### Configure the Kubernetes auth method

```bash
kubectl apply -f ./modules/k8s/yamls/hashicorp/hv-crb.yaml
kubectl apply -f ./modules/k8s/yamls/hashicorp/hv-token.yaml
```

```bash
vault auth enable kubernetes

export k8s_api_host=$(kubectl cluster-info | head -n 1 | awk '{ print $7 }' | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")

export sa_ca_cert=$(kubectl get -n hashicorp secrets -o json \
  | jq -r --arg vault_sa_name "hashicorp-vault-agent-injector" '.items[] | select(.type == "kubernetes.io/service-account-token") | . | select(.metadata.annotations."kubernetes.io/service-account.name" == $vault_sa_name ) | .data."ca.crt"' | base64 -d)

export sa_jwt_token=$(kubectl get -n hashicorp secrets -o json \
  | jq -r --arg vault_sa_name "hashicorp-vault-agent-injector" '.items[] | select(.type == "kubernetes.io/service-account-token") | . | select(.metadata.annotations."kubernetes.io/service-account.name" == $vault_sa_name ) | .data.token' | base64 -d)

vault write auth/kubernetes/config \
  kubernetes_host=${k8s_api_host} \
  kubernetes_ca_cert=${sa_ca_cert} \
  token_reviewer_jwt=${sa_jwt_token}

vault policy write read-policy - <<EOF
path "kv/data/test/secrets" {
  capabilities = ["read"]
}
EOF

vault write auth/kubernetes/role/readonly-hv-role \
  bound_service_account_names=test-sa \
  bound_service_account_namespaces=default \
  policies=read-policy \
  ttl=5m
```
