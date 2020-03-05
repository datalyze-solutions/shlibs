#!/usr/bin/env bash

add_user() {
    local uid="${1:-1000}"
    local gid="${2:-1000}"
    local username="${3:-horst}"
    local shell="${4:-/bin/sh}"

    log_info "creating new user: $uid $gid $username $shell"

    if [[ $(getent passwd "${uid}") ]]; then
        log_warn "User '${uid}' still exists as '$(getent passwd "${uid}")'"
        return
    fi
    if [ $(getent group "${gid}") ]; then
        log_warn "Group '${gid}' still exists"
        return
    fi

    addgroup --gid "${gid}" "${username}"
    if [ -z "${shell}" ]; then
        adduser --uid "${uid}" --disabled-password --ingroup "${gid}" "${username}"
    else
        adduser --uid "${uid}" --disabled-password --ingroup "${gid}" "${username}" --shell "${shell}"
    fi
}
