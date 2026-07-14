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

case "$(uname -m)" in
    x86_64 | amd64)
        architecture="amd64"
        ;;
    arm64 | aarch64)
        architecture="arm64"
        ;;
    *)
        die "Unsupported architecture: $(uname -m)"
        ;;
esac

if ! command -v docker >/dev/null 2>&1; then
    die "Docker is not installed or is not on PATH."
fi

if ! docker buildx version >/dev/null 2>&1; then
    die "The Docker Buildx plugin is not available."
fi

destination="heartprime/$image:$tag"
platform="linux/$architecture"

if inspection="$(docker buildx imagetools inspect "$destination" 2>/dev/null)" &&
    grep -Eq "^[[:space:]]*Platform:[[:space:]]*$platform([[:space:]]|$)" \
        <<<"$inspection"; then
    printf '%s exists for %s.\n' "$destination" "$platform"
    exit 0
fi

printf '%s does not exist for %s.\n' "$destination" "$platform"
exit 1
