#!/usr/bin/env bash

# Build or retrieve a HeartPrime image for the host architecture.
#
# Usage:
#   ./get.sh <image> <tag>
#   ./get.sh <image> <tag> --rebuild
#
# If the tagged image exists, it is pulled unless --rebuild is specified. A
# build is performed and pushed only when Docker Hub push access is available.

set -euo pipefail

usage() {
    printf 'Usage: %s <image> <tag> [--rebuild]\n' "${0##*/}" >&2
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
rebuild=false

if [[ $# -eq 3 ]]; then
    if [[ "$3" != "--rebuild" ]]; then
        die "Unknown option: $3" 2
    fi
    rebuild=true
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd "$script_dir/.." && pwd)"
valid_script="$script_dir/valid.sh"
exists_script="$script_dir/exists.sh"
access_script="$script_dir/access.sh"
dockerfile="$repo_dir/dockerfiles/$image/$tag.Dockerfile"
destination="heartprime/$image:$tag"
builder_name=""
builder_available=false
build_succeeded=false

cleanup() {
    local exit_status=$?

    trap - EXIT INT TERM

    if [[ "$builder_available" == true && "$build_succeeded" == true ]]; then
        printf 'Removing builder and build cache after successful build...\n'
        if ! docker buildx rm --force "$builder_name" >/dev/null 2>&1; then
            printf 'Warning: failed to remove builder %s.\n' \
                "$builder_name" >&2
        fi
    elif [[ "$builder_available" == true ]]; then
        printf 'Retaining builder %s and its cache for the next attempt.\n' \
            "$builder_name"
    fi

    exit "$exit_status"
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

if [[ ! -x "$valid_script" ]]; then
    die "Image validation check is not executable: $valid_script"
fi

"$valid_script" "$image" "$tag"

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

if [[ "$image_exists" == true && "$rebuild" == false ]]; then
    printf 'Pulling %s from Docker Hub...\n' "$destination"
    docker pull "$destination"
    exit 0
fi

if [[ ! -x "$access_script" ]]; then
    die "Docker Hub access check is not executable: $access_script"
fi

if "$access_script" "$image"; then
    :
else
    access_status=$?
    if [[ $access_status -eq 1 ]]; then
        if [[ "$rebuild" == true ]]; then
            die "Cannot rebuild $destination without Docker Hub push access. Log in with an authorized account and try again."
        fi
        die "$destination is not published and cannot be built without Docker Hub push access. Log in with an authorized account and try again."
    fi
    die "Unable to check Docker Hub push access for heartprime/$image." "$access_status"
fi

if [[ ! -f "$dockerfile" ]]; then
    die "Dockerfile not found: $dockerfile"
fi

if ! native_platform="$(
    docker version --format '{{.Server.Os}}/{{.Server.Arch}}'
)" || [[ -z "$native_platform" || "$native_platform" == "/" ]]; then
    die "Unable to determine the Docker engine's native platform."
fi

builder_name="heartprime-build-${image}-${tag}-${native_platform//\//-}"

if docker buildx inspect "$builder_name" >/dev/null 2>&1; then
    printf 'Reusing builder %s and its cached layers.\n' "$builder_name"
else
    docker buildx create \
        --name "$builder_name" \
        --driver docker-container \
        --platform "$native_platform" \
        >/dev/null
fi
builder_available=true

printf 'Building %s for native platform %s and loading it locally...\n' \
    "$destination" "$native_platform"
docker buildx build \
    --builder "$builder_name" \
    --platform "$native_platform" \
    --file "$dockerfile" \
    --tag "$destination" \
    --load \
    "$repo_dir"

printf 'Pushing %s to Docker Hub...\n' "$destination"
docker push "$destination"
build_succeeded=true
