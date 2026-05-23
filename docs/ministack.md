# Ministack

Default `CLOUD=ministack`. Region `us-east-1` (see `live/ministack.hcl`).

```bash
docker compose up -d
make bootstrap
cd live/staging && CLOUD=ministack terragrunt run --all apply
```

EKS: k3s via Docker socket. Kubeconfig:

```bash
CLUSTER=finops-ministack-staging-eks
docker exec ministack-eks-${CLUSTER} cat /etc/rancher/k3s/k3s.yaml \
  | sed "s/127.0.0.1:6443/localhost:$(docker port ministack-eks-${CLUSTER} 6443/tcp | cut -d: -f2)/" \
  > kubeconfig.yaml
```

Full EKS (node groups, addons): `CLOUD=aws`.
