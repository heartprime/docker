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

die() {
    printf 'Error: %s\n' "$1" >&2
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
    die "Invalid image name: $image" 2
fi

for command in curl jq; do
    command -v "$command" >/dev/null 2>&1 || \
        die "$command is required to check Docker Hub access." 3
done

if [[ ! -r "$docker_config" ]]; then
    die "Docker Hub credentials are not configured; run docker login."
fi

if ! credential_source="$(
    jq -r --arg registry "$registry" \
        '
            [
                [$registry, .credHelpers[$registry]],
                ["registry-1.docker.io", .credHelpers["registry-1.docker.io"]],
                ["docker.io", .credHelpers["docker.io"]],
                [$registry, .credsStore]
            ]
            | map(select(.[1] | type == "string" and length > 0))
            | first // empty
            | @tsv
        ' \
        "$docker_config"
)"; then
    die "Unable to read Docker configuration: $docker_config" 3
fi

if [[ -n "$credential_source" ]]; then
    IFS=$'\t' read -r credential_server helper <<<"$credential_source"
    credential_helper="docker-credential-$helper"
    command -v "$credential_helper" >/dev/null 2>&1 || \
        die "Docker credential helper $credential_helper was not found." 3

    if ! credentials="$(printf '%s' "$credential_server" | "$credential_helper" get 2>/dev/null)"; then
        die "Docker Hub credentials are not configured; run docker login."
    fi
    if ! username="$(jq -r '.Username // empty' <<<"$credentials")" ||
        ! secret="$(jq -r '.Secret // empty' <<<"$credentials")"; then
        die "Docker credential helper returned invalid credentials." 3
    fi
else
    if ! encoded="$(
        jq -r --arg registry "$registry" '
            .auths[$registry].auth
            // .auths["registry-1.docker.io"].auth
            // .auths["docker.io"].auth
            // empty
        ' "$docker_config"
    )"; then
        die "Unable to read Docker configuration: $docker_config" 3
    fi
    [[ -n "$encoded" ]] || \
        die "Docker Hub credentials are not configured; run docker login."
    if ! decoded="$(jq -Rr '@base64d' <<<"$encoded")"; then
        die "Invalid Docker Hub credentials in $docker_config." 3
    fi
    [[ "$decoded" == *:* ]] || \
        die "Invalid Docker Hub credentials in $docker_config." 3
    username="${decoded%%:*}"
    secret="${decoded#*:}"
fi

if [[ -z "$username" || -z "$secret" ]]; then
    die "Docker Hub credentials are not configured; run docker login."
fi

if [[ "$username" == *$'\n'* || "$username" == *$'\r'* ||
    "$secret" == *$'\n'* || "$secret" == *$'\r'* ]]; then
    die "Docker Hub credentials contain unsupported line breaks." 3
fi

curl_credentials="$username:$secret"
curl_credentials="${curl_credentials//\\/\\\\}"
curl_credentials="${curl_credentials//\"/\\\"}"

if ! result="$(
    printf 'user = "%s"\n' "$curl_credentials" |
        curl --config - \
            --silent \
            --show-error \
            --get \
            --data-urlencode 'service=registry.docker.io' \
            --data-urlencode "scope=repository:$repository:pull,push" \
            --write-out $'\n%{http_code}' \
            'https://auth.docker.io/token'
)"; then
    die "Unable to contact Docker Hub." 3
fi

http_status="${result##*$'\n'}"
response="${result%$'\n'*}"

if [[ "$http_status" == 401 || "$http_status" == 403 ]]; then
    die "Docker Hub credentials are invalid or do not grant access."
elif [[ "$http_status" != 200 ]]; then
    die "Docker Hub access check returned HTTP $http_status." 3
fi

if ! token="$(jq -r '.token // .access_token // empty' <<<"$response")" ||
    [[ -z "$token" || "$token" != *.*.* ]]; then
    die "Docker Hub returned an invalid access token." 3
fi

payload="${token#*.}"
payload="${payload%%.*}"
payload="${payload//-/+}"
payload="${payload//_/\/}"
while (( ${#payload} % 4 != 0 )); do
    payload+="="
done

if ! claims="$(jq -Rr '@base64d' <<<"$payload")" ||
    ! jq -e 'type == "object"' >/dev/null <<<"$claims"; then
    die "Unable to inspect the Docker Hub access token." 3
fi

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

die "Docker Hub push access is not available for $repository."
