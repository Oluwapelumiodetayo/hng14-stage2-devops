# syntax=docker/dockerfile:1

# ---- Stage 1: Builder ----
FROM node:18-alpine AS builder

WORKDIR /build

COPY package*.json ./
# hadolint ignore=DL3016
RUN npm ci --only=production

# ---- Stage 2: Production ----
FROM node:18-alpine

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /build/node_modules ./node_modules
COPY --chown=appuser:appgroup . .

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "server.js"]
