# HeartPrime Docker images

This repository provides HeartPrime images published [`heartprime`](https://hub.docker.com/u/heartprime) Docker Hub account.

## Available images and tags

| Image | Tag | Full name |
| --- | --- | --- |
| `cuda` | `v1` | `heartprime/cuda:v1` |

## Usage

### Prerequisites

Before getting an image, make sure:

- Docker is installed and the Docker engine is running.
- The Docker Buildx plugin is available. Check with `docker buildx version`.
- If you need to build and publish an image that is not already on Docker Hub,
  `curl`, `jq`, and a Docker Hub account with push permission for the relevant
  repository owned by the `heartprime` account.

### Log in to Docker Hub (optional)

You do not need to log in to pull an image that is already published. Log in
only when building and publishing an image that does not exist on Docker Hub,
or when replacing an existing image with `--overwrite`. Use an account that
has push access to the required repository in the `heartprime` account:

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
local Docker image store. Existing images are pulled without requiring Docker
Hub credentials. If the image is not already published, the command verifies
push access to `heartprime/<image>` before building it and publishing it.

To recreate an existing image and publish the replacement, log in to Docker
Hub as described above and add `--overwrite`:

```bash
./scripts/get.sh <image> <tag> --overwrite
```
