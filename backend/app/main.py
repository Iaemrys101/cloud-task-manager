from datetime import UTC, datetime
from uuid import uuid4

from fastapi import FastAPI, HTTPException, Response, status
from pydantic import BaseModel, Field


app = FastAPI(
    title="Cloud Task Manager API",
    description="Simple deployment target for a production-grade cloud engineering project.",
    version="0.1.0",
)


class HealthResponse(BaseModel):
    status: str
    service: str
    version: str


class LoginRequest(BaseModel):
    username: str = Field(min_length=1)
    password: str = Field(min_length=1)


class LoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TaskCreate(BaseModel):
    title: str = Field(min_length=1, max_length=120)
    description: str | None = Field(default=None, max_length=500)


class TaskUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=120)
    description: str | None = Field(default=None, max_length=500)
    completed: bool | None = None


class Task(BaseModel):
    id: str
    title: str
    description: str | None = None
    completed: bool = False
    created_at: datetime
    updated_at: datetime


tasks: dict[str, Task] = {}


def now_utc() -> datetime:
    return datetime.now(UTC)


@app.get("/health", response_model=HealthResponse)
def health() -> HealthResponse:
    return HealthResponse(
        status="ok",
        service="cloud-task-manager-api",
        version=app.version,
    )


@app.post("/auth/login", response_model=LoginResponse)
def login(payload: LoginRequest) -> LoginResponse:
    # Demo token for local development. Real authentication is added in the security phase.
    return LoginResponse(access_token=f"demo-token-for-{payload.username}")


@app.get("/api/v1/tasks", response_model=list[Task])
def list_tasks() -> list[Task]:
    return list(tasks.values())


@app.post("/api/v1/tasks", response_model=Task, status_code=status.HTTP_201_CREATED)
def create_task(payload: TaskCreate) -> Task:
    task_id = str(uuid4())
    timestamp = now_utc()
    task = Task(
        id=task_id,
        title=payload.title,
        description=payload.description,
        completed=False,
        created_at=timestamp,
        updated_at=timestamp,
    )
    tasks[task_id] = task
    return task


@app.get("/api/v1/tasks/{task_id}", response_model=Task)
def get_task(task_id: str) -> Task:
    task = tasks.get(task_id)
    if task is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    return task


@app.patch("/api/v1/tasks/{task_id}", response_model=Task)
def update_task(task_id: str, payload: TaskUpdate) -> Task:
    task = tasks.get(task_id)
    if task is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")

    updates = payload.model_dump(exclude_unset=True)
    updated_task = task.model_copy(update={**updates, "updated_at": now_utc()})
    tasks[task_id] = updated_task
    return updated_task


@app.patch("/api/v1/tasks/{task_id}/complete", response_model=Task)
def complete_task(task_id: str) -> Task:
    task = tasks.get(task_id)
    if task is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")

    updated_task = task.model_copy(update={"completed": True, "updated_at": now_utc()})
    tasks[task_id] = updated_task
    return updated_task


@app.delete("/api/v1/tasks/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(task_id: str) -> Response:
    if task_id not in tasks:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")

    del tasks[task_id]
    return Response(status_code=status.HTTP_204_NO_CONTENT)
