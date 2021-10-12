#!/usr/bin/env bash

shlibs.chown_directories() {
    # use the given array through a reference
    declare -n directories_ref="$1"
    local owner="${2}"

    for dir in "${directories_ref[@]}"; do
        chown ${owner} -R "${dir}"
    done
    unset -n directories_ref
}

shlibs.chmod_directories() {
    # use the given array through a reference
    declare -n directories_ref="$1"
    local permissions="${2}"

    for dir in "${directories_ref[@]}"; do
        chmod ${permissions} -R "${dir}"
    done
    unset -n directories_ref
}

chown_directories() {
    shlibs.chmod_directories "$@"
}

chmod_directories() {
    shlibs.chmod_directories "$@"
}