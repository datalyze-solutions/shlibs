#!/usr/bin/env bash

shlibs.user.groupname_from_gid() {
    local gid="${1}"
    getent group "${gid}" | cut -d : -f 1
}

shlibs.user.username_from_uid() {
    local HOST_UID="${1:-0}"
    getent passwd $HOST_UID | cut -d : -f 1
}

shlibs.user.add() {
    local uid="${1:-1000}"
    local gid="${2:-1000}"
    local username="${3:-horst}"
    local shell="${4:-/bin/sh}"

    distribution_id=$(shlibs.os.distribution_id)

    log_info "creating new user: $uid $gid $username $shell"

    if [[ $(getent passwd "${uid}") ]]; then
        log_warn "User '${uid}' still exists as '$(getent passwd "${uid}")'"
        return
    fi
    if [ $(getent group "${gid}") ]; then
        log_warn "Group '${gid}' still exists"
        return
    fi

    case "$(shlibs.os.type.base)" in
    linux)
        shlibs.user.add.linux $uid $gid $username $shell
        ;;
    *)
        log_error "Unknown os detected."
        ;;
    esac
}

shlibs.user.add.linux() {
    local uid="${1:-1000}"
    local gid="${2:-1000}"
    local username="${3:-horst}"
    local shell="${4:-/bin/sh}"

    addgroup --gid "${gid}" "${username}"
    groupname=$(shlibs.user.groupname_from_gid "${gid}")

    if [ -z "${shell}" ]; then
        adduser --uid "${uid}" --disabled-password --ingroup "${groupname}" --gecos "" "${username}"
    else
        adduser --uid "${uid}" --disabled-password --ingroup "${groupname}" --gecos "" "${username}" --shell "${shell}"
    fi
}

# old versions
add_user() {
    shlibs.user.add "$@"
}

get_username_from_uid() {
    shlibs.user.username_from_uid "$@"
}

get_groupname() {
    shlibs.user.groupname_from_gid "$@"
}
