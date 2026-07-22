# HeartPrime Docker Images

HeartPrime Docker images are published to the
[HeartPrime account on Docker Hub](https://hub.docker.com/u/heartprime).

## Available images

| Image | Tag | Repository |
| --- | --- | --- |
| `v1` | `cpu` | `heartprime/v1:cpu` |
| `v1` | `cuda` | `heartprime/v1:cuda` |

## Requirements

- A running Docker engine
- The Docker Buildx plugin
- `curl` and `jq` (required only when publishing an image)

Installation guides:

- [Ubuntu](docs/ubuntu.md)
- [macOS](docs/macos.md)
- [Windows](docs/windows.md)

## Instantiate an Image

From the `docker` directory, run:

```bash
./image.sh <image> <tag> [--rebuild]
```

For example:

```bash
./image.sh v1 cuda
```

Add `--rebuild` to rebuild and publish the image even if it already exists.

The script pulls an existing image or builds and publishes a missing image,
depending on its availability and your Docker Hub access. Published images
contain both `linux/amd64` and `linux/arm64` under the same tag. After the
script finishes, `heartprime/<image>:<tag>` is available locally for the host
architecture.

## Script Behavior

| Condition | Result | Push access required? |
| --- | --- | --- |
| Image is published | Pulls the image | No |
| Image is unpublished | Builds and publishes the image | Yes |
| Rebuild requested | Rebuilds and publishes the image | Yes |

Existing images are pulled for the Docker engine's native Linux platform. New
and rebuilt images are built and published for both `linux/amd64` and
`linux/arm64`, then the native platform is pulled locally.

## Log In for Push Access

Publishing an image requires push access to the corresponding
HeartPrime repository. Log in with an authorized Docker Hub account:

```bash
docker login --username <docker-hub-username>
```

When prompted for a password, enter a Docker Hub personal access token. Do not
include the token directly in the command.
