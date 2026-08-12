# Architecture

## Purpose

This document describes the target production architecture for Cloud Task Manager.

The application is simple, but the infrastructure is designed to show professional cloud engineering practices: secure networking, managed services, infrastructure automation, CI/CD, monitoring, and operational readiness.

## Target Architecture

```mermaid
flowchart TD
    User[User Browser]
    Internet[Internet]
    Route53[Amazon Route53]
    ACM[AWS Certificate Manager]
    ECR[Amazon ECR]
    ALB[Application Load Balancer]
    ECS[ECS Fargate Service]
    Backend[FastAPI Backend Container]
    RDS[(Amazon RDS PostgreSQL)]
    S3[(Amazon S3 Attachments Bucket)]
    Secrets[AWS Secrets Manager]
    CW[Amazon CloudWatch Logs and Metrics]
    SNS[Amazon SNS Alerts]
    CT[AWS CloudTrail]

    User --> Internet
    Internet --> Route53
    Route53 --> ALB
    ACM --> ALB
    ECR --> ECS
    ALB --> ECS
    ECS --> Backend
    Backend --> RDS
    Backend --> S3
    Backend --> Secrets
    ECS --> CW
    CW --> SNS
    CT --> CW
```

## Main Components

### Route53

Route53 will manage the custom domain name for the application.

Why it matters: users should access the application through a stable domain instead of an AWS-generated load balancer address.

### AWS Certificate Manager

ACM will provide the TLS certificate used for HTTPS.

Why it matters: production applications should encrypt traffic between users and the application.

### Application Load Balancer

The Application Load Balancer will receive public HTTPS traffic and forward valid requests to ECS tasks.

Why it matters: the load balancer gives us health checks, routing, TLS termination, and a stable entry point for the service.

### ECS Fargate

ECS Fargate will run the containerized FastAPI backend without us managing EC2 servers.

Why it matters: Fargate is a managed container platform. It lets us focus on service deployment, scaling, health checks, logs, and networking.

### Amazon ECR

ECR stores immutable backend container images and scans them for known vulnerabilities before deployment.

Why it matters: production deployments need a private, versioned source of container artifacts rather than images built manually on a server.

### Amazon RDS PostgreSQL

RDS will host the PostgreSQL database.

Why it matters: production databases need backups, encryption, monitoring, maintenance windows, and private network access.

### Amazon S3

S3 will store optional task attachments.

Why it matters: files should not be stored inside containers. Containers are temporary and can be replaced at any time.

### AWS Secrets Manager

Secrets Manager will store sensitive values such as database credentials.

Why it matters: secrets should not be committed to Git, stored in Docker images, or hardcoded in Terraform.

### CloudWatch

CloudWatch will collect logs, metrics, alarms, and dashboards.

Why it matters: engineers need visibility into failures, performance, availability, and application behavior.

### SNS

SNS will send alert notifications.

Why it matters: production systems need a way to tell engineers when something is unhealthy.

### CloudTrail

CloudTrail will record AWS account activity.

Why it matters: engineers and security teams need audit logs showing who changed what and when.

## Network Design

The application network is managed by Terraform in `eu-west-2`.

Implemented subnet model:

- Two public subnets across two Availability Zones for the load balancer and internet-facing routing.
- Two private subnets across two Availability Zones for ECS tasks and RDS.
- Separate security groups isolate the load balancer, application, and database tiers.

The database will not be publicly accessible.

Security group direction:

- Internet can reach the load balancer on HTTPS.
- Load balancer can reach ECS tasks on the backend application port.
- ECS tasks can reach RDS on PostgreSQL port 5432.
- ECS tasks can reach S3 and Secrets Manager as required.
- No direct public access to RDS.

## Infrastructure Management

Terraform is organized into environment root modules and reusable child modules. Development state is stored in a protected, versioned, encrypted S3 backend with S3-native state locking.

The current Terraform-managed foundation includes:

- An account-wide S3 state bucket.
- One development VPC across two Availability Zones.
- Two public and two private subnets.
- Public and private routing with no NAT gateway.
- Separate load balancer and API security groups.
- An encrypted ECR repository with immutable tags, scan-on-push, and lifecycle cleanup.

The ECS runtime has also been proven through an opt-in Terraform deployment. It includes an Application Load Balancer, private Fargate tasks, separate execution and task roles, CloudWatch logging, and the private ECR, Logs, and S3 network paths required without a NAT gateway. The runtime is disabled by default so hourly billed resources exist only during planned exercises.

## Current Cost Position

No load balancer, ECS service, interface VPC endpoints, RDS database, NAT gateway, or paid public IPv4 address is currently deployed. The S3 state bucket and ECR image incur usage-based storage and request charges, and the AWS budget remains the main cost guardrail.

Before each later stage, purpose, cost, security impact, verification, and cleanup will be reviewed before deployment.
