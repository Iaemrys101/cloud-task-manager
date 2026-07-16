# Day 2: Local Backend Application

## Objective

Create the simple backend service that we will deploy throughout the rest of the project.

The goal is not to become a backend developer today. The goal is to create a realistic deployment target for Docker, ECS, CI/CD, monitoring, and security work.

## What We Built

Today adds a FastAPI backend with:

- a health check endpoint
- basic login endpoint
- create task endpoint
- list tasks endpoint
- get task endpoint
- update task endpoint
- mark task complete endpoint
- delete task endpoint
- automated tests

## Why This Matters For Deployment

Cloud infrastructure needs an application to run.

The backend gives us something real to:

- containerize with Docker
- scan for vulnerabilities
- deploy to ECS Fargate
- expose through an Application Load Balancer
- check with health checks
- monitor with CloudWatch
- test in GitHub Actions
- connect to PostgreSQL later

## Important Engineering Concept: Health Checks

The `/health` endpoint is small but important.

Later, the load balancer and deployment pipeline can use it to ask:

```text
Is the service alive and able to respond?
```

If this endpoint fails, ECS or the load balancer can treat the running task as unhealthy.

## Important Engineering Concept: In-Memory Storage

For Day 2, tasks are stored in memory.

That means:

- the app works locally
- tests can run quickly
- we avoid database setup for now
- data disappears when the app restarts

This is not production storage. PostgreSQL comes later.

## Files Created Today

### backend/app/main.py

The FastAPI application.

It defines the API routes, request models, response models, and temporary in-memory task storage.

### backend/app/__init__.py

Marks `app` as a Python package so imports work cleanly.

### backend/tests/test_health.py

Tests the `/health` endpoint.

### backend/tests/test_tasks.py

Tests the task create, list, update, complete, and delete workflow.

### backend/requirements.txt

Runtime dependencies needed to run the backend.

### backend/requirements-dev.txt

Development dependencies needed to run tests.

### backend/README.md

Backend-specific setup, run, and test instructions.

## Commands

From the repository root:

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-dev.txt
python -m pytest
uvicorn app.main:app --reload
```

On Windows PowerShell, activate the virtual environment with:

```powershell
.\.venv\Scripts\Activate.ps1
```

## Common Mistakes

- Running commands from the wrong folder.
- Forgetting to activate the virtual environment.
- Expecting in-memory data to persist after restart.
- Building database logic too early.
- Skipping the health check endpoint.
- Installing packages globally instead of using a virtual environment.

## Testing Instructions

Run:

```bash
cd backend
python -m pytest
```

Expected result:

```text
3 passed
```

## Cost Note

No AWS resources are created on Day 2.

Current AWS cost: 0.

## Completion Checklist

- [ ] Backend folder exists
- [ ] FastAPI app exists
- [ ] Health endpoint exists
- [ ] Task endpoints exist
- [ ] Tests exist
- [ ] Dependencies are documented
- [ ] Tests pass locally
- [ ] Changes are committed

## Suggested Commit

```bash
git add .
git commit -m "feat: add local FastAPI backend"
```

