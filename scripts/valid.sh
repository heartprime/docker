#!/usr/bin/env bash

# Check whether an image and tag have a Dockerfile in this repository.
#
# Usage: ./valid.sh <image> <tag>
# Example: ./valid.sh cuda v1
#
# Exits with 0 when the Dockerfile exists, 1 when it does not, and 2 when the
# arguments are invalid.

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
repo_dir="$(cd "$script_dir/.." && pwd)"
dockerfile="$repo_dir/images/$image/$tag.Dockerfile"

if [[ -f "$dockerfile" ]]; then
    printf '%s:%s is valid.\n' "$image" "$tag"
    exit 0
fi

printf '%s:%s is not valid: Dockerfile not found.\n' "$image" "$tag" >&2
exit 1
