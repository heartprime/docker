# HeartPrime Docker Images

HeartPrime Docker images are published to the
[HeartPrime account on Docker Hub](https://hub.docker.com/u/heartprime).

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
./scripts/get.sh <image> <tag> [--rebuild]
```

For example:

```bash
./scripts/get.sh cuda v1
```

Add `--rebuild` to rebuild and publish the image even if it already exists.

The script pulls an existing image or builds and publishes a missing image,
depending on its availability and your Docker Hub access. After it finishes,
`heartprime/<image>:<tag>` is available locally for the host architecture.

## Script Behavior

| Condition | Result | Push access required? |
| --- | --- | --- |
| Image is published | Pulls the image | No |
| Image is unpublished | Builds and publishes the image | Yes |
| Rebuild requested | Rebuilds and publishes the image | Yes |

Images are pulled or built for the Docker engine's native Linux platform.

## Log In for Push Access

Publishing an image requires push access to the corresponding
HeartPrime repository. Log in with an authorized Docker Hub account:

```bash
docker login --username <docker-hub-username>
```

When prompted for a password, enter a Docker Hub personal access token. Do not
include the token directly in the command.
