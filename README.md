# Cloud Task Manager

Cloud Task Manager is a portfolio project focused on production-grade cloud engineering rather than application complexity.

The application will stay intentionally simple:

- Users can create, update, delete, and complete tasks.
- Users can log in securely.
- Task data will be stored in PostgreSQL.
- Optional file attachments will be stored in Amazon S3.

The engineering work is the main learning goal:

- Infrastructure as Code with Terraform
- Containerized deployment with Docker
- AWS deployment on ECS Fargate
- Secure networking with VPC public and private subnets
- Managed PostgreSQL with Amazon RDS
- CI/CD with GitHub Actions and AWS OIDC
- Monitoring, logging, alerting, and operational runbooks
- Security scanning and least privilege IAM
- Professional documentation and Git workflow

## Learning Approach

This project is built one focused stage at a time. Each stage should end with:

- a working deliverable
- a clear explanation of what changed
- testing instructions
- cost awareness
- a completion checklist
- a Git commit and pull request

The goal is to understand the system well enough to explain it in an interview, maintain it in production, and troubleshoot it when something fails.

## Planned Milestones

1. Project planning and architecture
2. Local application development
3. Docker and Docker Compose
4. Git and GitHub workflow
5. AWS networking: VPC, subnets, IAM
6. Terraform infrastructure
7. ECS and ECR deployment
8. CI/CD with GitHub Actions
9. Security hardening
10. Monitoring and observability
11. Documentation and disaster recovery
12. Portfolio polish

## Current Status

Day 8 established the automated integration and container delivery path:

- Pull requests automatically run backend tests, Terraform checks, and a Docker build.
- GitHub Actions authenticates to AWS through OIDC instead of permanent access keys.
- The AWS trust policy is restricted to this repository's immutable identity and the `main` branch.
- The publishing role has permission only to upload images to the project ECR repository.
- Approved backend images are built for `linux/amd64` and tagged with their full Git commit SHA.
- Amazon ECR stores immutable images and scans every push.

Terraform can still deploy a selected image to private ECS Fargate tasks behind an Application Load Balancer, but the runtime remains disabled by default. The persistent AWS footprint is limited to the Terraform state bucket, ECR image storage, IAM/OIDC resources, and the no-hourly-charge network foundation.

## Repository Structure

```text
backend/
  app/
    main.py
  tests/
docs/
infrastructure/
  bootstrap/
  environments/
  modules/
.github/
README.md
```
