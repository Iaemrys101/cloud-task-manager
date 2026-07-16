# Backend

This folder contains the FastAPI backend for Cloud Task Manager.

The backend is intentionally simple. It exists so we have a real service to containerize, deploy, monitor, test, and troubleshoot throughout the cloud engineering project.

## Current Features

- `GET /health`
- `POST /auth/login`
- `GET /api/v1/tasks`
- `POST /api/v1/tasks`
- `GET /api/v1/tasks/{task_id}`
- `PATCH /api/v1/tasks/{task_id}`
- `PATCH /api/v1/tasks/{task_id}/complete`
- `DELETE /api/v1/tasks/{task_id}`

## Local Setup

From the `backend` folder:

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-dev.txt
```

On Windows PowerShell, activate the virtual environment with:

```powershell
.\.venv\Scripts\Activate.ps1
```

## Run The API

```bash
uvicorn app.main:app --reload
```

Then open:

```text
http://127.0.0.1:8000/docs
```

## Run Tests

```bash
python -m pytest
```

## Important Note

Day 2 uses in-memory task storage.

That means tasks disappear when the app restarts. This is expected for now. PostgreSQL will be introduced later so we can learn database configuration, Docker Compose, secrets, migrations, and eventually Amazon RDS.

