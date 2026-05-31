# ministack-aws-infracost

Example of [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install) config for AWS with [Ministack](https://ministack.org) (local emulator, LocalStack-compatible API on port 4566).

FinOps pet project: VPC + EKS via [terraform-aws-modules](https://registry.terraform.io/namespaces/terraform-aws-modules).

### 1. Start ministack

```bash
docker compose up -d
```
or
```bash
just ministack-up
```

EKS needs Docker socket in the container (see `docker-compose.yml`).

### 2. Create S3 bucket

```bash
aws --endpoint-url=http://localhost:4566 s3 mb s3://finops-ministack-tfstate-us-east-1
```

### 3. Create DynamoDB table for locks

```bash
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name finops-ministack-lock-us-east-1 \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST
```

### Or in one step:
```bash
just bootstrap
```
### Checking S3 bucket

```bash
aws --endpoint-url=http://localhost:4566 s3 ls
```

### Checking DynamoDB table

```bash
aws --endpoint-url=http://localhost:4566 dynamodb list-tables
```

### Checking status of ministack

```bash
docker compose ps
docker compose logs -f ministack
```

### Install infra

Default target is local Ministack (`CLOUD=ministack`, region `us-east-1`). For real AWS use `CLOUD=aws` (region `eu-central-1`, see `live/aws.hcl`).

Setup provider:
```bash
cat << 'EOF' > ~/.terraformrc
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
EOF
```
```bash
cd live/staging
CLOUD=ministack terragrunt run --all init
CLOUD=ministack terragrunt run --all plan
CLOUD=ministack terragrunt run --all apply
CLOUD=ministack terragrunt run --all destroy

cd live/prod
CLOUD=ministack terragrunt run --all init
CLOUD=ministack terragrunt run --all plan
CLOUD=ministack terragrunt run --all apply
CLOUD=ministack terragrunt run --all destroy
```

### Shorthand via justfile (from the **repository root**, not from `live/`):
```bash
sudo snap install just
# Ministack environment (default: staging)
just local-plan             # → plan for staging
just local-apply            # → apply for staging
just local-destroy          # → destroy staging

just ENV=prod local-plan    # → plan for prod
just ENV=prod local-apply   # → apply for prod
just ENV=prod local-destroy # → destroy prod

# aws environment:
just aws-plan               # → plan for staging
just aws-apply              # → apply for staging
just aws-destroy            # → destroy staging

just ENV=prod aws-plan      # → plan for prod
just ENV=prod aws-apply     # → apply for prod
just ENV=prod aws-destroy   # → destroy prod
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

|        `CLOUD`        |        Profile File        |     Region     |
|-----------------------|----------------------------|----------------|
| `ministack` (default) | `live/ministack.hcl`       | `us-east-1`    |
| `aws`                 | `live/aws.hcl`             | `eu-central-1` |

## Docs

- [architecture.md](docs/architecture.md)
- [ministack.md](docs/ministack.md) — kubeconfig for k3s
- [cost-estimation.md](docs/cost-estimation.md)
- [finops-decisions.md](docs/finops-decisions.md)
