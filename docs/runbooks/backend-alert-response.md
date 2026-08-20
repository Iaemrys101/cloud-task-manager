# Backend Alert Response Runbook

## Purpose

Use this runbook when a CloudWatch alarm reports high CPU, high memory, excessive backend errors, high latency, or unhealthy load balancer targets.

The goal is to restore service safely, preserve useful evidence, and record enough information to prevent recurrence.

## Safety Rules

- Confirm the AWS profile and Region before running commands.
- Do not paste account IDs, ARNs, tokens, or credentials into issues or chat.
- Do not restart, scale, redeploy, or roll back before collecting initial evidence.
- Obtain approval before making a production change.
- Prefer small, reversible changes.

## Initial Triage

Record:

- Alarm name and current state.
- Environment and AWS Region.
- State-change timestamp.
- User-visible symptoms.
- Recent deployments or infrastructure changes.

List the project alarms without exposing resource identifiers:

```bash
AWS_PROFILE=cloud-admin-login aws cloudwatch describe-alarms \
  --alarm-name-prefix cloud-task-manager-dev- \
  --region eu-west-2 \
  --query 'MetricAlarms[].{Name:AlarmName,State:StateValue,Reason:StateReason}' \
  --output table
```

## Check ECS Service Health

When the optional runtime is enabled, inspect desired, running, and pending task counts plus the most recent service event:

```bash
AWS_PROFILE=cloud-admin-login aws ecs describe-services \
  --cluster cloud-task-manager-dev-cluster \
  --services cloud-task-manager-dev-backend \
  --region eu-west-2 \
  --query 'services[0].{Status:status,Desired:desiredCount,Running:runningCount,Pending:pendingCount,LatestEvent:events[0].message}' \
  --output table
```

Important conditions include:

- `runningCount` below `desiredCount`.
- Tasks repeatedly starting and stopping.
- Failed image pulls.
- Failed health checks.
- Insufficient permissions or network connectivity.

## Inspect Backend Logs

Review recent logs around the alarm time:

```bash
AWS_PROFILE=cloud-admin-login aws logs tail \
  /ecs/cloud-task-manager-dev-backend \
  --since 30m \
  --region eu-west-2
```

Look for:

- Python exceptions and stack traces.
- Repeated HTTP 5xx responses.
- Startup failures.
- Dependency timeouts.
- Out-of-memory termination evidence.
- A sharp change immediately after deployment.

## Alarm-Specific Investigation

### High CPU

Check whether request volume increased at the same time. Look for repeated expensive operations, retry loops, or abnormal traffic. Confirm whether all tasks or one deployment revision are affected.

### High Memory

Look for steadily increasing memory, large requests, repeated object accumulation, or out-of-memory task stops. Compare current behavior with the previous deployment.

### Backend HTTP 5xx

Search application logs for exceptions matching the alarm window. Compare error count with request count so a small number of errors is not mistaken for a complete outage.

### High Latency

Compare response time with CPU, memory, request volume, target health, and dependency errors. A slow service with normal CPU may be waiting on a network or database dependency rather than lacking compute.

### Unhealthy Targets

Confirm the task is running, port `8000` is exposed, and `/health` returns HTTP 200. Review ECS events, task logs, security groups, and target-group health reasons.

## Mitigation Options

Choose the smallest action supported by evidence:

- Roll back to the last known-good immutable image.
- Correct a broken environment value or permission.
- Restore required network connectivity.
- Increase task CPU, memory, or desired count when sustained demand justifies it.
- Disable a failing optional dependency while preserving core service behavior.

Changes must pass the normal GitHub pull-request and Terraform plan process. Emergency actions must be documented afterward.

## Recovery Verification

Confirm all of the following:

- ECS running count equals desired count.
- The `/health` endpoint returns HTTP 200.
- Target health is restored.
- CPU, memory, latency, and error metrics return to normal.
- No new related exceptions appear in logs.
- CloudWatch alarms return to `OK`.
- User-visible behavior is restored.

## Incident Record

Document:

- Impact and duration.
- Detection source.
- Timeline.
- Technical root cause.
- Mitigation and recovery.
- What worked and what delayed recovery.
- Preventive action with an owner.
- Monitoring or runbook improvements.

An alarm is complete only when service is restored and the learning is recorded.
