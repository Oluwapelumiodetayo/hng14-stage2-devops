#!/bin/bash
set -e

TIMEOUT=120
FRONTEND_URL="http://localhost:3000"
API_URL="http://localhost:8000"

echo "=== Integration Test Start ==="

# Wait for frontend health
echo "Waiting for frontend..."
ELAPSED=0
until curl -sf "$FRONTEND_URL/health" > /dev/null 2>&1; do
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "ERROR: Frontend not ready after ${TIMEOUT}s"
    docker compose logs
    exit 1
  fi
  sleep 5
  ELAPSED=$((ELAPSED + 5))
  echo "  waiting... ${ELAPSED}s"
done
echo "Frontend ready."

# Submit job
echo "Submitting job..."
JOB_RESPONSE=$(curl -sf -X POST "$FRONTEND_URL/jobs" \
  -H "Content-Type: application/json" \
  -d '{"task": "integration_test"}' 2>/dev/null) || \
JOB_RESPONSE=$(curl -sf -X POST "$API_URL/jobs" \
  -H "Content-Type: application/json" \
  -d '{"task": "integration_test"}')

echo "Response: $JOB_RESPONSE"
JOB_ID=$(echo "$JOB_RESPONSE" | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(d.get('job_id', d.get('id','')))" 2>/dev/null)

if [ -z "$JOB_ID" ]; then
  echo "ERROR: No job_id in response"
  exit 1
fi
echo "Job ID: $JOB_ID"

# Poll with timeout
echo "Polling for completion..."
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
  STATUS_RESP=$(curl -sf "$FRONTEND_URL/jobs/$JOB_ID" 2>/dev/null) || \
  STATUS_RESP=$(curl -sf "$API_URL/jobs/$JOB_ID" 2>/dev/null) || true

  STATUS=$(echo "$STATUS_RESP" | python3 -c \
    "import sys,json; print(json.load(sys.stdin).get('status','unknown'))" 2>/dev/null || echo "unknown")

  echo "  status=$STATUS elapsed=${ELAPSED}s"

  if [ "$STATUS" = "completed" ] || [ "$STATUS" = "done" ] || [ "$STATUS" = "success" ]; then
    echo "=== Job completed! Integration test PASSED ==="
    exit 0
  fi

  sleep 5
  ELAPSED=$((ELAPSED + 5))
done

echo "ERROR: Job did not complete within ${TIMEOUT}s"
docker compose logs
exit 1
