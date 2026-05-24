# FinOps decisions

Tune in `live/<env>/env.hcl` (same for Ministack and AWS):

|              | staging   |   prod   |
|------------  |-----------|----------|
| `single_nat` | true      | false    |
| `use_spot`   | true      | false    |
| `node_type`  | t3.medium | m5.large |

`CLOUD=aws` applies managed node groups; `CLOUD=ministack` only provisions control plane (k3s).
