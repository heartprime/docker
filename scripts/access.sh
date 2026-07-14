#!/usr/bin/env bash

# Check whether the current Docker Hub credentials can push to a HeartPrime
# image repository.
#
# Usage: ./access.sh <image>
#
# Exits with 0 when push access is granted, 1 when credentials or push access
# are missing, 2 when the arguments are invalid, and 3 when the check fails.

set -euo pipefail

usage() {
    printf 'Usage: %s <image>\n' "${0##*/}" >&2
}

fail() {
    printf '%s\n' "$1" >&2
    exit "${2:-1}"
}

if [[ $# -ne 1 ]]; then
    usage
    exit 2
fi

image="$1"
repository="heartprime/$image"
registry="https://index.docker.io/v1/"
docker_config="${DOCKER_CONFIG:-$HOME/.docker}/config.json"

if [[ ! "$image" =~ ^[a-z0-9]+([._-][a-z0-9]+)*$ ]]; then
    fail "Error: Invalid image name: $image" 2
fi

for command in curl jq; do
    command -v "$command" >/dev/null 2>&1 || \
        fail "Error: $command is required to check Docker Hub access." 3
done

if [[ ! -r "$docker_config" ]]; then
    fail "Docker Hub credentials are not configured; run docker login."
fi

helper="$(
    jq -r --arg registry "$registry" \
        '
            .credHelpers[$registry]
            // .credHelpers["registry-1.docker.io"]
            // .credHelpers["docker.io"]
            // .credsStore
            // empty
        ' \
        "$docker_config"
)" || fail "Error: unable to read $docker_config." 3

if [[ -n "$helper" ]]; then
    credential_helper="docker-credential-$helper"
    command -v "$credential_helper" >/dev/null 2>&1 || \
        fail "Error: Docker credential helper $credential_helper was not found." 3

    if ! credentials="$(printf '%s' "$registry" | "$credential_helper" get 2>/dev/null)"; then
        fail "Docker Hub credentials are not configured; run docker login."
    fi
    username="$(jq -r '.Username // empty' <<<"$credentials")"
    secret="$(jq -r '.Secret // empty' <<<"$credentials")"
else
    encoded="$(
        jq -r --arg registry "$registry" '
            .auths[$registry].auth
            // .auths["registry-1.docker.io"].auth
            // .auths["docker.io"].auth
            // empty
        ' "$docker_config"
    )"
    [[ -n "$encoded" ]] || \
        fail "Docker Hub credentials are not configured; run docker login."
    decoded="$(jq -Rr '@base64d' <<<"$encoded")" || \
        fail "Error: invalid Docker Hub credentials in $docker_config." 3
    [[ "$decoded" == *:* ]] || \
        fail "Error: invalid Docker Hub credentials in $docker_config." 3
    username="${decoded%%:*}"
    secret="${decoded#*:}"
fi

if [[ -z "$username" || -z "$secret" ]]; then
    fail "Docker Hub credentials are not configured; run docker login."
fi

if ! result="$(
    printf 'user = "%s:%s"\n' "$username" "$secret" |
        curl --config - \
            --silent \
            --show-error \
            --get \
            --data-urlencode 'service=registry.docker.io' \
            --data-urlencode "scope=repository:$repository:pull,push" \
            --write-out $'\n%{http_code}' \
            'https://auth.docker.io/token'
)"; then
    fail "Error: unable to contact Docker Hub." 3
fi

http_status="${result##*$'\n'}"
response="${result%$'\n'*}"

if [[ "$http_status" == 401 || "$http_status" == 403 ]]; then
    fail "Docker Hub credentials are invalid or do not grant access."
elif [[ "$http_status" != 200 ]]; then
    fail "Error: Docker Hub access check returned HTTP $http_status." 3
fi

token="$(jq -r '.token // .access_token // empty' <<<"$response")" || \
    fail "Error: Docker Hub returned an invalid access token." 3
[[ -n "$token" ]] || fail "Error: Docker Hub returned an invalid access token." 3

payload="${token#*.}"
payload="${payload%%.*}"
payload="${payload//-/+}"
payload="${payload//_/\/}"
while (( ${#payload} % 4 != 0 )); do
    payload+="="
done

claims="$(jq -Rr '@base64d' <<<"$payload")" || \
    fail "Error: unable to inspect the Docker Hub access token." 3

if jq -e --arg repository "$repository" '
    .access[]?
    | select(
        .type == "repository"
        and .name == $repository
        and (.actions | index("push"))
    )
' >/dev/null <<<"$claims"; then
    printf 'Docker Hub push access is available for %s.\n' "$repository"
    exit 0
fi

fail "Docker Hub push access is not available for $repository."
