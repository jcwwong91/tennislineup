APP       := tennislineup
CMD       := ./cmd/server
BIN       := bin/$(APP)

IMAGE     := $(APP)
TAG       ?= latest

LDFLAGS   := -ldflags="-s -w"

.PHONY: all build run clean fmt vet test \
        docker-build docker-run docker-stop docker-clean

all: fmt vet build

## ── Local ──────────────────────────────────────────────────────────────────

build:
	go build $(LDFLAGS) -o $(BIN) $(CMD)

run:
	go run $(CMD)

fmt:
	go fmt ./...

vet:
	go vet ./...

test:
	go test ./... -race -cover

clean:
	rm -rf bin/

## ── Docker ─────────────────────────────────────────────────────────────────

docker-build:
	docker build -t $(IMAGE):$(TAG) .

docker-run:
	docker run --rm -p 8080:8080 --name $(APP) $(IMAGE):$(TAG)

docker-stop:
	docker stop $(APP)

docker-clean:
	docker rmi $(IMAGE):$(TAG)
