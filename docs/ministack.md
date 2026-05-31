# Ministack

Default `CLOUD=ministack`. Region `us-east-1` (see `live/ministack.hcl`).

```bash
docker compose up -d
make bootstrap
cd live/staging && CLOUD=ministack terragrunt run --all apply
```

EKS: k3s via Docker socket. Kubeconfig:

```bash
#!/bin/bash
CLUSTER=${1:-finops-ministack-staging-eks}
CONTAINER="ministack-eks-${CLUSTER}"

PORT=$(docker port "$CONTAINER" 6443/tcp | cut -d: -f2)
if [ -z "$PORT" ]; then
  echo "Error: Can't find exposed port for $CONTAINER"
  exit 1
fi

echo "Using port $PORT for API server"

docker exec "$CONTAINER" cat /etc/rancher/k3s/k3s.yaml \
  | sed "s/server:.*/server: https:\/\/localhost:$PORT/" \
  | sed "s/127.0.0.1/localhost/" \
  > kubeconfig.yaml

chmod 600 kubeconfig.yaml
echo "✅ kubeconfig saved to kubeconfig.yaml"
echo "Use with: kubectl --kubeconfig=kubeconfig.yaml get nodes"
```
