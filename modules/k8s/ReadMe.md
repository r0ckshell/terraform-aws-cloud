# Hashicorp Vault integration setup

## Configure the Kubernetes auth method

```bash
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: hashicorp-vault-agent-injector-token-review-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: hashicorp-vault-agent-injector
  namespace: hashicorp
EOF
```

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: hashicorp-vault-agent-injector-token
  namespace: hashicorp
  annotations:
    kubernetes.io/service-account.name: hashicorp-vault-agent-injector
type: kubernetes.io/service-account-token
EOF
```

## Configure Vault

```bash
vault auth enable kubernetes

TOKEN_REVIEW_JWT=$(kubectl get secret hashicorp-vault-agent-injector-token -n hashicorp -o go-template='{{ .data.token }}' | base64 --decode)
KUBE_HOST=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')
KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 --decode)

vault write auth/kubernetes/config \
  token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
  kubernetes_host="$KUBE_HOST" \
  kubernetes_ca_cert="$KUBE_CA_CERT" \
  disable_local_ca_jwt="true"

vault policy write read-policy - <<EOF
path "kv/data/test/secret" {
  capabilities = ["read"]
}
EOF

vault write auth/kubernetes/role/readonly-hv-role \
  bound_service_account_names=test-sa \
  bound_service_account_namespaces=default \
  policies=read-policy \
  ttl=5m
```
