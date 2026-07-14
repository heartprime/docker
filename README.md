# HeartPrime Docker Images

HeartPrime Docker images are published to the
[HeartPrime organization on Docker Hub](https://hub.docker.com/u/heartprime).

## Available images

| Image | Tag | Repository |
| --- | --- | --- |
| `cuda` | `v1` | `heartprime/cuda:v1` |

## Requirements

- A running Docker engine
- The Docker Buildx plugin
- `curl` and `jq` (required only when publishing an image)

## Get an Image

From the `docker` directory, run:

```bash
./scripts/get.sh <image> <tag>
```

For example:

```bash
./scripts/get.sh cuda v1
```

The script pulls an existing image or builds and publishes a missing image,
depending on its availability and your Docker Hub access. After it finishes,
`heartprime/<image>:<tag>` is available locally for the host architecture.

## Script Behavior

| Image state | Command | Result | Push access required? |
| --- | --- | --- | --- |
| Published | `./scripts/get.sh <image> <tag>` | Pulls the image | No |
| Unpublished | `./scripts/get.sh <image> <tag>` | Builds, loads, and publishes the image | Yes |
| Any | `./scripts/get.sh <image> <tag> --overwrite` | Rebuilds, loads, and publishes the image | Yes |

Images are built for the Docker engine's native Linux platform. After a
successful build and push, the script removes its temporary Buildx builder and
build cache. If a build or push fails, it retains both for the next attempt.

## Publish to Docker Hub

Publishing or replacing an image requires push access to the corresponding
HeartPrime repository. Log in with an authorized Docker Hub account:

```bash
docker login --username <docker-hub-username>
```

When prompted for a password, enter a Docker Hub personal access token. Do not
include the token directly in the command.
