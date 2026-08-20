# Day 10: Monitoring and Observability

## Objective

Design operational visibility for the optional ECS Fargate runtime without creating new billable AWS resources.

## Observability Model

Observability uses several types of evidence:

- Logs explain individual events and failures.
- Metrics show numerical behavior over time.
- Alarms evaluate metrics against operational limits.
- Dashboards place related signals in one investigation view.
- Notifications tell engineers when an alarm changes state.

Distributed tracing is intentionally deferred. The current application is one backend service and does not yet have a multi-service request path that justifies tracing infrastructure.

## Existing Foundation

The ECS design already provided:

- CloudWatch Logs through the `awslogs` driver.
- Seven-day development log retention.
- ECS Container Insights.
- Application Load Balancer metrics.
- A `/health` target-group health check.

Day 10 turns those signals into an operational monitoring system.

## Monitoring Module

The reusable Terraform module is located at `infrastructure/modules/monitoring`.

It receives the ECS cluster name, ECS service name, load balancer ARN suffix, target group ARN suffix, log group name, and AWS Region. This keeps monitoring separate from service deployment while connecting every metric to the correct resource.

The module is created only when `deploy_container_runtime` is `true`. This keeps development cost-safe while preserving a deployable monitoring design.

## CloudWatch Alarms

| Alarm | Metric | Trigger | Purpose |
| --- | --- | --- | --- |
| ECS CPU high | `AWS/ECS CPUUtilization` | Average at least 80% for two minutes | Detect sustained compute pressure |
| ECS memory high | `AWS/ECS MemoryUtilization` | Average at least 80% for two minutes | Detect memory pressure or leaks |
| Backend 5xx high | `AWS/ApplicationELB HTTPCode_Target_5XX_Count` | At least five errors in one minute | Detect application failures |
| Target latency high | `AWS/ApplicationELB TargetResponseTime` | Average at least one second for two minutes | Detect sustained slow responses |
| Unhealthy targets | `AWS/ApplicationELB UnHealthyHostCount` | At least one unhealthy target for two minutes | Detect failed health checks |

Every alarm uses `treat_missing_data = "notBreaching"`. When the optional runtime is disabled, absent metrics do not produce false alarms.

## Operations Dashboard

The CloudWatch dashboard uses an eight-hour default time range and contains:

- Current state of all five alarms.
- ECS CPU and memory utilization.
- Request count and target HTTP 5xx responses.
- Backend response latency.
- Healthy and unhealthy target counts.
- A CloudWatch Logs Insights table for recent `ERROR` and `Exception` messages.

The dashboard follows a troubleshooting order: alarm, capacity, traffic, latency, health, then detailed logs.

## SNS Notifications

CloudWatch alarm and recovery actions publish to an encrypted SNS topic. Its topic policy permits publishing only from CloudWatch alarms in the same AWS account whose names begin with the project and environment prefix.

No email address is committed to Git or stored in Terraform. A notification subscription can be created during a planned runtime exercise and confirmed by its recipient.

## Alert Response

The backend alert-response runbook is stored at `docs/runbooks/backend-alert-response.md`.

The response sequence is:

1. Record the alarm, state-change time, and affected environment.
2. Check the operations dashboard for correlated signals.
3. Inspect ECS service events and deployment history.
4. Search backend logs around the alarm time.
5. Identify a recent deployment, load increase, resource limit, or dependency failure.
6. Apply the smallest approved mitigation.
7. Confirm health checks, metrics, logs, and alarm recovery.
8. Record the cause and prevention work.

## Deferred Monitoring

- RDS alarms will be added with the database because no database currently exists.
- External synthetic availability checks require a stable deployed endpoint and add usage charges.
- X-Ray or OpenTelemetry tracing will be reconsidered when requests cross multiple application services.
- Email subscription is deferred until a planned runtime exercise.
- The existing AWS budget remains the billing alert and cost guardrail.

These are explicit lifecycle decisions, not missing controls disguised as completed work.

## Cost Impact

No monitoring resources were applied. CloudWatch dashboards, alarms, Logs Insights queries, SNS delivery, and the ECS runtime can incur usage charges when enabled.

The default runtime setting remains `false`, so the final normal plan reported no changes. The enabled design was tested with a plan-only command and was not applied.

## Verification

Terraform formatting completed with no changes. Terraform initialization discovered the new module, and validation reported a valid configuration.

The default cost-safe plan reported:

```text
No changes. Your infrastructure matches the configuration.
```

The enabled simulation reported:

```text
Plan: 26 to add, 0 to change, 0 to destroy.
```

No `terraform apply` command was run.

## Completion Checklist

- [x] Existing logging and health checks reviewed.
- [x] CPU and memory alarms defined.
- [x] HTTP 5xx and latency alarms defined.
- [x] Unhealthy-target alarm defined.
- [x] Alarm and recovery notifications connected to SNS.
- [x] SNS publishing policy restricted to project alarms in the current account.
- [x] CloudWatch operations dashboard defined.
- [x] Recent-error Logs Insights widget defined.
- [x] Alert-response runbook documented.
- [x] Database, tracing, and synthetic monitoring deferrals documented.
- [x] Terraform formatting and validation pass.
- [x] Default plan reports no changes.
- [x] Enabled design is verified by plan without apply.
- [ ] Pull request checks pass.
