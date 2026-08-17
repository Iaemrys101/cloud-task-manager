# Day 8: GitHub Actions CI/CD And AWS OIDC

## Objective

Automate project validation for every pull request and create a secure delivery path that publishes approved backend container images to Amazon ECR without storing long-lived AWS access keys in GitHub.

## Delivery Flow

```mermaid
flowchart LR
    Developer[Developer] --> Branch[Feature branch]
    Branch --> PR[Pull request]
    PR --> CI[GitHub Actions CI]
    CI --> Review[Reviewed merge]
    Review --> Main[Main branch]
    Main --> Publish[Image publishing workflow]
    Publish --> OIDC[AWS OIDC trust]
    OIDC --> Role[Temporary IAM role session]
    Role --> ECR[Amazon ECR]
```

Continuous integration checks proposed changes before they reach `main`. Continuous delivery packages approved code after it reaches `main` and stores the resulting image in ECR. The workflow does not automatically start the ECS runtime.

## Continuous Integration

The `Continuous Integration` workflow runs for pull requests, pushes to `main`, and manual requests. It grants only read access to repository contents and runs three independent jobs on temporary GitHub-hosted Ubuntu runners.

### Backend Tests

The backend job:

- Checks out the repository.
- Installs Python 3.12.
- Caches downloaded Python packages.
- Installs the development dependencies.
- Runs the three `pytest` tests.

### Terraform Checks

The Terraform job:

- Installs the project Terraform version.
- Checks formatting across `infrastructure/`.
- Initialises the development configuration without connecting to the remote backend.
- Validates the complete module structure.

Using `-backend=false` means pull-request validation does not require AWS credentials and cannot change the remote Terraform state.

### Docker Build

The Docker job builds the backend for `linux/amd64` without pushing it. This proves that the Dockerfile and application build context work before a merge is allowed.

BuildKit provenance and SBOM attestations remain disabled for this ECR Basic Scanning workflow so the published artifact is a directly scannable OCI image manifest.

## AWS Authentication With OIDC

GitHub Actions uses OpenID Connect to request short-lived AWS credentials. No AWS access key or secret access key is stored in GitHub.

The Terraform `github_actions_oidc` module creates:

- The account-wide GitHub OIDC identity provider.
- An IAM role for backend image publishing.
- A trust policy restricted to this repository's immutable GitHub identity and the `main` branch.
- An inline least-privilege ECR publishing policy.

AWS validates both the token audience and subject before allowing `sts:AssumeRoleWithWebIdentity`. The assumed session is limited to one hour.

## Least-Privilege ECR Access

The publishing role can request an ECR authentication token and perform only the layer and image operations required to push to the project backend repository. It cannot administer the AWS account, modify Terraform state, create ECS services, or publish to unrelated ECR repositories.

## Image Publishing

The `Publish Backend Image` workflow runs only on `main` when the backend or publishing workflow changes. A manual run is also available, but the job still checks that it is running from `main`.

The workflow:

1. Checks out the approved source revision.
2. Exchanges a GitHub OIDC token for temporary AWS credentials.
3. Logs Docker in to the private ECR registry.
4. Builds the backend for `linux/amd64`.
5. Tags the image with the full Git commit SHA.
6. Pushes the immutable image to ECR.

The Git commit SHA creates a traceable connection between source code, workflow run, and container artifact. ECR scan-on-push then evaluates the new image.

## GitHub Repository Variables

The workflow reads non-secret configuration from these repository variables:

- `AWS_GITHUB_ACTIONS_ROLE_ARN`
- `AWS_REGION`
- `ECR_REPOSITORY`

The role ARN identifies the role but is not a credential. Account-specific values are intentionally excluded from committed documentation.

## Verification

Completed before merge:

- Terraform formatting completed without changes.
- Terraform initialisation discovered the new module.
- Terraform validation succeeded.
- Terraform planned three additions with no changes or deletions.
- Terraform applied the OIDC provider, IAM role, and inline policy.
- A follow-up Terraform plan reported no changes.
- Pull-request backend tests passed.
- Pull-request Terraform checks passed.
- Pull-request Docker build passed.

The publishing workflow intentionally does not run on a feature branch. Its first ECR publication is verified from the Actions run and ECR image tag after the reviewed pull request reaches `main`.

## Cost Position

GitHub OIDC providers, IAM roles, and IAM policies have no hourly AWS charge. Pull-request CI does not create AWS resources.

Publishing adds a compressed image to ECR and therefore creates a small storage and request cost. The workflow does not enable ECS, Fargate, an Application Load Balancer, interface VPC endpoints, a NAT gateway, or RDS.

## Key Learning

CI proves that a proposed change is buildable and valid before merge. CD produces a traceable release artifact from approved code. OIDC connects GitHub to AWS with temporary, narrowly scoped credentials, removing the risk and maintenance burden of permanent AWS keys in GitHub secrets.
