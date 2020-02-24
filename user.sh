#!/bin/sh

add_user() {
    local uid="${1:-1000}"
    local user="${2:-horst}"

    addgroup --gid "${uid}" "${usr}"
    adduser --uid "${uid}" --disabled-password --ingroup "${user}" "${user}"
}