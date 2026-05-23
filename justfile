set shell := ["bash", "-cu"]

CLOUD := "ministack"
MINISTACK_ENDPOINT := "http://localhost:4566"
REGION := "eu-central-1"

TFSTATE_BUCKET := "finops-ministack-tfstate"
TFSTATE_LOCK := "finops-ministack-lock"

ENV := "staging"
ENV_DIR := "live/aws/" + REGION + "/" + ENV

# Показать список всех доступных команд
default:
    @just --list

# ----------------------------
# MINISTACK (LOCAL ENVIRONMENT)
# ----------------------------

# Запустить локальное облако в Docker
ministack-up:
    docker compose up -d

# Остановить локальное облако
ministack-down:
    docker compose down

# Смотреть логи локального облака
ministack-logs:
    docker compose logs -f ministack

# Создать S3 бакет и DynamoDB таблицу для стейта в Ministack
bootstrap:
    @echo "Waiting for Ministack to be ready..."
    sleep 3
    @# Создаем бакет, если он еще не существует
    aws --endpoint-url={{MINISTACK_ENDPOINT}} s3 api head-bucket --bucket {{TFSTATE_BUCKET}} 2>/dev/null || \
    aws --endpoint-url={{MINISTACK_ENDPOINT}} s3 mb s3://{{TFSTATE_BUCKET}}
    @# Создаем таблицу DynamoDB для блокировок стейта
    aws --endpoint-url={{MINISTACK_ENDPOINT}} dynamodb describe-table --table-name {{TFSTATE_LOCK}} 2>/dev/null || \
    aws --endpoint-url={{MINISTACK_ENDPOINT}} dynamodb create-table \
        --table-name {{TFSTATE_LOCK}} \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST

# ----------------------------
# TERRAGRUNT (LOCAL MINISTACK)
# ----------------------------

local-plan:
    cd {{ENV_DIR}} && CLOUD=ministack terragrunt run-all plan

local-apply:
    cd {{ENV_DIR}} && CLOUD=ministack terragrunt run-all apply --terragrunt-non-interactive

local-destroy:
    cd {{ENV_DIR}} && CLOUD=ministack terragrunt run-all destroy --terragrunt-non-interactive

# ----------------------------
# TERRAGRUNT (AWS PRODUCTION/STAGING)
# ----------------------------

aws-plan:
    cd {{ENV_DIR}} && CLOUD=aws terragrunt run-all plan
    
aws-apply:
    cd {{ENV_DIR}} && CLOUD=aws terragrunt run-all apply --terragrunt-non-interactive

aws-destroy:
    cd {{ENV_DIR}} && CLOUD=aws terragrunt run-all destroy --terragrunt-non-interactive

# ----------------------------
# FINOPS & DEVSECOPS CONTROLS
# ----------------------------

# Проверить безопасность инфраструктуры через Checkov
check-security:
    checkov -d modules/ --framework terraform

# Локальный аудит стоимости будущих изменений через Infracost
check-cost:
    infracost breakdown --path {{ENV_DIR}}
