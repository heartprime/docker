# HeartPrime Docker images

This repository contains the Dockerfiles used to build images published to the
[`heartprime`](https://hub.docker.com/u/heartprime) Docker Hub namespace.

## Prerequisites

Before building an image, make sure:

- Docker is installed and the Docker engine is running.
- The Docker Buildx plugin is available. Check by running
  `docker buildx version`.
- Your Docker Hub account has permission to push to the `heartprime`
  namespace.

## Log in to Docker Hub

Log in with a Docker Hub account that has access to the `heartprime` namespace:

```bash
docker login --username <docker-hub-username>
```

When prompted for a password, use a Docker Hub personal access token. Do not
put a password or token directly on the command line.

## Build or retrieve an image

Change to the root of this repository before running the create script:

```bash
cd /path/to/docker
./scripts/create.sh <image> <tag> [--overwrite]
```

The script first checks whether the image and tag exist on Docker Hub for the
host architecture. Its behavior is:

- If the image exists, the script builds it for the Docker engine's native
  platform and pushes it to Docker Hub.
- If the image does not exist and `--overwrite` is specified, the script builds
  and pushes the image.
- If the image does not exist and `--overwrite` is omitted, the script pulls
  the image from Docker Hub.

To use the default behavior:

```bash
./scripts/create.sh cuda v1
```

To build and push when the host-architecture image does not exist:

```bash
./scripts/create.sh cuda v1 --overwrite
```

When building, these examples use `dockerfiles/cuda/v1.Dockerfile` and push the
resulting image as `heartprime/cuda:v1`.

## Repository layout

The build script and Dockerfiles are organized as follows:

```text
scripts/create.sh
dockerfiles/<image>/<tag>.Dockerfile
```

The currently available image and tag are:

| Image | Tag |
| --- | --- |
| `cuda` | `v1` |
