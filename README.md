# HeartPrime Docker images

This directory contains the Dockerfiles and scripts used to retrieve or build
images published in the [`heartprime`](https://hub.docker.com/u/heartprime)
Docker Hub namespace.

## Available images and tags

| Image | Tag | DockerHub |
| --- | --- | --- |
| `cuda` | `v1` | `heartprime/cuda:v1` |

## Usage

### Prerequisites

Before creating an image, make sure:

- Docker is installed and the Docker engine is running.
- The Docker Buildx plugin is available. Check with `docker buildx version`.
- Your Docker Hub account has permission to push to the `heartprime` namespace
  if the image needs to be built and published.

### Login to Docker Hub

Log in with a Docker Hub account that has access to the `heartprime` namespace:

```bash
docker login --username <docker-hub-username>
```

When prompted for a password, use a Docker Hub personal access token. Do not
put a password or token directly on the command line.

### Create docker image

From this `docker` directory, create or retrieve an image with:

```bash
./scripts/create.sh <image> <tag>
```

The script checks for `heartprime/<image>:<tag>` on Docker Hub for the host
architecture. If it exists, the script pulls the image from Docker Hub. If it
does not exist, the script builds `dockerfiles/<image>/<tag>.Dockerfile` for the
Docker engine's native platform and pushes the image.

To build and push the image even when it already exists, add `--overwrite`:

```bash
./scripts/create.sh <image> <tag> --overwrite
```
