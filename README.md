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

## Infrastructure (AWS / k3s)

The app runs on a single-node k3s cluster in a private AWS subnet. Access is via EC2 Instance Connect (EIC) — no bastion, no public SSH exposure.

### SSH into the k3s instance

```bash
aws ec2-instance-connect ssh \
  --instance-id <instance-id> \
  --connection-type eice \
  --os-user ubuntu \
  --profile tennis \
  --region us-east-1
```

### kubectl via SSH tunnel

Since the k3s API server is in a private subnet, kubectl traffic is forwarded over an SSH tunnel through EIC.

**Step 1 — open the tunnel** (leave this running in a dedicated terminal):

```bash
ssh -i ~/.ssh/tennislineup \
  -L 6443:localhost:6443 \
  -o "ProxyCommand=aws ec2-instance-connect open-tunnel --instance-id <instance-id> --remote-port 22 --profile tennis --region us-east-1" \
  ubuntu@<instance-id>
```

**Step 2 — copy the kubeconfig** (first time only):

```bash
scp -i ~/.ssh/tennislineup \
  -o "ProxyCommand=aws ec2-instance-connect open-tunnel --instance-id <instance-id> --remote-port 22 --profile tennis --region us-east-1" \
  ubuntu@<instance-id>:~/.kube/config \
  ~/.kube/config
```

**Step 3 — use kubectl normally** in any other terminal:

```bash
kubectl get nodes
```

> Note: kubectl is slow over EIC as it routes through AWS's management plane. This is expected.

### Provisioning

```bash
# Shared networking, NAT, EIC endpoint
cd terraform/shared && terraform apply

# k3s instance
cd terraform/environments/k3s && terraform apply
```

## License

MIT
