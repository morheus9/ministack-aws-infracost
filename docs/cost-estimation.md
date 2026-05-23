# Cost estimation

Use `CLOUD=aws` and Infracost on `terragrunt run --all plan` output. Ministack has no billable cost.

Compare environments via `live/staging/env.hcl` vs `live/prod/env.hcl` (NAT, spot, instance types).
