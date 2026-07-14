# HeartPrime Docker images

This repository provides HeartPrime images published in the
[`heartprime`](https://hub.docker.com/u/heartprime) Docker Hub namespace.

## Available images and tags

| Image | Tag | Full name |
| --- | --- | --- |
| `cuda` | `v1` | `heartprime/cuda:v1` |

## Usage

### Prerequisites

Before getting an image, make sure:

- Docker is installed and the Docker engine is running.
- The Docker Buildx plugin is available. Check with `docker buildx version`.
- Your Docker Hub account has permission to push to the `heartprime` namespace
  if the image needs to be built and published.

### Log in to Docker Hub

Log in with a Docker Hub account that has access to the `heartprime` namespace:

```bash
docker login --username <docker-hub-username>
```

When prompted for a password, use a Docker Hub personal access token. Do not
put a password or token directly on the command line.

### Get an image

From the `docker` directory, run:

```bash
./scripts/get.sh <image> <tag>
```

When the command finishes, `heartprime/<image>:<tag>` is available in your
local Docker image store. If the image was not already published, it is also
created and published to Docker Hub.

To recreate an existing image and publish the replacement, add `--overwrite`:

```bash
./scripts/get.sh <image> <tag> --overwrite
```
