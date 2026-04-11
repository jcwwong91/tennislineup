# Build stage
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Download dependencies first (cache layer)
COPY go.mod go.sum* ./
RUN go mod download

# Copy source and build
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/server ./cmd/server

# Runtime stage
FROM scratch

COPY --from=builder /app/server /server

EXPOSE 8080

ENTRYPOINT ["/server"]
