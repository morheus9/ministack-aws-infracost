SHELL := /bin/bash

CLOUD ?= ministack
MINISTACK_ENDPOINT ?= http://localhost:4566
AWS_CLI := aws --endpoint-url=$(MINISTACK_ENDPOINT)
TFSTATE_BUCKET := finops-ministack-tfstate
TFSTATE_LOCK := finops-ministack-lock
ENV ?= staging
ENV_DIR := live/$(ENV)

.PHONY: help ministack-up ministack-down ministack-logs bootstrap local-plan local-apply local-destroy aws-plan

help:
	@echo "Run make from the repository root (not from live/)."
	@echo "Targets:"
	@echo "  ministack-up    Start Ministack (docker compose)"
	@echo "  ministack-down  Stop Ministack"
	@echo "  bootstrap       Create S3 bucket and DynamoDB lock table (Ministack)"
	@echo "  local-plan      CLOUD=ministack terragrunt plan (ENV=staging|prod, default staging)"
	@echo "  local-apply     CLOUD=ministack terragrunt apply (staging)"
	@echo "  aws-plan        CLOUD=aws terragrunt plan (staging, real AWS creds)"

ministack-up:
	docker compose up -d

ministack-down:
	docker compose down

ministack-logs:
	docker compose logs -f ministack

bootstrap: ministack-up
	@sleep 2
	-$(AWS_CLI) s3 mb s3://$(TFSTATE_BUCKET)
	-$(AWS_CLI) dynamodb create-table \
		--table-name $(TFSTATE_LOCK) \
		--attribute-definitions AttributeName=LockID,AttributeType=S \
		--key-schema AttributeName=LockID,KeyType=HASH \
		--billing-mode PAY_PER_REQUEST

local-plan:
	cd $(ENV_DIR) && CLOUD=ministack terragrunt run --all plan

local-apply:
	cd $(ENV_DIR) && CLOUD=ministack terragrunt run --all apply -auto-approve

local-destroy:
	cd $(ENV_DIR) && CLOUD=ministack terragrunt run --all destroy -auto-approve

aws-plan:
	cd $(ENV_DIR) && CLOUD=aws terragrunt run --all plan
