#!/usr/bin/env bash

set -euo pipefail

usage() {
    printf 'Usage: %s <image> <tag>\n' "${0##*/}" >&2
}

die() {
    printf 'Error: %s\n' "$1" >&2
    exit "${2:-1}"
}

if [[ $# -ne 2 ]]; then
    usage
    exit 2
fi

image="$1"
tag="$2"

if [[ ! "$image" =~ ^[a-z0-9]+([._-][a-z0-9]+)*$ ]]; then
    die "Invalid image name: $image" 2
fi

if (( ${#tag} > 128 )) || [[ ! "$tag" =~ ^[A-Za-z0-9_][A-Za-z0-9._-]*$ ]]; then
    die "Invalid tag: $tag" 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dockerfile="$script_dir/$image/$tag.Dockerfile"
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

if [[ ! -f "$dockerfile" ]]; then
    die "Dockerfile not found: $dockerfile"
fi

if ! command -v docker >/dev/null 2>&1; then
    die "Docker is not installed or is not on PATH."
fi

if ! docker buildx version >/dev/null 2>&1; then
    die "The Docker Buildx plugin is not available."
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
    "$script_dir"
