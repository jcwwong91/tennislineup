# Tennis Lineup

A Go HTTP server for managing tennis lineups.

## Requirements

- [Go 1.21+](https://golang.org/dl/)
- [Docker](https://docs.docker.com/get-docker/) (optional)
- [Make](https://www.gnu.org/software/make/)

## Project Structure

```
tennislineup/
├── cmd/
│   └── server/
│       └── main.go          # Entry point — signal handling, graceful shutdown
├── internal/
│   └── server/
│       └── server.go        # HTTP mux and route handlers
├── bin/                     # Compiled binaries (git-ignored)
├── terraform/               # AWS infrastructure
├── Dockerfile
├── Makefile
└── go.mod
```

## Getting Started

### Run locally

```bash
make run
```

### Build and run the binary

```bash
make build
./bin/tennislineup
```

### Run with a custom port

```bash
PORT=9090 make run
```

## API

| Method | Path      | Description        |
|--------|-----------|--------------------|
| GET    | `/`       | Hello World        |
| GET    | `/health` | Health check       |

```bash
curl http://localhost:8080/
# Hello, World!

curl http://localhost:8080/health
# {"status":"ok"}
```

## Docker

### Build the image

```bash
make docker-build
```

### Run the container

```bash
make docker-run
```

### Build with a specific tag

```bash
make docker-build TAG=v1.0.0
make docker-run TAG=v1.0.0
```

### Stop and clean up

```bash
make docker-stop
make docker-clean
```

## Makefile Reference

| Target          | Description                              |
|-----------------|------------------------------------------|
| `make`          | fmt + vet + build                        |
| `make build`    | Compile binary to `bin/tennislineup`     |
| `make run`      | Run via `go run` (no compile step)       |
| `make fmt`      | Format all Go source files               |
| `make vet`      | Run static analysis                      |
| `make test`     | Run tests with race detector + coverage  |
| `make clean`    | Remove `bin/`                            |
| `make docker-build` | Build Docker image                   |
| `make docker-run`   | Run container on port 8080           |
| `make docker-stop`  | Stop the running container           |
| `make docker-clean` | Remove the Docker image              |

## License

MIT
