# HNG14 Stage 2 - DevOps Microservices App

## Overview
This project is a containerized microservices system consisting of:
- Frontend (Node.js)
- API (FastAPI)
- Worker (Python)
- Redis (queue broker)

---

## How to run locally

### 1. Clone repo
git clone <your-repo-url>

### 2. Start services
docker compose up -d --build

---

## Services

- Frontend: http://localhost:3000
- API: http://localhost:8000/docs
- Redis: internal only

---

## API Usage

### Create job
POST /jobs

### Check job
GET /jobs/{job_id}

---

## Architecture
Frontend → API → Redis Queue → Worker → Redis → API response

---

## Notes
- All services run in Docker
- Redis is not exposed publicly
- Healthchecks implemented
- Non-root users used in containers# hng14-stage2-devops
