# FIXES DOCUMENTATION

## 1. Redis connection issue
- File: api/main.py
- Issue: used localhost instead of docker service name
- Fix: changed to REDIS_HOST=redis

---

## 2. Worker decode error
- File: worker/worker.py
- Issue: job_id was already string but .decode() was used
- Fix: removed .decode()

---

## 3. Worker indentation error
- File: worker/worker.py
- Issue: inconsistent indentation caused crash
- Fix: standardized indentation to 4 spaces

---

## 4. Redis queue misunderstanding
- Issue: expected LRANGE to show jobs but using BRPOP removes items
- Fix: verified correct queue behavior (no code change)

---

## 5. Docker container communication
- Issue: services initially failed to communicate
- Fix: ensured all services use docker-compose network + service names
