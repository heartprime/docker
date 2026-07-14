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

## Build and push an image

Change to the root of this repository before running the build script:

```bash
cd /path/to/docker
./build-and-push.sh <image> <tag>
```

For example:

```bash
./build-and-push.sh cudalab v1
```

The script builds the image for the Docker engine's native platform and pushes
it to Docker Hub. In the example above, it uses `cudalab/v1.Dockerfile` and
pushes the resulting image as `heartprime/cudalab:v1`.

## Repository layout

Dockerfiles are organized by image and tag:

```text
<image>/<tag>.Dockerfile
```

The currently available image and tag are:

| Image | Tag |
| --- | --- |
| `cudalab` | `v1` |
