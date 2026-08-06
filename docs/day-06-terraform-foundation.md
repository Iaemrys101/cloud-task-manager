# Day 6: Terraform Foundation And AWS Networking

## Objective

Reproduce the manually studied Day 5 AWS network as version-controlled Terraform and establish protected remote state before deploying application infrastructure.

## What Terraform Does

Terraform compares three sources of information:

1. Configuration files describe the desired infrastructure.
2. Terraform state records which real resources Terraform manages.
3. AWS APIs report the infrastructure that currently exists.

`terraform plan` previews the difference between those sources. `terraform apply` performs an approved plan and updates state with the resulting AWS resource identifiers.

## Repository Structure

```text
infrastructure/
|-- bootstrap/
|   `-- state/                 # Creates and protects the remote-state bucket
|-- environments/
|   `-- dev/                   # Development root module and S3 backend settings
`-- modules/
    `-- network/               # Reusable VPC, routing, subnet, and security resources
```

The development root module supplies environment-specific values. The network child module contains reusable resource definitions and returns IDs through outputs.

## Remote State

An account-wide S3 bucket stores Terraform state. The bucket configuration includes:

- Versioning for recovery from accidental state changes.
- Server-side encryption with S3-managed AES-256 keys.
- All four S3 Block Public Access controls.
- A bucket policy that denies requests without TLS.
- Terraform `prevent_destroy` protection.

The backend uses S3-native locking with `use_lockfile = true`. DynamoDB locking is not used because it is deprecated for the Terraform S3 backend.

Separate object keys isolate the two root modules:

```text
bootstrap/terraform.tfstate
environments/dev/terraform.tfstate
```

The bucket name and AWS credentials are not committed. The bucket name is supplied as partial backend configuration during `terraform init`, and AWS authentication comes from the temporary `terraform` CLI profile.

## Network Resources

Terraform manages the following development network in `eu-west-2`:

| Resource | Terraform name | Configuration |
| --- | --- | --- |
| VPC | `cloud-task-manager-dev-vpc` | `10.0.0.0/16` |
| Public subnet A | `cloud-task-manager-dev-public-a` | `10.0.1.0/24`, `eu-west-2a` |
| Public subnet B | `cloud-task-manager-dev-public-b` | `10.0.2.0/24`, `eu-west-2b` |
| Private subnet A | `cloud-task-manager-dev-private-a` | `10.0.11.0/24`, `eu-west-2a` |
| Private subnet B | `cloud-task-manager-dev-private-b` | `10.0.12.0/24`, `eu-west-2b` |
| Internet gateway | `cloud-task-manager-dev-igw` | Attached to the VPC |
| Public route table | `cloud-task-manager-dev-public-rt` | `0.0.0.0/0` to the internet gateway |
| Private route table | `cloud-task-manager-dev-private-rt` | Local VPC route only |

Public IP assignment on subnet launch is disabled. A subnet is public because its route table reaches the internet gateway, not because instances automatically receive public IP addresses.

## Security Groups

### Load Balancer Security Group

- Allows inbound TCP port `80` from `0.0.0.0/0` for the initial deployment.
- Allows outbound TCP port `8000` only to the API security group.

### API Security Group

- Allows inbound TCP port `8000` only from the load balancer security group.
- Allows outbound traffic, subject to the private subnet route table.

The private route table has no internet route. An outbound security-group rule grants permission, but it does not create a network path.

## NAT Gateway Decision

No NAT gateway is deployed. This avoids NAT hourly and data-processing charges while the project is not running ECS workloads.

Before ECS deployment, the project will compare a NAT gateway with VPC endpoints required for ECR, CloudWatch Logs, Secrets Manager, and S3.

## Deployment Workflow

The main commands used were:

```bash
export AWS_PROFILE=terraform

terraform -chdir=infrastructure/bootstrap/state init
terraform -chdir=infrastructure/bootstrap/state validate
terraform -chdir=infrastructure/bootstrap/state plan -out=.terraform/bootstrap.tfplan
terraform -chdir=infrastructure/bootstrap/state apply .terraform/bootstrap.tfplan

export TF_STATE_BUCKET="$(terraform -chdir=infrastructure/bootstrap/state output -raw state_bucket_name)"

terraform -chdir=infrastructure/bootstrap/state init \
  -migrate-state \
  -backend-config="bucket=$TF_STATE_BUCKET"

terraform -chdir=infrastructure/environments/dev init \
  -reconfigure \
  -backend-config="bucket=$TF_STATE_BUCKET"

terraform -chdir=infrastructure/environments/dev validate
terraform -chdir=infrastructure/environments/dev plan -out=.terraform/dev.tfplan
terraform -chdir=infrastructure/environments/dev apply .terraform/dev.tfplan
```

Saved plans are written inside `.terraform/`, which is ignored by Git. Plan and state files must never be committed because they can contain sensitive data.

## Manual-To-Terraform Handover

The Day 5 console-built VPC was deleted only after the complete Terraform plan had been validated. An AWS CLI query confirmed that zero VPCs remained with the old manual name before Terraform applied the replacement.

This avoided duplicate learning infrastructure and established Terraform as the single owner of the development network.

## Verification

- Bootstrap plan: `5 to add, 0 to change, 0 to destroy`.
- Bootstrap apply: `5 added, 0 changed, 0 destroyed`.
- Development plan: `19 to add, 0 to change, 0 to destroy`.
- Development apply: `19 added, 0 changed, 0 destroyed`.
- Post-apply development plan: no changes.

The final no-change plan confirmed that the Terraform configuration, remote state, and AWS infrastructure agreed.

## Cost And Security Position

- The S3 state bucket incurs usage-based storage and request charges.
- No NAT gateway, load balancer, ECS service, RDS database, or paid public IPv4 address is deployed.
- The monthly AWS budget remains the primary cost guardrail.
- AWS credentials, account IDs, resource IDs, state files, and saved plans are not committed.

## Cleanup Order

The development network must be destroyed before the state bootstrap. Destroying the state bucket first would remove the management record needed to cleanly destroy development resources.

The state bucket has `prevent_destroy` enabled and requires a separate, deliberate retirement procedure. It must not be removed as part of routine development cleanup.

## Key Learning

Terraform configuration describes the desired infrastructure, while state establishes ownership of real resources. Remote state, locking, saved plans, and no-change verification make infrastructure changes repeatable and safer for team workflows.
