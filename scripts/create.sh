#!/usr/bin/env bash

# Build or retrieve a HeartPrime image for the host architecture.
#
# Usage:
#   ./create.sh <image> <tag>
#   ./create.sh <image> <tag> --overwrite
#
# If the tagged image exists, it is built and pushed. If it does not exist,
# --overwrite builds and pushes it; without --overwrite, it is pulled from the
# registry instead.

set -euo pipefail

usage() {
    printf 'Usage: %s <image> <tag> [--overwrite]\n' "${0##*/}" >&2
}

die() {
    printf 'Error: %s\n' "$1" >&2
    exit "${2:-1}"
}

if [[ $# -lt 2 || $# -gt 3 ]]; then
    usage
    exit 2
fi

image="$1"
tag="$2"
overwrite=false

if [[ $# -eq 3 ]]; then
    if [[ "$3" != "--overwrite" ]]; then
        die "Unknown option: $3" 2
    fi
    overwrite=true
fi

if [[ ! "$image" =~ ^[a-z0-9]+([._-][a-z0-9]+)*$ ]]; then
    die "Invalid image name: $image" 2
fi

if (( ${#tag} > 128 )) || [[ ! "$tag" =~ ^[A-Za-z0-9_][A-Za-z0-9._-]*$ ]]; then
    die "Invalid tag: $tag" 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd "$script_dir/.." && pwd)"
exists_script="$script_dir/exists.sh"
dockerfile="$repo_dir/dockerfiles/$image/$tag.Dockerfile"
destination="heartprime/$image:$tag"
builder_name="heartprime-build-$$-$RANDOM"
builder_created=false

cleanup() {
    local exit_status=$?

    trap - EXIT INT TERM

    if [[ "$builder_created" == true ]]; then
        printf 'Removing temporary builder and build cache...\n'
        if ! docker buildx rm --force "$builder_name" >/dev/null 2>&1; then
            printf 'Warning: failed to remove temporary builder %s.\n' \
                "$builder_name" >&2
        fi
    fi

    exit "$exit_status"
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

if [[ ! -x "$exists_script" ]]; then
    die "Image existence check is not executable: $exists_script"
fi

if "$exists_script" "$image" "$tag"; then
    image_exists=true
else
    exists_status=$?
    if [[ $exists_status -ne 1 ]]; then
        die "Unable to check whether $destination exists." "$exists_status"
    fi
    image_exists=false
fi

if [[ "$image_exists" == false && "$overwrite" == false ]]; then
    printf 'Pulling %s from Docker Hub...\n' "$destination"
    docker pull "$destination"
    exit 0
fi

if [[ ! -f "$dockerfile" ]]; then
    die "Dockerfile not found: $dockerfile"
fi

if ! native_platform="$(
    docker version --format '{{.Server.Os}}/{{.Server.Arch}}'
)" || [[ -z "$native_platform" || "$native_platform" == "/" ]]; then
    die "Unable to determine the Docker engine's native platform."
fi

docker buildx create \
    --name "$builder_name" \
    --driver docker-container \
    --platform "$native_platform" \
    >/dev/null
builder_created=true

printf 'Building %s for native platform %s and pushing it to Docker Hub...\n' \
    "$destination" "$native_platform"
docker buildx build \
    --builder "$builder_name" \
    --platform "$native_platform" \
    --file "$dockerfile" \
    --tag "$destination" \
    --push \
    "$repo_dir"
