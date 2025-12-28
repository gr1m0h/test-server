# test-server

## Usage

### local

Run test-server

```sh
go run app/main.go
```

#### Docker

Build Docker image

```sh
make docker-build
```

#### Docker Compose

Run test-server with PostgreSQL database and Adminer interface

```sh
make docker-run
```

This will start:
- test-server on http://localhost:9090
- Adminer (database management interface) on http://localhost:8080
- PostgreSQL database on port 5432

Stop the services:

```sh
make docker-stop
```

#### Kubernetes

Prepare Docker Image.

```sh
make docker-build
```

Create K8s Cluster using [kind](https://github.com/kubernetes-sigs/kind) and load local Docker Image.

```sh
kind create cluster
kubectl cluster-info --context kind-kind
kind load docker-image test-server
```

##### Kubernetes Manifest(Raw)

Apply K8s manifest and connect to K8s service.

```sh
kubectl apply -f kubernetes/raw
kubectl port-forward service/test-server 8080:8080 -n test-server
```

##### Kubernetes Manifest(HelmChart)

##### Kubernetes Manifest(Helmfile)

## API Endpoints

### Get Articles List

```sh
curl -X GET "http://localhost:9090/articles?num=10&cursor="
```

### Get Article by ID

```sh
curl -X GET "http://localhost:9090/articles/1"
```

### Create Article

```sh
curl -X POST "http://localhost:9090/articles" \
  -H "Content-Type: application/json" \
  -d '{"title": "Title", "content": "Content", "author": {"id": 1}}'
```

> **Note**: `author.id` is required. Please use the sample author (id=1) created by `init.sql`.

### Delete Article

```sh
curl -X DELETE "http://localhost:9090/articles/1"
```
