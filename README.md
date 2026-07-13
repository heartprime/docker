# HeartPrime Docker images

This repository contains Dockerfiles for images published to the
[`heartprime`](https://hub.docker.com/u/heartprime) Docker Hub namespace.

Dockerfiles follow this layout:

```text
<image>/<tag>.Dockerfile
```

The currently available image and tag are:

| Image | Tag |
| --- | --- |
| `cudalab` | `v1` |

## Log in to Docker Hub

You need permission to push images to the `heartprime` namespace. Log in using
the `heartprime` account (or a Docker Hub account with access to the namespace):

```bash
docker login --username heartprime
```

When prompted for a password, use a Docker Hub personal access token rather
than putting a password or token directly on the command line.

## Build and push an image

Docker with the Buildx plugin is required. Run the script from anywhere and
provide the image and tag:

```bash
./build-and-push.sh <image> <tag>
```

For example:

```bash
./build-and-push.sh cudalab v1
```

This builds `cudalab/v1.Dockerfile` and pushes it to
`heartprime/cudalab:v1`.