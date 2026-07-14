# HeartPrime Docker images

HeartPrime images are published on [Docker Hub](https://hub.docker.com/u/heartprime).

## Available images

| Image | Tag | Docker image |
| --- | --- | --- |
| `cuda` | `v1` | `heartprime/cuda:v1` |

## Get an image

From the `docker` directory, run:

```bash
./scripts/get.sh <image> <tag>
```

For example:

```bash
./scripts/get.sh cuda v1
```

If the image is published, the script pulls it from Docker Hub. After the
script succeeds, `heartprime/<image>:<tag>` is available locally.

## Build or replace an image

Building and publishing is intended for maintainers with push access to the
HeartPrime Docker Hub repository. The script chooses an action based on the
image's current state:

| Image state | Command | Action |
| --- | --- | --- |
| Published | `./scripts/get.sh <image> <tag>` | Pull the image. |
| Not published | `./scripts/get.sh <image> <tag>` | Build it, load it locally, and publish it. |
| Published or unpublished | `./scripts/get.sh <image> <tag> --overwrite` | Build it, load it locally, and publish or replace it. |

The build uses the Docker engine's native platform. Building an unpublished
image and using `--overwrite` both require Docker Hub push access.

### Log in to Docker Hub

Use an account with push access to the HeartPrime repository:

```bash
docker login --username <docker-hub-username>
```

When prompted for a password, use a Docker Hub personal access token. Do not
put the token directly in the command.
