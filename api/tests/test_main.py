import pytest
from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from main import app

client = TestClient(app)


def test_health_returns_200():
    """Health endpoint returns 200"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


@patch("main.r")
def test_create_job_returns_job_id(mock_r):
    """POST /jobs returns a job_id with Redis mocked"""
    mock_r.lpush = MagicMock(return_value=1)
    mock_r.hset = MagicMock(return_value=True)

    response = client.post("/jobs")
    assert response.status_code == 200
    body = response.json()
    assert "job_id" in body


@patch("main.r")
def test_get_existing_job_returns_status(mock_r):
    """GET /jobs/{id} returns status when job exists"""
    mock_r.hget = MagicMock(return_value="queued")

    response = client.get("/jobs/test-job-123")
    assert response.status_code == 200
    body = response.json()
    assert "status" in body
    assert body["status"] == "queued"


@patch("main.r")
def test_missing_job_returns_404(mock_r):
    """GET /jobs/{id} for unknown job returns 404"""
    mock_r.hget = MagicMock(return_value=None)

    response = client.get("/jobs/nonexistent-xyz-000")
    assert response.status_code == 404
