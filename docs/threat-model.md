# Cloud Task Manager Threat Model

## Purpose

This document identifies important assets, trust boundaries, likely threats, implemented controls, and residual risks for Cloud Task Manager. It is reviewed whenever the architecture or deployment path changes.

## Scope

The current scope includes:

- Source code and GitHub repository governance.
- GitHub Actions CI and ECR publishing.
- AWS IAM and OIDC federation.
- Terraform configuration and remote state.
- The backend container image.
- The optional ECS Fargate and Application Load Balancer runtime.
- The VPC, subnets, routes, security groups, and VPC endpoints.

RDS, application authentication, user data, attachment storage, DNS, and HTTPS are target components. Their final controls remain production gates until those components are implemented.

## Important Assets

- Source code and protected branch history.
- GitHub workflow definitions and repository variables.
- Temporary AWS credentials issued through OIDC.
- Terraform configuration and remote state.
- ECR container images and tags.
- Application availability and logs.
- Future user accounts, task data, database credentials, and attachments.

## Trust Boundaries

1. Developer workstation to GitHub.
2. Pull request code to the trusted `main` branch.
3. GitHub Actions to AWS Security Token Service through OIDC.
4. GitHub Actions to the private ECR repository.
5. Internet clients to the public load balancer.
6. Load balancer to private ECS tasks.
7. ECS tasks to private AWS service endpoints.
8. Terraform client to the protected S3 state backend.

## Threats And Controls

| Threat | Potential impact | Current controls | Residual action |
| --- | --- | --- | --- |
| Malicious or accidental code reaches `main` | Compromised image or broken deployment | Feature branches, pull requests, required CI checks, protected `main` | Add independent reviewers when collaborators join |
| Permanent AWS credentials are stolen from GitHub | Long-lived account access | OIDC temporary credentials; no GitHub access keys; repository and branch trust conditions | Review OIDC trust policy after repository identity changes |
| CI role is used outside its purpose | Unauthorized AWS changes | Publishing role is limited to ECR upload actions for one repository | Continue reviewing permissions when the workflow expands |
| Vulnerable Python dependency is introduced | Application compromise | `pip-audit` blocks known production dependency vulnerabilities | Add a controlled dependency update process and lock file |
| Vulnerable operating system package enters an image | Container compromise | Minimal Alpine base, ECR scan-on-push, immutable image tags | Rebuild regularly and block deployment on severe findings |
| Container process is compromised | Privilege escalation or filesystem tampering | Numeric non-root user, read-only root filesystem, all Linux capabilities dropped | Re-test controls whenever the runtime image changes |
| Public traffic reaches ECS directly | Bypass of load balancer controls | ECS tasks use private subnets; API ingress accepts only the ALB security group | Keep public IP assignment disabled |
| Compromised task exfiltrates data | Data loss or command-and-control traffic | No NAT gateway; task egress is limited to required private endpoints | Add explicit database and Secrets Manager paths only when required |
| Secrets are committed or placed in images | Credential disclosure | `.gitignore`, no embedded AWS keys, OIDC, no current application secrets | Store future credentials in Secrets Manager and inject them at task launch |
| Terraform state is exposed or modified | Infrastructure disclosure or takeover | S3 encryption, versioning, public access block, TLS-only bucket policy, state locking | Add state access monitoring and recovery exercises |
| Unencrypted client traffic is intercepted | Credential or task data disclosure | HTTPS is part of the target architecture | Do not treat the service as production-ready until ACM and HTTPS are enabled |
| AWS activity cannot be investigated | Delayed incident response | Default AWS event history and planned application logs | Configure retained CloudTrail evidence and alerting before production |
| Unexpected resource creation increases cost | Financial impact | AWS budget, opt-in runtime flag, no NAT gateway, documented cleanup | Add anomaly alerts and review Terraform plans before apply |

## OWASP Considerations

### Broken Access Control

Authentication and per-user task authorization are not implemented yet. They are production gates. AWS access is separated between GitHub publishing, ECS execution, and application task roles.

### Cryptographic Failures

Terraform state and ECR images are encrypted at rest. HTTPS and encrypted RDS are required before production data is introduced.

### Injection

FastAPI request models validate current inputs. Future database access must use parameterized queries or an ORM and must never construct SQL from raw user input.

### Insecure Design

The architecture separates public, application, and future database tiers. This threat model is reviewed as new data flows are added.

### Security Misconfiguration

Terraform, CI validation, private subnets, scoped security groups, non-root containers, and read-only filesystems reduce configuration drift and dangerous defaults.

### Vulnerable And Outdated Components

Python dependencies are audited in CI and ECR scans published images. Dependency and base-image updates must pass the same tests and scans as application changes.

### Identification And Authentication Failures

Application authentication is not implemented. A managed identity design and secure session handling are required before user accounts are enabled.

### Software And Data Integrity Failures

Protected pull requests, immutable ECR tags, commit-SHA image tags, and OIDC-restricted publishing protect the delivery path. Deployment must reference an immutable image tag.

### Security Logging And Monitoring Failures

ECS writes application logs to CloudWatch when deployed. Day 10 will add dashboards, alarms, notification paths, and operational queries.

### Server-Side Request Forgery

The current API does not fetch user-provided URLs. Private task egress has no general internet route and is restricted to required AWS service endpoints.

## Production Security Gates

The system must not be presented as production-ready until all of the following are complete:

- HTTPS with a validated domain and ACM certificate.
- Managed authentication and authorization.
- Private encrypted RDS with backup and restore testing.
- Secrets Manager integration and rotation procedure.
- Retained CloudTrail audit evidence.
- CloudWatch alarms and incident notification.
- Automated deployment blocking for severe image findings.
- Documented incident response and disaster recovery exercises.
