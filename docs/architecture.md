# Architecture

## Layout

- `live/ministack.hcl` / `live/aws.hcl` — region, subnets, provider, remote_state (one file per target, no extra folder).
- `live/_envcommon/vpc.hcl`, `eks.hcl` — shared stack config (profile + env via `find_in_parent_folders` from the leaf stack dir).
- `live/<env>/env.hcl` — FinOps knobs: NAT, spot, instance type.
- `modules/vpc`, `modules/eks` — thin wrappers over terraform-aws-modules (names match `live/*/vpc` and `live/*/eks` stacks).

## Flow

```text
CLOUD -> live/{ministack|aws}.hcl
env.hcl -> sizing / FinOps flags
vpc -> eks (terragrunt dependency)
```

## EKS profiles

| | Ministack | AWS |
|---|-----------|-----|
| Node groups | off (`is_local`) | on |
| KMS / IRSA / addons | off | on |
| Runtime | k3s container | real EKS |
