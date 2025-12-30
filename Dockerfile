# syntax=docker/dockerfile:1

# ====================
# Build stage
# ====================
FROM golang:1.25-alpine AS builder

# Security: Apply latest security patches
RUN apk update && apk upgrade && apk add --no-cache ca-certificates tzdata

WORKDIR /app

# Leverage dependency caching
COPY go.mod go.sum ./
RUN go mod download

# Copy source code and build
COPY . .

# Build as static binary (CGO disabled)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-w -s" \
    -o /app/server \
    ./app/main.go

# ====================
# Runtime stage
# ====================
FROM scratch

# Copy timezone data and certificates
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Run as non-root user (security)
# Specify user ID directly for scratch image
USER 65534:65534

# Copy binary
COPY --from=builder /app/server /server

# Metadata
LABEL org.opencontainers.image.title="Go Test Server"
LABEL org.opencontainers.image.description="Simple Go HTTP server for vulnerability scanning demo"
LABEL org.opencontainers.image.source="https://github.com/gr1m0h/test-server"

# Health check configuration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["/server", "-health-check"] || exit 1

EXPOSE 8080

ENTRYPOINT ["/server"]
