from fastapi.testclient import TestClient

from app.main import app, tasks


client = TestClient(app)


def setup_function() -> None:
    tasks.clear()


def test_create_and_list_tasks() -> None:
    create_response = client.post(
        "/api/v1/tasks",
        json={"title": "Deploy backend", "description": "Prepare the local API"},
    )

    assert create_response.status_code == 201
    created_task = create_response.json()
    assert created_task["title"] == "Deploy backend"
    assert created_task["completed"] is False

    list_response = client.get("/api/v1/tasks")

    assert list_response.status_code == 200
    assert len(list_response.json()) == 1


def test_update_complete_and_delete_task() -> None:
    create_response = client.post("/api/v1/tasks", json={"title": "Original title"})
    task_id = create_response.json()["id"]

    update_response = client.patch(
        f"/api/v1/tasks/{task_id}",
        json={"title": "Updated title"},
    )

    assert update_response.status_code == 200
    assert update_response.json()["title"] == "Updated title"

    complete_response = client.patch(f"/api/v1/tasks/{task_id}/complete")

    assert complete_response.status_code == 200
    assert complete_response.json()["completed"] is True

    delete_response = client.delete(f"/api/v1/tasks/{task_id}")

    assert delete_response.status_code == 204
    assert client.get(f"/api/v1/tasks/{task_id}").status_code == 404

