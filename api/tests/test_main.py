import pytest
from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from main import app

client = TestClient(app)


def test_health_returns_200():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


@patch("main.r")
def test_create_job_returns_job_id(mock_r):
    mock_r.lpush = MagicMock(return_value=1)
    mock_r.hset = MagicMock(return_value=True)
    response = client.post("/jobs")
    assert response.status_code == 200
    assert "job_id" in response.json()


@patch("main.r")
def test_get_existing_job_returns_status(mock_r):
    mock_r.hget = MagicMock(return_value="queued")
    response = client.get("/jobs/test-job-123")
    assert response.status_code == 200
    assert "status" in response.json()


@patch("main.r")
def test_missing_job_returns_404(mock_r):
    mock_r.hget = MagicMock(return_value=None)
    response = client.get("/jobs/nonexistent-xyz")
    assert response.status_code == 404
