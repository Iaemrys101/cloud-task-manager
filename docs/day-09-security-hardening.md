# Day 9: Security Hardening

## Objective

Strengthen the existing application supply chain, container runtime, IAM permissions, and network paths without deploying new billable AWS resources.

## Security Principle

Security uses independent layers. If one control is accidentally removed or bypassed, another control should still limit the impact.

## Changes Implemented

### Non-Root Container

The Docker image now creates a dedicated numeric user and group with ID `10001`. The application files are owned by that identity, and the final image uses `USER 10001:10001`.

Why it matters: a compromised web process should not automatically receive root privileges inside its container.

### ECS Runtime Restrictions

The ECS task definition independently enforces:

- User and group `10001:10001`.
- A read-only root filesystem.
- No default Linux capabilities.
- An init process for correct signal and child-process handling.

Why it matters: runtime enforcement still protects the service if a future image accidentally omits its Docker `USER` instruction.

### Python Dependency Audit

The CI workflow now runs `pip-audit` against `backend/requirements.txt`.

The check fails when:

- A production dependency has a known vulnerability.
- Dependency collection fails and the audit cannot provide a trustworthy result.

Why it matters: a passing unit test does not prove that third-party software is free from known security defects.

### Least-Privilege ECS Execution Role

The general AWS-managed ECS execution policy was replaced with a project-managed policy. It allows only:

- Retrieval of an ECR authorization token.
- Pulling image layers and manifests from the backend ECR repository.
- Writing log events to the backend CloudWatch log group.

The application task role remains empty because the current backend does not call AWS APIs.

Why it matters: execution permissions and application permissions have different owners and should not be mixed.

### Restricted Task Egress

The API security group no longer permits unrestricted outbound traffic. When the optional runtime is enabled, tasks may reach only:

- Private ECR API and ECR Docker endpoints over HTTPS.
- The private CloudWatch Logs endpoint over HTTPS.
- The S3 gateway endpoint over HTTPS for ECR image layers.

Why it matters: a compromised task has a much smaller network path for data exfiltration.

### Threat Model

`docs/threat-model.md` records assets, trust boundaries, important threats, implemented controls, OWASP considerations, and production security gates.

Why it matters: security decisions need an explicit record that can be reviewed when the system changes.

## Existing Controls Confirmed

- GitHub branch protection and required checks.
- GitHub OIDC instead of permanent AWS access keys.
- Repository- and branch-restricted OIDC trust.
- ECR immutable tags, encryption, scan-on-push, and lifecycle cleanup.
- Private ECS subnet design and ALB-only application ingress.
- Encrypted and versioned Terraform state.
- Public access block and TLS-only state bucket policy.
- Disabled-by-default billable container runtime.

## Verification

The hardened local image was built successfully.

The container identity check returned:

```text
uid=10001(appuser) gid=10001(appgroup) groups=10001(appgroup)
```

The health endpoint still returned:

```json
{"status":"ok","service":"cloud-task-manager-api","version":"0.1.0"}
```

The local production dependency audit reported:

```text
No known vulnerabilities found
```

The backend test suite passed all three tests. Terraform formatting and validation completed successfully. The unrestricted API egress rule was removed from AWS, and a final plan confirmed that the infrastructure matches the configuration.

## Deferred Security Controls

Some controls require components that do not exist yet:

- HTTPS requires a domain and ACM certificate.
- Secrets Manager requires real application secrets and ECS injection.
- RDS encryption, backups, and database security require the database module.
- CloudTrail retention and monitoring will be coordinated with observability work.
- Authentication and authorization require the application identity design.

These are documented production gates, not silently accepted risks.

## Cost Impact

The Docker, CI, Terraform configuration, and documentation changes create no new billable AWS resources. The ECS runtime remains disabled. A Terraform apply removed one unrestricted security-group egress rule, then a final plan reported no changes.

GitHub-hosted Actions usage follows the repository's GitHub plan. The public repository does not add an AWS service charge for the dependency audit.

## Completion Checklist

- [x] Container runs as a non-root user.
- [x] Non-root identity is verified locally.
- [x] Health endpoint works in the hardened container.
- [x] ECS task enforces non-root execution.
- [x] Linux capabilities are dropped.
- [x] Root filesystem remains read-only.
- [x] Python dependency audit is added to CI.
- [x] Current production dependencies have no known vulnerabilities.
- [x] ECS execution role follows least privilege.
- [x] Task egress is restricted to required private endpoints.
- [x] Threat model and OWASP considerations are documented.
- [x] Terraform formatting and validation pass.
- [x] Unrestricted API egress is removed from AWS.
- [x] Final Terraform plan reports no changes.
- [ ] Pull request checks pass.
