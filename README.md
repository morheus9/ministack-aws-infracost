# ministack-aws-infracost

Example of [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install) config for AWS with [Ministack](https://ministack.org) (local emulator, LocalStack-compatible API on port 4566).

FinOps pet project: VPC + EKS via [terraform-aws-modules](https://registry.terraform.io/namespaces/terraform-aws-modules).

## Ministack

```bash
docker compose up -d
```
or
```bash
make ministack-up
```

EKS needs Docker socket in the container (see `docker-compose.yml`).

### Create S3 bucket

```bash
aws --endpoint-url=http://localhost:4566 s3 mb s3://finops-ministack-tfstate
```

### Create DynamoDB table for locks

```bash
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name finops-ministack-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST
```
___________________________________________________________________________________

Or one step: `make bootstrap` (starts Ministack and runs the commands above).

### Checking S3 bucket

```bash
aws --endpoint-url=http://localhost:4566 s3 ls
```

### Checking DynamoDB table

```bash
aws --endpoint-url=http://localhost:4566 dynamodb list-tables
```

### Checking status of Ministack

```bash
docker compose ps
docker compose logs -f ministack
```

## Install infra

Default target is local Ministack (`CLOUD=ministack`, region `us-east-1`). For real AWS use `CLOUD=aws` (region `eu-central-1`, see `live/aws.hcl`).

```bash
cd ~/Downloads/ministack-aws-infracost

CLOUD=ministack terragrunt run --all init
CLOUD=ministack terragrunt run --all plan
CLOUD=ministack terragrunt run --all apply
CLOUD=ministack terragrunt run --all destroy
```

Shorthand via Makefile (from the **repository root**, not from `live/`):

```bash
make local-plan
make local-apply
make local-destroy

# prod environment:
make local-plan ENV=prod
```

## Layout

```text
live/
  root.hcl
  ministack.hcl      # CLOUD=ministack
  aws.hcl            # CLOUD=aws
  _envcommon/
  staging|prod/
    env.hcl
    vpc/
    eks/
modules/
  vpc/
  eks/
```

| `CLOUD` | Profile file | Region |
|---------|--------------|--------|
| `ministack` (default) | `live/ministack.hcl` | us-east-1 |
| `aws` | `live/aws.hcl` | eu-central-1 |

Obsolete local folders (`live/clouds`, `modules/network`, `modules/networking`): `make clean-legacy`

## Docs

- [architecture.md](docs/architecture.md)
- [ministack.md](docs/ministack.md) — kubeconfig for k3s
- [cost-estimation.md](docs/cost-estimation.md)
- [finops-decisions.md](docs/finops-decisions.md)
