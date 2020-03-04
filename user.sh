#!/usr/bin/env bash

add_user() {
    local uid="${1:-1000}"
    local gid="${2:-1000}"
    local username="${3:-horst}"
    local shell="${4:-/bin/sh}"

    log_info "creating new user: $uid $gid $username $shell"

    addgroup --gid "${gid}" "${username}"
    if [ -z "${shell}" ]; then
        adduser --uid "${uid}" --disabled-password --ingroup "${username}" "${username}"
    else
        adduser --uid "${uid}" --disabled-password --ingroup "${username}" "${username}" --shell "${shell}"
    fi
}
