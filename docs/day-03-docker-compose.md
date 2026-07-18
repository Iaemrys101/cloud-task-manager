# Day 3: Docker and Docker Compose

## Objective

Containerize the FastAPI backend and run it consistently using Docker Compose.

## Files Added

- `backend/Dockerfile` - instructions for building the backend image.
- `backend/.dockerignore` - excludes unnecessary local files from the build context.
- `compose.yaml` - defines how the backend service is built and started.

## Container Workflow

1. Docker reads the Dockerfile.
2. Docker builds an immutable image containing Python, dependencies, and application code.
3. Docker creates a container from that image.
4. Port `8000` on the host maps to port `8000` in the container.
5. Docker Compose stores and manages this configuration.

## Commands Used

Build the image manually:

```powershell
docker build -t cloud-task-manager-backend:day3 .\backend
```

Run the container manually:

```powershell
docker run --rm -p 8000:8000 cloud-task-manager-backend:day3
```

Validate the Compose configuration:

```powershell

docker compose config
```

Build and start with Compose:

```powershell
docker compose up --build
```

Stop and remove Compose resources:

```powershell
docker compose down
```

## Verification

The health endpoint was opened at:

```text
http://localhost:8000/health
```
The endpoint returned HTTP 200 OK and confirmed that the API was healthy.

## Troubleshooting

Docker Desktop worked from Windows PowerShell, but Docker commands were unreliable inside Ubuntu WSL. Docker commands were therefore run from PowerShell, while Git commands remained in the Ubuntu WSL terminal.

The Compose file was initially created inside `backend`, so Docker could not discover it from the project root. Moving `compose.yaml` to the repository root resolved the issue.

## Key Learning

A Docker image is the packaged application template. A container is a running instance of that image. Docker Compose provides a repeatable configuration for building, networking, and running containers.