# HeartPrime Docker images

HeartPrime images are published on [Docker Hub](https://hub.docker.com/u/heartprime).

## Available images

| Image | Tag | Docker image |
| --- | --- | --- |
| `cuda` | `v1` | `heartprime/cuda:v1` |

## Log in to Docker Hub (optional)

Login is only required to publish a new image or replace an existing image with
`--overwrite`. Use an account with push access to the HeartPrime repository:

```bash
docker login --username <docker-hub-username>
```

Use a Docker Hub personal access token when prompted for a password. Do not put
the token directly in the command.

## Get an image

From the `docker` directory, run:

```bash
./scripts/get.sh <image> <tag>
```

To rebuild and replace an existing image, run:

```bash
./scripts/get.sh <image> <tag> --overwrite
```

The script:

- pulls the image from Docker Hub when it is already published; or
- builds the image, stores it locally, and publishes it when it does not exist.

With `--overwrite`, the script rebuilds the image and replaces the published
version.

After the script succeeds, `heartprime/<image>:<tag>` is available locally.
